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

import vsql

fn main() {
	config := vsql.Config{
		client: 'pg'
		host: 'localhost'
		port: 5432	
		user: 'postgres'
		password: ''
		database: 'dev_db'
		pool: {min:2,max:10}
		timeout: 60000
		debug: true
	}
	db := vsql.connect(config) or {
		panic('connect wrong')
	}

	//select_
	res:=db.table('person as u').select_('id,name,age').where('id',3).end() //must need end?
	res:=db.table('person').select_('id,name as name2,age as age2').where('id',3).end() //must need end?
	res:=db.table('person').column('id,name,age').where('id',3).to(&person).end()
	res:=db.table('person').select_('id,name,age').where('id',1).first().end()
	res:=db.table('person').select_('id,name,age').where('id',1).limit(10).offset(20).end()
	res:=db.select_('*').from('person').where('id',3).end() //optional
	res:=db.select_('id,name').from('person').where('id',3).end() //optional
	res:=db.from('person').select_('id,name').where('id',3).end() 
	res:=db.table('person').or_where('id',1).and_where('id','<1').end()
	res:=db.table('t_balance').column('id,name').first().where('sourceId','33').end() 
	res:=db.table('t_balance').first('*').where('sourceId','33').end() //todo
	res:=db.table('person as tc').select_('name','id as personId','age as age2').where_not('tc.status',-1).order_by('tc.pinyin').end()
	//where in select_
	db.table('person').select_('*').where('id',1)
	db.table('person').select_('*').where({id:1,name:'tom'})
	db.table('person').select_('*').where('name','like','t*')
	db.table('person').select_('*').where('age','>',20)
	db.table('person').select_('*').where('age>20')

	db.table('person').select_('*').where_not('age','>',20)
	db.table('person').select_('*').or_where_not('age','>',20)

	db.table('person').select_('*').where_in('age',[10,12,15])
	db.table('person').select_('*').or_where_in('age',[10,12,15])
	db.table('person').select_('*').where_not_in('age',[10,12,15])
	db.table('person').select_('*').or_where_not_in('age',[10,12,15])

	db.table('person').select_('*').where_exists(fn() {})
	db.table('person').select_('*').or_where_exists(fn() {})
	db.table('person').select_('*').where_not_exists(fn() {})
	db.table('person').select_('*').orwhere_not_exists(fn() {})

	db.table('person').select_('*').where('name','like','t*').or_where('id',1).or_where()
	db.table('person').select_('*').where('age','>',20).and_where('id',1)

	db.table('person').select_('*').where_null('id')
	db.table('person').select_('*').or_where_null('id')
	db.table('person').select_('*').where_not_null('id')
	db.table('person').select_('*').or_where_not_null('id')

	db.table('person').select_('*').where_between('votes', [1, 100])
	db.table('person').select_('*').or_where_between('votes', [1, 100])
	db.table('person').select_('*').and_where_between('votes', [1, 100])
	db.table('person').select_('*').where_not_between('votes', [1, 100])
	db.table('person').select_('*').or_where_not_between('votes', [1, 100])
	db.table('person').select_('*').and_where_not_between('votes', [1, 100])

	db.table('person').select_('*').where_raw('id = ?', [1])
	db.table('person').select_('*').or_where_raw('id = ?', [1])

	//where in update 
	db.table('person').update({'name':'jack'}).where('id',1).returning('id').end()
	//where in delete
	db.table('person').delete().where('id',3).end()

	//orderby,groupby,having
	db.table('person').select_('age','count(age)').where('age<=30').order_by('income desc,age asc').group_by('age').having('count(*)=2')

	//union
	db.table('person').select_('id','name','age').union_(fn() {
		db.table('person2').select_('id','name','age')
	}).order_by('id asc')


	//table join
	res:= db.table('t_leader as tl')
			.select_('tl.id','tl.phone','tl.status','tc.name as personName','tu2.name as creatorName')
			.where('tl.id','33')
			.left_join('person as tc','tc.id=tl.personId')
			.right_join('person as tu','tu.id=tl.auditor')
			.right_outer_join('person as tu2','tu2.id>tl.creator')
			.end()

	//aggregate function
	res:=db.table('person').count('*').end()
	res:=db.table('person').count('* as cc').end()
	res:=db.table('person').count('distinct name as n').end()
	// res:=db.table('person').count({age: 'a',income:'i'}).end() //todo
	res:=db.table('person').min('age').end()
	res:=db.table('person').where('id','>','3').min('age').end()
	res:=db.table('person').min('age as min_age').max('age as max_age').end()
	res:=db.table('person').sum('income').end()
	res:=db.table('person').avg('income').end()
	// res:=db.table('person').min('age as a','income as i').end() //todo
	// res:=db.table('person').min({age:'a',imcome:'i'}).end() //todo

	//insert
	res:=db.table('person').insert({name:'xxx',id:123}).returning('id').end()
	res:=db.table('person').insert([{name:'xxx',id:123},{name:'abc',id:222}]).returning('id').end()
	res:=db.insert(data).into('person').returning('id') //optional

	//update
	res:=db.table('person').update({'name':'paris'}).where('id',personId).returning('id').end()
	res:=db.table('person').update('name','Paris').where('id',personId).returning('id').end()
	//update increment/decrement
	res:=db.table('person').where('age','>','40').increment('amount',100).end()
	res:=db.table('person').where('age','>','40').increment({amount:100,age:1}).end()
	res:=db.table('person').where('age','>','40').decrement('amount',100).end()
	
	//delete
	db.table('person').delete().where('id',3).end()
	db.table('person').where('id',3).delete().end()

	//shcema ddl
	db.create_database('person') //optional

	db.create_table_if_not_exists('person',fn(table Table) {
		table.increment('id')
		table.uuid('leader_id').primary().index()
		table.str('open_id').size(255).uinique()
		table.datetime('attend_time').nullable()
		table.str('form_id').not_nullable()
		table.integer('is_send').default(1)
		table.decimal('amount').size(10,2).comment('field comment')
	}) or {
		panic('wrong')
	}
	db.create_table('person',fn(t Table) {
		t.increment('id')
		t.uuid('leader_id').primary().index()
		t.str('open_id').size(255).uinique()
		t.datetime('attend_time').nullable()

	})

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

	db.rename_table('old','new')


	db.has_table('name')
	db.has_column('table','column')


	db.table('person').create_index('form_id','asc')

	db.drop_table('person')
	db.drop_table_if_exists('person')


	// raw
	db.query('select_ * from person where id=?',1)
	db.exec('delete from person where id=?',1)

	//transaction
	//way one 
	t:=db.transaction()

	t.table('person')....
	t.table('person')....

	t.commit() //or
	t.rollback()

	//way two
	db.transaction(fn(t Transaction) {
		db.table('person')...
		db.table('person')...
		t.rollback()
	})


	//other
	db.table('person').truncate()
	db.to_sql() 
	db.to_str()

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

//model migration
db.up()
db.down()


