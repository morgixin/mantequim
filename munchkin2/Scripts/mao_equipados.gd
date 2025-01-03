class_name MaoEquipados extends Node2D

const CARD_WIDTH = 120*0.7
const MAO_Y = 80

var cartasEquipadas = []
var end_screen_x 
var isBot: bool = false
var jogadorReference

func _ready() -> void:
	jogadorReference = $"../Jogador"
	get_tree().get_root().size_changed.connect(resize)
	end_screen_x = get_viewport().size.x

func addMao(card):
	if card not in cartasEquipadas:
		cartasEquipadas.insert(0, card)
		print(cartasEquipadas.size())
		print("123")
		if !isBot:
			updatePosicoes()
		else:
			jogadorReference.calcularForcaTurno()
	elif !isBot:
		animateCardToPosition(card, card.posInicial)
		
func calcularForca():
	var forcaAtual = jogadorReference.nivel
	print(cartasEquipadas.size())
	for i in range(cartasEquipadas.size()):
		if cartasEquipadas[i].tipo == 2:
			print("rs")
			forcaAtual += cartasEquipadas[i].forca
			print(cartasEquipadas[i].forca)
	jogadorReference.setForca(forcaAtual)
	print("jk")
	
func updatePosicoes():
	jogadorReference.calcularForcaTurno()
	for i in range(cartasEquipadas.size()):
		cartasEquipadas[i].z_index = cartasEquipadas.size() - i
		var newPosition = Vector2(calculaPosicao(i), MAO_Y - randi_range(0,15))
		var random_degrees = randf_range(-3, 3)
		var cartinha = cartasEquipadas[i]
		var tween = get_tree().create_tween()
		tween.tween_property(cartinha, "scale", Vector2(0.7, 0.7), 0.35)
		cartinha.posInicial = newPosition
		cartinha.rotation = deg_to_rad(random_degrees)
		animateCardToPosition(cartinha, newPosition)

func animateCardToPosition(card, newPosition):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPosition, 0.35)
		
func calculaPosicao(index):
	var totalWidth = (cartasEquipadas.size() - 1) * CARD_WIDTH
	var x_offset = end_screen_x - CARD_WIDTH/2 - 30 - index*CARD_WIDTH
	return x_offset
	
func removeDaMao(card):
	if card in cartasEquipadas:
		cartasEquipadas.erase(card)
		print("removeu")
		if !isBot:
			updatePosicoes()
		else:
			jogadorReference.calcularForcaTurno()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func resize() -> void:
	if !isBot:
		end_screen_x = get_viewport().size.x
		updatePosicoes()
