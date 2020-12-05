module vsql

// print sql string for debug
pub fn (mut db DB) print_sql() &DB {
	s := db.gen_sql()
	println(s)
	return db
}

// print sql to object struct for debug
pub fn (mut db DB) print_obj() &DB {
	println(db.stmt)
	return db
}

// generate sql string for debug
// do not use together with end()
pub fn (mut db DB) to_sql() string {
	s := db.gen_sql()
	// after to_sql clear the db.stmt,that do not impact next sql
	db.stmt = Stmt{}
	return s
}

// ----------
// create table print sql string for debug
pub fn (t &Table) print_sql() &Table {
	s := t.gen_table_sql()
	println(s)
	return t
}

// create table print sql to object struct for debug
pub fn (t &Table) print_obj() &Table {
	println(t)
	return t
}

// create table generate sql string for debug
pub fn (t &Table) to_sql() string {
	s := t.gen_table_sql()
	return s
}

// debug mode
pub fn (mut db DB) debug() {
}

// timeout,only mysql pg
pub fn (mut db DB) timeout(during int) {
}
