class_name InstanciarMaldicao extends Instanciador

static func instanciarCartas(selectedCard, playerReference = null):
	var CardScene = preload(VariaveisGlobais.MALDITION_PATH)
	var newCard = CardScene.instantiate()
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.tipo = selectedCard.tipo
	newCard.acao = selectedCard.acao
	newCard.acao_parametro = selectedCard.acao_parametro
	newCard.target = selectedCard.target
	newCard.donoDaCarta = playerReference
	return newCard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
