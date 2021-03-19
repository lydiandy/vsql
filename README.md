## vsql

**vsql is just wip,do not use in production,but it can works now**

- just a sql query builder,not orm

- easy to learn,easy to use

- support multi-dialect:pg,mysql,sqlite,mssql, by now just pg as the first version

- method call chain 

### main idea

the main idea of vsql is:  **method call chain => ast => sql**

### some limit

here are some limits,maybe need to find better solution,advice is welcome~

- select is a key word of vlang,so have to use select_
- in query statement,at the end of every method call chain need end() to know the end of chain and start generate sql. Is it possible to remove it?
- by now,there is no database interface for driver like go,not easy to support multi-dialect

### example

create table first:

```v
module main

import vsql

fn main() {
	config := vsql.Config{
		client: 'pg'
		host: 'localhost'
		port: 5432
		user: 'postgres' // change to your user
		password: '' // chagne to your password
		database: 'test_db' // change to your database
	}
	// connect to database with config
	mut db := vsql.connect(config) or { panic('connect error:$err') }
	// create table person
	db.exec('drop table if exists person')
	db.exec("create table person (id integer primary key, name text default '',age integer default 0,income integer default 0);")
	// insert data
	db.exec("insert into person (id,name,age,income) values (1,'tom',29,1000)")
	db.exec("insert into person (id,name,age,income) values (2,'jack',33,500)")
	db.exec("insert into person (id,name,age,income) values (3,'mary',25,2000)")
	db.exec("insert into person (id,name,age,income) values (4,'lisa',25,1000)")
	db.exec("insert into person (id,name,age,income) values (5,'andy',18,0)")
	// create table cat
	db.exec('drop table if exists cat')
	db.exec("create table cat (id integer primary key,name text default '',owner_id integer)")
	// insert data
	db.exec("insert into cat (id,name,owner_id) values (1,'cat1',1)")
	db.exec("insert into cat (id,name,owner_id) values (2,'cat2',3)")
	db.exec("insert into cat (id,name,owner_id) values (3,'cat3',5)")
	// create table food
	db.exec('drop table if exists food')
	db.exec("create table food (id integer primary key,name text default '',cat_id integer)")
	// insert data
	db.exec("insert into food (id,name,cat_id) values (1,'food1',1)")
	db.exec("insert into food (id,name,cat_id) values (2,'food2',3)")
	db.exec("insert into food (id,name,cat_id) values (3,'food3',0)")
	// for test create table,drop person2
	db.exec('drop table if exists person2')
	db.exec('drop table if exists new_person')
}
```

```v
module main

import vsql

fn main() {
	// config to connect db,by now just support pg
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
	// start to use db
	res := db.table('person').column('*').end()
	println(res)
}
```

all the sql statement can be found in example or test directory

### select

#### table+column

```sql
res := db.table('person').column('*').end()
select * from person

res := db.table('person').column('id,name,age').end()
select id,name,age from person
```

#### select+from

select is key word of v,so use select_

```sql
res :=db.select_('*').from('person').end()
select * from person

res :=db.select_('id,name,age,income').from('person').end()
select * from person
```

#### where

```sql
//where
res := db.table('person').column('id,name,age').where('id=1').end()
select id,name,age from person where (id=1)

// or where
res:= db.table('person').column('id,name,age').where('id=1').or_where('id=2').end()
select id,name,age from person where (id=1) or (id=2)

// and where
res:= db.table('person').column('id,name,age').where('id=1').and_where('age=29').end()
select id,name,age from person where (id=1) and (age=29)

// where not
res:= db.table('person').column('id,name,age').where('id=1').where_not('age=0').end()
select id,name,age from person where (id=1) and not (age=0)

// or where not
res:= db.table('person').column('id,name,age').where('id=1').or_where_not('age=0').end()
select id,name,age from person where (id=1) or not (age=0)
```

where in

