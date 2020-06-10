module mysql

import database.sql
import database.sql.driver

pub struct DB {
mut:
	conn &C.MYSQL
}

pub struct Driver {
}

pub struct Config {
	host     string = 'localhost'
	port     int = 3306
	user     string
	password string
	database string
}

pub fn (c Config) driver_name() string {
	return 'mysql'
}

pub fn (c Config) connect_str() string {
	return ''
}

pub fn (d Driver) connect(name string) ?driver.Conn {
}

pub fn init() {
	sql.register('mysql', &Driver{})
}
