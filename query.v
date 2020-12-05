module vsql

// status:done
pub fn (mut db DB) table(name string) &DB {
	// handle table alias,like:select * from person as p
	table_name, table_alias := split_by_separator(name, 'as')
	db.stmt.typ = .select_
	db.stmt.table_name = table_name
	db.stmt.table_alias = table_alias
	return db
}

// status:done
pub fn (mut db DB) column(columns string) &DB {
	if columns in [' ', '*'] {
		db.stmt.columns = []Column{}
	} else {
		column_array := columns.split(',')
		for col in column_array {
			// handle column and column alias,like:column('id,name as name2,age as age2')
			name, alias := split_by_separator(col, 'as')
			db.stmt.columns << Column{
				name: name
				alias: alias
			}
		}
	}
	return db
}

// the same with table()
// status:done
pub fn (mut db DB) from(name string) &DB {
	return db.table(name)
}

// the same with column()
// status:done
pub fn (mut db DB) select_(columns string) &DB {
	return db.column(columns)
}

// status:done
pub fn (mut db DB) first() &DB {
	db.stmt.limit = 1
	return db
}

// status:done
pub fn (mut db DB) limit(num int) &DB {
	if num <= 0 {
		panic('limit must great zero')
	}
	db.stmt.limit = num
	return db
}

// status:done
pub fn (mut db DB) offset(num int) &DB {
	if num <= 0 {
		panic('offset must great zero')
	}
	db.stmt.offset = num
	return db
}

// status:done
pub fn (mut db DB) distinct() &DB {
	db.stmt.is_distinct = true
	return db
}

// status:done
pub fn (mut db DB) group_by(column string) &DB {
	db.stmt.group_by << column
	return db
}

// status:done
pub fn (mut db DB) group_by_raw(raw string) &DB {
	if db.stmt.group_by.len > 0 {
		panic('when use group_by_raw,the group_by will be ignored,remove group_by first')
	}
	db.stmt.group_by_raw = raw
	return db
}

// status:done
pub fn (mut db DB) order_by(column string) &DB {
	col, mut order := split_by_space(column)
	if order == '' {
		order = 'asc'
	}
	if order !in ['asc', 'desc'] {
		panic('order by must be asc or desc')
	}
	// check col is already in order_by array
	for c in db.stmt.order_by {
		if c.column == col {
			panic('$col is already in order by')
		}
	}
	db.stmt.order_by << OrderBy{
		column: col
		order: order
	}
	return db
}

// status:done
pub fn (mut db DB) order_by_raw(raw string) &DB {
	if db.stmt.order_by.len > 0 {
		panic('when use order_by_raw,the order_by will be ignored,remove order_by first')
	}
	db.stmt.order_by_raw = raw
	return db
}

// status:done
pub fn (mut db DB) having(condition string) &DB {
	db.stmt.having = condition
	return db
}

// union statement
// status:done
pub fn (mut db DB) union_type(typ string, stmt string, other_stmts ...string) &DB {
	db.stmt.union_type = typ
	db.stmt.union_stmts << stmt
	for s in other_stmts {
		db.stmt.union_stmts << s
	}
	return db
}

// status:done
pub fn (mut db DB) union_(stmt string, other_stmts ...string) &DB {
	return db.union_type('union', stmt, other_stmts)
}

// status:done
pub fn (mut db DB) union_all(stmt string, other_stmts ...string) &DB {
	return db.union_type('union all', stmt, other_stmts)
}

// status:done
pub fn (mut db DB) intersect(stmt string, other_stmts ...string) &DB {
	return db.union_type('intersect', stmt, other_stmts)
}

// status:done
pub fn (mut db DB) except(stmt string, other_stmts ...string) &DB {
	return db.union_type('except', stmt, other_stmts)
}

// result to struct
// status:wip
pub fn (mut db DB) to() &DB {
	return db
}
