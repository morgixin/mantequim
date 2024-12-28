class_name CartaMonstro
extends CartaClass

@export var tipo: int = -1
@export var forca: int = 0
@export var acao = -1
@export var acaoParametro = -1
var força_especifica:int = -1
var classe_especifica: int = -1
var raça_especifica: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()
	self.isTreasure = false
	self.isMonster = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
