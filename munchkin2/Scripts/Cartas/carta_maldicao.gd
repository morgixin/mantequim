class_name CartaMaldicao extends CartaClass

@export var acao: int = -1
@export var acao_parametro: int = 0
@export var target: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()
	
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
