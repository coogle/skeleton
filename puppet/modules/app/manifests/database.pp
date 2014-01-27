class app::database {

  class { '::mysql::server' :
     root_password => 'password'
  }
   
}
