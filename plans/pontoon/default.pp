class dokku {
  package { "git":
    ensure => installed
  }
  package { "make":
    ensure => installed
  }
  package { "curl":
    ensure => installed
  }
  package { "software-properties-common":
    ensure => installed
  }
  exec { "clone":
    command => "/usr/bin/git clone https://github.com/progrium/dokku.git",
    cwd => "/root",
    creates => "/root/dokku",
    require => Package["git"]
  }
  exec { "checkout": 
    command => "/usr/bin/git checkout v0.2.0",
    cwd => "/root/dokku",
    subscribe => Exec["clone"],
    refreshonly => true
  }
  exec { "make": 
    command => "/usr/bin/make install",
    cwd => "/root/dokku",
    require => [Package["make"], Package["software-properties-common"], Package["curl"], Exec["checkout"]],
    creates => "/usr/local/bin/dokku"
  }
  exec { "add-keys":
    command => "/bin/cat /root/.ssh/authorized_keys | /usr/local/bin/sshcommand acl-add dokku dokku",
    subscribe => Exec["make"],
    refreshonly => true
  }
}

include dokku
