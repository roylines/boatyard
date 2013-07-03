class base {
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
	package { "zlib":
	  ensure  => installed,
	}
	package { "pcre":
	  ensure  => installed,
	}
	package { "openssl":
	  ensure  => installed,
	}
	package { "nginx":
	  ensure  => installed,
	  require => Yumrepo["nginxrepo"]
	}
	file { "/etc/nginx/nginx.conf":
		source => "/plans/nginx.conf",
		require => [Package["nginx"], Package["zlib"], Package["pcre"], Package["openssl"]]
	}
	exec { "restart-nginx":								
		command => "/bin/kill -QUIT $( cat /var/run/nginx.pid )",
		user => root,
		onlyif => '/usr/bin/test -f /var/run/nginx.pid',
		subscribe => File["/etc/nginx/nginx.conf"],
		refreshonly => true,
		require => File["/etc/nginx/nginx.conf"]
	}
	exec { "start-nginx":								
		command => "/usr/sbin/nginx",
		creates => "/var/run/nginx.pid",
		user => root,
		require => File["/etc/nginx/nginx.conf"]
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
		subscribe => File["/etc/sysconfig/iptables"],
		refreshonly => true,
		user => root,
		require => File["/etc/sysconfig/iptables"]
	}	
}

include base
include nginx
include nodejs
include firewall