class app::database {

  class { '::mysql::server' :
    root_password => 'password',
    databases => {
        'wordpress' => {
     	    ensure => 'present',
	    charset => 'utf8'
    	}
    }
  }

}
