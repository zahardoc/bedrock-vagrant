class wordpress::db {
	# execution order
#	class { 'wordpress::db_init': } ->
#		class { 'wordpress::db_setup': } ->
#			class { 'wordpress::db_dev_import': }
	notify { 'wordpress::db not defined properly':}
}