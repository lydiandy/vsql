module vsql

// type of stmt
pub enum StmtType {
	select_
	insert
	update
	delete
	create_database
	create_table
	alter_table
	rename_table
	truncate_table
	drop_table
}

// sql statement
pub struct Stmt {
pub mut:
	// public
	typ            StmtType
	table_name     string
	table_alias    string
	// select
	is_distinct    bool
	columns        []Column // [] is *
	where          []Where
	join           []Join
	join_raw       string
	limit          int
	offset         int
	order_by       []OrderBy
	order_by_raw   string
	group_by       []string
	group_by_raw   string
	having         string
	aggregate_fn   []AggregateFn
	// union statement
	union_type     string
	union_stmts    []string
	// union_stmt     UnionStmt
	// insert,update
	data           map[string]string // TODO:map[string]interface
	returning      []string
	// create_database
	db_name        string
	// alter_table
	alter_content  []AlterContent
	// rename_talbe
	new_table_name string
}

// select column
pub struct Column {
pub mut:
	name  string
	alias string
}

// where statement
pub struct Where {
pub mut:
	typ         string // where,where_in,where_null,where_exists,where_between,where_raw
	operator    string // '',and,or,not,or not
	condition   string // where raw use
	column_name string // where null use
	range       []string // where range and where in use.  should interface type
	exist_stmt  string // where exist use
}

// join statement
pub struct Join {
pub mut:
	typ            string // join,inner join,left join,right join,full join,cross join
	table_name     string
	table_alias    string
	join_condition string
}

// aggregate function
pub struct AggregateFn {
pub mut:
	name         string // count,min,max,avg,sum
	column_name  string
	column_alias string
	is_distinct  bool
}

// order by statement
pub struct OrderBy {
pub mut:
	column string
	order  string = 'asc'
}

// union statement
// pub struct UnionStmt {
// pub mut:
// 	typ   string // union,union all,intersect,except
// 	stmts []string
// }

// alter table statement
pub struct AlterContent {
	typ         string // create_column,rename_column,drop_column,has_column,drop_index,drop_foreign,drop_unique,drop_primary
	new_column  NewColumn // for create new column
	new_name    string // for rename
	old_name    string // for rename
	column_name string // for drop
}
