module vsql

// status:done
pub fn (mut db DB) join(table, join_condition string) &DB {
	return db.join_typ('join', table, join_condition)
}
// status:done
pub fn (mut db DB) inner_join(table, join_condition string) &DB {
	return db.join_typ('inner join', table, join_condition)
}

// status:done
pub fn (mut db DB) left_join(table, join_condition string) &DB {
	return db.join_typ('left join', table, join_condition)
}

// status:done
// pub fn (mut db DB) left_outer_join(table, join_condition string) &DB {
// return db.join_typ('left outer join',table,join_condition)
// }

// status:done
pub fn (mut db DB) right_join(table, join_condition string) &DB {
	return db.join_typ('right join', table, join_condition)
}
// status:done
// pub fn (mut db DB) right_outer_join(table, join_condition string) &DB {
// return db.join_typ('rigth outer join',table,join_condition)
// }

// status:done
pub fn (mut db DB) outer_join(table, join_condition string) &DB {
	return db.join_typ('full outer join', table, join_condition)
}
// status:done
// pub fn (mut db DB) full_outer_join(table, join_condition string) &DB {
// return db.join_typ('full outer  join',table,join_condition)
// }

// status:done
// Cross join only supported in MySQL and SQLite3
pub fn (mut db DB) cross_join(table string) &DB {
	return db.join_typ('cross join', table, '')
}

// status:done
pub fn (mut db DB) join_raw(raw string) &DB {
	mut s := db.stmt as Select
	s.join_raw = raw
	return db
}


fn (mut db DB) join_typ(typ, table, join_condition string) &DB {
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
