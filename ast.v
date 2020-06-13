module vsql

pub const (
	version = '0.0.1'
)

pub type Stmt = AlterTable | CreateDatabase | Delete | DropTable | Insert | RenameTable | Select |
	Truncate | Update

// select statement
pub struct Select {
pub mut:
	table_name   string
	table_alias  string
	is_distinct  bool
	columns      []Column // [] is *
	where        []Where
	join         []Join
	join_raw     string
	first        bool
	limit        int
	offset       int
	order_by     []OrderBy
	order_by_raw string
	group_by     []string
	group_by_raw string
	having       string
	aggregate_fn []AggregateFn
	timeout      int // ms
}

// table, table('user as u')
pub struct TableName {
pub mut:
	name  string
	alias string
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
	operator    string // '',and,or,not,or_not
	condition   string
	column_name string
	range       []string // ??interface
	exist_stmt  string
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

// order_by
pub struct OrderBy {
pub mut:
	column string
	order  string = 'asc'
}

// union statement
pub struct Union {
	tye      string // union,union_all,intersect
	union_fn CallbackFn
}

// insert statement
pub struct Insert {
pub mut:
	table_name string
	keys       []string
	vals       []string
	returning  []string
}

// update statement
pub struct Update {
pub mut:
	table_name string
	data       map[string]string
	where      []Where
	returning  []string
}

// delete statement
pub struct Delete {
pub mut:
	table_name string
	where      []Where
}

// -----------------------------------
// create database
pub struct CreateDatabase {
pub mut:
	db_name string
}

pub struct AlterTable {
pub mut:
	table_name    string
	alter_content []AlterContent
}

pub struct AlterContent {
	typ         string // create_column,rename_column,drop_column,has_column,drop_index,drop_foreign,drop_unique,drop_primary
	new_column  NewColumn // for create new column
	new_name    string // for rename
	old_name    string // for rename
	column_name string // for drop
}

// rename table
pub struct RenameTable {
pub mut:
	old_name string
	new_name string
}

// drop table
pub struct DropTable {
pub mut:
	table_name string
}

// truncate table
pub struct Truncate {
pub mut:
	table_name string
}
