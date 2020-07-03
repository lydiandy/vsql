module vsql

// status:done
pub fn (db &DB) join(table, join_condition string) &DB {
	return db.join_type('join', table, join_condition)
}

// status:done
pub fn (db &DB) inner_join(table, join_condition string) &DB {
	return db.join_type('inner join', table, join_condition)
}

// status:done
pub fn (db &DB) left_join(table, join_condition string) &DB {
	return db.join_type('left join', table, join_condition)
}

// status:done
pub fn (db &DB) right_join(table, join_condition string) &DB {
	return db.join_type('right join', table, join_condition)
}

// status:done
pub fn (db &DB) outer_join(table, join_condition string) &DB {
	return db.join_type('full outer join', table, join_condition)
}

// status:done
// Cross join only supported in MySQL and SQLite3
pub fn (db &DB) cross_join(table string) &DB {
	return db.join_type('cross join', table, '')
}

// status:done
pub fn (db &DB) join_raw(raw string) &DB {
	db.stmt.join_raw = raw
	return db
}

// status:done
fn (db &DB) join_type(typ, table, join_condition string) &DB {
	name, alias := split_by_separator(table, 'as')
	db.stmt.join << Join{
		typ: typ
		table_name: name
		table_alias: alias
		join_condition: join_condition
	}
	return db
}
