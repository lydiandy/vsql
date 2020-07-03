module vsql

// status:done
// aggregate fn count
pub fn (db &DB) count(column string) &DB {
	db.add_aggregate_fn('count', column)
	return db
}

// status:done
// aggregate fn min
pub fn (db &DB) min(column string) &DB {
	db.add_aggregate_fn('min', column)
	return db
}

// status:done
// aggregate fn max
pub fn (db &DB) max(column string) &DB {
	db.add_aggregate_fn('max', column)
	return db
}

// status:done
// aggregate fn sum
pub fn (db &DB) sum(column string) &DB {
	db.add_aggregate_fn('sum', column)
	return db
}

// status:done
// aggregate fn avg
pub fn (db &DB) avg(column string) &DB {
	db.add_aggregate_fn('avg', column)
	return db
}

// status:done
fn (db &DB) add_aggregate_fn(fn_name, column string) {
	s := db.stmt as Select
	s.columns = []Column{}
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
	s.aggregate_fn << new_fn
}
