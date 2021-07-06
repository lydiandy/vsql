module main

import vsql

fn main() {
	config := vsql.Config{
		client: 'pg'
		host: 'localhost'
		port: 5432
		user: 'postgres' // change to your user
		password: '' // change to your password
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
