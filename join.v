module vsql

// status:done
pub fn (mut db DB) join(table string, join_condition string) &DB {
	return db.join_type('join', table, join_condition)
}

// status:done
pub fn (mut db DB) inner_join(table string, join_condition string) &DB {
	return db.join_type('inner join', table, join_condition)
}

// status:done
pub fn (mut db DB) left_join(table string, join_condition string) &DB {
	return db.join_type('left join', table, join_condition)
}

// status:done
pub fn (mut db DB) right_join(table string, join_condition string) &DB {
	return db.join_type('right join', table, join_condition)
}

// status:done
pub fn (mut db DB) outer_join(table string, join_condition string) &DB {
	return db.join_type('full outer join', table, join_condition)
}

// status:done
// Cross join only supported in MySQL and SQLite3
pub fn (mut db DB) cross_join(table string) &DB {
	return db.join_type('cross join', table, '')
}

// status:done
pub fn (mut db DB) join_raw(raw string) &DB {
	db.stmt.join_raw = raw
	return &db
}

// status:done
fn (mut db DB) join_type(typ string, table string, join_condition string) &DB {
	name, alias := split_by_separator(table, 'as')
	db.stmt.join << Join{
		typ: typ
		table_name: name
		table_alias: alias
		join_condition: join_condition
	}
	return &db
}
