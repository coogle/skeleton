# -*- mode: ruby -*-
# vi: set ft=ruby :

# Usage: ENV=staging vagrant up
environment = "development"
if ENV["ENV"] && ENV["ENV"] != ''
    environment = ENV["ENV"].downcase
end

Vagrant.configure("2") do |config|

    if environment == 'development'
      config.vm.box = "precise64"
      config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    
      config.vm.network :forwarded_port, guest: 80,    host: 10080    # apache http
      config.vm.network :forwarded_port, guest: 3306,  host: 3306  # mysql
      config.vm.network :forwarded_port, guest: 10081, host: 10081 # zend http
      config.vm.network :forwarded_port, guest: 10082, host: 10082 # zend https
    
      config.vm.network :private_network, ip: "192.168.42.70"
    
        config.vm.provider :virtualbox do |vb, override|
            vb.gui = false
            vb.customize ["modifyvm", :id, "--memory", 512]
            vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant-root", "1"]
            config.vm.synced_folder ".", "/vagrant", :group => "www-data"
        end
    
        config.vm.provision :puppet do |puppet|
            puppet.options        = "--verbose --debug"
            puppet.manifests_path = "puppet/manifests"
            puppet.module_path    = "puppet/modules"
            puppet.manifest_file  = "site.pp"
            puppet.facter         = {
                "vagrant"     => true,
                "environment" => environment,
                "role"        => "local",
            }
        end
    end
    
    if environment == 'ec2'
        config.vm.provision :shell, :path => "aws_bootstrap.sh"
        config.vm.box = "dummy"

        config.vm.provider :aws do |aws, override|
            aws.access_key_id     = "AKIAIG4GFINOWTIQHL7A"
            aws.secret_access_key = "BzyGOlLdAI/PL8+S0LmJoFxJAnc+o61ahBpaBAt9"
            aws.instance_type     = "t1.micro"
            aws.region            = "us-east-1"
            aws.security_groups   = [ ]
            aws.tags              = {
                "environment" => environment,
                "role"        => role,
                "elastic_ip"  => "54.197.236.109",
                "Name"        => "Google-OAuth2-Demo"
            }

            aws.region_config "us-east-1" do |region|
                region.ami          = "ami-d0f89fb9"
                region.keypair_name = "googleglass"
            end

            override.ssh.username         = "ubuntu"
            override.ssh.private_key_path = "~/.ssh/googleglass.pem"
        end

        config.vm.provision :puppet do |puppet|
            puppet.options        = "--verbose --debug"
            puppet.manifests_path = "puppet/manifests"
            puppet.module_path    = "puppet/modules"
            puppet.manifest_file  = "site.pp"
            puppet.facter         = {
                "environment" => environment,
                "role"        => role,
            }
        end
    end
end