```sql
//where in
res := db.table('person').column('id,name,age').where_in('id', ['1', '2', '3']).end()
select id,name,age from person where (id in (1,2,3))

// or where in
res := db.table('person').column('id,name,age').where('id=1').or_where_in('id', ['1', '2', '3']).end()
select id,name,age from person where (id=1) or (id in (1,2,3))

// and where in
res := db.table('person').column('id,name,age').where('id=1').and_where_in('id', ['1', '2', '3']).end()
select id,name,age from person where (id=1) and (id in (1,2,3))

// where not in
res := db.table('person').column('id,name,age').where('id=1').where_not_in('id', ['2', '3']).end()
select id,name,age from person where (id=1) and not (id in (2,3))

// or where not in
res := db.table('person').column('id,name,age').where('id=1').or_where_not_in('id', ['2', '3']).end()
select id,name,age from person where (id=1) or not (id in (2,3))
```

where null

```sql
//where null
res := db.table('person').column('id,name,age').where('id>1').where_null('income).end()
select id,name,age from person where (id>1) and (income is null)
                                                                         
//or where null
res := db.table('person').column('id,name,age').where('id>1').or_where_null('income').end()
select id,name,age from person where (id>1) or (income is null)
                                                                         
//and where null
res := db.table('person').column('id,name,age').where('id>1').and_where_null('income').end()
select id,name,age from person where (id>1) and (income is null)
                                                                         
//where not null
res := db.table('person').column('id,name,age').where('id>1').where_not_null('income').end()
select id,name,age from person where (id>1) and not (income is null)
                                                                         
//or where not null
res := db.table('person').column('id,name,age').where('id>1').or_where_not_null('income').end()
select id,name,age from person where (id>1) or not (income is null)
```

where between

```sql
//where between
res := db.table('person').column('id,name,age,income').where('id>1').where_between('income',['100','1000']).end()
select id,name,age,income from person where (id>1) and (income between 100 and 1000)

//or where between
res := db.table('person').column('id,name,age,income').where('id>1').or_where_between('income',['100','1000']).end()
select id,name,age,income from person where (id>1) or (income between 100 and 1000)

//and where between
res := db.table('person').column('id,name,age,income').where('id>1').and_where_between('income',['100','1000']).end()
select id,name,age,income from person where (id>1) and (income between 100 and 1000)

//where not between
res := db.table('person').column('id,name,age,income').where('id>1').where_not_between('income',['100','1000']).end()
select id,name,age,income from person where (id>1) and not (income between 100 and 1000)

//or where not between
res := db.table('person').column('id,name,age,income').where('id>1').or_where_not_between('income',['100','1000']).end()
select id,name,age,income from person where (id>1) or not (income between 100 and 1000)
```

where exists

```sql
//where exists
res := db.table('person').column('id,name,age,income').where('id>1').where_exists('select income from person where income>1000').end()
select id,name,age,income from person where (id>1) and exists (select income from person where income>1000)

//or where exists
res := db.table('person').column('id,name,age,income').where('id>1').or_where_exists('select income from person where income>1000').end()
select id,name,age,income from person where (id>1) or exists (select income from person where income>1000)

//and where exists
res := db.table('person').column('id,name,age,income').where('id>1').and_where_exists('select income from person where income>1000').end()
select id,name,age,income from person where (id>1) and exists (select income from person where income>1000)

//where not exists
res := db.table('person').column('id,name,age,income').where('id>1').where_not_exists('select income from person where income>1000').end()
select id,name,age,income from person where (id>1) and not exists (select income from person where income>1000)

//or where not exists
res := db.table('person').column('id,name,age,income').where('id>1').or_where_not_exists('select income from person where income>1000').end()
select id,name,age,income from person where (id>1) or not exists (select income from person where income>1000)
```

where raw

```sql
res := db.table('person').where_raw('id=?', '1').end()
select * from person where id=1
```

#### first/offset/limit

```sql
// first
res := db.table('person').column('').first().end()
select * from person limit 1
// limit
res := db.table('person').column('').limit(3).end()
select * from person limit 3
// offset
res := db.table('person').column('').offset(1).end()
select * from person offset 1
// offset+limit
res := db.table('person').column('').offset(2).limit(2).end()
elect * from person offset 2 limit 2
```

#### distinct

```sql
res := db.table('person').column('id,name,age').distinct().end()
select distinct id,name,age from person
```

#### order by

