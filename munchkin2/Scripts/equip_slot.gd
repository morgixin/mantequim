extends Node2D
var stack_index: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func getNextStackIndex() -> int:
	stack_index += 1
	return stack_index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
