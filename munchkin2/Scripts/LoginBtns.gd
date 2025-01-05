extends Node

signal CreateUser(username, password)
signal LoginUser(username, password)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 


## ON HOVER
# menu btns hover interaction

func _on_exit_btn_mouse_entered() -> void:
	$HBoxContainer/ExitBtn/CancelLabel.text = "[wave][center]Cancelar"
	
func _on_exit_btn_mouse_exited() -> void:
	$HBoxContainer/ExitBtn/CancelLabel.text = "[center]Cancelar"

func _on_login_btn_mouse_entered() -> void:
	$HBoxContainer/LoginBtn/LoginLabel.text = "[wave][center]Logar"

func _on_login_btn_mouse_exited() -> void:
	$HBoxContainer/LoginBtn/LoginLabel.text = "[center]Logar"

func _on_signin_btn_mouse_entered() -> void:
	$HBoxContainer/SigninBtn/SigninLabel.text = "[wave][center]Cadastrar"

func _on_signin_btn_mouse_exited() -> void:
	$HBoxContainer/SigninBtn/SigninLabel.text = "[center]Cadastrar"



## ON CLICK

func _on_exit_btn_pressed() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

func _on_login_btn_pressed() -> void:
	LoginUser.emit($UsernameLineEdit.text, $PasswordLineEdit.text)
	if UC.isUserLogged():
		queue_free()
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
	
func _on_signin_btn_pressed() -> void:
	CreateUser.emit($UsernameLineEdit.text, $PasswordLineEdit.text)


## User Signals
func loginUser(username, password) -> void:
	LoginUser.emit(username, password)

func createUser(username, password) -> void:
	CreateUser.emit(username, password)
