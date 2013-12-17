class dokku {
  package {
    "wget":
      ensure => installed
  }
	exec { "get-dokku-bootstrap":								
		command => "/usr/bin/wget https://raw.github.com/progrium/dokku/v0.2.0/bootstrap.sh -O /plans/dokku-2.0-bootstrap.sh",
    creates => "/plans/dokku-2.0-bootstrap.sh",
		require => Package["wget"]
	}	
}

include dokku
