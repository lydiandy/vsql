module vsql

// import database.sql
import dialect.pg

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
	typ         StmtType
	table_name  string
	table_alias string
	// select
	is_distinct  bool
	columns      []Column // [] is *
	where        []Where
	has_where    bool // handle where must be the first,and other(and/or/not/or not) where just can after it
	join         []Join
	join_raw     string
	limit        int
	offset       int
	order_by     []OrderBy
	order_by_raw string
	group_by     []string
	group_by_raw string
	having       string
	aggregate_fn []AggregateFn
	// union statement
	union_type  string
	union_stmts []string
	// insert,update
	data      map[string]string // TODO:map[string]interface
	returning []string
	// create_database
	db_name string
	// alter_table
	alter_table []AlterTable
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
	typ         string   // where,where_in,where_null,where_exists,where_between,where_raw
	operator    string   // '',and,or,not,or not
	condition   string   //
	column_name string   // where null use
	range       []string // where range and where in use.should interface type
	exist_stmt  string   // where exist use
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

// create table statement
pub struct Table {
pub:
	db DB
pub mut:
	name     string
	columns  []&NewColumn
	primarys []string // table primary constraint
	uniques  []string // table unique constraint
	indexs   []string // table index
	checks   []string // table check constraint
}

// alter table statement
pub struct AlterTable {
	typ         string    // create_column,rename_column,drop_column,has_column,drop_index,drop_foreign,drop_unique,drop_primary
	new_column  NewColumn // for create new column
	drop_column Column    // for drop column
}

// new column when create table
[heap]
pub struct NewColumn {
pub mut:
	name          string
	typ           string
	size          int = 255
	precision     int = 8
	scale         int = 2
	is_increment  bool
	is_primary    bool
	is_unique     bool
	is_not_null   bool
	default_value string
	index         string
	reference     string // table(column)
	check         string
	is_first      bool   // only mysql,todo
	after         string // only mysql,todo
	collate       string // only mysql,todo
}

// create column
pub fn (mut t Table) uuid(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'serial'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) increment(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'serial'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) integer(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'integer'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) big_integer(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'bigint'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) text(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'text'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) string_(name string, size int) &NewColumn {
	if size <= 0 {
		panic('size must be greater than zero')
	}
	mut column := &NewColumn{
		name: name
		typ: 'varchar($size)'
		size: size
	}
	t.columns << column
	return column
}

pub fn (mut t Table) decimal(name string, precision int, scale int) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'decimal($precision,$scale)'
		precision: precision
		scale: scale
	}
	t.columns << column
	return column
}

pub fn (mut t Table) boolean(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'boolean'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) date(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'date'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) datetime(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'timestamp'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) time(name string, precision int) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'time'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) binary(name string, size int) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'bytea'
		size: size
	}
	t.columns << column
	return column
}

pub fn (mut t Table) json(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'json'
	}
	t.columns << column
	return column
}

pub fn (mut t Table) jsonb(name string) &NewColumn {
	mut column := &NewColumn{
		name: name
		typ: 'jsonb'
	}
	t.columns << column
	return column
}

// exec create table sql
pub fn (t Table) exec() []pg.Row {
	s := t.gen_table_sql()
	res := t.db.exec(s)
	return res
}

// ---------
// column method can be chain call after create column
pub fn (mut c NewColumn) size(size int) &NewColumn {
	c.size = size
	return c
}

pub fn (mut c NewColumn) precision(precision int, scale int) &NewColumn {
	c.precision = precision
	c.scale = scale
	return c
}

pub fn (mut c NewColumn) increment() &NewColumn {
	c.is_increment = true
	return c
}

pub fn (mut c NewColumn) primary() &NewColumn {
	c.is_primary = true
	return c
}

// pub fn (mut c NewColumn) reference(ref string) &NewColumn {
// c.reference = ref // such like this: 'table(column)'
// return c
// }

pub fn (mut c NewColumn) unique() &NewColumn {
	c.is_unique = true
	return c
}

pub fn (mut c NewColumn) not_null() &NewColumn {
	c.is_not_null = true
	return c
}

pub fn (mut c NewColumn) default_to(value string) &NewColumn {
	c.default_value = value
	return c
}

pub fn (mut c NewColumn) check(check string) &NewColumn {
	c.check = check
	return c
}

pub fn (mut c NewColumn) first() &NewColumn {
	c.is_first = true
	return c
}

pub fn (mut c NewColumn) after(column string) &NewColumn {
	c.after = column
	return c
}

pub fn (mut c NewColumn) collate(column string) &NewColumn {
	c.collate = column
	return c
}

// --------------------
// table constraint
pub fn (mut t Table) primary(columns []string) &Table {
	t.primarys = columns
	return t
}

pub fn (mut t Table) unique(columns []string) &Table {
	t.uniques = columns
	return t
}

pub fn (mut t Table) index(indexs []string) &Table {
	t.indexs = indexs
	return t
}

pub fn (mut t Table) check(check string) &Table {
	t.checks << check
	return t
}

// ---------------------
// for table create and alter
pub fn (mut t Table) has_column(name string) bool {
	return true
}

pub fn (mut t Table) drop_column(name string) &Table {
	return t
}

pub fn (mut t Table) drop_columns(columns []string) &Table {
	return t
}

pub fn (mut t Table) rename_column(from string, to string) &Table {
	return t
}

pub fn (mut t Table) create_index(name string) &Table {
	return t
}

pub fn (mut t Table) drop_unique(name string) &Table {
	return t
}

pub fn (mut t Table) drop_primary(name string) &Table {
	return t
}

pub fn (mut t Table) drop_index(name string) &Table {
	return t
}

pub fn (mut t Table) drop_foreign(name string) &Table {
	return t
}

pub fn (mut t Table) charset(name string) &Table {
	return t
}
