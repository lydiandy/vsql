// before you run the example,run create_and_init_db.v first
module main

import vsql

fn main() {
	config := vsql.Config{
		client: 'pg'
		host: 'localhost'
		port: 5432
		user: 'postgres'
		password: ''
		database: 'test_db'
	}

	// connect to database with config
	mut db := vsql.connect(config) or { panic('connect error:$err') }

	t := db.transaction()
	// t := db.tx() //the shorter fn
	t.exec("insert into person (id,name,age,income) values (33,'name33',33,0)")
	t.exec("insert into person (id,name,age,income) values (44,'name44',44,0)")
	t.exec("insert into person (id,name,age,income) values (55,'name55',55,0)")
	// t.rollback()
	t.commit()
}
