extends Node2D

signal hovered
signal hoveredOff
var posInicial

const CARD_PATH = "res://Scenes/Carta.tscn"

@export var nome: String
@export var frame: int
@export var descricao: String
var cardScene = preload(CARD_PATH)

func create_card_instance(nome: String, frame: int, descricao: String) -> Node2D:
	var instance = cardScene.instantiate()
	instance.nome = nome
	instance.frame = frame
	instance.descricao = descricao
	return instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)
	#var spriteCard = get_node("carta_sprite")
	$carta_sprite.frame = frame;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
