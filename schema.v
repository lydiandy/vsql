module vsql

// import database.sql
import dialect.pg


pub type CreateTableFn = fn (Table)

// create database
pub fn (mut db DB) create_database(name string) {
	create_stmt := CreateDatabase{
		db_name: name
	}
	db.stmt = create_stmt
	db.end()
}

// create table
pub fn (mut db DB) create_table(table_name string, create_table_fn CreateTableFn) ?[]pg.Row {
	mut table := Table{
		name: table_name
	}
	create_table_fn(table)
	sql := table.gen()
	res := db.exec(sql)
	return res
}

pub fn (mut db DB) create_table_if_not_exists(table_name string, create_table_fn CreateTableFn) ?[]pg.Row {
	if db.has_table(table_name) {
		println('table $table_name is already exists')
		
	} else {
		return db.create_table(table_name,create_table_fn)
	}
	
}

// alter table
pub fn (mut db DB) alter_table() &DB {
	return db
}

// rename table
// ERROR:  invalid byte sequence for encoding "UTF8": 0xae
pub fn (mut db DB) rename_table(old_name, new_name string) []pg.Row {
	rename_stmt := RenameTable{
		old_name: old_name
		new_name: new_name
	}
	db.stmt = rename_stmt
	return db.end()
}

// drop table
// ERROR:  invalid byte sequence for encoding "UTF8": 0xae
pub fn (mut db DB) drop_table(name string) []pg.Row {
	drop_stmt := DropTable{
		table_name: name
	}
	db.stmt = drop_stmt
	return db.end()
}

pub fn (mut db DB) drop_table_if_exists(name string) {
	if db.has_table(name) {
		db.drop_table(name)
	}
}

// has
// staut:wip
// just pg is ok
pub fn (mut db DB) has_table(name string) bool {
	mut sql := ''
	match db.config.client {
		'pg' {
			sql = "select count(*) from information_schema.tables where table_schema=\'public\' and  table_name =\'$name\'"
		}
		'mysql' {
			// todo
		}
		'sqlite' {
			// todo
		}
		else {
			panic('unknown database client')
		}
	}
	res := db.exec(sql)
	if res[0].vals[0] == '1' {
		return true
	} else {
		return false
	}
}

// staut:wip
// ERROR:  syntax error at or near "and column_name"
pub fn (mut db DB) has_column(table_name, column_name string) bool {
	mut sql := ''
	match db.config.client {
		'pg' {
			sql = "select count(*) from information_schema.columns where table_schema=\'public\' and table_name =\'$table_name\' and column_name=\'$column_name\'"
		}
		'mysql' {
			// todo
		}
		'sqlite' {
			// todo
		}
		else {
			panic('unknown database client')
		}
	}
	res := db.exec(sql)
	println(res)
	if res[0].vals[0] == '1' {
		return true
	} else {
		return false
	}
}

// truncate table
// status:wip
// ERROR:  invalid byte sequence for encoding "UTF8": 0xae
pub fn (mut db DB) truncate(name string) []pg.Row {
	truncate_stmt := Truncate{
		table_name: name
	}
	db.stmt = truncate_stmt
	return db.end()
}
