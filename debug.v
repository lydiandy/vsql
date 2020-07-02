module vsql

// print sql to object struct for debug
pub fn (db &DB) print_obj() &DB {
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

// print sql string for debug
pub fn (db &DB) print_sql() &DB {
	s := gen(db.stmt)
	println(s)
	return db
}

// generate sql string for debug
//do not use together with end()
pub fn (db &DB) to_sql() string {
	s := gen(db.stmt)
	// after to_sql clear the db.stmt,that do not impact next sql
	db.stmt = Select{}
	return s
}

// debug mode
pub fn (db &DB) debug() {
}

// timeout,only mysql pg
pub fn (db &DB) timeout(during int) {
}
