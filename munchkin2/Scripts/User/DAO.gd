extends RefCounted
class_name DAO

var db

# Called when the node enters the scene tree for the first time.
func _init():
	db = SQLite.new()
	db.path = "res://data.db"
	db.open_db()
	
	var table = {
		"id" : {"data_type": "int", "primary_key" : true, "not_null" : true, "auto_increment"  : true},
		"username": {"data_type" : "text"},
		"password" : {"data_type" : "text"},
		"salt" :{"data_type" : "int", "not_null" : true}
	}
	
	db.create_table("players", table)
	pass # Replace with function body.

func InsertUserData(username, password, salt):
	var data = {
		"username" : username,
		"password" : password,
		"salt" : salt
	}
	db.insert_row("players", data)

func GetUserFromDB(username):
	var query = "SELECT id, password, salt from players where username = ?"
	var paramBindings = [username]
	db.query_with_bindings(query, paramBindings)
	for i in db.query_result:
		return{
			"id" : i["id"],
			"hashedPassword" : i["password"],
			"salt" : i["salt"],
			"username" : username,
		}
