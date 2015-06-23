class Entropy
  def Entropy.configure(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

    # Configure Local Variable To Access Scripts From Remote Location
    scriptDir = File.dirname(__FILE__)

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Configure The Box
    config.vm.box = settings["box"] ||= "ammonkc/entropy"
    config.vm.hostname = settings["hostname"] ||= "entropy"
    config.vm.box_version = settings["box_version"] ||= "~>2.0"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.20"

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.name = settings["name"] ||= 'entropy'
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", settings["ostype"] ||= "RedHat_64"]
    end

    # Configure A Few VMware Settings
    ["vmware_fusion", "vmware_workstation"].each do |vmware|
      config.vm.provider vmware do |v|
        v.vmx["displayName"] = "entropy"
        v.vmx["memsize"] = settings["memory"] ||= 2048
        v.vmx["numvcpus"] = settings["cpus"] ||= 1
        v.vmx["guestOS"] = settings["ostype"] ||= "RedHat_64"
      end
    end

    # Standardize Ports Naming Schema
    if (settings.has_key?("ports"))
      settings["ports"].each do |port|
        port["guest"] ||= port["to"]
        port["host"] ||= port["send"]
        port["protocol"] ||= "tcp"
      end
    else
      settings["ports"] = []
    end

    # Default Port Forwarding
    default_ports = {
      80   => 8000,
      443  => 44300,
      3306 => 33060,
      5432 => 54320
    }

    # Use Default Port Forwarding Unless Overridden
    default_ports.each do |guest, host|
      unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
        config.vm.network "forwarded_port", guest: guest, host: host
      end
    end

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"]
      end
    end

    # Configure The Public Key For SSH Access
    if settings.include? 'authorize'
      config.vm.provision "shell" do |s|
        s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
        s.args = [File.read(File.expand_path(settings["authorize"]))]
      end
    end

    # Copy The SSH Private Keys To The Box
    if settings.include? 'keys'
      settings["keys"].each do |key|
        config.vm.provision "shell" do |s|
          s.privileged = false
          s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
          s.args = [File.read(File.expand_path(key)), key.split('/').last]
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'folders'
      settings["folders"].each do |folder|
        mount_opts = folder["type"] == "nfs" ? ['actimeo=1','dmode=777','fmode=666'] : ['dmode=777','fmode=666']
        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, mount_options: mount_opts
      end
    end

    # Install All The Configured vhost Sites
    settings["sites"].each do |site|
      config.vm.provision "shell" do |s|
        if (settings.has_key?("box") && settings["box"] == "laravel/homestead")
          if (site.has_key?("hhvm") && site["hhvm"])
            s.path = scriptDir + "/serve-hhvm.sh"
            s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
          else
            s.path = scriptDir + "/serve.sh"
            s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
          end
        else
          if (site.has_key?("hhvm") && site["hhvm"])
            s.path = scriptDir + "/serve-hhvm.sh"
            s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
          else
            s.path = scriptDir + "/serve-httpd.sh"
            s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
          end
        end
      end
    end

    # clear existing hosts file if any
    config.vm.provision "shell" do |s|
      s.inline = "> $1"
      s.args = ["/etc/hosts.dnsmasq"]
    end

    # Add sites to hosts.dnsmasq
    settings["sites"].each do |site|
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/dnsmasq.sh $1 $2"
        s.args = [settings["ip"], site["map"]]
      end
    end

    # Configure All Of The Configured Databases
    if settings.has_key?("databases")
      settings["databases"].each do |database|
          config.vm.provision "shell" do |s|
              s.path = scriptDir + "/create-mysql.sh"
              if (database.has_key?("sql") && database["sql"])
                s.args = [database["db"], database["sql"]]
              else
                s.args = database["db"]
              end
          end

          config.vm.provision "shell" do |s|
              s.path = scriptDir + "/create-postgres.sh"
              if (database.has_key?("psql") && database["psql"])
                s.args = [database["db"], database["psql"]]
              else
                s.args = database["db"]
              end
          end
      end
    end

    # Configure All Of The Server Environment Variables
    if settings.has_key?("variables")
      settings["variables"].each do |var|
        config.vm.provision "shell" do |s|
          if (settings.has_key?("box") && settings["box"] == "laravel/homestead")
            s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php5/fpm/php-fpm.conf"
            s.args = [var["key"], var["value"]]
          else
            s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php-fpm.conf"
            s.args = [var["key"], var["value"]]
          end

          config.vm.provision "shell" do |s|
              s.inline = "echo \"\n#Set Entropy environment variable\nexport $1=$2\" >> /home/vagrant/.profile"
              s.args = [var["key"], var["value"]]
          end
        end
      end

      config.vm.provision "shell" do |s|
        if (settings.has_key?("box") && settings["box"] == "laravel/homestead")
          s.inline = "service php5-fpm restart"
        else
          s.inline = "service php-fpm restart"
        end
      end
    end

    # Update Composer On Every Provision
    config.vm.provision "shell" do |s|
      s.inline = "/usr/local/bin/composer self-update"
    end

    # Configure Blackfire.io
    if settings.has_key?("blackfire")
      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/blackfire.sh"
        s.args = [
          settings["blackfire"][0]["id"],
          settings["blackfire"][0]["token"],
          settings["blackfire"][0]["client-id"],
          settings["blackfire"][0]["client-token"]
        ]
      end
    end
  end
end