```sql
res := db.table('person').column('*').order_by('name desc').order_by('age').end()
select * from person order by name desc,age asc

res := db.table('person').column('').order_by_raw('name desc,age asc').end()
select * from person order by name desc,age asc
```

#### group by/having

```sql
res := db.table('person').column('age,count(age)').group_by('age').group_by('name').end()
select age,count(age) from person group by age,name
res := db.table('person').column('age,count(age)').group_by_raw('age,income').end()
select age,count(age) from person group by age,income
//having
res = db.table('person').column('age,count(age),avg(income)').group_by('age').having('count(*)=2').end()
select age,count(age),avg(income) from person group by age having count(*)=2
```

#### join

```sql
//inner join
res := db.table('cat as c').column('c.id,c.name,p.name,p.age').inner_join('person as p','c.owner_id=p.id').end()
		
select c.id,c.name,p.name,p.age from cat as c inner join person as p on c.owner_id=p.id'

// left join
res := db.table('cat as c').column('c.id,c.name,p.name,p.age').left_join('person as p','c.owner_id=p.id').end()
select c.id,c.name,p.name,p.age from cat as c left join person as p on c.owner_id=p.id

// right join
res := db.table('cat as c').column('c.id,c.name,p.name,p.age').right_join('person as p','c.owner_id=p.id').end()
select c.id,c.name,p.name,p.age from cat as c right join person as p on c.owner_id=p.id

// outer join
res := db.table('cat as c').column('c.id,c.name,p.name,p.age').outer_join('person as p','c.owner_id=p.id').end()
select c.id,c.name,p.name,p.age from cat as c full outer join person as p on c.owner_id=p.id

// cross join
res := db.table('cat as c').column('c.id,c.name,p.name,p.age').cross_join('person as p').end()
select c.id,c.name,p.name,p.age from cat as c cross join person as p

// join raw
res := db.table('cat as c').column('c.id,c.name,p.name,p.age').join_raw('join person as p on c.owner_id=p.id').end()
select c.id,c.name,p.name,p.age from cat as c join person as p on c.owner_id=p.id

// multi join
res := db.table('cat as c').column('c.id,c.name,p.name,p.age,f.name').left_join('person as p','c.owner_id=p.id').left_join('food as f', 'c.id=f.cat_id').end()
select c.id,c.name,p.name,p.age,f.name from cat as c left join person as p on c.owner_id=p.id left join food as f on c.id=f.cat_id
```

#### aggregate function

```sql
res := db.table('person').count('*').end()
select count(*) from person

res := db.table('person').count('* as rows').end()
select count(*) as rows from person

res := db.table('person').count('distinct name as n').end()
select distinct count(name) as n from person

res := db.table('person').min('age').end()
select min(age) from person

res := db.table('person').max('age').end()
select max(age) from person

res := db.table('person').min('age as min_age').max('age as max_age').end()
select min(age) as min_age,max(age) as max_age from person

res := db.table('person').sum('income').end()
select sum(income) from person

res := db.table('person').avg('income').end()
select avg(income) from person
```

#### union

union is a key word of v,so use union_()

```sql
stmt1 := db.table('person').column('id,name').where('id=1').to_sql()
stmt2 := db.table('person').column('id,name').where('id=2').to_sql()
stmt3 := db.table('person').column('id,name').where('id=3').to_sql()
res = db.table('person').column('id,name').where('id=4').union_(stmt1, stmt2, stmt3).end()
res = db.table('person').column('id,name').where('id=4').union_all(stmt1, stmt2, stmt3).end()
res = db.table('person').column('id,name').where('id=4').intersect(stmt1, stmt2, stmt3).end()
res = db.table('person').column('id,name').where('id=4').except(stmt1, stmt2, stmt3).end()
```

### insert

```sql
res := db.table('person').insert({
		'id': '255'
		'name': 'abc'
		'age': '36'
	}).end()
insert into person (id,name,age) values ('255','abc','36')

res := db.table('person').insert({
		'id': '255'
		'name': 'abc'
		'age': '36'
	}).returning('id', 'name').end()
insert into person (id,name,age) values ('255','abc','36') returning id,name

res := db.insert({
		'id': '12'
		'name': 'tom'
	}).into('person').returning('id').end()
insert into person (id,name) values ('12','tom') returning id
```

