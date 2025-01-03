class_name GerenciadorCartasClass extends Node2D
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const CARD_ITEM_PATH = "res://Scenes/Cartas/CartaItem.tscn"

func instanciarCartaMonstro(selectedCard, playerReference = null):
	var cardMonsterScene = preload(CARD_MONSTER_PATH)
	var newCard = cardMonsterScene.instantiate()
	newCard.tesouro = selectedCard.tesouro
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.tipo = selectedCard.tipo
	newCard.forca = selectedCard.força
	newCard.forca_total = newCard.forca
	newCard.força_especifica = selectedCard.força_especifica
	newCard.classe_especifica = selectedCard.classe_especifica
	newCard.raça_especifica = selectedCard.raça_especifica
	newCard.lvl_reward = selectedCard.lvl_reward
	newCard.acao = selectedCard.acao
	newCard.acaoParametro = selectedCard.acao_parametro
	newCard.donoDaCarta = playerReference
	return newCard

func instanciarCartaTesouro(selectedCard, playerReference = null):
	var CardSceneItem = preload(CARD_ITEM_PATH)
	var newCard = CardSceneItem.instantiate()
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
	newCard.acao_parametro = selectedCard.acao_parametro
	newCard.donoDaCarta = playerReference
	return newCard
	
func carregarCartasMonstro():
	var json_file = FileAccess.open("res://data/cartas_monstro.json", FileAccess.READ)
	var cartas_monstro = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	return cartas_monstro

func carregarCartasTesouro():
	var json_file = FileAccess.open("res://data/cartas_tesouro.json", FileAccess.READ)
	var cartas_tesouro = JSON.parse_string(json_file.get_as_text())
	json_file.close()
	return cartas_tesouro
	
func gerarRandom(cartas_array):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var selectedCard = cartas_array[rng.randi_range(0, cartas_array.size()-1)]
	return selectedCard

func sortearCartaMonstroMesa() -> CartaMonstro:	
	var cartas_monstro = carregarCartasMonstro()
	var selectedCard = gerarRandom(cartas_monstro)
	var newCard = instanciarCartaMonstro(selectedCard)
	return newCard
	
func sortearCartaTesouro(mao, playerReference):
	var cartas_tesouro = carregarCartasTesouro()
	var selectedCard = evitarRepeticao(cartas_tesouro, mao)
	var newCard = instanciarCartaTesouro(selectedCard, playerReference)
	return newCard

func sortearCartaMonstro(mao, playerReference) -> CartaMonstro:	
	var cartas_monstro = carregarCartasMonstro()
	var selectedCard = evitarRepeticao(cartas_monstro, mao)
	var newCard = instanciarCartaMonstro(selectedCard, playerReference)
	return newCard
	
func evitarRepeticao(cartas_array, mao):
	var cartaSelecionada = gerarRandom(cartas_array)
	for carta in mao:
		if (carta.descricao == cartaSelecionada.descricao_carta) and (carta.nome == cartaSelecionada.nome_carta):
			cartaSelecionada = evitarRepeticao(cartas_array, mao)
	return cartaSelecionada

func sortearCartaPorta():	#TODO: ADICIONAR MAIS TIPOS DE CARTA NO SORTEIO
	var dicCartasDoor = {
			0: sortearCartaMonstroMesa(),
			#1: sortearCartaMaldicao(),
			#2: sortearCartaRaca()
		}
	var cartaSorteada = dicCartasDoor[randi_range(0,0)]
	return cartaSorteada

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
