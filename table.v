module vsql

import strings

// create table use
pub struct Table {
pub mut:
	name     string
	columns  []NewColumn
	primarys []string // table primary constraint
	uniques  []string // table unique constraint
	indexs   []string // table index
	checks   []string // table check constraint
}

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
	is_first      bool // only mysql,todo
	after         string // only mysql,todo
	collate       string // only mysql,todo
}

// create column
pub fn (t &Table) uuid(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'serial'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) increment(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'serial'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) integer(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'integer'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) big_integer(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'bigint'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) text(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'text'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) string_(name string, size int) &NewColumn {
	if size <= 0 {
		panic('size must be greater than zero')
	}
	column := NewColumn{
		name: name
		typ: 'varchar($size)'
		size: size
	}
	t.columns << column
	return &t.columns.last()
}

// ??
pub fn (t &Table) float(name string, precision, scale int) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'decimal($precision,$scale)'
		precision: precision
		scale: scale
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) decimal(name string, precision, scale int) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'decimal($precision,$scale)'
		precision: precision
		scale: scale
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) boolean(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'boolean'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) date(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'date'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) datetime(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'timestamp'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) time(name string, precision int) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'time'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) binary(name string, size int) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'bytea'
		size: size
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) json(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'json'
	}
	t.columns << column
	return &t.columns.last()
}

pub fn (t &Table) jsonb(name string) &NewColumn {
	column := NewColumn{
		name: name
		typ: 'jsonb'
	}
	t.columns << column
	return &t.columns.last()
}

// ---------
// column method can be chain call after create column
pub fn (c &NewColumn) size(size int) &NewColumn {
	c.size = size
	return c
}

pub fn (c &NewColumn) precision(precision, scale int) &NewColumn {
	c.precision = precision
	c.scale = scale
	return c
}

pub fn (c &NewColumn) increment() &NewColumn {
	c.is_increment = true
	return c
}

pub fn (c &NewColumn) primary() &NewColumn {
	c.is_primary = true
	return c
}

pub fn (c &NewColumn) reference(ref string) &NewColumn {
	c.reference = ref // such like this: 'table(column)'
	return c
}

pub fn (c &NewColumn) unique() &NewColumn {
	c.is_unique = true
	return c
}

pub fn (c &NewColumn) not_null() &NewColumn {
	c.is_not_null = true
	return c
}

pub fn (c &NewColumn) default_to(value string) &NewColumn {
	c.default_value = value
	return c
}

pub fn (c &NewColumn) check(check string) &NewColumn {
	c.check = check
	return c
}

pub fn (c &NewColumn) first() &NewColumn {
	c.is_first = true
	return c
}

pub fn (c &NewColumn) after(column string) &NewColumn {
	c.after = column
	return c
}

pub fn (c &NewColumn) collate(column string) &NewColumn {
	c.collate = column
	return c
}

// --------------------
// table constraint
pub fn (t &Table) primary(columns []string) &Table {
	t.primarys = columns
	return t
}

pub fn (t &Table) unique(columns []string) &Table {
	t.uniques = columns
	return t
}

pub fn (t &Table) check(check string) &Table {
	t.checks << check
	return t
}

// ---------------------
// for table create and alter
pub fn (t &Table) has_column(name string) bool {
	return true
}

pub fn (t &Table) drop_column(name string) &Table {
	return t
}

pub fn (t &Table) drop_columns(columns []string) &Table {
	return t
}

pub fn (t &Table) rename_column(from, to string) &Table {
	return t
}

pub fn (t &Table) create_index(name string) &Table {
	return t
}

pub fn (t &Table) drop_unique(name string) &Table {
	return t
}

pub fn (t &Table) drop_primary(name string) &Table {
	return t
}

pub fn (t &Table) drop_index(name string) &Table {
	return t
}

pub fn (t &Table) drop_foreign(name string) &Table {
	return t
}

pub fn (t &Table) charset(name string) &Table {
	return t
}

// generate sql of create table
pub fn (t &Table) gen() string {
	mut s := strings.new_builder(200)
	s.writeln('create table $t.name (')
	for column in t.columns {
		s.write('$column.name ')
		s.write('$column.typ ')
		if column.default_value != '' {
			s.write("default \'$column.default_value\' ")
		}
		if column.is_increment {
			s.write('serial ')
		}
		if column.is_not_null {
			s.write('not null ')
		}
		if column.is_primary {
			s.write('primary key ')
		}
		if column.is_unique {
			s.write('unique ')
		}
		if column.index != '' {
			s.write('index $column.index ')
		}
		if column.reference != '' {
			s.write('references $column.reference ')
		}
		if column.is_first {
		}
		if column.after != '' {
		}
		if column.collate != '' {
		}
		if column.check != '' {
			s.write('check ($column.check)')
		}
		s.go_back(1)
		s.writeln(',')
	}
	if t.primarys.len == 0 && t.uniques.len == 0 && t.checks.len == 0 {
		s.go_back(2)
	}
	// s.writeln('')
	// table constraint
	// primary key
	if t.primarys.len > 0 {
		s.write('primary key (')
		for column in t.primarys {
			s.write('$column,')
		}
		s.go_back(1)
		s.writeln('),')
	}
	// unique
	if t.uniques.len > 0 {
		s.write('unique (')
		for column in t.uniques {
			s.write('$column,')
		}
		s.go_back(1)
		s.writeln('),')
	}
	// check
	if t.checks.len > 0 {
		for c in t.checks {
			s.writeln('check ($c),')
		}
		s.go_back(2)
	}
	s.writeln('')
	s.write(');')
	return s.str()
}

pub fn (t &Table) to_sql() string {
	s := t.gen()
	return s
}
