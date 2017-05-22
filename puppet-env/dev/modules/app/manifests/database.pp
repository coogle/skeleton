class app::database {

  class { '::mysql::server' :
     root_password => 'password'
  }
  
  mysql::db { $::dbname : 
  	 user => $::dbuser,
  	 password => $::dbpass,
  	 host => 'localhost',
  }
  
  exec { "migrate application db" :
  	 command => "/usr/bin/php artisan migrate",
  	 cwd => "/vagrant",
  	 require => [ Class['::php'], Exec["Installing From Composer"] ]
  }
  	 
}
