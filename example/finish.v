// the following sql statements is already finished
module main

import vsql

fn main() {
	config := vsql.Config{
		client: 'pg'
		host: 'localhost'
		port: 5432
		user: 'your user'
		password: 'your password'
		database: 'your db'
	}
	db := vsql.connect(config) or {
		panic('connect error:$err')
	}
	// raw
	db.exec('update person set age=33 where id=1')
	// query
	db.table('person').select_('id,name,age').first().end()
	db.table('person').column('id,name,age').offset(1).limit(3).end()
	db.select_('*').from('person').end()
	db.select_('*').from('person').offset(1).limit(3).end()
	db.select_('age').distinct().from('person').end()
	// where
	db.table('person').where_raw('id=?', 1)
	db.table('person').column('id,name,age').where('id=1').where_not('id=2').where_in('id',
		['1', '3', '5']).where_between('id', ['1', '5']).where_null('age').end()
	//
	db.table('person').column('id,name,age').where('id=1').or_where_not('id=2').or_where_in('id',
		['1', '3', '5']).or_where_between('id', ['1', '5']).or_where_null('age').end()
	//
	db.table('person').column('id,name,age').where('id=1').and_where_not('id=2').and_where_in('id',
		['1', '3', '5']).and_where_between('id', ['1', '5']).and_where_null('age').end()
	//
	db.table('person').column('id,name,age').where('id=1').where_not('id=2').where_not_in('id',
		['1', '3', '5']).where_not_between('id', ['1', '5']).where_not_null('age').end()
	// aggregate function
	db.table('person').count('*').end()
	db.table('person').count('* as cc').end()
	db.table('person').count('distinct name as n').end()
	db.table('person').min('age').end()
	db.table('person').max('age').end()
	db.table('person').min('age as min_age').max('age as max_age').end()
	db.table('person').sum('income').end()
	db.table('person').avg('income').end()
	// order by
	db.table('person').select_('*').order_by('id asc').end()
	db.table('person').select_('*').order_by('id asc').order_by('name desc').end()
	db.table('person').select_('*').order_by_raw('id asc,name desc').end()
	// group by
	db.table('person').select_('count(age)').group_by('age').end()
	db.table('person').select_('count(age)').group_by('age').group_by('name').end()
	db.table('person').select_('count(age)').group_by_raw('age,name').end()
	// having
	db.table('person').select_('age,count(age)').where('age<=30').group_by('age').having('count(*)=2').end()
	// union
	// join
	db.table('cat as c').select_('c.id,c.name,p.name,p.age').join('person as p', 'c.owner_id=p.id').end()
	db.table('cat as c').select_('c.id,c.name,p.name,p.age').inner_join('person as p',
		'c.owner_id=p.id').end()
	db.table('cat as c').select_('c.id,c.name,p.name,p.age').left_join('person as p',
		'c.owner_id=p.id').end()
	db.table('cat as c').select_('c.id,c.name,p.name,p.age').right_join('person as p',
		'c.owner_id=p.id').end()
	db.table('cat as c').select_('c.id,c.name,p.name,p.age').outer_join('person as p',
		'c.owner_id=p.id').end()
	db.table('cat as c').select_('c.id,c.name,p.name,p.age').cross_join('person as p').end()
	db.table('cat as c').select_('c.id,c.name,p.name,p.age').join_raw('join person as p on c.owner_id=p.id').end()
	db.table('cat as c').select_('c.id,c.name,p.name,p.age,f.name').left_join('person as p',
		'c.owner_id=p.id').left_join('food as f', 'c.id=f.cat_id').end()
	// insert
	db.table('person').insert({
		'name': 'abc'
		'id': '255'
		'age': '36'
	}).end()
	db.table('person').insert({
		'name': 'abc'
		'id': '255'
		'age': '36'
	}).returning('id', 'name').end()
	db.insert({
		'name': 'tom'
		'id': '12'
	}).into('person').returning('id').end()
	// update
	db.table('person').update({
		'name': 'paris'
	}).where('id=1').returning('id').end()
	db.table('person').update({
		'name': 'paris'
		'age': '32'
	}).where('id=1').returning('id').end()
	// delete
	db.table('person').delete().where('id=3').end()
	db.table('person').where('id=2').delete().end()
	// schema
	// create database
	// create table
	db.create_table('person3', fn (table vsql.Table) {
		table.increment('id').primary()
		table.boolean('is_ok')
		table.string_('open_id', 255).size(100).unique()
		table.datetime('attend_time')
		table.string_('form_id', 255).not_null().reference('person(id)')
		table.integer('is_send').default_to('1')
		table.decimal('amount', 10, 2).not_null().check('amount>0')
		//
		table.primary(['id', 'name'])
		table.unique(['id', 'name'])
		table.check('age>30').check('age<60')
		table.to_sql()
	})
	// alter table
	// other table operation
	// transaction
	t := db.transaction()
	// t := db.tx() //the shorter fn
	t.exec('insert into uu (id) values (1)')
	t.exec('insert into uu (id) values (2)')
	t.exec('insert into uu (id) values (3)')
	// t.rollback()
	t.commit()
	// other
	db.table('person').avg('income').to_sql()
	db.table('person').avg('income').to_obj()
	db.table('person').avg('income').to_sql().to_obj().end()
}
