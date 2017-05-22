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
      config.vm.box = "geerlingguy/ubuntu1604"
      config.vm.box_url = "https://atlas.hashicorp.com/geerlingguy/boxes/ubuntu1604/"
    
      config.vm.network :forwarded_port, guest: 80,    host: 10080    # apache http
      config.vm.network :forwarded_port, guest: 3306,  host: 3306  # mysql
    
      config.vm.network :private_network, ip: localConf['ipAddress']
    
        config.vm.provider :virtualbox do |vb, override|
            
            vb.gui = false
            vb.customize ["modifyvm", :id, "--memory", localConf['vmMemory']]
            vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
            vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant-root", "1"]


            host = RbConfig::CONFIG['host_os']

            if host =~ /darwin/
               cpus = `sysctl -n hw.ncpu`.to_i
            elsif host =~ /linux/
               cpus = `nproc`.to_i
            else
               cpus = 2
            end

            vb.customize ["modifyvm", :id, "--cpus", cpus]
            config.vm.synced_folder ".", "/vagrant",  nfs: true
        end
    
        config.vm.provision :puppet do |puppet|
            puppet.options        = "--verbose --debug"
#            puppet.manifests_path = "puppet/manifests"
#            puppet.module_path    = "puppet/modules"
#            puppet.manifest_file  = "site.pp"
            puppet.environment_path = "puppet-env"
            puppet.environment = "dev"
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
                "php_version" => localConf['phpVersion']
            }
        end
    end
    
    if environment == 'ec2'
        config.vm.provision :shell, :path => "aws_bootstrap.sh"
        config.vm.box = "dummy"

        config.vm.provider :aws do |aws, override|
            aws.access_key_id     = localConf['aws']['accessKey']
            aws.secret_access_key = localConf['aws']['secretKey']
            aws.instance_type     = localConf['aws']['instanceType']
            aws.region            = localConf['aws']['region']
            aws.security_groups   = localConf['aws']['securityGroups']
            aws.tags              = {
                "environment" => environment,
                "elastic_ip"  => localConf['aws']['elasticIP'],
                "Name"        => localConf['aws']['name']
            }

            aws.region_config localConf['aws']['region'] do |region|
                region.ami          = localConf['aws']['ami']
                region.keypair_name = localConf['aws']['keyPair']
            end

            override.ssh.username         = "ubuntu"
            override.ssh.private_key_path = "~/.ssh/appdemos.pem"
        end

        config.vm.provision :puppet do |puppet|
            puppet.options        = "--verbose --debug"
            puppet.manifests_path = "puppet/manifests"
            puppet.module_path    = "puppet/modules"
            puppet.manifest_file  = "site.pp"
            puppet.facter         = {
                "site_domain" => localConf['siteDomain'],
                "environment" => environment,
                "aws_access_key" => localConf['aws']['accessKey'],
                "aws_secret_key" => localConf['aws']['secretKey'],
                "php_version" => localConf['phpVersion']
            }
        end
    end
end
