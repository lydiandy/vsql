module vsql

// status:done
pub fn (mut db DB) count(column string) &DB {
	db.add_aggregate_fn('count', column)
	return db
}

// status:done
pub fn (mut db DB) min(column string) &DB {
	db.add_aggregate_fn('min', column)
	return db
}

// status:done
pub fn (mut db DB) max(column string) &DB {
	db.add_aggregate_fn('max', column)
	return db
}

// status:done
pub fn (mut db DB) sum(column string) &DB {
	db.add_aggregate_fn('sum', column)
	return db
}

// status:done
pub fn (mut db DB) avg(column string) &DB {
	db.add_aggregate_fn('avg', column)
	return db
}

fn (mut db DB) add_aggregate_fn(fn_name, column string) {
	s := db.stmt as Select
	mut new_fn := AggregateFn{
		name: fn_name
	}
	if fn_name != 'count' && column.starts_with('*') {
		panic('only count function can use *')
	}
	if fn_name == 'count' && column.starts_with('*') {
		name, alias := split_to_arg(column, 'as')
		new_fn.column_name = name
		new_fn.column_alias = alias
	}
	mut col := ''
	if column.starts_with('distinct ') {
		new_fn.is_distinct = true
		col = column.substr(9, column.len)
	} else {
		col = column
	}
	name, alias := split_to_arg(col, 'as')
	new_fn.column_name = name
	new_fn.column_alias = alias
	s.aggregate_fn << new_fn
}
