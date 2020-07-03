module vsql

pub type CallbackFn = fn ()

// the same with from()
// status:done
pub fn (db &DB) table(name string) &DB {
	table_name, table_alias := split_to_arg(name, 'as')
	mut select_stmt := Select{
		table_name: table_name
		table_alias: table_alias
	}
	if db.stmt is Select {
		select_stmt.columns = (db.stmt as Select).columns
		select_stmt.is_distinct = (db.stmt as Select).is_distinct
	}
	db.stmt = select_stmt
	return db
}

// status:done
pub fn (db &DB) from(name string) &DB {
	return db.table(name)
}

// status:done
pub fn (db &DB) select_(columns string) &DB {
	mut select_stmt := Select{}
	if db.stmt is Select {
		select_stmt.table_name = (db.stmt as Select).table_name
		select_stmt.table_alias = (db.stmt as Select).table_alias
	}
	if columns in [' ', '*'] {
		select_stmt.columns = []Column{}
	} else {
		column_array := columns.split(',')
		mut name := ''
		mut alias := ''
		for col in column_array {
			name, alias = split_to_arg(col, 'as')
			select_stmt.columns << Column{
				name: name
				alias: alias
			}
		}
	}
	db.stmt = select_stmt
	return db
}

// TODO
// pub fn (mut db DB) column(columns ...string) &DB {}
//
// the same with select_()
// status:done
pub fn (db &DB) column(columns string) &DB {
	return db.select_(columns)
}

// status:done
pub fn (db &DB) first() &DB {
	s := db.stmt as Select
	s.first = true
	return db
}

// status:done
pub fn (db &DB) limit(num int) &DB {
	s := db.stmt as Select
	s.limit = num
	return db
}

// status:done
pub fn (db &DB) offset(num int) &DB {
	s := db.stmt as Select
	s.offset = num
	return db
}

// status:done
pub fn (db &DB) distinct() &DB {
	s := db.stmt as Select
	s.is_distinct = true
	return db
}

// status:done
pub fn (db &DB) group_by(column string) &DB {
	s := db.stmt as Select
	s.group_by << column
	return db
}

// status:done
pub fn (db &DB) group_by_raw(raw string) &DB {
	mut s := db.stmt as Select
	s.group_by_raw = raw
	return db
}

// status:done
pub fn (db &DB) order_by(column string) &DB {
	s := db.stmt as Select
	col, mut order := split_by_space(column)
	if order == '' {
		order = 'asc'
	}
	if order !in ['asc', 'desc'] {
		panic('order by must be asc or desc')
	}
	s.order_by << OrderBy{
		column: col
		order: order
	}
	return db
}

// status:done
pub fn (db &DB) order_by_raw(raw string) &DB {
	mut s := db.stmt as Select
	s.order_by_raw = raw
	return db
}

// status:done
pub fn (db &DB) having(condition string) &DB {
	s := db.stmt as Select
	s.having = condition
	return db
}

//union statement
// status:wip
pub fn (db &DB) union_(union_fn CallbackFn) &DB {
	return db
}

// status:wip
pub fn (db &DB) union_all(union_fn CallbackFn) &DB {
	return db
}

// status:wip
pub fn (db &DB) intersect(union_fn CallbackFn) &DB {
	return db
}

// status:wip
pub fn (db &DB) except(union_fn CallbackFn) &DB {
	return db
}

// result to struct
// status:wip
pub fn (db &DB) to() &DB {
	return db
}
