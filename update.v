module vsql

// insert statement
// status: done
// todo:map[string]string => map[string]interface{}
pub fn (db &DB) insert(data map[string]string) &DB {
	db.stmt.typ = .insert
	db.stmt.data = data
	return db
}

// status:done
pub fn (db &DB) into(name string) &DB {
	db.stmt.table_name = name
	return db
}

// only use for pg,mysql
// status:done
pub fn (db &DB) returning(column string, other_columns ...string) &DB {
	db.stmt.returning << column
	for c in other_columns {
		db.stmt.returning << c
	}
	return db
}

// update statement
// staus:done
pub fn (db &DB) update(data map[string]string) &DB { // TODO:map[string]interface
	db.stmt.typ = .update
	db.stmt.data = data
	return db
}

// staus:wip
pub fn (db &DB) increment(column string) &DB {
	return db
}

// staus:wip
pub fn (db &DB) decrement(column string) &DB {
	return db
}

// delete statement
// staus:done
pub fn (db &DB) delete() &DB {
	db.stmt.typ = .delete
	return db
}
