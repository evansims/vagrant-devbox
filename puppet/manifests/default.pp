# Basic Puppet manifest

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

class dbx-setup-apt {

	include apt

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

	package { [ "build-essential" ]:
		ensure  => "installed",
		require => Exec['apt-get update'],
	}
}

class dbx-setup-toolbox {

	package { [ "htop", "curl", "git", "nodejs", "rubygems" ]:
		ensure  => "installed",
		require => Exec['apt-get update'],
	}

	package { [ "npm" ]:
		ensure  => "installed",
		require => Package['nodejs'],
	}

	exec { 'gem install sass':
		command => 'gem install sass',
		require => Package['rubygems'],
	}
}

class dbx-setup-databases {

	class { 'mysql':
		root_password => 'root',
	}

	class { 'mongodb':
		enable_10gen => true,
	}
}

class dbx-setup-memcached {

	class { 'memcached':
		max_memory => '10%',
		logfile    => '/vagrant/logs/memcached.log',
	}
}

class dbx-setup-php {
	
	include php::fpm
	include pear

	php::module { [ 'curl', 'gd', 'mcrypt', 'memcached', 'mysql', 'imap' ]:
		notify => Class['php::fpm::service'],
	}

	exec { 'pecl-mongo-install':
		command => 'pecl install mongo',
		unless  => "pecl info mongo",
		require => Class['pear'],
		notify  => Class['php::fpm::service'],
	}

	php::conf { [ 'mysqli', 'pdo', 'pdo_mysql' ]:
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

	file { "/etc/php5/fpm/pool.d/www.conf":
		owner  => root,
		group  => root,
		mode   => 664,
		source => "/vagrant/conf/php/php-fpm/www.conf",
		notify => Class['php::fpm::service'],
	}
}

class dbx-setup-nginx {

	include nginx

	file { "/etc/nginx/sites-available/php-fpm":
		owner   => root,
		group   => root,
		mode    => 664,
		source  => "/vagrant/conf/nginx/default",
		require => Package["nginx"],
		notify  => Service["nginx"],
	}

	file { "/etc/nginx/sites-enabled/default":
		owner   => root,
		ensure  => link,
		target  => "/etc/nginx/sites-available/php-fpm",
		require => Package["nginx"],
		notify  => Service["nginx"],
	}
}

include dbx-setup-apt
include dbx-setup-toolbox
include dbx-setup-databases
include dbx-setup-memcached
include dbx-setup-php
include dbx-setup-nginx
