class base {
	group { "pirates":
		ensure => present,
		gid => 1000
	}
	user { "blackbeard":
		ensure => present,
		gid => "pirates",
		membership => minimum,
		shell => "/bin/bash",
		require => Group["pirates"]
	}
	package { "ntp":
	  ensure  => installed
	}
	package { "git":
	  ensure  => installed
	}
}

class nginx {
	yumrepo { "nginxrepo":
		baseurl => "http://nginx.org/packages/centos/6/x86_64/",
		descr => "nginx repo",
		enabled => 1,
		gpgcheck => 0
	}
	package { "nginx":
	  ensure  => installed,
	  require => Yumrepo["nginxrepo"]
	}
}

class nodejs {
	exec { "get-nave":								
		command => "/usr/bin/wget https://raw.github.com/isaacs/nave/master/nave.sh -O /usr/local/bin/nave",
		creates => "/usr/local/bin/nave",
		user => root
	}
	file { "/usr/local/bin/nave":
  	mode => 700,
  	require => Exec['get-nave']
	}
	exec { "node":								
		command => "/usr/local/bin/nave usemain 0.10.12",
		creates => "/usr/local/bin/node",
		user => root,
		require => File['/usr/local/bin/nave']
	}
}

class firewall {
	file { "/etc/sysconfig/iptables":
		source => "/plans/iptables"
	}
	exec { "fw-restart":								
		command => "/sbin/service iptables restart",
		user => root,
		require => File["/etc/sysconfig/iptables"]
	}	
}

include base
include nginx
include nodejs
include firewall