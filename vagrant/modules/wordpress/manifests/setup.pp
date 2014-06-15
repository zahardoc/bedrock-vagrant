class wordpress::setup {
	# var declaration
	$baseDir        = $wordpress::dir[base]
	$cmsDir         = $wordpress::dir[cms]
	$vagrantFiles   = $wordpress::dir[vFiles]
	$configTemplate = $wordpress::wp_config_template

  # Copy a working wp-config.php file for the vagrant setup.
  exec { "cp-base-wp-config":
    cwd     => "/${baseDir}",
	  unless  => "test -f /${baseDir}/${cmsDir}/wp-config.php",
	  command => "cp  /${baseDir}/${vagrantFiles}/files/wp-config.php /${baseDir}/${cmsDir}/wp-config.php",
  }
}
