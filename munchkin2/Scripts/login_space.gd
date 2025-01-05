extends MarginContainer

var UC = UserController.getInstancia()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if UC.isUserLogged():
		$VBoxContainer/LoginSignin.hide()
		$VBoxContainer/UsernameLabel.show()
		$VBoxContainer/UsernameLabel/Username.text = "[wave]"+UC.get_logged_user_username()
	else:
		$VBoxContainer/LoginSignin.show()
		$VBoxContainer/UsernameLabel.hide()
		$VBoxContainer/UsernameLabel/Username.text = ""
	pass
