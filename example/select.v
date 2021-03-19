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

	// select+from
	res = db.select_('*').from('person').end()
	res = db.select_('id,name,age,income').from('person').end()

	// table+column
	res = db.table('person').column('*').end()
	res = db.table('person').column('id,name,age').end()

	// table+select is also ok
	res = db.table('person').select_('*').end()

	// from+column is also ok
	res = db.from('person').column('*').end()

	// first
	res = db.table('person').column('*').first().end()

	// limit
	res = db.table('person').column('*').limit(3).end()

	// offset
	res = db.table('person').column('*').offset(1).end()

	// offset+limit
	res = db.table('person').column('*').offset(2).limit(2).end()

	// distinct
	res = db.table('person').column('id,name,age').distinct().end()
	res = db.select_('id,name,age').distinct().from('person').end()

	// order by
	res = db.table('person').column('*').order_by('id desc').end()
	res = db.table('person').column('*').order_by('name desc').order_by('age asc').end()
	res = db.table('person').column('*').order_by('name desc').order_by('age').end()
	res = db.table('person').column('').order_by_raw('name desc,age asc').end()

	// group by
	res = db.table('person').column('age,count(age)').group_by('age').end()
	res = db.table('person').column('age,count(age)').group_by('age').group_by('name').end()
	res = db.table('person').column('age,count(age)').group_by_raw('age,income').end()
	res = db.table('person').column('age,count(age),avg(income)').group_by('age').end()

	// having
	res = db.table('person').column('age,count(age),avg(income)').group_by('age').having('count(*)=2').end()

	// where raw
	res = db.table('person').where_raw('id=?', '1').end()

	// where
	res = db.table('person').column('id,name,age').where('id=1').end()

	// or where
	res = db.table('person').column('id,name,age').where('id=1').or_where('id=2').end()

	// and where
	res = db.table('person').column('id,name,age').where('id=1').and_where('age=29').end()

	// where not
	res = db.table('person').column('id,name,age').where('id=1').where_not('age=0').end()

	// or where not
	res = db.table('person').column('id,name,age').where('id=1').or_where_not('age=0').end()

	// where in
	res = db.table('person').column('id,name,age').where_in('id', ['1', '2', '3']).end()

	// or where in
	res = db.table('person').column('id,name,age').where('id=1').or_where_in('id', ['1', '2', '3']).end()

	// and where in
	res = db.table('person').column('id,name,age').where('id=1').and_where_in('id', ['1', '2',
		'3',
	]).end()

	// where not in
	res = db.table('person').column('id,name,age').where('id=1').where_not_in('id', ['2', '3']).end()

	// or where not in
	res = db.table('person').column('id,name,age').where('id=1').or_where_not_in('id',
		['2', '3']).end()

	// where null
	res = db.table('person').column('id,name,age').where('id>1').where_null('income').end()

	// or where null
	res = db.table('person').column('id,name,age').where('id>1').or_where_null('income').end()

	// and where null
	res = db.table('person').column('id,name,age').where('id>1').and_where_null('income').end()

	// where not null
	res = db.table('person').column('id,name,age').where('id>1').where_not_null('income').end()

	// or where not null
	res = db.table('person').column('id,name,age').where('id>1').or_where_not_null('income').end()

	// where between
	res = db.table('person').column('id,name,age,income').where('id>1').where_between('income',
		['100', '1000']).end()

	// or where between
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_between('income',
		['100', '1000']).end()

	// and where between
	res = db.table('person').column('id,name,age,income').where('id>1').and_where_between('income',
		['100', '1000']).end()

	// where not between
	res = db.table('person').column('id,name,age,income').where('id>1').where_not_between('income',
		['100', '1000']).end()

	// or where not between
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_not_between('income',
		['100', '1000']).end()

	// where exists
	res = db.table('person').column('id,name,age,income').where('id>1').where_exists('select income from person where income>1000').end()

	// or where exists
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_exists('select income from person where income>1000').end()

	// and where exists
	res = db.table('person').column('id,name,age,income').where('id>1').and_where_exists('select income from person where income>1000').end()

	// where not exists
	res = db.table('person').column('id,name,age,income').where('id>1').where_not_exists('select income from person where income>1000').end()

	// or where not exists
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_not_exists('select income from person where income>1000').end()

	// aggregate function
	res = db.table('person').count('*').end()
	res = db.table('person').count('* as rows').end()
	res = db.table('person').count('distinct name as n').end()
	res = db.table('person').min('age').end()
	res = db.table('person').max('age').end()
	res = db.table('person').min('age as min_age').max('age as max_age').end()
	res = db.table('person').sum('income').end()
	res = db.table('person').avg('income').end()

	// union statement
	stmt1 := db.table('person').column('id,name').where('id=1').to_sql()
	stmt2 := db.table('person').column('id,name').where('id=2').to_sql()
	stmt3 := db.table('person').column('id,name').where('id=3').to_sql()
	res = db.table('person').column('id,name').where('id=4').union_(stmt1, stmt2, stmt3).end()
	res = db.table('person').column('id,name').where('id=4').union_all(stmt1, stmt2, stmt3).end()
	res = db.table('person').column('id,name').where('id=4').intersect(stmt1, stmt2, stmt3).end()
	res = db.table('person').column('id,name').where('id=4').except(stmt1, stmt2, stmt3).end()

	// join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').join('person as p',
		'c.owner_id=p.id').end()

	// inner join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').inner_join('person as p',
		'c.owner_id=p.id').end()

	// left join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').left_join('person as p',
		'c.owner_id=p.id').end()

	// right join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').right_join('person as p',
		'c.owner_id=p.id').end()

	// outer join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').outer_join('person as p',
		'c.owner_id=p.id').end()

	// cross join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').cross_join('person as p').end()
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').join_raw('join person as p on c.owner_id=p.id').end()

	// multi join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age,f.name').left_join('person as p',
		'c.owner_id=p.id').left_join('food as f', 'c.id=f.cat_id').end()
}
