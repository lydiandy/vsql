module sql

pub interface Config {
	driver_name() string
	connect_str() string
}

pub interface Driver {
	connect(config Config) ?Driver
	ping() ?string
	exec(stmt string) ?[]Row
	close() 
	begin() ?Tx
	prepare(stmt string) ?Stmt
}

pub interface ITx {
	commit() 
	rollback()
}

pub interface IStmt {
	close()
	num_input() int
	query(args []string) ?[]Row
}

pub interface Scanner {
	scan(t string)
}