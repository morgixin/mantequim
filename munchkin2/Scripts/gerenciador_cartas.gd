class_name GerenciadorCartasClass extends Node2D
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const CARD_ITEM_PATH = "res://Scenes/Cartas/CartaItem.tscn"
const MALDITION_PATH = "res://Scenes/Cartas/CartaMaldicao.tscn"
const RACE_PATH = "res://Scenes/Cartas/CartaRaca.tscn"
const CLASS_PATH = "res://Scenes/Cartas/CartaClasse.tscn"

static var instancia = null
static func getInstancia():
	if instancia == null:
		instancia = GerenciadorCartasClass.new()
	return instancia

func carregarCartas(path):
	var json_file = FileAccess.open(path, FileAccess.READ)
	var cartas_array = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	return cartas_array

func gerarRandom(cartas_array):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var selectedCard = cartas_array[rng.randi_range(0, cartas_array.size()-1)]
	return selectedCard

func sortearCarta(path: String, tipo: int, cenario: int = 1, mao = null, playerReference = null) -> CartaClass:
	var dictTipos = {
		0: InstanciarMonstros,
		1: InstanciarMaldicao,
		2: InstanciarClasses,
		3: InstanciarRaca,
		4: InstanciarTesouro
	}
	var cartas_array = carregarCartas(path)
	var selectedCard 
	if cenario == 1: #sorteio para mesa
		selectedCard = gerarRandom(cartas_array)
	else: #sorteio para mão
		selectedCard = evitarRepeticao(cartas_array, mao)
	var newCard = dictTipos[tipo].instanciarCartas(selectedCard, playerReference)
	return newCard
	
func evitarRepeticao(cartas_array, mao):
	var cartaSelecionada = gerarRandom(cartas_array)
	for carta in mao:
		if (carta.descricao == cartaSelecionada.descricao_carta) and (carta.nome == cartaSelecionada.nome_carta):
			cartaSelecionada = evitarRepeticao(cartas_array, mao)
	return cartaSelecionada

func gerarCartaPorta(path) -> CartaClass:	#TODO: ADICIONAR MAIS TIPOS DE CARTA NO SORTEIO
	var dicCartasDoor = {
			0: sortearCarta(path, 0),
			#1: sortearCarta(path, 1),
			#2: sortearCarta(path, 2),
			#3: sortearCarta(path, 3),
		}
	var cartaSorteada = dicCartasDoor[randi_range(0,0)]
	return cartaSorteada

func _ready() -> void:
	pass
