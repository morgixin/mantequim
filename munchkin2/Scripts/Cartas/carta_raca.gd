class_name CartaRaca extends CartaClass

@export var raca_id: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setRaca(raca: int) -> void:
	self.raca = raca

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
