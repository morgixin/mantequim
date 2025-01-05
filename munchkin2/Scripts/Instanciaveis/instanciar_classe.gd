class_name InstanciarClasses extends Instanciador

static func instanciarCartas(selectedCard, playerReference = null) -> CartaClass:
	var CardScene = preload(VariaveisGlobais.CLASS_PATH)
	var newCard = CardScene.instantiate()
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.tipo = selectedCard.tipo
	newCard.classe_id = selectedCard.classe
	return newCard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
