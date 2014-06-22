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
    'nano',
    'subversion'
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
  priority      => '0',
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

wp::site {"/var/www":
  location        =>  '/var/www',
  url             =>  $wp_home,
  siteurl         =>  $wp_home,
  sitename        =>  $wp_site_title,
  admin_user      =>  $wp_site_admin_name,
  admin_email     =>  $wp_site_admin_email,
  admin_password  =>  $wp_site_admin_pw,
  network         => false,
  subdomains      => false,
  require => [Mysql::Db["${db_name}"],Class['php']]
}

if $wp_test == 'true' {

  exec { "wptest.xml":
    command => "curl -L -o /tmp/wptest.xml https://raw.githubusercontent.com/manovotny/wptest/master/wptest.xml",
    creates => "/var/www/wptest.xml",
    require => Wp::Site["/var/www"]
  } 

  wp::command{ 'wordpress-importer':
    location => "/var/www",
    command  => "plugin install wordpress-importer --activate",
    require => Wp::Site["/var/www"]
  }

  wp::command{ '/var/www':
    location        =>  '/var/www',
    command => "import /tmp/wptest.xml --authors=create",
    require => [Exec['wptest.xml'], Wp::Command['wordpress-importer']],
    notify  => Exec['remove-wptest.xml']
  }

  exec { "remove-wptest.xml":
    command => "rm /tmp/wptest.xml",
    refreshonly => true
  }
}

if $wp_dev_plugin == 'true' {

  if $wp_dev_plugin_test == 'false' or $wp_test == 'false'{
    notify{'skip-tests':}
    exec {"/var/www wp scaffold plugin $wp_dev_plugin_name --activate --skip-tests":
      command => "/usr/bin/wp scaffold plugin $wp_dev_plugin_name --activate --skip-tests",
      cwd => '/var/www',
      user => 'www-data',
      require => [ Wp::Site["/var/www"] ],
      creates => "/var/www/web/app/plugins/$wp_dev_plugin_name"
    }
  }
  elsif $wp_dev_plugin_test == 'true' or $wp_test == 'true'{
    exec {"/var/www wp scaffold plugin $wp_dev_plugin_name --activate":
      command => "/usr/bin/wp scaffold plugin $wp_dev_plugin_name --activate",
      cwd => '/var/www',
      user => 'www-data',
      require => [ Wp::Site["/var/www"] ],
      creates => "/var/www/web/app/plugins/$wp_dev_plugin_name",
    }

  }

  
}
