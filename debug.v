module vsql

// generate sql to object struct for debug
pub fn (db &DB) to_obj() &DB {
	stmt := db.stmt
	match stmt {
		Select { println(stmt) }
		Insert { println(stmt) }
		Update { println(stmt) }
		Delete { println(stmt) }
		else { println('unknown struct') }
	}
	return db
}

// generate to sql string for debug
pub fn (db &DB) to_sql() &DB {
	s := gen(db.stmt)
	println(s)
	return db
}

pub fn (db &DB) debug() {
}

// timeout,only mysql pg
pub fn (db &DB) timeout(during int) {
}
