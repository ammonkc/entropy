class Entropy
  def Entropy.configure(config, settings)
    # Configure The Box
    config.vm.box = settings["box"] ||= "ammonkc/entropy"
    config.vm.box_version = settings["box_version"] ||= "~>2.0"
    config.vm.hostname = "entropy"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.20"

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.name = 'entropy'
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", settings["ostype"] ||= "RedHat_64"]
    end

    # Configure Port Forwarding To The Box
    config.vm.network "forwarded_port", guest: 80, host: 8000
    config.vm.network "forwarded_port", guest: 443, host: 44300
    config.vm.network "forwarded_port", guest: 3306, host: 33060
    config.vm.network "forwarded_port", guest: 5432, host: 54320

    # Configure The Public Key For SSH Access
    config.vm.provision "shell" do |s|
      s.inline = "echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
      s.args = [File.read(File.expand_path(settings["authorize"]))]
    end

    # Copy The SSH Private Keys To The Box
    settings["keys"].each do |key|
      config.vm.provision "shell" do |s|
        s.privileged = false
        s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
        s.args = [File.read(File.expand_path(key)), key.split('/').last]
      end
    end

    # Register All Of The Configured Shared Folders
    settings["folders"].each do |folder|
      config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, :mount_options => ["dmode=777","fmode=666"]
    end

    # remove existing hosts file if any
    config.vm.provision "shell" do |s|
      s.inline = "rm $1"
      s.args = ["/etc/dnsmasq.hosts"]
    end

    # Install All The Configured Nginx Sites
    settings["sites"].each do |site|
      config.vm.provision "shell" do |s|
        if (settings.has_key?("box") && settings["box"] == "laravel/homestead")
          if (site.has_key?("hhvm") && site["hhvm"])
            s.inline = "bash /vagrant/scripts/serve-hhvm.sh $1 $2"
            s.args = [site["map"], site["to"]]
          else
            s.inline = "bash /vagrant/scripts/serve-nginx.sh $1 $2"
            s.args = [site["map"], site["to"]]
          end
        else
          if (site.has_key?("hhvm") && site["hhvm"])
            s.inline = "bash /vagrant/scripts/serve-hhvm.sh $1 $2"
            s.args = [site["map"], site["to"]]
          else
            s.inline = "bash /vagrant/scripts/serve-httpd.sh $1 $2"
            s.args = [site["map"], site["to"]]
          end
        end
        # Add hosts
        s.inline = "echo $1 $2. >> /etc/dnsmasq.hosts"
        s.args = [settings["ip"], site["map"]]
      end
    end

    # Configure All Of The Configured Databases
    settings["databases"].each do |database|
        config.vm.provision "shell" do |s|
            sql = database["sql"] ||= ""
            s.path = "./scripts/create-mysql.sh"
            if (database.has_key?("sql") && database["sql"])
              s.args = [database["db"], database["sql"]]
            else
              s.args = database["db"]
            end
        end

        # config.vm.provision "shell" do |s|
        #     s.path = "./scripts/create-postgres.sh"
        #     s.args = [db]
        # end
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
  end
end
