module test

fn test_select() {
	db := connect_and_init_db()
	mut res := ''
	// select+from
	res = db.select_('*').from('person').to_sql()
	assert res == 'select * from person'
	res = db.select_('id,name,age,income').from('person').to_sql()
	assert res == 'select id,name,age,income from person'
	// table+column
	res = db.table('person').column('*').to_sql()
	assert res == 'select * from person'
	res = db.table('person').column('id,name,age').to_sql()
	assert res == 'select id,name,age from person'
	// table+select is also ok
	res = db.table('person').select_('*').to_sql()
	assert res == 'select * from person'
	// from+column is also ok
	res = db.from('person').column('*').to_sql()
	assert res == 'select * from person'
	// first
	res = db.table('person').column('').first().to_sql()
	assert res == 'select * from person limit 1'
	// limit
	res = db.table('person').column('').limit(3).to_sql()
	assert res == 'select * from person limit 3'
	// offset
	res = db.table('person').column('').offset(1).to_sql()
	assert res == 'select * from person offset 1'
	// offset+limit
	res = db.table('person').column('').offset(2).limit(2).to_sql()
	assert res == 'select * from person offset 2 limit 2'
	// distinct
	res = db.table('person').column('id,name,age').distinct().to_sql()
	assert res == 'select distinct id,name,age from person'
	res = db.select_('id,name,age').distinct().from('person').to_sql()
	assert res == 'select distinct id,name,age from person'
	// order by
	res = db.table('person').column('*').order_by('id desc').to_sql()
	assert res == 'select * from person order by id desc'
	res = db.table('person').column('*').order_by('name desc').order_by('age asc').to_sql()
	assert res == 'select * from person order by name desc,age asc'
	res = db.table('person').column('*').order_by('name desc').order_by('age').to_sql()
	assert res == 'select * from person order by name desc,age asc'
	res = db.table('person').column('').order_by_raw('name desc,age asc').to_sql()
	assert res == 'select * from person order by name desc,age asc'
	// group by
	res = db.table('person').column('age,count(age)').group_by('age').to_sql()
	assert res == 'select age,count(age) from person group by age'
	res = db.table('person').column('age,count(age)').group_by('age').group_by('name').to_sql()
	assert res == 'select age,count(age) from person group by age,name'
	res = db.table('person').column('age,count(age)').group_by_raw('age,income').to_sql()
	assert res == 'select age,count(age) from person group by age,income'
	res = db.table('person').column('age,count(age),avg(income)').group_by('age').to_sql()
	assert res == 'select age,count(age),avg(income) from person group by age'
	// having
	res = db.table('person').column('age,count(age),avg(income)').group_by('age').having('count(*)=2').to_sql()
	assert res == 'select age,count(age),avg(income) from person group by age having count(*)=2'
	// where raw
	// res = db.table('person').where_raw('id=?', 1).to_sql()
	// assert res == 'select * from person where id=1'
	// where
	res = db.table('person').column('id,name,age').where('id=1').to_sql()
	assert res == 'select id,name,age from person where (id=1)'
	// or where
	res = db.table('person').column('id,name,age').where('id=1').or_where('id=2').to_sql()
	assert res == 'select id,name,age from person where (id=1) or (id=2)'
	// and where
	res = db.table('person').column('id,name,age').where('id=1').and_where('age=29').to_sql()
	assert res == 'select id,name,age from person where (id=1) and (age=29)'
	// where not
	res = db.table('person').column('id,name,age').where('id=1').where_not('age=0').to_sql()
	assert res == 'select id,name,age from person where (id=1) and not (age=0)'
	// or where not
	res = db.table('person').column('id,name,age').where('id=1').or_where_not('age=0').to_sql()
	assert res == 'select id,name,age from person where (id=1) or not (age=0)'
	//
	// aggregate function
	res = db.table('person').count('*').to_sql()
	assert res == 'select count(*) from person'
	res = db.table('person').count('* as rows').to_sql()
	assert res == 'select count(*) as rows from person'
	res = db.table('person').count('distinct name as n').to_sql()
	assert res == 'select distinct count(name) as n from person'
	res = db.table('person').min('age').to_sql()
	assert res == 'select min(age) from person'
	res = db.table('person').max('age').to_sql()
	assert res == 'select max(age) from person'
	res = db.table('person').min('age as min_age').max('age as max_age').to_sql()
	assert res == 'select min(age) as min_age,max(age) as max_age from person'
	res = db.table('person').sum('income').to_sql()
	assert res == 'select sum(income) from person'
	res = db.table('person').avg('income').to_sql()
	assert res == 'select avg(income) from person'
	// join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c join person as p on c.owner_id=p.id'
	// inner join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').inner_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res ==
		'select c.id,c.name,p.name,p.age from cat as c inner join person as p on c.owner_id=p.id'
	// left join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').left_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res ==
		'select c.id,c.name,p.name,p.age from cat as c left join person as p on c.owner_id=p.id'
	// right join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').right_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res ==
		'select c.id,c.name,p.name,p.age from cat as c right join person as p on c.owner_id=p.id'
	// outer join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').outer_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res ==
		'select c.id,c.name,p.name,p.age from cat as c full outer join person as p on c.owner_id=p.id'
	// cross join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').cross_join('person as p').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c cross join person as p'
	// join raw
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').join_raw('join person as p on c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c join person as p on c.owner_id=p.id'
	// multi join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age,f.name').left_join('person as p',
		'c.owner_id=p.id').left_join('food as f', 'c.id=f.cat_id').to_sql()
	assert res ==
		'select c.id,c.name,p.name,p.age,f.name from cat as c left join person as p on c.owner_id=p.id left join food as f on c.id=f.cat_id'
}
