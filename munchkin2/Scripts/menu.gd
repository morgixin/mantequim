extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gerCartas = GerenciadorCartasClass.getInstancia()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_is_logged():
	if UC.isUserLogged():
		$MarginContainer2/VBoxContainer/Label.visible = true
		$MarginContainer2/VBoxContainer/Label/Username.text = UC.getUsername()
