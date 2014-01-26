class app::database {

  class { 'mysql' :
     root_password => 'password'
  }
   
}
