require 'json'
require 'yaml'

# VAGRANTFILE_API_VERSION = "2"

entropyYamlPath = File.expand_path("~/.entropy/Entropy.yaml")
afterScriptPath = File.expand_path("~/.entropy/after.sh")
aliasesPath = File.expand_path("~/.entropy/aliases")

require_relative 'scripts/entropy.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	if File.exists? aliasesPath then
		config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
	end

	Entropy.configure(config, YAML::load(File.read(entropyYamlPath)))

	if File.exists? afterScriptPath then
		config.vm.provision "shell", path: afterScriptPath
	end
end
