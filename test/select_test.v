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
	db.exec("insert into person (id,name,age,income) values (2,'jack',33,500)")
	db.exec("insert into person (id,name,age,income) values (3,'mary',25,2000)")
	db.exec("insert into person (id,name,age,income) values (4,'lisa',25,1000)")
	// start to test
	mut res := ''
	// select+from
	res = db.select_('*').from('person').to_sql()
	assert res == 'select * from person'
	res = db.select_('*').from('person').to_sql()
	assert res == 'select * from person'
	res = db.select_('id,name,age,income').from('person').to_sql()
	assert res == 'select id,name,age,income from person'
	// table+column
	res = db.table('person').column('*').to_sql()
	assert res == 'select * from person'
	res = db.table('person').column('id,name,age').to_sql()
	assert res == 'select id,name,age from person'
	// table+select is also ok
	res = db.table('person').select_('*').to_sql()
	assert res == 'select * from person'
	// from+column is also ok
	res = db.from('person').column('*').to_sql()
	assert res == 'select * from person'
	// first
	res = db.table('person').column('').first().to_sql()
	assert res == 'select * from person limit 1'
	// limit
	res = db.table('person').column('').limit(3).to_sql()
	assert res == 'select * from person limit 3'
	// offset
	res = db.table('person').column('').offset(1).to_sql()
	assert res == 'select * from person offset 1'
	// offset+limit
	res = db.table('person').column('').offset(2).limit(2).to_sql()
	assert res == 'select * from person offset 2 limit 2'
	// distinct
	res = db.table('person').column('id,name,age').distinct().to_sql()
	assert res == 'select distinct id,name,age from person'
	res = db.select_('id,name,age').distinct().from('person').to_sql()
	assert res == 'select distinct id,name,age from person'
	// order by
	res = db.table('person').column('*').order_by('id desc').to_sql()
	assert res == 'select * from person order by id desc'
	res = db.table('person').column('*').order_by('name desc').order_by('age asc').to_sql()
	assert res == 'select * from person order by name desc,age asc'
	res = db.table('person').column('*').order_by('name desc').order_by('age').to_sql()
	assert res == 'select * from person order by name desc,age asc'
	res = db.table('person').column('').order_by_raw('name desc,age asc').to_sql()
	assert res == 'select * from person order by name desc,age asc'
	// group by
	res = db.table('person').column('age,count(age)').group_by('age').to_sql()
	assert res == 'select age,count(age) from person group by age'
	res = db.table('person').column('age,count(age)').group_by('age').group_by('name').to_sql()
	assert res == 'select age,count(age) from person group by age,name'
	res = db.table('person').column('age,count(age)').group_by_raw('age,name').to_sql()
	assert res == 'select age,count(age) from person group by age,name'
	res = db.table('person').column('age,count(age),avg(income)').group_by('age').to_sql()
	assert res == 'select age,count(age),avg(income) from person group by age'
	// where
	// aggregate function
}
