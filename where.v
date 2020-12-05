module vsql

// where raw
// status: done
pub fn (mut db DB) where_raw(raw string, args ...string) &DB { // TODO: interface type
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
	db.stmt.where << w
	return db
}

// where
//make sure the other(and/or/not) where methods must be after where method
fn (mut db DB) check_where_order(operator string) {
	if operator == '' {
		db.stmt.has_where = true
	}
	if operator != '' && !db.stmt.has_where {
		panic('the other(and/or/not) where methods must be after where method')
	}
}

// status:done
fn (mut db DB) where_type(typ string, operator string, condition string) &DB {
	db.check_where_order(operator)
	w := Where{
		typ: typ
		operator: operator
		condition: condition
	}
	db.stmt.where << w
	return db
}

// status:done
pub fn (mut db DB) where(condition string) &DB {
	return db.where_type('where', '', condition)
}

// status:done
pub fn (mut db DB) or_where(condition string) &DB {
	return db.where_type('where', 'or', condition)
}

// status:done
pub fn (mut db DB) and_where(condition string) &DB {
	return db.where_type('where', 'and', condition)
}

// status:done
pub fn (mut db DB) where_not(condition string) &DB {
	return db.where_type('where', 'and not', condition)
}

// status:done
pub fn (mut db DB) or_where_not(condition string) &DB {
	return db.where_type('where', 'or not', condition)
}

// where in
fn (mut db DB) where_in_type(typ string, operator string, column string, range []string) &DB {
	db.check_where_order(operator)
	w := Where{
		typ: typ
		operator: operator
		column_name: column
		range: range
	}
	db.stmt.where << w
	return db
}

// status:done
pub fn (mut db DB) where_in(column string, range []string) &DB {
	return db.where_in_type('where_in', '', column, range)
}

// status:done
pub fn (mut db DB) or_where_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'or', column, range)
}

// status:done
pub fn (mut db DB) and_where_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'and', column, range)
}

// status:done
pub fn (mut db DB) where_not_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'and not', column, range)
}

// status:done
pub fn (mut db DB) or_where_not_in(column string, range []string) &DB {
	return db.where_in_type('where_in', 'or not', column, range)
}

// where null
fn (mut db DB) where_null_type(typ string, operator string, column string) &DB {
	db.check_where_order(operator)
	w := Where{
		typ: typ
		operator: operator
		column_name: column
	}
	db.stmt.where << w
	return db
}

// status:done
pub fn (mut db DB) where_null(column string) &DB {
	return db.where_null_type('where_null', '', column)
}

// status:done
pub fn (mut db DB) or_where_null(column string) &DB {
	return db.where_null_type('where_null', 'or', column)
}

// status:done
pub fn (mut db DB) and_where_null(column string) &DB {
	return db.where_null_type('where_null', 'and', column)
}

// status:done
pub fn (mut db DB) where_not_null(column string) &DB {
	return db.where_null_type('where_null', 'and not', column)
}

// status:done
pub fn (mut db DB) or_where_not_null(column string) &DB {
	return db.where_null_type('where_null', 'or not', column)
}

// where between
fn (mut db DB) where_between_type(typ string, operator string, column string, range []string) &DB {
	db.check_where_order(operator)
	w := Where{
		typ: typ
		operator: operator
		column_name: column
		range: range
	}
	db.stmt.where << w
	return db
}

// status:done
pub fn (mut db DB) where_between(column string, range []string) &DB {
	return db.where_between_type('where_between', '', column, range)
}

// status:done
pub fn (mut db DB) or_where_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'or', column, range)
}

// status:done
pub fn (mut db DB) and_where_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'and', column, range)
}

// status:done
pub fn (mut db DB) where_not_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'and not', column, range)
}

// status:done
pub fn (mut db DB) or_where_not_between(column string, range []string) &DB {
	return db.where_between_type('where_between', 'or not', column, range)
}

// where exists
// status:done
fn (mut db DB) where_exists_type(typ string, operator string, stmt string) &DB {
	db.check_where_order(operator)
	w := Where{
		typ: typ
		operator: operator
		exist_stmt: stmt
	}
	db.stmt.where << w
	return db
}

// status:done
pub fn (mut db DB) where_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', '', stmt)
}

// status:done
pub fn (mut db DB) or_where_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'or', stmt)
}

// status:done
pub fn (mut db DB) and_where_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'and', stmt)
}

// status:done
pub fn (mut db DB) where_not_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'and not', stmt)
}

// status:done
pub fn (mut db DB) or_where_not_exists(stmt string) &DB {
	return db.where_exists_type('where_exists', 'or not', stmt)
}
