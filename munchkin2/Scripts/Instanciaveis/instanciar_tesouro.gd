class_name InstanciarTesouro extends Instanciador

static func instanciarCartas(selectedCard, playerReference = null):
	var CardSceneItem = preload(VariaveisGlobais.CARD_ITEM_PATH)
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
