module vsql
// output for debug
//generate to object struct
pub fn (db &DB) to_obj() &DB {
	match db.stmt {
		Select { println(it) }
		Insert { println(it) }
		Update { println(it) }
		Delete { println(it) }
		else { println('unknown struct') }
	}
	println('')
	return db
}
//generate to sql string
pub fn (db &DB) to_sql() &DB {
	sql := gen(db.stmt)
	println(sql)
	println('')
	return db
}

pub fn (db &DB) debug() {
}

// timeout,only mysql pg
pub fn (db &DB) timeout(during int) {
}
