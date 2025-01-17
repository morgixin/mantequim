class_name MaoJogador extends Node2D

const HAND_COUNT_TREASURE = 4
const HAND_COUNT_DOOR = 4
const CARD_ITEM_PATH = "res://Scenes/Cartas/CartaItem.tscn"
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const DATA_MONSTER = "res://data/cartas_monstro.json"
const DATA_ITEM = "res://data/cartas_tesouro.json"
const DATA_MALDITION = "res://data/cartas_maldicao.json"
const DATA_CLASS = "res://data/cartas_classe.json"
const DATA_RACA = "res://data/cartas_raca.json"
const CARD_WIDTH = 120
var MAO_Y: int

var maoJogador: Array[CartaClass] = []
var center_screen_x 
var cartas_tesouro = []
var cartas_monstro = []
var isBot: bool = false
var playerReference
var gerCartas = GerenciadorCartasClass.getInstancia()

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
	cartas_tesouro = gerCartas.carregarCartas(VariaveisGlobais.DATA_ITEM)
	cartas_monstro = gerCartas.carregarCartas(VariaveisGlobais.DATA_MONSTER)
	gerarCartasTesouro(HAND_COUNT_TREASURE)
	gerarCartasPorta(HAND_COUNT_DOOR)

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
		
func gerarCartasTesouro(qtd: int):
	for i in range(qtd):		
		var cartaTesouro = gerCartas.sortearCarta(VariaveisGlobais.DATA_ITEM, 4, 2, self.maoJogador, playerReference)
		if !isBot:
			$"../cartasDaMesa".add_child(cartaTesouro)
		addMao(cartaTesouro)

func gerarCartasPorta(qtd: int):
	for i in range(qtd):		
		var dicCartasDoor = {
			0: gerCartas.sortearCarta(VariaveisGlobais.DATA_MONSTER, 0, 2, self.maoJogador, playerReference),
			1: gerCartas.sortearCarta(VariaveisGlobais.DATA_MALDITION, 1, 2, self.maoJogador, playerReference),
			2: gerCartas.sortearCarta(VariaveisGlobais.DATA_CLASS, 2, 2, self.maoJogador, playerReference),
			3: gerCartas.sortearCarta(VariaveisGlobais.DATA_RACA, 3, 2, self.maoJogador, playerReference)
		}
		var cartaDoor = dicCartasDoor[randi_range(0,3)]
		if !isBot:
			$"../cartasDaMesa".add_child(cartaDoor)
		addMao(cartaDoor)

func resize() -> void:
	if !isBot:
		center_screen_x = get_viewport().size.x / 2
		MAO_Y = get_viewport().size.y - 100
		updatePosicoes()
		
func verificarCartasMonstro(procurar_por_menor_nivel: bool = true) -> CartaMonstro:
	var carta_escolhida: CartaMonstro = null
	for carta in maoJogador:
		if carta.tipo != 3:
			continue
		if carta_escolhida == null and procurar_por_menor_nivel == false and  playerReference.nivel >= carta.min_level:
			carta_escolhida = carta
			break
		if procurar_por_menor_nivel:
			if carta_escolhida == null:
				carta_escolhida = carta
			elif carta_escolhida.forca > carta.forca:
				carta_escolhida = carta
	return carta_escolhida
		
func limpaMao(qtd: int):
	if qtd == 99 or self.maoJogador.size() < qtd:
		for i in range(self.maoJogador.size()):
			maoJogador[-1].scale = Vector2(0,0)
			maoJogador[-1].hide()
			self.removeDaMao(maoJogador[-1])

	else:
		for i in range(qtd):
			var cartaEscolhida = maoJogador[randi()%(self.maoJogador.size())]
			cartaEscolhida.hide()
			cartaEscolhida.scale = Vector2(0,0)
			self.removeDaMao(cartaEscolhida)
			
			
		
		
	
