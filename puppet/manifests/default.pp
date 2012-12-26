# Basic Puppet manifest

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

class system-update {

    file { "/etc/apt/sources.list.d/dotdeb.list":
        owner  => root,
        group  => root,
        mode   => 664,
        source => "/vagrant/conf/apt/dotdeb.list",
    }

    exec { 'dotdeb-apt-key':
        cwd     => '/tmp',
        command => "wget http://www.dotdeb.org/dotdeb.gpg -O dotdeb.gpg &&
                    cat dotdeb.gpg | apt-key add -",
        unless  => 'apt-key list | grep dotdeb',
        require => File['/etc/apt/sources.list.d/dotdeb.list'],
        notify  => Exec['apt_update'],
    }

  exec { 'apt-get update':
    command => 'apt-get update',
  }

  $sysPackages = [ "build-essential" ]
  package { $sysPackages:
    ensure => "installed",
    require => Exec['apt-get update'],
  }
}

class nginx-setup {

  include nginx

  file { "/etc/nginx/sites-available/php-fpm":
    owner  => root,
    group  => root,
    mode   => 664,
    source => "/vagrant/conf/nginx/default",
    require => Package["nginx"],
    notify => Service["nginx"],
  }

  file { "/etc/nginx/sites-enabled/default":
    owner  => root,
    ensure => link,
    target => "/etc/nginx/sites-available/php-fpm",
    require => Package["nginx"],
    notify => Service["nginx"],
  }
}

class development {

  $devPackages = [ "curl", "git", "nodejs", "npm", "rubygems" ]
  package { $devPackages:
    ensure => "installed",
    require => Exec['apt-get update'],
  }
}

class main {

    php::module { [ 'curl', 'gd', 'mcrypt', 'memcached', 'mysql' 'imap', ]:
        notify => Class['php::fpm::service'],
    }

    php::module { [ 'memcache', 'apc', ]:
        notify => Class['php::fpm::service'],
        source  => '/etc/php5/conf.d/',
    }

    php::module { [ 'suhosin', ]:
        notify  => Class['php::fpm::service'],
        source  => '/vagrant/conf/php/',
    }

    exec { 'pecl-mongo-install':
        command => 'pecl install mongo',
        unless => "pecl info mongo",
        notify => Class['php::fpm::service'],
    }

    exec { 'pecl-xhprof-install':
        command => 'pecl install xhprof',
        unless => "pecl info xhprof",
        notify => Class['php::fpm::service'],
    }

    php::conf { [ 'mysqli', 'pdo', 'pdo_mysql', ]:
        require => Package['php-mysql'],
        notify  => Class['php::fpm::service'],
    }

    file { "/etc/php5/conf.d/custom.ini":
        owner  => root,
        group  => root,
        mode   => 664,
        source => "/vagrant/conf/php/custom.ini",
        notify => Class['php::fpm::service'],
    }

    include php::fpm

    file { "/etc/php5/fpm/pool.d/www.conf":
        owner  => root,
        group  => root,
        mode   => 664,
        source => "/vagrant/conf/php/php-fpm/www.conf",
        notify => Class['php::fpm::service'],
    }
}

class { 'apt': }

include system-update

include php::fpm
include main

include nginx-setup
include apache
include mysql

class {'mongodb':
  enable_10gen => true,
}

include development
