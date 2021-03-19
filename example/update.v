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

	// insert
	res = db.table('person').insert(map{
		'id':   '6'
		'name': 'abc'
		'age':  '36'
	}).end()
	res = db.table('person').insert(map{
		'id':   '7'
		'name': 'abc'
		'age':  '36'
	}).returning('id', 'name').end()
	res = db.insert(map{
		'id':   '8'
		'name': 'tom'
	}).into('person').returning('id').end()

	// update
	res = db.table('person').update(map{
		'name': 'paris'
	}).where('id=1').returning('id').end()
	res = db.table('person').update(map{
		'name': 'paris'
		'age':  '32'
	}).where('id=1').returning('id').end()

	// delete
	res = db.table('person').delete().where('id=3').end()

	res = db.table('person').where('id=2').delete().end()

	// res = db.create_database('mydb')
	// create table
	// db.create_table('person2', fn (mut table vsql.Table) {
	// table.increment('id').primary()
	// table.boolean('is_ok')
	// table.string_('open_id', 255).size(100).unique()
	// table.datetime('attend_time')
	// table.string_('form_id', 255).not_null().reference('person(id)')
	// table.integer('is_send').default_to('1')
	// table.decimal('amount', 10, 2).not_null().check('amount>0')
	// //
	// table.primary(['id', 'name'])
	// table.unique(['id', 'name'])
	// table.check('age>30').check('age<60')
	// result := table.end()
	// assert result == ''
	// }) or {
	// panic('create table failed:$err')
	// }

	// rename table
	res = db.rename_table('person', 'new_person')

	// truncate table
	res = db.truncate('new_person')

	// drop table
	res = db.drop_table('food')

	// drop table if exist
	res = db.drop_table_if_exist('cat')
}
