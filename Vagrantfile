require 'json'
require 'yaml'

if (defined?(VAGRANTFILE_API_VERSION)).nil? # will now return true or false
    VAGRANTFILE_API_VERSION = "2"
end

confDir = $confDir ||= File.expand_path("~/.entropy")

entropyYamlPath = confDir + "/Entropy.yaml"
afterScriptPath = confDir + "/after.sh"
aliasesPath = confDir + "/aliases"

require File.expand_path(File.dirname(__FILE__) + '/scripts/entropy.rb')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	if File.exists? aliasesPath then
		config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
	end

	Entropy.configure(config, YAML::load(File.read(entropyYamlPath)))

	if File.exists? afterScriptPath then
		config.vm.provision "shell", path: afterScriptPath
	end
end
