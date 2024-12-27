extends Node2D

const HAND_COUNT = 6
const CARD_PATH = "res://Scenes/Carta.tscn"
const CARD_WIDTH = 120
const MAO_Y = 633

var maoJogador = []
var center_screen_x 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	var cardScene = preload(CARD_PATH)
	for i in range(HAND_COUNT):
		var newCard = cardScene.instantiate().create_card_instance("a", randi_range(0, 22), "b")
		newCard.name = "Carta-%s" % str(i)
		$"../cartasDaMesa".add_child(newCard)
		addMao(newCard)

func addMao(card):
	if card not in maoJogador:
		maoJogador.insert(0, card)
		updatePosicoes()
	else:
		animateCardToPosition(card, card.posInicial)
		
	
func updatePosicoes():
	print("Reorganizando cartas")
	for i in range(maoJogador.size()):
		maoJogador[i].z_index = maoJogador.size() - i
		var newPosition = Vector2(calculaPosicao(i), MAO_Y + randi_range(0, 25))
		var random_degrees = randf_range(-3, 3)
		var cartinha = maoJogador[i]
		cartinha.posInicial = newPosition
		cartinha.rotation = deg_to_rad(random_degrees)
		animateCardToPosition(cartinha, newPosition)

func animateCardToPosition(card, newPosition):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPosition, 0.35)
		
func calculaPosicao(index):
	var totalWidth = (maoJogador.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index*CARD_WIDTH - totalWidth/2
	return x_offset
	
func removeDaMao(card):
	if card in maoJogador:
		maoJogador.erase(card)
		updatePosicoes()
		
func _process(delta: float) -> void:
	pass
