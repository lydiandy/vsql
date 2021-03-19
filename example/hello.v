// before you run the example,run create_and_init_db.v first
module main

import vsql

fn main() {
	// config to connect db,by now just support pg
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
	
	// start to use db
	res := db.table('person').column('*').end()
	println(res)
}
