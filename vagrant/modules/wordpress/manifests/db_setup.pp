class wordpress::db_setup {
	# var declaration
	$wpDbUser      = $wordpress::db[wpUser]
	$wpDbPW        = $wordpress::db[wpPw]
	$wpDbName      = $wordpress::db[wpName]
	$wpDbTemplate  = $wordpress::db[wpDbTemplate]
	$wpDbTableTest = $wordpress::db[wpDbTableForTest]

	# execution order
	File["/tmp/${wpDbTemplate}"] ->
		Exec['load-template-db']


	# Import a MySQL database for a basic wordpress site.
  file { "/tmp/${wpDbTemplate}":
    source => "puppet:///modules/wordpress/${wpDbTemplate}",
  }

  exec { 'load-template-db':
    unless => "mysql -u${wpDbUser} -p${wpDbPW} ${wpDbName} --execute=\"Select * From ${wpDbTableTest};\"",
    command => "mysql -u${wpDbUser} -p${wpDbPW} ${wpDbName} < /tmp/${wpDbTemplate}",
  }
}