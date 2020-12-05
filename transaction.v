module vsql

pub fn (db &DB) transaction() &DB {
	db.exec('begin')
	return db
}

pub fn (db &DB) tx() &DB {
	return db.transaction()
}

pub fn (db &DB) commit() {
	db.exec('commit')
}

pub fn (db &DB) rollback() {
	db.exec('rollback')
}
