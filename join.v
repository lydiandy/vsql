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
// pub fn (db &DB) left_outer_join(table, join_condition string) &DB {
// return db.join_type('left outer join',table,join_condition)
// }
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
	mut s := db.stmt as Select
	s.join_raw = raw
	return db
}

// status:done
fn (db &DB) join_type(typ, table, join_condition string) &DB {
	mut s := db.stmt as Select
	name, alias := split_to_arg(table, 'as')
	s.join << Join{
		typ: typ
		table_name: name
		table_alias: alias
		join_condition: join_condition
	}
	return db
}
