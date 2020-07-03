module vsql

// the sql statement sum type
pub type Stmt = AlterTable | CreateDatabase | Delete | DropTable | Insert | RenameTable |
	Select | Truncate | Update

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
	data       map[string]string // TODO:map[string]interface
	where      []Where
	returning  []string
}

// delete statement
pub struct Delete {
pub mut:
	table_name string
	where      []Where
}

// create database statement
pub struct CreateDatabase {
pub mut:
	db_name string
}

// alter table statement
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
