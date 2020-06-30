module vsql

// TODO:use pg driver as the first version,later support more,need database.sql.Driver interface
import dialect.pg

pub const (
	version = '0.0.1'
)

pub struct DB {
pub:
	config Config
	conn   pg.DB //TODO: replace to Driver interface
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

// execute the sql statement
pub fn (db &DB) exec(sql string) []pg.Row {
	res := db.conn.exec(sql)
	return res
}

// end of select|insert|update|delete stmt,generate the sql string and exec
pub fn (db &DB) end() []pg.Row {
	s := gen(db.stmt)
	res := db.exec(s)
	return res
}
