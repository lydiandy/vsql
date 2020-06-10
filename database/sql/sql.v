module sql

// the first function call for connection
pub fn connect(d Driver,c Config) ?DB {
	dr := d.connect(c) or {
		return error('connect failed:$err')
	}
	db := DB{
		driver: dr
	}
	return db
}

// register the driver,use by driver in module init
pub fn register(name string, driver Driver) {
}

pub struct DB {
	driver       Driver

}

pub fn (db DB) ping() ?string {
	return db.driver.ping()
}

pub fn (db DB) exec(stmt string) ?[]Row {
	return db.driver.exec(stmt)
}

pub fn (db DB) prepare(stmt string) ?Stmt {
	return db.driver.prepare(stmt)
}

pub fn (db DB) begin() ?Tx {
	return db.driver.begin()
}

pub fn (db DB) close() {
	db.driver.close()
}

pub struct Stmt {
pub mut:
	stmt string
}


pub struct Row {
pub mut:
	vals []string
}

pub struct ColumnType {
}

pub struct Tx {
}

pub fn (t Tx) commit() {
}

pub fn (t Tx) rollback() {
}

pub struct TxOption {
}
