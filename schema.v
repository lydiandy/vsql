module vsql

// import database.sql
import dialect.pg

pub type CreateTableFn = fn (mut tablemut  Table)

// create database
// status:done
pub fn (mut db DB) create_database(name string) []pg.Row {
	db.stmt.typ = .create_database
	db.stmt.db_name = name
	return db.end()
}

// create table
// status:done
pub fn (mut db DB) create_table(table_name string, create_table_fn CreateTableFn) []pg.Row {
	mut table := Table{
		name: table_name
	}
	create_table_fn(mut table)
	s := table.gen_table_sql()
	res := db.exec(s)
	return res
}

// create table if not exists
// status:done
pub fn (mut db DB) create_table_if_not_exist(table_name string, create_table_fn CreateTableFn) []pg.Row {
	if db.has_table(table_name) {
		println('table $table_name is already exists')
	} else {
		return db.create_table(table_name, create_table_fn)
	}
	return []pg.Row{}
}

// alter table
// status: wip
pub fn (mut db DB) alter_table() &DB {
	return &db
}

// rename table
// status:done
pub fn (mut db DB) rename_table(old_name, new_name string) []pg.Row {
	db.stmt.typ = .rename_table
	db.stmt.table_name = old_name
	db.stmt.new_table_name = new_name
	return db.end()
}

// drop table
// status:done
pub fn (mut db DB) drop_table(name string) []pg.Row {
	db.stmt.typ = .drop_table
	db.stmt.table_name = name
	return db.end()
}

// drop table
// status:done
pub fn (mut db DB) drop_table_if_exist(name string) []pg.Row {
	if db.has_table(name) {
		return db.drop_table(name)
	}
	return []pg.Row{}
}

// has
// staut:wip
// only pg is ok
pub fn (mut db DB) has_table(name string) bool {
	mut s := ''
	match db.config.client {
		'pg' {
			s = "select count(*) from information_schema.tables where table_schema=\'public\' and  table_name =\'$name\'"
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
	res := db.exec(s)
	if res[0].vals[0] == '1' {
		return true
	} else {
		return false
	}
}

// staut:wip
// ERROR:  syntax error at or near "and column_name"
pub fn (mut db DB) has_column(table_name, column_name string) bool {
	mut s := ''
	match db.config.client {
		'pg' {
			s = "select count(*) from information_schema.columns where (table_schema=\'public\') and (table_name ='$table_name') and (column_name='$column_name')"
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
	// println(s)
	res := db.exec(s)
	// println(res)
	if res[0].vals[0] == '1' {
		return true
	} else {
		return false
	}
}

// truncate table
// status:done
pub fn (mut db DB) truncate(name string) []pg.Row {
	db.stmt.typ = .truncate_table
	db.stmt.table_name = name
	return db.end()
}
