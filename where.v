module vsql

// status: done
pub fn (db &DB) where_raw(raw string, args ...string) &DB { //TODO: interface type
	count := raw.count('?')
	times := if count == -1 { 0 } else { count }
	len := args.len
	if times != len {
		panic('the ? count is not match argument count')
	}
	mut condition := raw
	for arg in args {
		condition = condition.replace_once('?', arg)
	}
	w := Where{
		typ: 'where_raw'
		condition: condition
	}
	stmt := db.stmt
	match stmt {
		Select { stmt.where << w }
		Update { stmt.where << w }
		Delete { stmt.where << w }
		else { panic('unknown where clause') }
	}
	return db
}

// ---------------
// status:done
fn (db &DB) where_type(typ, operator, condition string) &DB {
	w := Where{
		typ: typ
		operator: operator
		condition: condition
	}
	stmt := db.stmt
	match stmt {
		Select { stmt.where << w }
		Update { stmt.where << w }
		Delete { stmt.where << w }
		else { panic('unknown where clause') }
	}
	return db
}

// status:done
pub fn (db &DB) where(condition string) &DB {
	return db.where_type('where', '', condition)
}

// status:done
pub fn (db &DB) or_where(condition string) &DB {
	return db.where_type('where', 'or', condition)
}

// status:done
pub fn (db &DB) and_where(condition string) &DB {
	return db.where_type('where', 'and', condition)
}

// status:done
pub fn (db &DB) where_not(condition string) &DB {
	return db.where_type('where', 'and not', condition)
}

// status:done
pub fn (db &DB) or_where_not(condition string) &DB {
	return db.where_type('where', 'or not', condition)
}

// ---------------
fn (db &DB) where_in_type(typ, operator, column string, range []string) &DB {
	w := Where{
		typ: typ
		operator: operator
		column_name: column
		range: range
	}
	stmt := db.stmt
	match stmt {
		Select { stmt.where << w }
		Update { stmt.where << w }
		Delete { stmt.where << w }
		else { panic('unknown where clause') }
	}
	return db
}

// status:done
pub fn (db &DB) where_in(column string, range []string) &DB {
	return db.where_in_type('where_in', '', column, range)
}

// status:done
pub fn (db &DB) or_where_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'or', column, range)
}

// status:done
pub fn (db &DB) and_where_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'and', column, range)
}

// status:done
pub fn (db &DB) where_not_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'and not', column, range)
}

// status:done
pub fn (db &DB) or_where_not_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'or not', column, range)
}

// ---------------
fn (db &DB) where_null_type(typ, operator, column string) &DB {
	w := Where{
		typ: typ
		operator: operator
		column_name: column
	}
	stmt := db.stmt
	match stmt {
		Select { stmt.where << w }
		Update { stmt.where << w }
		Delete { stmt.where << w }
		else { panic('unknown where clause') }
	}
	return db
}

// status:done
pub fn (db &DB) where_null(column string) &DB {
	return db.where_null_type('where_null', '', column)
}

// status:done
pub fn (db &DB) or_where_null(column string) &DB {
	return db.where_null_type('where_null', 'or', column)
}

// status:done
pub fn (db &DB) and_where_null(column string) &DB {
	return db.where_null_type('where_null', 'and', column)
}

// status:done
pub fn (db &DB) where_not_null(column string) &DB {
	return db.where_null_type('where_null', 'and not', column)
}

// status:done
pub fn (db &DB) or_where_not_null(column string) &DB {
	return db.where_null_type('where_null', 'or not', column)
}

// ---------------
fn (db &DB) where_between_type(typ, operator, column string, range []string) &DB {
	w := Where{
		typ: typ
		operator: operator
		column_name: column
		range: range
	}
	stmt := db.stmt
	match stmt {
		Select { stmt.where << w }
		Update { stmt.where << w }
		Delete { stmt.where << w }
		else { panic('unknown where clause') }
	}
	return db
}

// status:done
pub fn (db &DB) where_between(column string, range []string) &DB {
	return db.where_between_type('where_between', '', column, range)
}

// status:done
pub fn (db &DB) or_where_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'or', column, range)
}

// status:done
pub fn (db &DB) and_where_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'and', column, range)
}

// status:done
pub fn (db &DB) where_not_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'and not', column, range)
}

// status:done
pub fn (db &DB) or_where_not_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'or not', column, range)
}

// ---------------
fn (db &DB) where_exists_type(typ, operator, stmt string) &DB {
	w := Where{
		typ: typ
		operator: operator
		exist_stmt: stmt
	}
	s := db.stmt
	match s {
		Select { s.where << w }
		Update { s.where << w }
		Delete { s.where << w }
		else { panic('unknown where clause') }
	}
	return db
}

pub fn (db &DB) where_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', '', stmt)
}

pub fn (db &DB) or_where_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'or', stmt)
}

pub fn (db &DB) and_where_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'and', stmt)
}

pub fn (db &DB) where_not_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'and not', stmt)
}

pub fn (db &DB) or_where_not_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'or not', stmt)
}
