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
var gerCartas: GerenciadorCartasClass

static func create(donoDaMao = null) -> MaoJogador:
	var newObject = MaoJogador.new()
	newObject.playerReference = donoDaMao
	return newObject
	
func _ready() -> void:
	gerCartas = GerenciadorCartasClass.new()
	if (!playerReference):
		playerReference = $"../Jogador"
	
	get_tree().get_root().size_changed.connect(resize)
	center_screen_x = get_viewport().size.x / 2
	MAO_Y = get_viewport().size.y - 100
	cartas_tesouro = gerCartas.carregarCartasTesouro()
	cartas_monstro = gerCartas.carregarCartasMonstro()
	
	for i in range(HAND_COUNT_TREASURE):		
		var cartaTesouro = gerCartas.sortearCartaTesouro(self.maoJogador, playerReference)
		if !isBot:
			$"../cartasDaMesa".add_child(cartaTesouro)
		addMao(cartaTesouro)

	for i in range(HAND_COUNT_DOOR):		
		var dicCartasDoor = {
			0: gerCartas.sortearCartaMonstro(self.maoJogador, playerReference),
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
		
func resize() -> void:
	if !isBot:
		center_screen_x = get_viewport().size.x / 2
		MAO_Y = get_viewport().size.y - 100
		updatePosicoes()
