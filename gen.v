module vsql

import strings

// generate stmt to sql string
pub fn (mut db DB) gen_sql() string {
	mut s := strings.new_builder(200)
	stmt := db.stmt
	match stmt.typ {
		.select_ {
			s.write_string('select ')
			if stmt.is_distinct {
				s.write_string('distinct ')
			}
			for i, f in stmt.aggregate_fn {
				if f.is_distinct {
					s.write_string('distinct ')
				}
				s.write_string('${f.name}(')
				s.write_string('$f.column_name)')
				s.write_string(' ')
				if f.column_alias != '' {
					s.write_string('as ')
					s.write_string('$f.column_alias,')
					if i == stmt.aggregate_fn.len - 1 {
						s.go_back(1)
						s.write_string(' ')
					}
				}
			}
			if stmt.columns.len == 0 && stmt.aggregate_fn.len == 0 {
				s.write_string('* ')
			} else {
				for i, column in stmt.columns {
					s.write_string('$column.name')
					if column.alias != '' {
						s.write_string(' as ')
						s.write_string('$column.alias,')
					} else {
						s.write_string(',')
					}
					if i == stmt.columns.len - 1 {
						s.go_back(1)
						s.write_string(' ')
					}
				}
			}
			s.write_string('from ')
			s.write_string('$stmt.table_name ')
			if stmt.table_alias != '' {
				s.write_string('as $stmt.table_alias ')
			}
			// where statement
			db.write_where(stmt.where, mut &s)
			// join statement
			if stmt.join_raw != '' {
				s.write_string('$stmt.join_raw ')
			} else {
				if stmt.join.len > 0 {
					for j in stmt.join {
						s.write_string('$j.typ ')
						s.write_string('$j.table_name ')
						if j.table_alias != '' {
							s.write_string('as $j.table_alias ')
						}
						if j.join_condition != '' { // cross join will be ''
							s.write_string('on $j.join_condition ')
						}
					}
				}
			}
			// offset
			if stmt.offset > 0 {
				s.write_string('offset $stmt.offset ')
			}
			// limit
			if stmt.limit > 0 {
				s.write_string('limit $stmt.limit ')
			}
			// order by statement
			if stmt.order_by_raw != '' {
				s.write_string('order by ')
				s.write_string('$stmt.order_by_raw ')
			} else if stmt.order_by.len > 0 {
				s.write_string('order by ')
				for o in stmt.order_by {
					s.write_string('$o.column $o.order,')
				}
			}
			// group by statement
			if stmt.group_by_raw != '' {
				s.write_string('group by ')
				s.write_string('$stmt.group_by_raw ')
			} else if stmt.group_by.len > 0 {
				s.write_string('group by ')
				for col in stmt.group_by {
					s.write_string('$col,')
				}
				s.go_back(1)
				s.write_string(' ')
			}
			// having
			if stmt.having != '' {
				s.write_string('having $stmt.having ')
			}
			// union statement
			if stmt.union_stmts.len > 0 {
				for us in stmt.union_stmts {
					s.write_string('$stmt.union_type ')
					s.write_string('$us ')
				}
			}
			s.go_back(1)
		}
		.insert {
			s.write_string('insert into ')
			s.write_string('$stmt.table_name ')
			// write data
			s.write_string('(')
			mut keys := []string{}
			mut vals := []string{}
			for key, val in stmt.data {
				keys << key
				vals << val
			}
			for key in keys {
				s.write_string('$key,')
			}
			s.go_back(1)
			s.write_string(')')
			s.write_string(' values ')
			s.write_string('(')
			for len, val in vals {
				s.write_string("'$val'")
				if len < vals.len - 1 {
					s.write_string(',')
				}
			}
			s.write_string(')')
			// write returning
			if stmt.returning.len != 0 {
				s.write_string(' returning ')
				for r in stmt.returning {
					s.write_string('$r,')
				}
				s.go_back(1)
			}
		}
		.update {
			s.write_string('update ')
			s.write_string('$stmt.table_name ')
			s.write_string('set ')
			for key, val in stmt.data {
				s.write_string("$key='$val',")
			}
			s.go_back(1)
			s.write_string(' ')
			// where statement
			db.write_where(stmt.where, mut &s)
			// write returning
			if stmt.returning.len != 0 {
				s.write_string('returning ')
				for r in stmt.returning {
					s.write_string('$r,')
				}
				s.go_back(1)
			}
		}
		.delete {
			s.write_string('delete from ')
			s.write_string('$stmt.table_name ')
			// where statement
			db.write_where(stmt.where, mut &s)
		}
		.create_database {
			s.write_string('create database $stmt.db_name')
		}
		.create_table {}
		.alter_table {}
		.rename_table {
			s.write_string('alter table $stmt.table_name rename to $stmt.new_table_name')
		}
		.drop_table {
			s.write_string('drop table $stmt.table_name')
		}
		.truncate_table {
			s.write_string('truncate table $stmt.table_name')
		}
	}
	return s.str()
}

