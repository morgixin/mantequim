class_name CartaDeClasse extends CartaClass

@export var classe_id: int = -1

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()

func setClasse(classe: int) -> void:
	self.classe = classe
	
func _process(delta: float) -> void:
	pass
	
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
