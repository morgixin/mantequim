class_name InstanciarMonstros extends Instanciador

static func instanciarCartas(selectedCard, playerReference = null):
	var cardMonsterScene = preload(VariaveisGlobais.CARD_MONSTER_PATH)
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
	newCard.target = selectedCard.target
	newCard.donoDaCarta = playerReference
	newCard.min_level = selectedCard.min_level
	return newCard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
