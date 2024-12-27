extends Node2D
var cardInSlot = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($Area2D.collision_mask)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
