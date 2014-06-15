class wordpress::db_init {
	# var declaration
	$rootUser = $wordpress::db[rootUser]
	$rootPw   = $wordpress::db[rootPw]
	$wpDbUser = $wordpress::db[wpUser]
	$wpDbPW   = $wordpress::db[wpPw]
    $wpDbName = $wordpress::db[wpName]

	# execution order
	Exec['create-wp-database'] ->
		Exec['create-wp-user']


	exec { 'create-wp-database':
		unless  => "mysql -u${rootUser} -p${rootPw} ${wpDbName}",
		command => "mysql -u${rootUser} -p${rootPw} --execute=\'create database ${wpDbName}\'",
        require => Class['mysql::config'],
	}

	exec { 'create-wp-user':
		unless  => "mysql -u${wpDbUser} -p${wpDbPW}",
		command => "mysql -u${rootUser} -p${rootPw} --execute=\"GRANT ALL PRIVILEGES ON ${wpDbName}.* TO \'${wpDbUser}\'@\'localhost\' IDENTIFIED BY \'${wpDbUser}\'\"",
	}
}