### update

```sql
res := db.table('person').update({
		'name': 'paris'
	}).where('id=1').returning('id').end()
update person set name='paris' where (id=1) returning id

res := db.table('person').update({
		'name': 'paris'
		'age': '32'
	}).where('id=1').returning('id').end()
update person set name='paris',age='32' where (id=1) returning id
```

### delete

```sql
res := db.table('person').delete().where('id=3').end()
delete from person where (id=3)

res := db.table('person').where('id=2').delete().end()
delete from person where (id=2)
```

### schema

#### create table

```v
// create table
mut table := db.create_table('person2') 

//create column
//table.increment('id').primary()
table.increment('id')          
table.boolean('is_ok')
//string is a key word of v, so use string_
table.string_('open_id', 255).size(100).unique()
table.datetime('attend_time')
table.string_('form_id', 255).not_null() 
table.integer('is_send').default_to('1')
table.decimal('amount', 10, 2).not_null().check('amount>0')
//table constraint
table.primary(['id'])
table.unique(['id'])
table.check('amount>30')
table.check('amount<60')

//exec create table sql
table.exec()
```

#### alter table

```sql
res := db.rename_table('person', 'new_person')
```

#### drop table

```sql
res := db.drop_table('food')
```

### transaction

```c
t := db.transaction()
// t := db.tx() //the shorter fn
t.exec("insert into person (id,name,age,income) values (33,'name33',33,0)")
t.exec("insert into person (id,name,age,income) values (44,'name44',44,0)")
t.exec("insert into person (id,name,age,income) values (55,'name55',55,0)")
// t.rollback()
t.commit()
```

### raw sql

```sql
db.exec('drop table if exists person')
db.exec("create table person (id integer primary key, name text default '',age integer default 0,income integer default 0);")

db.exec("insert into person (id,name,age,income) values (1,'tom',29,1000)")
db.exec("insert into person (id,name,age,income) values (2,'jack',33,500)")
db.exec("insert into person (id,name,age,income) values (3,'mary',25,2000)")
db.exec("insert into person (id,name,age,income) values (4,'lisa',25,1000)")
db.exec("insert into person (id,name,age,income) values (5,'andy',18,0)")

db.exec('drop table if exists cat')
db.exec("create table cat (id integer primary key,name text default '',owner_id integer)")
```

### other

**print_sql**

If you need to print the sql string,you can use print_sql() before end().

```sql
db.table('person').column('id,name,age').where('id=1').print_sql().end()
```

```sql
select id,name,age from person where (id=1)
```

**print_obj**

If you need to print the object struct of sql,you can you print_obj() before end().

```sql
db.table('person').column('id,name,age').where('id=1').print_obj().end()
```

```
vsql.Select {
    table_name: 'person'
    table_alias: ''
    is_distinct: false
    columns: [vsql.Column {
    name: 'id'
    alias: ''
}, vsql.Column {
    name: 'name'
    alias: ''
}, vsql.Column {
    name: 'age'
    alias: ''
}]
    where: [vsql.Where {
    typ: 'where'
    operator: ''
    condition: 'id=1'
    column_name: ''
    range: []
    exist_stmt: ''
}]
    join: []
    join_raw: ''
    first: false
    limit: 0
    offset: 0
    order_by: []
    order_by_raw: ''
    group_by: []
    group_by_raw: ''
    having: ''
    aggregate_fn: []
    timeout: 0
}
```

**to_sql**

to_sql() is used to test. It will not execute the sql,just generate the sql string.

```c
res := db.table('person').column('*').to_sql()
assert res == 'select * from person'
res := db.table('person').column('id,name,age').to_sql()
assert res == 'select id,name,age from person'
```

###  todo

```c
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

	//select
res:=db.table('person').column('id,name,age').where('id',3).to(&person).end()

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

```

### run vsql test

all the test sql statement are in vsql/test, you can run the test by:

```shell
v test vsql/test
```



## Acknowledgments

Inspired by [knex](https://github.com/knex/knex) that  was my favorite sql query builder before I meet V.

## License

Licensed under [MIT](license)