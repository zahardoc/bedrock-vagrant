class wordpress::db_dev_import(
	# var declaration
	$baseDir        = 'vagrant',
	$cmsDir         = 'public',
	$wpDbUser       = 'wordpress',
	$wpDbPW         = 'wordpress',
	$wpDbName       = 'wordpress',
	$wpDbPath       = 'vagrant/public/wp-content/dev_db',
	$wpDbDevFile    = 'dev.sql'
) {

	# import wordpress dev db
	exec { 'import-dev-db':
		onlyif => "test -f /${wpDbPath}/${wpDbDevFile}",
		command => "mysql -u${wpDbUser} -p${wpDbPW} ${wpDbName} < /${wpDbPath}/${wpDbDevFile}",
	}
}

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
class { 'wordpress::db_dev_import': }