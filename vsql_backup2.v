module vsql

// import database.sql

// pub struct DB {
// pub:
// 	client string
// 	conn sql.DB // no & can work
// mut:
// 	stmt Stmt
// }

// // connect to sql
// pub fn connect(d sql.Driver,c sql.Config) ?DB {
// 	conn := sql.connect(d,c) or {
// 		panic('database connect failed:$err')
// 	}
// 	db := &DB{
// 		client:c.driver_name()
// 		conn: conn
// 		stmt: Stmt{}
// 	}
// 	return db
// }

// //
// pub fn (db &DB) exec(sql string) []sql.Row {
// 	res := db.conn.exec(sql) or {
// 		panic('exec failed:$err')
// 	}
// 	return res
// }

// // end of select/insert/update/delete stmt,generate the sql string and exec
// pub fn (db &DB) end() []sql.Row {
// 	sql := gen(db.stmt)
// 	res := db.exec(sql)
// 	return res
// }
