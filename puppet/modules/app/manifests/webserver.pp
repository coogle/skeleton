class app::webserver {

    package { 'supervisor':
      ensure => present
    }
     
    service { "supervisor" :
      ensure => 'running',
      enable => true,
      require => Package['supervisor']
    }
    
    class { 'nodejs' :
      repo_url_suffix => '8.x'
    }

    class { 'apache': 
      	default_vhost => false
    }
    
    apache::mod { 'proxy': }
    apache::mod { 'proxy_fcgi': }
    apache::mod { 'rewrite': }
    
    package { 'software-properties-common' :
    	   ensure => present
   	}
	
	class { '::php::globals':
		php_version => $::php_version
	}->
	class { '::php':
		ensure	=> latest,
		manage_repos => true,
		dev => true,
		fpm => true,
		composer => true,
		pear => true,
		phpunit => true,
		settings => {
			'Date/date.timezone' => $::timezone
		},
		require => [ Package['software-properties-common'], Class['apache'] ],
		extensions => {
		  gd => {},
			mbstring => {},
			pdo => {},
			"pdo-mysql" => {},
			calendar => {},
			curl => {},
			ctype => {},
			dom => {},
			exif => {},
			fileinfo => {},
			ftp => {},
			gettext => {},
			iconv => {},
			json => {},
			phar => {},
			posix => {},
			readline => {},
			shmop => {},
			simplexml => {},
			sockets => {},
			sysvmsg => {},
			sysvsem => {},
			sysvshm => {},
			tokenizer => {},
			wddx => {},
			xmlreader => {},
			xmlwriter => {},
			xsl => {},
			tidy => {},
			mcrypt => {}
		}
	}
	    
	file { "/vagrant/public" :
		ensure => directory
	}
	
    apache::vhost { 'development' :
    	ip => '*',
    	port => '80',
        docroot  => "/vagrant/public",
        docroot_owner => 'vagrant',
        docroot_group => 'www-data',
        priority => '000',
        override => ['all'],
        directoryindex => '/index.php',
        custom_fragment => 'ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/vagrant/public/$1',
        setenv => "APPLICATION_ENV $::environment",
        require => [ File['/vagrant/public'] ]
    }
    
    file { "/etc/profile.d/server_env.sh" :
        content => "export APPLICATION_ENV=$::environment",
        owner => root,
        group => root,
        mode => "755"
    }
}
