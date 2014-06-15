group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { owner => 0, group => 0, mode => 0644 }

class {'apt':
  always_apt_update => true,
}

Class['::apt::update'] -> Package <|
    title != 'python-software-properties'
and title != 'software-properties-common'
|>

apt::key { '4F4EA0AAE5267A6C': }

apt::ppa { 'ppa:ondrej/php5-oldstable':
  require => Apt::Key['4F4EA0AAE5267A6C']
}

package { [
    'build-essential',
    'vim',
    'curl',
    'git-core',
    'zip',
    'nano'
  ]:
  ensure  => 'installed',
}

class { 'timezone':
    timezone => 'Europe/Berlin',
    before => Package['apache'],
}

class { 'apache': }

apache::dotconf { 'custom':
  content => 'EnableSendfile Off',
}

apache::module { 'rewrite': }

apache::vhost { "${wp_host}":
  server_name   => $wp_host,
  serveraliases => [ ],
  docroot       => '/var/www/web/',
  port          => '80',
  env_variables => [],
  priority      => '1',
}

class { 'php':
  service       => 'apache',
  module_prefix => '',
  require       => Package['apache'],
}

php::module { 'php5-mysql': }
php::module { 'php5-cli': }
php::module { 'php5-curl': }
php::module { 'php5-intl': }
php::module { 'php5-mcrypt': }

class { 'php::devel':
  require => Class['php'],
}

class { 'php::pear':
  require => Class['php'],
}

class { 'xdebug':
  service => 'apache',
}

class { 'composer':
  require => Package['php5', 'curl'],
}

puphpet::ini { 'xdebug':
  value   => [
    'xdebug.default_enable = 1',
    'xdebug.remote_autostart = 0',
    'xdebug.remote_connect_back = 1',
    'xdebug.remote_enable = 1',
    'xdebug.remote_handler = "dbgp"',
    'xdebug.remote_port = 9000'
  ],
  ini     => '/etc/php5/conf.d/zzz_xdebug.ini',
  notify  => Service['apache'],
  require => Class['php'],
}

puphpet::ini { 'php':
  value   => [
    'date.timezone = "Europe/Berlin"'
  ],
  ini     => '/etc/php5/conf.d/zzz_php.ini',
  notify  => Service['apache'],
  require => Class['php'],
}

puphpet::ini { 'custom':
  value   => [
    'display_errors = On',
    'error_reporting = -1',
    'memory_limit = 256M',
    'post_max_size = 8M',
        'upload_max_filesize = 8M'
  ],
  ini     => '/etc/php5/conf.d/zzz_custom.ini',
  notify  => Service['apache'],
  require => Class['php'],
}

class { 'mysql::server':
  config_hash   => {
    'root_password' => 'vagrant',
    'bind_address' => '192.168.100.100',
  }
}

mysql::db { $db_name:
  grant    => [
    'ALL'
  ],
  user     => $db_user,
  password => $db_password,
  host     => $db_host,
  charset  => 'utf8',
  require  => Class['mysql::server'],
  #sql      => '/vagrant/db/development.sql',
}

database_user { "${db_user}@%":
  password_hash => mysql_password($db_password)
}

database_grant { "${db_user}@%/${db_name}":
  privileges => ['all'] ,
}

wp::site {"${wp_site_title}":
    location => '/var/www/web/wp',
    url => $wp_home,
    name => $wp_site_title,
    require => [Mysql::Db["${db_name}"],Class['php']]
}
