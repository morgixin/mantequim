extends Node2D

const HAND_COUNT = 6
const CARD_PATH = "res://Scenes/Cartas/CartaItem.tscn"
const CARD_WIDTH = 120
const MAO_Y = 633

var maoJogador = []
var center_screen_x 
var cartas_tesouro = []

func carregarCartas():
	var json_file = FileAccess.open("res://data/cartas_tesouro.json", FileAccess.READ)
	cartas_tesouro = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	
func _ready() -> void:
	carregarCartas()
	center_screen_x = get_viewport().size.x / 2
	var cardScene = preload(CARD_PATH)
	for i in range(HAND_COUNT):		
		var selectedCard = cartas_tesouro[randi_range(0, cartas_tesouro.size()-1)]
		var newCard = cardScene.instantiate()
		newCard.nome = selectedCard.nome_carta
		newCard.descricao = selectedCard.descricao_carta
		newCard.frame = selectedCard.frame
		newCard.name = "Carta-%s" % str(i)
		newCard.classe_exigida = selectedCard.classe_exigida
		newCard.raca_exigida = selectedCard.raça_exigida
		newCard.classe_restrita = selectedCard.classe_restrita
		newCard.raca_restrita = selectedCard.raça_restrita
		newCard.tipo = selectedCard.tipo
		newCard.isBig = selectedCard.isbig
		newCard.forca = selectedCard.força
		newCard.tipo_equipamento = selectedCard.equip_tipo
		$"../cartasDaMesa".add_child(newCard)
		addMao(newCard)

func addMao(card):
	if card not in maoJogador:
		maoJogador.insert(0, card)
		updatePosicoes()
	else:
		animateCardToPosition(card, card.posInicial)
		
	
func updatePosicoes():
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
