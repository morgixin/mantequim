extends Node2D

const HAND_COUNT_TREASURE = 4
const HAND_COUNT_DOOR = 4
const CARD_ITEM_PATH = "res://Scenes/Cartas/CartaItem.tscn"
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const CARD_WIDTH = 120
var MAO_Y: int

var maoJogador = []
var center_screen_x 
var cartas_tesouro = []
var cartas_monstro = []

func carregarCartasTesouro():
	var json_file = FileAccess.open("res://data/cartas_tesouro.json", FileAccess.READ)
	cartas_tesouro = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	
func carregarCartasMonstro():
	var json_file = FileAccess.open("res://data/cartas_monstro.json", FileAccess.READ)
	cartas_monstro = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	
func sortearCartaTesouro() -> CartaItem:
	var cardItemScene = preload(CARD_ITEM_PATH)
	var selectedCard = cartas_tesouro[randi_range(0, cartas_tesouro.size()-1)]
	var newCard = cardItemScene.instantiate()
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.classe_exigida = selectedCard.classe_exigida
	newCard.raca_exigida = selectedCard.raça_exigida
	newCard.classe_restrita = selectedCard.classe_restrita
	newCard.raca_restrita = selectedCard.raça_restrita
	newCard.tipo = selectedCard.tipo
	newCard.isBig = selectedCard.isbig
	newCard.forca = selectedCard.força
	newCard.tipo_equipamento = selectedCard.equip_tipo
	return newCard
	
func sortearCartaMonstro() -> CartaMonstro:	
	var cardMonsterScene = preload(CARD_MONSTER_PATH)
	var selectedCard = cartas_monstro[randi_range(0, cartas_monstro.size()-1)]
	var newCard = cardMonsterScene.instantiate()
	
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.tipo = selectedCard.tipo
	newCard.forca = selectedCard.força
	newCard.força_especifica = selectedCard.força_especifica
	newCard.classe_especifica = selectedCard.classe_especifica
	newCard.raça_especifica = selectedCard.raça_especifica
	
	return newCard

func resize() -> void:
	center_screen_x = get_viewport().size.x / 2
	MAO_Y = get_viewport().size.y - 100
	updatePosicoes()

func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	center_screen_x = get_viewport().size.x / 2
	MAO_Y = get_viewport().size.y - 100
	carregarCartasTesouro()
	carregarCartasMonstro()


	for i in range(HAND_COUNT_TREASURE):		
		var cartaTesouro = sortearCartaTesouro()
		$"../cartasDaMesa".add_child(cartaTesouro)
		addMao(cartaTesouro)
	for i in range(HAND_COUNT_DOOR):		
		var dicCartasDoor = {
			0: sortearCartaMonstro(),
			#1: sortearCartaMaldicao(),
			#2: sortearCartaRaca()
		}
		var cartaDoor = dicCartasDoor[randi_range(0,0)]
		$"../cartasDaMesa".add_child(cartaDoor)
		addMao(cartaDoor)

func addMao(card):
	if card not in maoJogador:
		maoJogador.insert(0, card)
		updatePosicoes()
	else:
		animateCardToPosition(card, card.posInicial)
		
	
func updatePosicoes():
	center_screen_x = get_viewport().size.x / 2
	MAO_Y = get_viewport().size.y - 100
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
