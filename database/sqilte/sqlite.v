module sqlite

import database.sql
import database.sql.driver

pub struct DB {
mut:
	conn &C.sqlite3
}

pub struct Driver {
}

pub struct Config {
	path string
}

// implements sql.Config interface
pub fn (config Config) driver_name() string {
	return 'sqlite'
}

// implements sql.Config interface
pub fn (config Config) connect_str() string {
	return config.path
}

pub fn (d Driver) connect(name string) driver.Conn {
}

pub fn init() {
	sql.register('sqlite', &Driver{})
}
