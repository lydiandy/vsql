module vsql

import strings


pub fn gen(stmt Stmt) string {
	mut sql := strings.new_builder(200)
	match stmt {
		Select {
			sql.write('select  ')
			if it.is_distinct {
				sql.write('distinct ')
			}
			for f in it.aggregate_fn {
				sql.write('${f.name}(')
				if f.is_distinct {
					sql.write('distinct ')
				}
				sql.write('${f.column_name}) ')
				if f.column_alias != '' {
					sql.write('as ')
					sql.write('$f.column_alias,')
				}
			}
			if it.aggregate_fn.len > 0 {
				sql.go_back(1)
			}
			if it.columns.len == 0 && it.aggregate_fn.len == 0 {
				sql.write('* ')
			} else {
				for column in it.columns {
					sql.write('$column.name ')
					if column.alias != '' {
						sql.write('as ')
						sql.write('$column.alias,')
					} else {
						sql.write(',')
					}
				}
				sql.go_back(1)
			}
			sql.write('from ')
			sql.write('$it.table_name ')
			if it.table_alias != '' {
				sql.write('as $it.table_alias ')
			}
			// where statement
			write_where(&it.where, &sql)
			// join statement
			if it.join_raw != '' {
				sql.write('$it.join_raw')
			} else {
				if it.join.len > 0 {
					for j in it.join {
						sql.write('$j.typ ')
						sql.write('$j.table_name ')
						if j.table_alias != '' {
							sql.write('as $j.table_alias ')
						}
						if j.join_condition != '' { // cross join will be ''
							sql.write('on $j.join_condition ')
						}
					}
				}
			}
			// limit
			if it.first {
				sql.write('limit 1 ')
			}
			if it.limit > 0 {
				sql.write('limit $it.limit ')
			}
			if it.offset > 0 {
				sql.write('offset $it.offset ')
			}
			// order by statement
			if it.order_by_raw != '' {
				sql.write('order by ')
				sql.write('$it.order_by_raw ')
			} else if it.order_by.len > 0 {
				sql.write('order by ')
				for order_obj in it.order_by {
					sql.write('$order_obj.column $order_obj.order,')
				}
				sql.go_back(1)
			}
			// group by statement
			if it.group_by_raw != '' {
				sql.write('group by ')
				sql.write('$it.group_by_raw ')
			} else if it.group_by.len > 0 {
				sql.write('group by ')
				for col in it.group_by {
					sql.write('$col,')
				}
				sql.go_back(1)
				sql.write(' ')
			}
			// having
			if it.having != '' {
				sql.write('having $it.having ')
			}
			return sql.str()
		}
		Insert {
			sql.write('insert into ')
			sql.write('$it.table_name ')
			// write data
			sql.write('(')
			for key in it.keys {
				sql.write('$key,')
			}
			sql.go_back(1)
			sql.write(')')
			sql.write(' values ')
			sql.write('(')
			for len, val in it.vals {
				sql.write("\'$val\'")
				if len < it.vals.len - 1 {
					sql.write(', ')
				}
			}
			sql.write(') ')
			// write returning
			if it.returning.len != 0 {
				sql.write('returning ')
				for r in it.returning {
					sql.write('$r,')
				}
				sql.go_back(1)
			}
			return sql.str()
		}
		Update {
			sql.write('update ')
			sql.write('$it.table_name ')
			sql.write('set ')
			for key, val in it.data {
				sql.write("$key=\'$val\',")
			}
			sql.go_back(1)
			// where statement
			write_where(&it.where, &sql)
			if it.returning.len != 0 {
				sql.write('returning ')
				for r in it.returning {
					sql.write('$r,')
				}
				sql.go_back(1)
			}
			return sql.str()
		}
		Delete {
			sql.write('delete from ')
			sql.write('$it.table_name ')
			// where statement
			write_where(&it.where, &sql)
			return sql.str()
		}
		CreateDatabase {
			sql.write('create database $it.db_name')
		}
		AlterTable {}
		RenameTable {
			sql.write('alter table $it.old_name rename to $it.new_name')
		}
		DropTable {
			sql.write('drop table $it.table_name')
		}
		Truncate {
			sql.write('truncate table $it.table_name')
		}
	}
}

// write where clause for select,update,delete
fn write_where(where &[]Where, sql &strings.Builder) {
	// where statement
	if where.len > 0 {
		sql.write('where ')
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
					sql.write('$operator ($w.condition) ')
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
					sql.write('$operator ($w.column_name in ($range_str)) ')
				}
				'where_null' {
					sql.write('$operator ($w.column_name is null) ')
				}
				'where_between' {
					sql.write('$operator ($w.column_name between ${w.range[0]} and ${w.range[1]}) ')
				}
				'where_exists' {
					sql.write('exists ($operator $w.exist_stmt) ')
				}
				'where_raw' {
					sql.write('$w.condition ')
				}
				else {}
			}
		}
	}
}
