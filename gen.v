module vsql

import strings

// generate Stmt to sql string
pub fn gen(stmt Stmt) string {
	mut s := strings.new_builder(200)
	match stmt {
		Select {
			s.write('select ')
			if stmt.is_distinct {
				s.write('distinct ')
			}
			for i, f in stmt.aggregate_fn {
				if f.is_distinct {
					s.write('distinct ')
				}
				s.write('${f.name}(')
				s.write('$f.column_name)')
				s.write(' ')
				if f.column_alias != '' {
					s.write('as ')
					s.write('$f.column_alias,')
					if i == stmt.aggregate_fn.len - 1 {
						s.go_back(1)
						s.write(' ')
					}
				}
			}
			if stmt.columns.len == 0 && stmt.aggregate_fn.len == 0 {
				s.write('* ')
			} else {
				for i, column in stmt.columns {
					s.write('$column.name')
					if column.alias != '' {
						s.write('as ')
						s.write('$column.alias,')
					} else {
						s.write(',')
					}
					if i == stmt.columns.len - 1 {
						s.go_back(1)
						s.write(' ')
					}
				}
			}
			s.write('from ')
			s.write('$stmt.table_name ')
			if stmt.table_alias != '' {
				s.write('as $stmt.table_alias ')
			}
			// where statement
			write_where(&stmt.where, &s)
			// join statement
			if stmt.join_raw != '' {
				s.write('$stmt.join_raw ')
			} else {
				if stmt.join.len > 0 {
					for j in stmt.join {
						s.write('$j.typ ')
						s.write('$j.table_name ')
						if j.table_alias != '' {
							s.write('as $j.table_alias ')
						}
						if j.join_condition != '' { // cross join will be ''
							s.write('on $j.join_condition ')
						}
					}
				}
			}
			// offset
			if stmt.offset > 0 {
				s.write('offset $stmt.offset ')
			}
			// first
			if stmt.first {
				s.write('limit 1 ')
			}
			// limit
			if stmt.limit > 0 {
				s.write('limit $stmt.limit ')
			}
			// order by statement
			if stmt.order_by_raw != '' {
				s.write('order by ')
				s.write('$stmt.order_by_raw ')
			} else if stmt.order_by.len > 0 {
				s.write('order by ')
				for o in stmt.order_by {
					s.write('$o.column $o.order,')
				}
			}
			// group by statement
			if stmt.group_by_raw != '' {
				s.write('group by ')
				s.write('$stmt.group_by_raw ')
			} else if stmt.group_by.len > 0 {
				s.write('group by ')
				for col in stmt.group_by {
					s.write('$col,')
				}
				s.go_back(1)
				s.write(' ')
			}
			// having
			if stmt.having != '' {
				s.write('having $stmt.having ')
			}
			s.go_back(1)
		}
		Insert {
			s.write('insert into ')
			s.write('$stmt.table_name ')
			// write data
			s.write('(')
			for key in stmt.keys {
				s.write('$key,')
			}
			s.go_back(1)
			s.write(')')
			s.write(' values ')
			s.write('(')
			for len, val in stmt.vals {
				s.write("\'$val\'")
				if len < stmt.vals.len - 1 {
					s.write(',')
				}
			}
			s.write(')')
			// write returning
			if stmt.returning.len != 0 {
				s.write(' returning ')
				for r in stmt.returning {
					s.write('$r,')
				}
				s.go_back(1)
			}
		}
		Update {
			s.write('update ')
			s.write('$stmt.table_name ')
			s.write('set ')
			for key, val in stmt.data {
				s.write("$key=\'$val\',")
			}
			s.go_back(1)
			s.write(' ')
			// where statement
			write_where(&stmt.where, &s)
			if stmt.returning.len != 0 {
				s.write(' returning ')
				for r in stmt.returning {
					s.write('$r,')
				}
				s.go_back(1)
			}
		}
		Delete {
			s.write('delete from ')
			s.write('$stmt.table_name ')
			// where statement
			write_where(&stmt.where, &s)
		}
		CreateDatabase {
			s.write('create database $stmt.db_name')
		}
		AlterTable {}
		RenameTable {
			s.write('alter table $stmt.old_name rename to $stmt.new_name')
		}
		DropTable {
			s.write('drop table $stmt.table_name')
		}
		Truncate {
			s.write('truncate table $stmt.table_name')
		}
	}
	return s.str()
}

// write where clause for select,update,delete
fn write_where(where &[]Where, s &strings.Builder) {
	// where statement
	if where.len > 0 {
		s.write('where')
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
					s.write('$operator ($w.condition) ')
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
					s.write('$operator ($w.column_name in ($range_str)) ')
				}
				'where_null' {
					s.write('$operator ($w.column_name is null) ')
				}
				'where_between' {
					s.write('$operator ($w.column_name between ${w.range[0]} and ${w.range[1]}) ')
				}
				'where_exists' {
					s.write('$operator exists ($w.exist_stmt) ')
				}
				'where_raw' {
					s.write(' $w.condition ')
				}
				else {
					panic('unknown where type')
				}
			}
		}
	}
}
