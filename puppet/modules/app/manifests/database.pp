class app::database {

  class { '::mysql::server' :
     root_password => 'password'
  }
  
  mysql::db { $::dbname : 
  	 user => $::dbuser,
  	 password => $::dbpass,
  	 host => 'localhost',
 }
  	 
}
