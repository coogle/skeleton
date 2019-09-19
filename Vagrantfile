# -*- mode: ruby -*-
# vi: set ft=ruby :

# Usage: ENV=staging vagrant up

VAGRANTFILE_API_VERSION = "2"

require 'json'

localConf = JSON.parse(File.read('VagrantConfig.json'))

environment = "development"
if ENV["ENV"] && ENV["ENV"] != ''
    environment = ENV["ENV"].downcase
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provision :shell, :path => "puppet_bootstrap.sh"
    
    if environment == 'development'
      config.vm.box = "tcataldo/bionic"
      
      config.vm.network :forwarded_port, guest: 80,    host: 10080, auto_correct: true    # apache http
      config.vm.network :forwarded_port, guest: 3306,  host: 3306, auto_correct: true  # mysql
      config.vm.network :forwarded_port, guest: 9200,  host: 9200, auto_correct: true # ElasticSearch
      config.vm.network :forwarded_port, guest: 8545,  host: 8545, auto_correct: true # Ethereum
 
      config.vm.network :private_network, ip: localConf['ipAddress']
    
      config.vm.synced_folder ".", "/vagrant"

        config.vm.provision :puppet do |puppet|
            puppet.options        = "--verbose --debug"
            puppet.manifests_path = "puppet/manifests"
            puppet.module_path    = "puppet/modules"
            puppet.manifest_file  = "site.pp"
            puppet.facter         = {
                "vagrant"     => true,
                "environment" => environment,
                "dbuser" => localConf['dbuser'],
                "dbpass" => localConf['dbpass'],
                "dbname" => localConf['dbname'],
                "site_domain" => localConf['siteDomain'],
                "role"        => "local",
                "awsAccessKey" => localConf['aws']['accessKey'],
                "awsSecretKey" => localConf['aws']['secretKey'],
                "php_version" => localConf['phpVersion'],
                "timezone" => localConf['timezone']
            }
        end
    end
    
end
