module vsql

// insert statement
// status: done
// todo:map[string]string => map[string]interface{}
pub fn (mut db DB) insert(data map[string]string) &DB {
	db.stmt.typ = .insert
	db.stmt.data = data.clone()
	return db
}

// status:done
pub fn (mut db DB) into(name string) &DB {
	db.stmt.table_name = name
	return db
}

// only use for pg,mysql
// status:done
pub fn (mut db DB) returning(column string, other_columns ...string) &DB {
	db.stmt.returning << column
	for c in other_columns {
		db.stmt.returning << c
	}
	return db
}

// update statement
// staus:done
pub fn (mut db DB) update(data map[string]string) &DB { // TODO:map[string]interface
	db.stmt.typ = .update
	db.stmt.data = data.clone()
	return db
}

// staus:wip
pub fn (mut db DB) increment(column string) &DB {
	return db
}

// staus:wip
pub fn (mut db DB) decrement(column string) &DB {
	return db
}

// delete statement
// staus:done
pub fn (mut db DB) delete() &DB {
	db.stmt.typ = .delete
	return db
}
