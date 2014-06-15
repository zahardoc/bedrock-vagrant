class wordpress::download {
	# vars
	$baseDir     = $wordpress::dir[base]
	$cmsDir      = $wordpress::dir[cms]
  $downloadDir = $wordpress::dir[download]
	$wpUrl       = $wordpress::wp[url]
	$wpFile      = $wordpress::wp[file]
	$wpTempDir   = $wordpress::wp[tmpDir]

	# execution order
	Exec['download-wp'] ->
		Exec['unzip-wp'] ->
			Exec['copy-wp-temp-dir'] ->
				Exec['remove-wp-tmpDir']


	exec { 'download-wp':
		cwd     => "/${baseDir}/${downloadDir}",
		command => "wget -O ${wpFile} ${wpUrl}",
		creates => "/${baseDir}/${downloadDir}/${wpFile}",
	}

	exec { 'unzip-wp':
		cwd     => "/${baseDir}/${downloadDir}",
		command => "unzip ${wpFile}",
		creates => "/${baseDir}/${downloadDir}/${wpTempDir}",
    require => Package['zip'],
	}

	exec { 'copy-wp-temp-dir':
		cwd     => "/${baseDir}/${downloadDir}",
		command => "cp -R ${wpTempDir}/* /${baseDir}/${cmsDir}",
		creates => "/${baseDir}/${cmsDir}/wp-content",
	}

	exec{ "remove-wp-tmpDir":
    cwd     => "/${baseDir}/${downloadDir}",
		onlyif  => "test -d /${baseDir}/${cmsDir}/wp-content",
		command => "rm -rf ${wpTempDir}",
	}
}