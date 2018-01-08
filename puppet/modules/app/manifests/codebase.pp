class app::codebase {

  info("Deploying Codebase for environment $environment")

  file { "/vagrant/public/.htaccess" :
     group => "www-data",
     owner => "root",
     mode => 775,
     source => "puppet:///modules/app/config/$::environment/public/.htaccess"
  }
  
  exec { "Installing From Composer" :
  	 command => "/usr/local/bin/composer install",
  	 cwd => "/vagrant",
  	 user => 'vagrant',
  	 environment => ['HOME=/home/vagrant'],
  	 timeout => 0,
  	 require => [ Class['::php'] ]
  }
  	 

  file { "/vagrant/.env" :
  	 group => "www-data",
  	 mode => 775,
  	 content => template("app/laravel-env.erb"),
  	 ensure => present,
  	 replace => 'no'
  }
  
  file { "/vagrant/storage" :
  	 group => "www-data",
  	 mode => 775,
     recurse => true,
     ensure => directory
  }
  
  file { "/vagrant/bootstrap/cache" :
  	 ensure => directory,
  	 group => "www-data",
  	 mode => 775,
  	 recurse => true
  }
  	 
  exec { "Generate Laravel Application Key" : 
  	 cwd => "/vagrant",
  	 unless => "/usr/bin/test -f /vagrant/.puppet-key-generated",
  	 before => File["/vagrant/.puppet-key-generated"],
  	 command => '/usr/bin/php artisan key:generate',
  	 require => [ Class['::php'], Exec["Installing From Composer"] ]
  }
  
  file { "/vagrant/.puppet-key-generated" :
  	 ensure => present,
  	 content => "delete me to regenerate app key through puppet"
  }
  	 
}
