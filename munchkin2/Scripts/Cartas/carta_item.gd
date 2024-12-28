
class_name CartaItem
extends CartaClass

@export var tipo_equipamento: int = -1
@export var isBig: bool = false
@export var forca: int = 0
@export var classe_exigida = -1
@export var raca_exigida = -1
@export var classe_restrita = -1
@export var raca_restrita = -1
@export var tipo = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
