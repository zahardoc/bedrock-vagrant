class wordpress::languages {
	# vars
	$baseDir     = $wordpress::dir[base]
	$cmsDir      = $wordpress::dir[cms]
    $downloadDir = $wordpress::dir[download]
	$wpLangUrl   = $wordpress::wp_lang[url]
	$wpLangFile  = $wordpress::wp_lang[file]

	# execution order
	Exec['download-zip-file'] ->
		Exec['unzip-file']


	# download language file for wordpress into project root
	exec { 'download-zip-file':
		cwd     => "/${baseDir}/${downloadDir}",
		command => "wget -O ${wpLangFile} ${wpLangUrl}",
		creates => "/${baseDir}/${downloadDir}/${wpLangFile}",
	}

	# unzip the language file into languages directory of wordpress installation
	exec { 'unzip-file':
		cwd     => "/${baseDir}/${downloadDir}",
		command => "unzip ${wpLangFile} -d /${baseDir}/${cmsDir}/wp-content/languages",
		creates => "/${baseDir}/${cmsDir}/wp-content/languages",
        require => Package['zip'],
	}

}