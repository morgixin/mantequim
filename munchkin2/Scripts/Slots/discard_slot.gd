extends Node2D
var stack_index: int = 2
var discard_confirmation
var btn
var maoDoJogador = []


func _ready() -> void:
	position = Vector2(get_viewport().size.x/2, get_viewport().size.y/2)
	get_tree().get_root().size_changed.connect(resize)
		
func getNextStackIndex() -> int:
	stack_index += 1
	return stack_index
	
func resize():
	var screen = get_viewport_rect().size
	position = Vector2(screen.x/2+120, screen.y/2)
	
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
