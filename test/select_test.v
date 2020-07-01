import vsql

fn test_select() {
	config := vsql.Config{
		client: 'pg'
		host: 'localhost'
		port: 5432
		user: 'postgres'
		password: ''
		database: 'test_db'
	}
	mut db := vsql.connect(config) or {
		panic('connect error:$err')
	}
	mut res := ''
	res = db.select_('*').from('person').to_sql()
	assert res == 'select  * from person '
	res = db.select_('*').from('person').to_sql()
	assert res == 'select  * from person '
}
