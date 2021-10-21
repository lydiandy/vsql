module test

pub fn test_inert_update_delete() {
	mut db := connect_and_init_db()
	mut res := ''
	// insert
	res = db.table('person').insert({
		'id':   '255',
		'name': 'abc',
		'age':  '36'
	}).to_sql()
	assert res == "insert into person (id,name,age) values ('255','abc','36')"

	res = db.table('person').insert({
		'id':   '255',
		'name': 'abc',
		'age':  '36'
	}).returning('id', 'name').to_sql()
	assert res == "insert into person (id,name,age) values ('255','abc','36') returning id,name"

	res = db.insert({
		'id':   '12',
		'name': 'tom',
	}).into('person').returning('id').to_sql()
	assert res == "insert into person (id,name) values ('12','tom') returning id"

	// update
	res = db.table('person').update({
		'name': 'paris'
	}).where('id=1').returning('id').to_sql()
	assert res == "update person set name='paris' where (id=1) returning id"

	res = db.table('person').update({
		'name': 'paris',
		'age':  '32'
	}).where('id=1').returning('id').to_sql()
	assert res == "update person set name='paris',age='32' where (id=1) returning id"

	// delete
	res = db.table('person').delete().where('id=3').to_sql()
	assert res == 'delete from person where (id=3) '
	res = db.table('person').where('id=2').delete().to_sql()
	assert res == 'delete from person where (id=2) '
}
