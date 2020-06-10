module pg

import database.sql

#flag -lpq
#flag linux -I/usr/include/postgresql
#flag darwin -I/opt/local/include/postgresql11
#flag windows -I @VROOT/thirdparty/pg/include
#flag windows -L @VROOT/thirdparty/pg/win64
#include <libpq-fe.h>
fn C.PQconnectdb(a byteptr) &C.PGconn

fn C.PQerrorMessage(arg_1 voidptr) byteptr

fn C.PQgetvalue(arg_1 voidptr, arg_2, arg_3 int) byteptr

fn C.PQstatus(arg_1 voidptr) int

fn C.PQntuples(arg_1 voidptr) int

fn C.PQnfields(arg_1 voidptr) int

fn C.PQexec(arg_1 voidptr) voidptr

fn C.PQexecParams(arg_1 voidptr) voidptr

// the pg Driver
pub struct Driver {
mut:
	conn C.PGconn
}

// register the driver when the module is loaded
pub fn init() {
	// sql.register('pg', &Driver{})
}

// implement driver.Driver interface
pub fn (mut d Driver) connect(config sql.Config) ?sql.Driver {
	conn := C.PQconnectdb(config.connect_str().str)
	status := C.PQstatus(conn)
	if status != C.CONNECTION_OK {
		error_msg := C.PQerrorMessage(conn)
		return error('Connection to a PG database failed: ' + string(error_msg))
	}
	d.conn = conn
	return d
}

pub fn (d Driver) ping() ?string {
	return 'ok'
}

pub fn (d Driver) exec(stmt string) ?[]sql.Row {
	res := C.PQexec(d.conn, stmt.str)
	e := string(C.PQerrorMessage(d.conn))
	if e != '' {
		return error('pg exec error:$e')
	}
	return res_to_rows(res)
}

pub fn (d Driver) close() {
}

pub fn (d Driver) begin() ?sql.Tx {
	return error('data error')
}

pub fn (d Driver) prepare(stmt string) ?sql.Stmt {
	return error('data error')
}

// transaction
pub struct Tx {
}

pub fn (t Tx) commit() {
}

pub fn (t Tx) rollback() {
}

// database connection config
pub struct Config {
pub mut:
	host     string = 'localhost'
	port     int = 5432
	user     string
	password string
	database string
}

// implements driver.Config interface
pub fn (config Config) driver_name() string {
	return 'pg'
}

// implements driver.Config interface
pub fn (config Config) connect_str() string {
	return 'host=$config.host port=$config.port user=$config.user dbname=$config.database password=$config.password'
}

fn res_to_rows(res voidptr) []sql.Row {
	nr_rows := C.PQntuples(res)
	nr_cols := C.PQnfields(res)
	mut rows := []sql.Row{}
	for i in 0 .. nr_rows {
		mut row := sql.Row{}
		for j in 0 .. nr_cols {
			val := C.PQgetvalue(res, i, j)
			row.vals << string(val)
		}
		rows << row
	}
	return rows
}
