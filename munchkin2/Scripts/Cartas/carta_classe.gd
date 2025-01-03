class_name CartaDeClasse extends CartaClass

@export var classe_id: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setClasse(classe: int) -> void:
	self.classe = classe

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
