class_name CartaClass extends Node2D

signal hovered
signal hoveredOff
var posInicial

const CARD_PATH = "res://Scenes/Cartas/Carta.tscn"

@export var nome: String
@export var descricao: String
@export var frame: int
var isTreasure: bool
var isMonster: bool = false
var cardScene = preload(CARD_PATH)
var donoDaCarta


func create_card_instance(nome: String, frame: int, descricao_new: String) -> Node2D:
	var instance = cardScene.instantiate()
	instance.nome = nome
	instance.frame = frame
	instance.descricao = descricao_new
	return instance

func definirFrame() -> void:
	$carta_sprite.frame = frame;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
