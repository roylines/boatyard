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