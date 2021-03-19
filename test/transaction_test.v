module test

fn test_transaction() {
	mut db := connect_and_init_db()
	mut t := db.transaction()
	// t := db.tx() //the shorter fn
	t.exec("insert into person (id,name,age,income) values (33,'name33',33,0)")
	t.exec("insert into person (id,name,age,income) values (44,'name44',44,0)")
	t.exec("insert into person (id,name,age,income) values (55,'name55',55,0)")
	// t.rollback()
	t.commit()
}
