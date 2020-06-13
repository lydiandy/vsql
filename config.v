module vsql

// config of connection
pub struct Config {
pub:
	client    string // mysql,pg,sqlite,mysql
	host      string
	port      int
	user      string
	password  string
	database  string
	file_name string // sqlite
	encoding  string
	debug     bool
	timeout   int = 60000 // ms,default 60s
	pool      map[string]int // {min:0,max:10}
}
