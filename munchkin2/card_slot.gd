extends Node2D
var cardInSlot = false
@export var stack_index: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($Area2D.collision_mask)
	
func getNextStackIndex() -> void:
	stack_index += 1
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
