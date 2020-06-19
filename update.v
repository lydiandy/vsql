module vsql

// insert statement
// status: done
// todo:map[string]string => map[string]interface{}
pub fn (mut db DB) insert(data map[string]string) &DB {
	mut insert_stmt := Insert{}
	if db.stmt is Select {
		insert_stmt.table_name = (db.stmt as Select).table_name
	}
	for key, val in data {
		insert_stmt.keys << key
		insert_stmt.vals << val
	}
	db.stmt = insert_stmt
	return db
}

// status:done
pub fn (mut db DB) into(name string) &DB {
	s := db.stmt as Insert
	s.table_name = name
	return db
}

// status:done
pub fn (mut db DB) returning(column string, other_columns ...string) &DB {
	stmt := db.stmt
	match stmt {
		Insert {
			stmt.returning << column
			for c in other_columns {
				stmt.returning << c
			}
		}
		Update {
			stmt.returning << column
			for c in other_columns {
				stmt.returning << c
			}
		}
		else {}
	}
	return db
}

// update statement
// staus:done
pub fn (mut db DB) update(data map[string]string) &DB {
	mut update_stmt := Update{
		table_name: (db.stmt as Select).table_name
		data: data
	}
	db.stmt = update_stmt
	return db
}

pub fn (mut db DB) increment(column string) &DB {
	return db
}

pub fn (mut db DB) decrement(column string) &DB {
	return db
}

// delete statement
// staus:done
pub fn (mut db DB) delete() &DB {
	delete_stmt := Delete{
		table_name: (db.stmt as Select).table_name
		where: (db.stmt as Select).where
	}
	db.stmt = delete_stmt
	return db
}
