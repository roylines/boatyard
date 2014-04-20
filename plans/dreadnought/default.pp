class firewall {
	file { "/etc/sysconfig/iptables":
		source => "/plans/iptables"
	}
	exec { "fw-restart":								
		command => "/sbin/service iptables restart",
		subscribe => File["/etc/sysconfig/iptables"],
		refreshonly => true,
		user => root,
		require => File["/etc/sysconfig/iptables"]
	}	
}

class nodejs {
  package { "wget":
    ensure => latest
  }
  package { "tar":
    ensure => latest
  }
  package { "gcc":
    ensure => latest
  }
  package { "gcc-c++":
    ensure => latest
  }
  package { "kernel-devel":
    ensure => latest
  }
	user { "nodeuser":
		ensure => present,
		comment => "user that nodejs applications run under",
		managehome => true
	}
  exec { "get-authbind":								
		command => "/usr/bin/wget http://ftp.debian.org/debian/pool/main/a/authbind/authbind_1.2.0.tar.gz -O /usr/local/src/authbind_1.2.0.tar.gz",
		creates => "/usr/local/src/authbind_1.2.0.tar.gz",
		user => root,
    require => Package["wget"]
	}
  exec { "untar-authbind":								
		command => "/bin/tar -zxvf authbind_1.2.0.tar.gz",
    cwd => "/usr/local/src",
		creates => "/usr/local/src/authbind_1.2.0",
		user => root,
    require => [Package["tar"], Exec["get-authbind"]]
	}
  exec { "make-authbind":								
		command => "/usr/bin/make",
    cwd => "/usr/local/src/authbind-1.2.0",
		creates => "/usr/local/src/authbind-1.2.0/authbind",
		user => root,
    require => [Exec["untar-authbind"], Package["gcc"], Package["gcc-c++"], Package["kernel-devel"]]
	}
  exec { "install-authbind":								
		command => "/usr/bin/make install",
    cwd => "/usr/local/src/authbind-1.2.0",
		creates => "/usr/local/bin/authbind",
		user => root,
    require => Exec["make-authbind"]
	}
	file { "/etc/authbind/byport/80":
		ensure => present,
    mode => '0755',
		group => 'nodeuser',
		owner => 'nodeuser',
		require => [User["nodeuser"], Exec["install-authbind"]]
	}
	file { "/home/nodeuser":
		ensure => directory,
		group => 'nodeuser',
		owner => 'nodeuser',
		require => User["nodeuser"]
	}
	file { "/home/nodeuser/.ssh":
		ensure => directory,
		group => 'nodeuser',
		owner => 'nodeuser',
		require => File["/home/nodeuser"]
	}
	file { "/home/nodeuser/.ssh/authorized_keys":
		source => "/root/.ssh/authorized_keys",
		group => 'nodeuser',
		owner => 'nodeuser',
		require => File["/home/nodeuser/.ssh"]
	}
	file { "/home/nodeuser/projects":
		ensure => directory,
		group => 'nodeuser',
		owner => 'nodeuser',
		require => File["/home/nodeuser"]
  }
  exec { "get-nave":								
		command => "/usr/bin/wget https://raw.github.com/isaacs/nave/master/nave.sh -O /usr/local/bin/nave",
		creates => "/usr/local/bin/nave",
		user => root,
    require => Package["wget"]
	}
	file { "/usr/local/bin/nave":
  		mode => 700,
  		require => Exec['get-nave']
	}
	exec { "node":								
		command => "/usr/local/bin/nave usemain 0.10.26",
		creates => "/usr/local/bin/node",
		user => root,
		require => File['/usr/local/bin/nave']
	}
	exec { "naught":								
		command => "/usr/local/bin/npm install -g naught",
		creates => "/usr/local/bin/naught",
		user => root,
		require => Exec['node']
	}
}

class mongo {
	yumrepo { "mongorepo":
		baseurl => "http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/",
		descr => "mongodb repo",
		enabled => 1,
		gpgcheck => 0
	}
  package { "mongodb-org":
    ensure => "latest",
    require => Yumrepo["mongorepo"]
  }
	exec { "ensure-mongo-runs-after-reboot":								
		command => "/sbin/chkconfig mongod on",
		require => Package["mongodb-org"]
	}
  service { "mongod":
    ensure=>"running",
		require => Package["mongodb-org"]
  }
}

include firewall
include nodejs
include mongo
