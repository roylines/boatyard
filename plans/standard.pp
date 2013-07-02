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

package { "ntp":
  ensure  => installed
}

wget::fetch { "nave":
  source      => "https://raw.github.com/isaacs/nave/master/nave.sh",
  destination => "/usr/local/bin",
  timeout     => 0,
  verbose     => false,
}

