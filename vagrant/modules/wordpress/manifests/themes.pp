class wordpress::themes
{
	# vars
	$baseDir     = $wordpress::dir[base]
	$cmsDir      = $wordpress::dir[cms]
    $downloadDir = $wordpress::dir[download]
	$wpThemeUrl  = $wordpress::wp_theme[url]
	$wpThemeFile = $wordpress::wp_theme[file]

	# execution order
	Exec['download-theme'] ->
		Exec['unzip-theme']


	exec { 'download-theme':
		cwd     => "/${baseDir}/${downloadDir}",
		command => "wget -O ${wpThemeFile} ${wpThemeUrl}",
		creates => "/${baseDir}/${downloadDir}/${wpThemeFile}",
	}

	exec { 'unzip-theme':
		cwd     => "/${baseDir}/${downloadDir}",
		command => "unzip ${wpThemeFile} -d /${baseDir}/${cmsDir}/wp-content/themes/reverie",
		creates => "/${baseDir}/${cmsDir}/wp-content/themes/reverie",
        require => Package['zip'],
	}

}