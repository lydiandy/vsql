module test

// import vsql
import dialect.pg

fn test_schema() {
	mut db := connect_db()
	// start to test
	mut res := []pg.Row{}
	// create database
	// create table
	// db.create_table('person2', fn (mut table vsql.Table) {
	// // table.increment('id').primary()
	// // table.boolean('is_ok')
	// // table.string_('open_id', 255).size(100).unique()
	// // table.datetime('attend_time')
	// // table.string_('form_id', 255).not_null().reference('person(id)')
	// // table.integer('is_send').default_to('1')
	// // table.decimal('amount', 10, 2).not_null().check('amount>0')
	// // //
	// // table.primary(['id', 'name'])
	// // table.unique(['id', 'name'])
	// // table.check('age>30').check('age<60')
	// // res := table.to_sql()
	// // assert res == ''
	// }) or {
	// panic('create table failed:$err')
	// }
	// alter table
	//
	// rename table
	res = db.rename_table('person', 'new_person')
	println(res)
	// truncate table
	res = db.truncate('person')
	println(res)
	// drop table
	res = db.drop_table('food')
	println(res)
	// drop table if exist
	res = db.drop_table_if_exist('cat')
	println(res)
}
