class_name EfeitoRemoveItem
extends Efeito

var cartasEncontradas = null

func _aplicarEfeito() -> void:
	var quantidadeDeNiveis = self.acaoParametro
	var target = self.target
	
	if (!self.alvoJogadorDoEfeito):
		return
		
	var mao_de_cartas_equipadas = alvoJogadorDoEfeito.maoCartasEquipadas.cartasEquipadas
	var mao_equipadas_reference = alvoJogadorDoEfeito.maoCartasEquipadas
	
	# Information expert
	var targetDict = {
		99: mao_equipadas_reference.encontraEquipamentoMaisForte(mao_de_cartas_equipadas),
		1: mao_equipadas_reference.encontrarEquipamentoAleatorio(mao_de_cartas_equipadas),
		2: mao_equipadas_reference.encontrarBigItemAleatorio(mao_de_cartas_equipadas),
		3: mao_equipadas_reference.encontrarFootgearAleatorio(mao_de_cartas_equipadas),
		4: mao_equipadas_reference.encontrarArmorAleatorio(mao_de_cartas_equipadas),
		5: mao_equipadas_reference.todosOsEquipamentos(mao_de_cartas_equipadas),
		6: mao_equipadas_reference.encontrarHeadgearAleatorio(mao_de_cartas_equipadas),
	}
		
	cartasEncontradas = targetDict[target]

	if (cartasEncontradas):
		print(cartasEncontradas.nome)
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
