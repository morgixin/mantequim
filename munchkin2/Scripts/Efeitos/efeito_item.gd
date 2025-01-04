class_name EfeitoRemoveItem
extends Efeito

var cartasEncontradas = null

func _aplicarEfeito() -> void:
	var quantidadeDeNiveis = self.acaoParametro
	var target = self.target
	
	if (!self.alvoJogadorDoEfeito):
		return
		
	var mao_de_cartas_equipadas = alvoJogadorDoEfeito.maoCartasEquipadas.cartasEquipadas
	
	var targetDict = {
		99: encontraEquipamentoMaisForte(mao_de_cartas_equipadas),
		1: encontrarEquipamentoAleatorio(mao_de_cartas_equipadas),
		2: encontrarBigItemAleatorio(mao_de_cartas_equipadas),
		3: encontrarFootgearAleatorio(mao_de_cartas_equipadas),
		4: encontrarArmorAleatorio(mao_de_cartas_equipadas),
		5: todosOsEquipamentos(mao_de_cartas_equipadas),
		6: encontrarHeadgearAleatorio(mao_de_cartas_equipadas),
	}
	
	
	cartasEncontradas = targetDict[target]

	if (cartasEncontradas):
		for carta in cartasEncontradas:
			self.alvoJogadorDoEfeito.maoCartasEquipadas.removeDaMao(carta)
			#var tween = get_tree().create_tween()
			#tween.tween_property(carta, "scale", Vector2(0,0), 0.3)
			#await tween.finished
			self.alvoJogadorDoEfeito.scale = Vector2(0,0)
			carta.hide()
			
	else:
		if (self.alvoDoEfeito == 1):
			self.alvoJogadorDoEfeito.aumentarNivel(quantidadeDeNiveis)

func _finalizarEfeito() -> void:
	var textEquipamentoDictEncontrado = {
		99: "o equipamento mais forte",
		1: "um equipamento aleatório",
		2: "um equipamento grande",
		3: "um footgear",
		4: "uma armor",
		5: "todos os equipamentos",
		6: "um headgear"
	}

	var textEquipamentoDictNaoEncontrado = {
		99: "nenhum equipamento",
		1: "um equipamento aleatório",
		2: "um equipamento grande",
		3: "um footgear",
		4: "uma armor",
		5: "nenhum equipamento",
		6: "um headgear"
	}

	if (!alvoJogadorDoEfeito):
		return

	if (cartasEncontradas):
		self.textoResultado = "Perdeu "+textEquipamentoDictEncontrado[self.target]
	else:
		if (self.alvoJogadorDoEfeito.nivel - abs(self.acaoParametro) <= 0):
			self.alvoJogadorDoEfeito.estaMorto = true

		if (self.alvoDoEfeito == 0):
			self.textoResultado = "O monstro recebeu um incremento de " + str(self.acaoParametro) + " de força"
		if (self.alvoDoEfeito == 1):
			if (self.acaoParametro < 0):
				self.textoResultado = "Não possui " + textEquipamentoDictNaoEncontrado[self.target]+" e perdeu " + str(abs(self.acaoParametro)) + " de nível"
			else:
				self.textoResultado = "Ganhou " + str(self.acaoParametro) + " de nível"



# Implementar information expert
func encontraEquipamentoMaisForte(mao_de_carta: Array[CartaClass]):
	var equipamentoMaisForte = null
	var forcaEquipamentoMaisForte = -1
	for carta in mao_de_carta:
		if (carta.tipo != 2):
			continue
		if (carta.forca > forcaEquipamentoMaisForte):
			equipamentoMaisForte = carta
			forcaEquipamentoMaisForte = carta.forca
	return [equipamentoMaisForte] if equipamentoMaisForte != null else null

func encontrarEquipamentoAleatorio(mao_de_carta: Array[CartaClass]):
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in mao_de_carta:
		if (carta.tipo != 2):
			continue
		if (carta.isBig):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func encontrarBigItemAleatorio(mao_de_carta: Array[CartaClass]):
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in mao_de_carta:
		if (carta.tipo != 2):
			continue
		if (!carta.isBig):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func encontrarFootgearAleatorio(mao_de_carta: Array[CartaClass]):
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in mao_de_carta:
		if (carta.tipo != 2):
			continue
		if (carta.tipo_equipamento != 6):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func encontrarArmorAleatorio(mao_de_carta: Array[CartaClass]):
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in mao_de_carta:
		if (carta.tipo != 2):
			continue
		if (carta.tipo_equipamento != 4):
			continue
		equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null

func todosOsEquipamentos(mao_de_carta: Array[CartaClass]):
	var equipamentos = []
	for carta in mao_de_carta:
		if (carta.tipo != 2):
			continue
		equipamentos.append(carta)
	return equipamentos

func encontrarHeadgearAleatorio(mao_de_carta: Array[CartaClass]):
	var equipamentoAleatorio = null
	var equipamentos = []
	for carta in mao_de_carta:
		if (carta.tipo != 2):
			continue
		if (carta.tipo_equipamento != 5):
			continue
		if (carta.tipo == 2 and carta.tipo_equipamento == 5):
			equipamentos.append(carta)
	if (equipamentos.size() > 0):
		equipamentoAleatorio = equipamentos[randi() % equipamentos.size()]
	return [equipamentoAleatorio] if equipamentoAleatorio != null else null
