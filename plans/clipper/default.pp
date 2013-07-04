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

class redis {
	package { "make":
		ensure => installed
	}
	package { "gcc":
		ensure => installed
	}
	file { "/etc/redis":
		ensure => directory
	}
	file { "/etc/redis/6379.conf":
		source => "/plans/redis.conf",
		require => File['/etc/redis']
	}
	file { "/etc/init.d/redis_6379":
		mode	=> 700,
		source => "/plans/redis.init.d"
	}
	file { "/var/redis":
		ensure => directory
	}
	file { "/var/redis/6379":
		ensure => directory,
		require => File['/var/redis']
	}
	exec { "get-redis":								
		command => "/usr/bin/wget http://redis.googlecode.com/files/redis-2.6.14.tar.gz",
		creates => "/usr/local/src/redis-2.6.14.tar.gz",
		cwd => "/usr/local/src",
		user => root
	}
	exec { "extract-redis":								
		command => "/bin/tar xzf redis-2.6.14.tar.gz",
		creates => "/usr/local/src/redis-2.6.14",
		cwd => "/usr/local/src",
		user => root,
		require => Exec["get-redis"]
	}
	exec { "make-redis":								
		command => "/usr/bin/make distclean all",
		creates => "/usr/local/src/redis-2.6.14/src/redis-cli",
		cwd => "/usr/local/src/redis-2.6.14",
		user => root,
		require => [Exec["extract-redis"], Package["make"], Package["gcc"]]
	}
	file { "/usr/local/bin/redis-server":
			ensure => link,
			target => "/usr/local/src/redis-2.6.14/src/redis-server",
			require => Exec['make-redis']
	}
	file { "/usr/local/bin/redis-cli":
			ensure => link,
			target => "/usr/local/src/redis-2.6.14/src/redis-cli",
			require => Exec['make-redis']
	}
	exec { "chkconfig-redis":								
		command => "/sbin/chkconfig --level 345 redis_6379 on",
		creates => "/etc/rc3.d/S80redis_6379",
		user => root,
		require => File['/etc/init.d/redis_6379']
	}
	exec { "start-redis":								
		command => "/etc/init.d/redis_6379 start",
		creates => "/var/run/redis_6379.pid",
		user => root,
		require => [
			File['/etc/init.d/redis_6379'], 
			File['/usr/local/bin/redis-server'], 
			File['/etc/redis/6379.conf'],
			File['/var/redis/6379']
		]
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

include firewall
include nginx
include redis
include nodejs
