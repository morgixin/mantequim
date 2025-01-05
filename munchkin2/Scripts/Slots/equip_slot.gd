extends Node2D
var stack_index: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(get_viewport().size.x/2, get_viewport().size.y/2)
	get_tree().get_root().size_changed.connect(resize)
	
func getNextStackIndex() -> int:
	stack_index += 1
	return stack_index

func resize():
	var screen = get_viewport_rect().size
	position = Vector2(screen.x/2, screen.y/2)