// write where clause for select,update,delete
pub fn (mut db DB) write_where(where []Where, mut s strings.Builder) {
	// where statement
	if where.len > 0 {
		s.write_string('where')
		mut operator := ''
		for pos, w in where {
			// if where is the second where clause,operator is and
			if pos >= 1 && w.operator == '' {
				operator = 'and'
			} else {
				operator = w.operator
			}
			match w.typ {
				'where' {
					s.write_string('$operator ($w.condition) ')
				}
				'where_in' {
					mut range_str := ''
					for i, r in w.range {
						if i < w.range.len - 1 {
							range_str += '$r,'
						} else {
							range_str += '$r'
						}
					}
					s.write_string('$operator ($w.column_name in ($range_str)) ')
				}
				'where_null' {
					s.write_string('$operator ($w.column_name is null) ')
				}
				'where_between' {
					s.write_string('$operator ($w.column_name between ${w.range[0]} and ${w.range[1]}) ')
				}
				'where_exists' {
					s.write_string('$operator exists ($w.exist_stmt) ')
				}
				'where_raw' {
					s.write_string(' $w.condition ')
				}
				else {
					panic('unknown where type')
				}
			}
		}
	}
}

// generate create table stmt to sql string
pub fn (t &Table) gen_table_sql() string {
	mut s := strings.new_builder(200)
	s.write_string('create table $t.name (')
	if t.columns.len == 0 {
		s.write_string(');')
		return s.str()
	}
	s.writeln('')
	for column in t.columns {
		s.write_string('$column.name ')
		s.write_string('$column.typ ')
		if column.default_value != '' {
			s.write_string("default '$column.default_value' ")
		}
		if column.is_increment {
			s.write_string('serial ')
		}
		if column.is_not_null {
			s.write_string('not null ')
		}
		if column.is_primary {
			s.write_string('primary key ')
		}
		if column.is_unique {
			s.write_string('unique ')
		}
		if column.index != '' {
			s.write_string('index $column.index ')
		}
		// if column.reference != '' {
		// s.write_string('references \'$column.reference\' ')
		// }
		if column.is_first {
		}
		if column.after != '' {
		}
		if column.collate != '' {
		}
		if column.check != '' {
			s.write_string('check ($column.check) ')
		}
		s.go_back(1)
		s.writeln(',')
	}
	if t.primarys.len == 0 && t.uniques.len == 0 && t.checks.len == 0 {
		s.go_back(2)
	}
	//
	// table constraint
	if t.primarys.len > 0 || t.uniques.len > 0 || t.indexs.len > 0 || t.checks.len > 0 {
		s.writeln('')
	}
	// primary key
	if t.primarys.len > 0 {
		s.write_string('primary key (')
		for column in t.primarys {
			s.write_string('$column,')
		}
		s.go_back(1)
		s.writeln('),')
	}
	// unique
	if t.uniques.len > 0 {
		s.write_string('unique (')
		for column in t.uniques {
			s.write_string('$column,')
		}
		s.go_back(1)
		s.writeln('),')
	}
	if t.indexs.len > 0 {
		// TODO
	}
	// check
	if t.checks.len > 0 {
		for c in t.checks {
			s.writeln('check ($c),')
		}
		s.go_back(2)
	}
	s.writeln('')
	s.write_string(');')
	return s.str()
}
