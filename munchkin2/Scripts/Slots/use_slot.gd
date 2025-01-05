extends Node2D
var stack_index: int = 2
var cartasUsadas: Array[CartaClass] = []
var slotAjudaJogador = false #Determina se esse slot mostrará prompt para que o usuário escolha quem vai ajudar
var use_card_confirmation
var btn

func _ready() -> void:
	position = Vector2(get_viewport().size.x/2, get_viewport().size.y/2)
	pass # Replace with function body.	

func desativarCartas() -> void:
	for carta in cartasUsadas:
		carta.get_node("Area2D/CollisionShape2D").disabled = true
		carta.hide()

func getNextStackIndex() -> int:
	stack_index += 1
	return stack_index
	
func admiteCarta(carta) -> bool:
	if (slotAjudaJogador):
		if (carta.tipo != 1):
			return false
		if (carta.acao != 1 and carta.acao != 2):
			return false
	else:
		if (carta.tipo != 1 and carta.tipo != 6):
			return false
	return true
	
func removerDaMao(carta: CartaClass) -> void:
	if carta in cartasUsadas:
		carta.alvoDoEfeito = -1
		cartasUsadas.erase(carta)

func addCartaUsada(carta: CartaClass) -> void:
	if (slotAjudaJogador == false):
		if (btn):
			btn.hide()
		use_card_confirmation.customize("Quem deseja ajudar?", "Escolha entre o monstro ou o jogador", "Jogador", "Monstro", false, false)
		var escolheuJogador = await use_card_confirmation.prompt(true)
		if (escolheuJogador):
			carta.alvoDoEfeito = 1
		else:
			carta.alvoDoEfeito = 0
		cartasUsadas.append(carta)
		if (btn):
			btn.show()
	else:
		carta.alvoDoEfeito = 1
		cartasUsadas.append(carta)
