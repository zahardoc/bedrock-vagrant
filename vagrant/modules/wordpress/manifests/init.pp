class wordpress (
  $dir = {
      base => 'vagrant',
      cms  => 'public',
      vFiles => 'vagrant/modules/wordpress',
      download => 'vagrant/download' },
  $wp = {
      url    => 'http://wordpress.org/latest.zip',
      file   => 'latest.zip',
      tmpDir => 'wordpress' },
  $wp_lang  =  {
      url  => 'http://wpde.org/files/2012/05/de_DE_Sie.zip',
      file => 'de_DE_Sie.zip' },
  $wp_theme = {
      url  => 'https://github.com/milohuang/reverie/archive/master.zip',
      file => 'reverie-theme.zip' },
  $db = {
      rootUser  => 'root',
      rootPw    => 'vagrant',
      wpUser    => 'wordpress',
      wpPw      => 'wordpress',
      wpName    => 'wordpress',
      wpDbTableForTest => 'wp_users', # not used
      wpDbTemplate => 'wordpress-db.sql', # not used
      wpDbDumpPath  => ''}, # not used
  $wp_config_template = 'puppet:///modules/wordpress/wp-config.php'
) {

	class { 'wordpress::download': }  ->
		class { 'wordpress::languages': } ->
			class { 'wordpress::setup': } ->
					Class['wordpress']
}

#todo render wp-config.php with hiera
#todo replace reverie theme with reactor
#todo add timber plugin

