class_name CartaRaca extends CartaClass

@export var raca_id: int = 1


func setRaca(raca: int) -> void:
	self.raca = raca

func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()
	
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
	
