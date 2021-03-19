// before you run the example,run create_and_init_db.v first
module main

import vsql
import dialect.pg

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
	mut res := []pg.Row{}

	// create database
	res = db.create_database('mydb')
	println(res)

	// create table
	mut table := db.create_table('person2')
	// table.increment('id').primary()
	table.increment('id')
	table.boolean('is_ok')
	table.string_('open_id', 255).size(100).unique()
	table.datetime('attend_time')
	table.string_('form_id', 255).not_null()
	table.integer('is_send').default_to('1')
	table.decimal('amount', 10, 2).not_null().check('amount>0')
	// table constraint
	table.primary(['id'])
	table.unique(['id'])
	table.check('amount>30')
	table.check('amount<60')

	table.exec()

	// alter table

	// rename table
	res = db.rename_table('person', 'new_person')
	println(res)

	// truncate table
	res = db.truncate('new_person')
	println(res)

	// drop table
	res = db.drop_table('food')
	println(res)

	// drop table if exist
	res = db.drop_table_if_exist('cat')
	println(res)
}
