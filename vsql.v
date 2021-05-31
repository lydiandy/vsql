module vsql

// TODO:use pg driver as the first version,later support more,need database.sql.Driver interface
import dialect.pg

pub const (
	version = '0.0.1'
)

[heap]
pub struct DB {
pub:
	config Config
	conn   pg.DB // TODO: replace to Driver interface
pub mut:
	stmt Stmt // the current statement
}

pub fn init_driver(c Config) pg.DB {
	config := pg.Config{
		host: c.host
		port: c.port
		user: c.user
		password: c.password
		dbname: c.database
	}
	db := pg.connect(config) or { panic('driver init failed:$err') }
	return db
}

// connect to sql
pub fn connect(c Config) ?DB {
	conn := init_driver(c)
	db := DB{
		config: c
		stmt: Stmt{}
		conn: conn
	}
	return db
}

// execute the sql statement
pub fn (db DB) exec(sql string) []pg.Row {
	res := db.conn.exec(sql) or { panic(err) }
	return res
}

// end of select|insert|update|delete stmt,generate the sql string and exec
// do not use together with to_sql()
pub fn (mut db DB) end() []pg.Row {
	s := db.gen_sql()
	// println(s)
	res := db.exec(s)
	// after exec clear the db.stmt,that do not impact next sql
	db.stmt = Stmt{}
	return res
}

pub fn (db DB) str() string {
	return '{config:$db.config,stmt:$db.stmt}'
}
