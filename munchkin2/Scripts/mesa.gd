class_name Mesa extends Node2D
var isBattleOn
@onready var btn = $Confirmation

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		btn.customize("deseja sair do jogo?", "escolha a opção desejada")
		var isConfirmed = await btn.prompt(true)
		if isConfirmed:
			get_tree().quit()
	else:
		pass
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
