class_name MaoJogador extends Node2D

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
var isBot: bool = false
var playerReference



static func create(donoDaMao = null) -> MaoJogador:
	var newObject = MaoJogador.new()
	newObject.playerReference = donoDaMao
	return newObject
	
func _ready() -> void:
	if (!playerReference):
		playerReference = $"../Jogador"
	
	get_tree().get_root().size_changed.connect(resize)
	center_screen_x = get_viewport().size.x / 2
	MAO_Y = get_viewport().size.y - 100
	carregarCartasTesouro()
	carregarCartasMonstro()
	for i in range(HAND_COUNT_TREASURE):		
		var cartaTesouro = sortearCartaTesouro()
		if !isBot:
			$"../cartasDaMesa".add_child(cartaTesouro)
		addMao(cartaTesouro)
	for i in range(HAND_COUNT_DOOR):		
		var dicCartasDoor = {
			0: sortearCartaMonstro(),
			#1: sortearCartaMaldicao(),
			#2: sortearCartaRaca()
		}
		var cartaDoor = dicCartasDoor[randi_range(0,0)]
		if !isBot:
			$"../cartasDaMesa".add_child(cartaDoor)
		addMao(cartaDoor)

func addMao(card):
	if card not in maoJogador:
		maoJogador.insert(0, card)
		if !isBot:
			updatePosicoes()
	elif !isBot:
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
		if !isBot:
			updatePosicoes()
		
func carregarCartasTesouro():
	var json_file = FileAccess.open("res://data/cartas_tesouro.json", FileAccess.READ)
	cartas_tesouro = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	
func carregarCartasMonstro():
	var json_file = FileAccess.open("res://data/cartas_monstro.json", FileAccess.READ)
	cartas_monstro = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	

func instanciarCartaMonstro(selectedCard):
	var cardMonsterScene = preload(CARD_MONSTER_PATH)
	var newCard = cardMonsterScene.instantiate()
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.tipo = selectedCard.tipo
	newCard.forca = selectedCard.força
	newCard.força_especifica = selectedCard.força_especifica
	newCard.classe_especifica = selectedCard.classe_especifica
	newCard.raça_especifica = selectedCard.raça_especifica
	newCard.donoDaCarta = playerReference
	return newCard
	
func instanciarCartaTesouro(selectedCard):
	var cardItemScene = preload(CARD_ITEM_PATH)
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
	newCard.acao = selectedCard.acao
	newCard.donoDaCarta = playerReference
	return newCard

func sortearCartaTesouro() -> CartaItem:
	var selectedCard = evitarRepeticao(cartas_tesouro)
	var newCard = instanciarCartaTesouro(selectedCard)
	return newCard
	
func sortearCartaMonstro() -> CartaMonstro:	
	var selectedCard = evitarRepeticao(cartas_monstro)
	var newCard = instanciarCartaMonstro(selectedCard)
	return newCard

func evitarRepeticao(cartas_array):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var selectedCard = cartas_array[rng.randi_range(0, cartas_monstro.size()-1)]
	var cartaSelecionada = selectedCard
	for carta in self.maoJogador:
		if (carta.descricao == cartaSelecionada.descricao_carta) and (carta.nome == cartaSelecionada.nome_carta):
			cartaSelecionada = evitarRepeticao(cartas_array)
	return cartaSelecionada
		

func resize() -> void:
	if !isBot:
		center_screen_x = get_viewport().size.x / 2
		MAO_Y = get_viewport().size.y - 100
		updatePosicoes()
