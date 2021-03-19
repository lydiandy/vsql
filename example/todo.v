//the following sql statement is still wip,need todo
module main

//sql interface
import database.sql

//use std driver
import database.pg
import database.mysql
import database.sqlite
import database.mssql
//or use driver in dialect
import vsql.dialect.pg
import vsql.dialect.mysql
import vsql.dialect.sqlite
import vsql.dialect.mssql

fn main() {
	//result to variable
	db.table('person').column('id,name,age').where('id',3).to(&person).end()
	
	//shcema ddl
	db.alter_table('person',fn(t Table) {
		t.drop_column('form_id')
		t.drop_columns('form_id','is_send')
		t.drop_index('form_id')
		t.drop_foreign('form_id')
		t.drop_unique('form_id')
		t.drop_primary('form_id')
		t.drop_column('name')
		t.rename_column('old','new')
		t.str('new_column')
	})

	//transaction

	//way two
	db.transaction(fn(t Transaction) {
		db.table('person')...
		db.table('person')...
		t.rollback()
	})
	
	//model migration
	db.up()
	db.down()
}

//model
// [db:person]
pub struct person {
	id          int 			[json:id,db:id]
	uuid        string			[json:uuid,db:'name:=uuid;size=100;uinique;primary_key']
	open_id     string			[json:open_id,db:open_id]
	attend_time time.datetime	[json:atten_time,db:attend_time]
	form_id     string			[json:form_id,db:form_id]
	is_send     int   			[json:is_send,db:is_send]
}
pub fn (u person)table_name() string {
	return 'person'
}




