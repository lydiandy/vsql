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
	// connect to database with config
	mut db := vsql.connect(config) or {
		panic('connect error:$err')
	}
	// create table
	db.exec('drop table if exists person')
	db.exec("create table person (id integer primary key, name text default '',age integer default 0,income integer default 0);")
	// insert data
	db.exec("insert into person (id,name,age,income) values (1,'tom',29,1000)")
	db.exec("insert into person (id,name,age,income) values (2,'jack',33,0)")
	db.exec("insert into person (id,name,age,income) values (3,'mary',25,2000)")
	db.exec("insert into person (id,name,age,income) values (4,'lisa',25,0)")
	// start to test
	mut res := ''
	res = db.select_('*').from('person').to_sql()
	assert res == 'select * from person '
	res = db.select_('*').from('person').to_sql()
	assert res == 'select * from person '
	res = db.select_('id,name,age,income').from('person').to_sql()
	assert res == 'select id ,name ,age ,income from person '
}
