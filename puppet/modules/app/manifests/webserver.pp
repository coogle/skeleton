class app::webserver {
	
	class { 'apache': }
	
	class { 'zendserver':
		php_version => '5.4',
		use_ce => false
	}
	
	case $::environment {
		staging: {
			file { "/usr/local/bin/aws_assign_ip.sh" : 
				source => "puppet:///modules/app/ec2/aws_assign_ip.sh",
				owner => root,
				group => root,
				mode => 744,
				require => [ Class['ec2'] ]
			}
		 
			exec { 'Assign Elastic IP' :
				command => "/usr/local/bin/aws_assign_ip.sh",
				require => [ Class['ec2'], File['/usr/local/bin/aws_assign_ip.sh'] ]
			}
		}
	}
	
	file { "/usr/local/bin/pear" : 
		target => '/usr/local/zend/bin/pear',
		ensure => 'link',
		require => [ Class['zendserver'] ]
	}

	file { "/usr/local/zend/etc/php.ini" :
		source => 'puppet:///modules/app/php/php.ini',
		owner => root,
		group => zend,
		mode => 644,
		require => [ Class['zendserver'] ]
	}
	
	apache::vhost { "dev-drank.coogleapps.com":
		docroot  => "/vagrant/public",
		ssl	  => true,
		priority => '000',
		template => 'app/apache/virtualhost/vhost.conf.erb',
		require => [ Package['apache'] ]
	}
	
	exec { "bootstrap-zs-server" :
		command => "/usr/local/zend/bin/zs-manage bootstrap-single-server --acceptEula TRUE -p 'password'",
		cwd => "/usr/local/zend/bin/",
		require => [ Class['zendserver'] ]
	}
	
	file { "/etc/profile.d/server_env.sh" :
		content => "export APPLICATION_ENV=$::environment",
		owner => root,
		group => root,
		mode => 755
	}
	
	# Disable the default (catch-all) vhost
	exec { "disable default virtual host from ${name}":
		command => "a2dissite default",
		onlyif  => "test -L ${apache::params::config_dir}/sites-enabled/000-default",
		notify  => Service['apache'],
		require => Package['apache'],
	}

	# Install Composer
	class { 'composer':
		target_dir   => '/usr/local/bin',
		command_name => 'composer',
		auto_update  => false,
		user		 => 'root'
	}

	exec { 'composer self-update':
		command => "${composer::composer_command_name} self-update",
		user	=> $composer::composer_user,
		require => [ Exec['composer-fix-permissions'], File['/usr/local/bin/php'], Class['composer'] ]
	}

	exec { 'composer update' :
		command => "${composer::composer_command_name} update",
		user => $composer::composer_user,
		cwd => "/vagrant",
		require => [ Exec['composer self-update'], Package['git'] ]
	}

}
