info("Configuring '${::fqdn}' (${::site_domain}) using environment '${::environment}'")

# Fix for Puppet working with Vagrants
group { 'puppet': ensure => 'present', }

# Setup global PATH variable
Exec { logoutput => true, path => [
    '/usr/local/bin',
    '/opt/local/bin',
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin',
    '/usr/local/zend/bin',
], }

node default {
    include apt
    include stdlib
    include git

    case $::environment { 
    	production: {
    	    include app::database
            include app::webserver
            include app::codebase
    	}
        development: {
            include app::database
            include app::webserver
            include app::codebase
        }
        ec2 : {
            include app::codebase
            include app::webserver
            include app::database
            include ec2
        }
    }

    package { 'unzip' :
       ensure => present
    }

    package { 'vim' :
        ensure => present
    }
        
    exec { "apt-get clean" :
      command => "/usr/bin/apt-get clean"
    }
    
    exec { "apt-update":
      command => "/usr/bin/apt-get update",
      require => [ Exec['apt-get clean'] ]
    }
    
    Exec["apt-update"] -> Package <| |>
}

