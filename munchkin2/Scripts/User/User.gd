extends Node
class_name User

var username : String

# Called when the node enters the scene tree for the first time.
func get_username() -> String:
	return username
	
func set_username(newUsername: String) -> void:
	username = newUsername
