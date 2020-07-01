## vsql

inspired by [knex](https://github.com/knex/knex)

- just a query builder,not orm

- easy to learn,easy to use

- support multi-dialect:pg,mysql,sqlite,mssql, by now just pg as the first version

- function call chain 

### main idea

the main idea of vsql is:  **function call chain => ast => sql**

### example

```c
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
	mut db := vsql.connect(config) or {
		panic('connect error:$err')
	}
	// start to use db
	res := db.table('person').column('*').end()
	println(res)
}

```

all the sql statement can be found in test directory

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

```

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

#### group by

```

```



#### join

```

```

#### aggregate function

```

```



### insert

```sql

```



### update

```sql

```



### delete

```sql

```

### schema

#### create table

```

```



#### alter table

```

```



#### drop table

```

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

### other

```sql
to_sql()
print_sql()
print_obj()
```



### todo

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
	//where in select
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

	//union
	db.table('person').select_('id','name','age').union_(fn() {
		db.table('person2').select_('id','name','age')
	}).order_by('id asc')

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

