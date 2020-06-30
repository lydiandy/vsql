module vsql

import dialect.pg

pub const (
	version = '0.0.1'
)

pub struct DB {
pub:
	config Config
	conn   pg.DB // no & can work
mut:
	stmt   Stmt
}

pub fn init_driver(c Config) pg.DB {
	config := pg.Config{
		host: c.host
		port: c.port
		user: c.user
		password: c.password
		dbname: c.database
	}
	db := pg.connect(config) or {
		panic('driver init failed:$err')
	}
	return db
}

// connect to sql
pub fn connect(c Config) ?DB {
	conn := init_driver(c)
	db := &DB{
		config: c
		stmt: Stmt{}
		conn: conn
	}
	return db
}
//
pub fn (db &DB) exec(sql string) []pg.Row {
	res := db.conn.exec(sql) // pg.db.exec()
	return res
}

// end of select/insert/update/delete stmt,generate the sql string and exec
pub fn (db &DB) end() []pg.Row {
	sql := gen(db.stmt)
	res := db.exec(sql)
	return res
}