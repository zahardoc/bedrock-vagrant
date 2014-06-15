class wordpress::db_dev_export(
	# var declaration
	$baseDir        = 'vagrant',
	$cmsDir         = 'public',
	$wpDbUser       = 'wordpress',
	$wpDbPW         = 'wordpress',
	$wpDbName       = 'wordpress',
	$wpDbPath       = 'vagrant/public/wp-content/dev_db',
	$wpDbDevFile    = 'dev.sql'
) {

	# export wordpress dev db
	exec { 'export-dev-db':
		onlyif => "mysql -u${wpDbUser} -p${wpDbPW} ${wpDbName}",
		command => "mysqldump --skip-comments --skip-extended-insert -u${wpDbUser} -p${wpDbPW} ${wpDbName} >/${wpDbPath}/${wpDbDevFile}",
	}
}

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
class { 'wordpress::db_dev_export': }