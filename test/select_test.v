module test

fn test_select() {
	mut db := connect_and_init_db()
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
	res = db.table('person').column(' ').first().to_sql()
	assert res == 'select * from person limit 1'

	// limit
	res = db.table('person').column('').limit(3).to_sql()
	assert res == 'select * from person limit 3'

	// offset
	res = db.table('person').column('   ').offset(1).to_sql()
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
	res = db.table('person').where_raw('id=?', '1').to_sql()
	assert res == 'select * from person where id=1'

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

	// where in
	res = db.table('person').column('id,name,age').where_in('id', ['1', '2', '3']).to_sql()
	assert res == 'select id,name,age from person where (id in (1,2,3))'

	// or where in
	res = db.table('person').column('id,name,age').where('id=1').or_where_in('id', ['1', '2', '3']).to_sql()
	assert res == 'select id,name,age from person where (id=1) or (id in (1,2,3))'

	// and where in
	res = db.table('person').column('id,name,age').where('id=1').and_where_in('id', ['1', '2',
		'3',
	]).to_sql()
	assert res == 'select id,name,age from person where (id=1) and (id in (1,2,3))'

	// where not in
	res = db.table('person').column('id,name,age').where('id=1').where_not_in('id', ['2', '3']).to_sql()
	assert res == 'select id,name,age from person where (id=1) and not (id in (2,3))'

	// or where not in
	res = db.table('person').column('id,name,age').where('id=1').or_where_not_in('id',
		['2', '3']).to_sql()
	assert res == 'select id,name,age from person where (id=1) or not (id in (2,3))'

	// where null
	res = db.table('person').column('id,name,age').where('id>1').where_null('income').to_sql()
	assert res == 'select id,name,age from person where (id>1) and (income is null)'

	// or where null
	res = db.table('person').column('id,name,age').where('id>1').or_where_null('income').to_sql()
	assert res == 'select id,name,age from person where (id>1) or (income is null)'

	// and where null
	res = db.table('person').column('id,name,age').where('id>1').and_where_null('income').to_sql()
	assert res == 'select id,name,age from person where (id>1) and (income is null)'

	// where not null
	res = db.table('person').column('id,name,age').where('id>1').where_not_null('income').to_sql()
	assert res == 'select id,name,age from person where (id>1) and not (income is null)'

	// or where not null
	res = db.table('person').column('id,name,age').where('id>1').or_where_not_null('income').to_sql()
	assert res == 'select id,name,age from person where (id>1) or not (income is null)'

	// where between
	res = db.table('person').column('id,name,age,income').where('id>1').where_between('income',
		['100', '1000']).to_sql()
	assert res == 'select id,name,age,income from person where (id>1) and (income between 100 and 1000)'

	// or where between
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_between('income',
		['100', '1000']).to_sql()
	assert res == 'select id,name,age,income from person where (id>1) or (income between 100 and 1000)'

	// and where between
	res = db.table('person').column('id,name,age,income').where('id>1').and_where_between('income',
		['100', '1000']).to_sql()
	assert res == 'select id,name,age,income from person where (id>1) and (income between 100 and 1000)'

	// where not between
	res = db.table('person').column('id,name,age,income').where('id>1').where_not_between('income',
		['100', '1000']).to_sql()
	assert res == 'select id,name,age,income from person where (id>1) and not (income between 100 and 1000)'

	// or where not between
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_not_between('income',
		['100', '1000']).to_sql()
	assert res == 'select id,name,age,income from person where (id>1) or not (income between 100 and 1000)'

	// where exists
	res = db.table('person').column('id,name,age,income').where('id>1').where_exists('select income from person where income>1000').to_sql()
	assert res == 'select id,name,age,income from person where (id>1) and exists (select income from person where income>1000)'

	// or where exists
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_exists('select income from person where income>1000').to_sql()
	assert res == 'select id,name,age,income from person where (id>1) or exists (select income from person where income>1000)'

	// and where exists
	res = db.table('person').column('id,name,age,income').where('id>1').and_where_exists('select income from person where income>1000').to_sql()
	assert res == 'select id,name,age,income from person where (id>1) and exists (select income from person where income>1000)'

	// where not exists
	res = db.table('person').column('id,name,age,income').where('id>1').where_not_exists('select income from person where income>1000').to_sql()
	assert res == 'select id,name,age,income from person where (id>1) and not exists (select income from person where income>1000)'

	// or where not exists
	res = db.table('person').column('id,name,age,income').where('id>1').or_where_not_exists('select income from person where income>1000').to_sql()
	assert res == 'select id,name,age,income from person where (id>1) or not exists (select income from person where income>1000)'

	// different where order
	res = db.table('person').column('id,name,age,income').where_between('income', ['100', '1000']).where('id>1').to_sql()
	assert res == 'select id,name,age,income from person where (income between 100 and 1000) and (id>1)'
	res = db.table('person').column('id,name,age,income').where_exists('select income from person where income>1000').and_where('id>1').to_sql()
	assert res == 'select id,name,age,income from person where exists (select income from person where income>1000) and (id>1)'
	res = db.table('person').column('id,name,age,income').where_in('id', ['1', '2', '3']).or_where('id>1').to_sql()
	assert res == 'select id,name,age,income from person where (id in (1,2,3)) or (id>1)'

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

	// union statement
	stmt1 := db.table('person').column('id,name').where('id=1').to_sql()
	stmt2 := db.table('person').column('id,name').where('id=2').to_sql()
	stmt3 := db.table('person').column('id,name').where('id=3').to_sql()

	// union
	res = db.table('person').column('id,name').where('id=4').union_(stmt1, stmt2, stmt3).to_sql()
	assert res == 'select id,name from person where (id=4) union select id,name from person where (id=1) union select id,name from person where (id=2) union select id,name from person where (id=3)'

	// union all
	res = db.table('person').column('id,name').where('id=4').union_all(stmt1, stmt2, stmt3).to_sql()
	assert res == 'select id,name from person where (id=4) union all select id,name from person where (id=1) union all select id,name from person where (id=2) union all select id,name from person where (id=3)'

	// intersect
	res = db.table('person').column('id,name').where('id=4').intersect(stmt1, stmt2, stmt3).to_sql()
	assert res == 'select id,name from person where (id=4) intersect select id,name from person where (id=1) intersect select id,name from person where (id=2) intersect select id,name from person where (id=3)'

	// except
	res = db.table('person').column('id,name').where('id=4').except(stmt1, stmt2, stmt3).to_sql()
	assert res == 'select id,name from person where (id=4) except select id,name from person where (id=1) except select id,name from person where (id=2) except select id,name from person where (id=3)'

	// join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c join person as p on c.owner_id=p.id'

	// inner join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').inner_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c inner join person as p on c.owner_id=p.id'

	// left join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').left_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c left join person as p on c.owner_id=p.id'

	// right join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').right_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c right join person as p on c.owner_id=p.id'

	// outer join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').outer_join('person as p',
		'c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c full outer join person as p on c.owner_id=p.id'

	// cross join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').cross_join('person as p').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c cross join person as p'

	// join raw
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age').join_raw('join person as p on c.owner_id=p.id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age from cat as c join person as p on c.owner_id=p.id'

	// multi join
	res = db.table('cat as c').column('c.id,c.name,p.name,p.age,f.name').left_join('person as p',
		'c.owner_id=p.id').left_join('food as f', 'c.id=f.cat_id').to_sql()
	assert res == 'select c.id,c.name,p.name,p.age,f.name from cat as c left join person as p on c.owner_id=p.id left join food as f on c.id=f.cat_id'
}

fn test_other_select() {
	mut db := connect_and_init_db()
	mut res := ''
	res = db.table('person as p').to_sql()
	assert res == 'select * from person as p'
	res = db.table('person as p').column('id,name as name2,age as age2').to_sql()
	assert res == 'select id,name as name2,age as age2 from person as p'
}
