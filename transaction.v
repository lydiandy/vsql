module vsql

pub fn (mut db DB) transaction() &DB {
	db.exec('begin')
	return db
}

pub fn (mut db DB) tx() &DB {
	return db.transaction()
}

pub fn (mut db DB) commit() {
	db.exec('commit')
}

pub fn (mut db DB) rollback() {
	db.exec('rollback')
}
