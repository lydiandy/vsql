module vsql

// status:done
// aggregate fn count
pub fn (mut db DB) count(column string) &DB {
	db.add_aggregate_fn('count', column)
	return db
}

// status:done
// aggregate fn min
pub fn (mut db DB) min(column string) &DB {
	db.add_aggregate_fn('min', column)
	return db
}

// status:done
// aggregate fn max
pub fn (mut db DB) max(column string) &DB {
	db.add_aggregate_fn('max', column)
	return db
}

// status:done
// aggregate fn sum
pub fn (mut db DB) sum(column string) &DB {
	db.add_aggregate_fn('sum', column)
	return db
}

// status:done
// aggregate fn avg
pub fn (mut db DB) avg(column string) &DB {
	db.add_aggregate_fn('avg', column)
	return db
}

// status:done
fn (mut db DB) add_aggregate_fn(fn_name string, column string) {
	db.stmt.columns = []Column{}
	mut new_fn := AggregateFn{
		name: fn_name
	}
	if fn_name != 'count' && column.starts_with('*') {
		panic('only count function can use *')
	}
	if fn_name == 'count' && column.starts_with('*') {
		name, alias := split_by_separator(column, 'as')
		new_fn.column_name = name
		new_fn.column_alias = alias
	} else {
		mut col := ''
		if column.starts_with('distinct ') {
			new_fn.is_distinct = true
			col = column.substr(9, column.len)
		} else {
			col = column
		}
		name, alias := split_by_separator(col, 'as')
		new_fn.column_name = name
		new_fn.column_alias = alias
	}
	db.stmt.aggregate_fn << new_fn
}
