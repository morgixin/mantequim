extends Node2D
var stack_index: int = 2
#var cartasUsadas = []
#var slotAjudaJogador = false #Determina se esse slot mostrará prompt para que o usuário escolha quem vai ajudar
var discard_confirmation
var btn
var maoDoJogador = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(get_viewport().size.x/2, get_viewport().size.y/2)
	pass # Replace with function body.	

#func desativarCartas() -> void:
	#for carta in cartasUsadas:
		#carta.get_node("Area2D/CollisionShape2D").disabled = true
		#carta.hide()

func getNextStackIndex() -> int:
	stack_index += 1
	return stack_index
	
func confirmaDescarte() -> bool:
	if btn:
		btn.hide()
	discard_confirmation.customize("Certeza que vai jogar essa carta fora?", "Para SEMPRE?", "Sim, tenho certeza", "Humm... vou pensar melhor", false, false)
	var apagou = await discard_confirmation.prompt(true)
	if apagou and maoDoJogador.size() <= 5:
		btn.mudarStatusBotao(0,false)	
	if btn:
		btn.show()
	return apagou
	
#func removerDaMao(carta: CartaClass) -> void:
	#print("Removendo Carta")
	#
	#if carta in cartasUsadas:
		#carta.alvoDoEfeito = -1
		#cartasUsadas.erase(carta)
	#print(cartasUsadas)

#func addCartaUsada(carta: CartaClass) -> void:
	#if (slotAjudaJogador == false):
		#if (btn):
			#btn.hide()
		#use_card_confirmation.customize("Quem deseja ajudar?", "Escolha entre o monstro ou o jogador", "Jogador", "Monstro", false, false)
		#var escolheuJogador = await use_card_confirmation.prompt(true)
		#if (escolheuJogador):
			#carta.alvoDoEfeito = 1
		#else:
			#carta.alvoDoEfeito = 0
		#cartasUsadas.append(carta)
		#if (btn):
			#btn.show()
	#else:
		#cartasUsadas.append(carta)
		#carta.alvoDoEfeito = 1
	#print(carta.alvoDoEfeito)
	#print(cartasUsadas)
