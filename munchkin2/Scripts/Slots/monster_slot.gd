extends Node2D
var stack_index: int = 2
var discard_confirmation

var cartaEscolhida: Array[CartaClass] = []
var promptBtn

func _ready() -> void:
	position = Vector2(get_viewport().size.x/2, get_viewport().size.y/2)
	pass # Replace with function body.	

func setPrompt(prompt_obt: Prompt):
	promptBtn = prompt_obt
	
func getNextStackIndex() -> int:
	stack_index += 1
	return stack_index

func adicionarCartaSlot(carta: CartaClass) -> void:
	cartaEscolhida.append(carta)
	verificarBotao()

func verificarBotao() -> void:
	if (promptBtn != null):
		if (cartaEscolhida.size() > 0):
			promptBtn.mudarStatusBotao(0, false)
		else:
			promptBtn.mudarStatusBotao(0, true)

func removerCartaSlot(carta: CartaClass) -> void:
	if (carta in cartaEscolhida):
		cartaEscolhida.erase(carta)
	verificarBotao()

func desativarCartas() -> void:
	for carta in cartaEscolhida:
		carta.get_node("Area2D/CollisionShape2D").disabled = true
		carta.hide()

func admiteCarta(carta: CartaClass) -> bool:
	if carta.tipo != 3:
		return false
	if cartaEscolhida.size() > 0:
		return false
	var donoDaCarta = carta.donoDaCarta
	if (carta.min_level > donoDaCarta.nivel):	
		return false
	
	return true
