module test

import dialect.pg

fn test_schema() {
	mut db := connect_and_init_db()
	mut res := []pg.Row{}

	// create database
	// res = db.create_database('mydb')

	// create table
	mut table := db.create_table('person2')
	table.increment('id').primary()
	table.string_('open_id', 255).size(100).unique()
	table.boolean('is_ok')
	table.datetime('attend_time')
	table.string_('form_id', 255).not_null()
	table.integer('is_send').default_to('1')
	table.decimal('amount', 10, 2).not_null().check('amount>0')
	// table constraint
	// table.primary(['id'])
	table.unique(['id'])
	table.check('amount>30')
	table.check('amount<60')

	result := table.to_sql()
	expert := "create table person2 (
id serial primary key,
open_id varchar(255) unique,
is_ok boolean,
attend_time timestamp,
form_id varchar(255) not null,
is_send integer default '1',
amount decimal(10,2) not null check (amount>0),

unique (id),
check (amount>30),
check (amount<60)
);"
	assert result == expert

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
