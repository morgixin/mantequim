class_name MaoEquipados extends Node2D

const CARD_WIDTH = 120*0.7
const MAO_Y = 80

var cartasEquipadas: Array[CartaClass] = []
var end_screen_x 
var isBot: bool = false
var jogadorReference

static func create(donoDaMao = null) -> MaoEquipados:
	var newObject = MaoEquipados.new()
	newObject.jogadorReference = donoDaMao
	return newObject

func _ready() -> void:
	if (!jogadorReference):
		jogadorReference = $"../Jogador"
	get_tree().get_root().size_changed.connect(resize)
	end_screen_x = get_viewport().size.x

func addMao(card):
	if card not in cartasEquipadas:
		cartasEquipadas.insert(0, card)
		
		if card.tipo == 4: 
			jogadorReference.setClasseJogador(card.classe_id)
		if card.tipo == 5:
			jogadorReference.setRacaJogador(card.raca_id)
		
		if !isBot:
			updatePosicoes()
		else:
			jogadorReference.calcularForcaTurno()
	elif !isBot:
		animateCardToPosition(card, card.posInicial)
		
func calcularForca():
	var forcaAtual = jogadorReference.nivel
	for i in range(cartasEquipadas.size()):
		if cartasEquipadas[i].tipo == 2:
			forcaAtual += cartasEquipadas[i].forca
	jogadorReference.setForca(forcaAtual)
	
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
		
		if card.tipo == 4: 
			jogadorReference.setClasseJogador(-1)
		if card.tipo == 5:
			jogadorReference.setRacaJogador(1)
		
		if !isBot:
			updatePosicoes()
		else:
			jogadorReference.calcularForcaTurno()

func mudarBloqueioDeck(valor: bool) -> void:
	if !jogadorReference.isHost:
		return
	for carta in cartasEquipadas:
		carta.get_node("Area2D/CollisionShape2D").disabled = valor
	
func resize() -> void:
	if !isBot:
		end_screen_x = get_viewport().size.x
		updatePosicoes()

func encontraEquipamentoMaisForte():
	var equipamentoMaisForte = null
	var forcaEquipamentoMaisForte = -1
	for carta in self.cartasEquipadas:
		if (carta.tipo != 2):
			continue
		if (carta.forca > forcaEquipamentoMaisForte):
			equipamentoMaisForte = carta
			forcaEquipamentoMaisForte = carta.forca
	return [equipamentoMaisForte] if equipamentoMaisForte != null else null

func encontrarEquipamentoAleatorio (tipo_equip: int = 0):
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in self.cartasEquipadas:
		if (carta.tipo != 2):
			continue
		if (carta.isBig):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func encontrarBigItemAleatorio():
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in self.cartasEquipadasa:
		if (carta.tipo != 2):
			continue
		if (!carta.isBig):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func encontrarFootgearAleatorio():
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in self.cartasEquipadas:
		if (carta.tipo != 2):
			continue
		if (carta.tipo_equipamento != 6):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func encontrarArmorAleatorio():
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in self.cartasEquipadas:
		if (carta.tipo != 2):
			continue
		if (carta.tipo_equipamento != 4):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func getEquipados():
	var equipamentos = []
	for carta in self.cartasEquipadas:
		if (carta.tipo != 2):
			continue
		equipamentos.append(carta)
	return equipamentos

func encontrarHeadgearAleatorio():
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in self.cartasEquipadas:
		if (carta.tipo != 2):
			continue
		if (carta.tipo_equipamento != 3):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func encontrarEquipamento(tipo_equip: int = 0, procurandoBig: bool = false):
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in self.cartasEquipadas:
		if (carta.tipo != 2):
			continue
		if (procurandoBig):
			if (!carta.isBig):
				continue
		else:
			if (carta.isBig) and tipo_equip == 0:
				continue
			if tipo_equip != 0:
				if (carta.tipo_equipamento != tipo_equip):
					continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null
