class_name Mesa extends Node2D
var momentoDoJogo = 0
var jogadorAtual = 0

@onready var btn = $Confirmation

@onready var sprite_mesa: Sprite2D = $sprite_mesa
@onready var sprite_batalha: Sprite2D = $sprite_batalha

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
	if jogadorAtual == 0 and momentoDoJogo == 0:
		btn.customize("É o seu Turno!", "Está pronto para chutar a porta?", "Chutar a porta!", "Me equipar")
		var jogadorChutouAPorta = await btn.prompt(false)
		if jogadorChutouAPorta:
			mudarParaBatalha()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func mudarParaBatalha() -> void:
	sprite_mesa.hide()
	sprite_batalha.show()
	
