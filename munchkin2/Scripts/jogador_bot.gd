class_name JogadorBot extends Jogador

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isHost = false

func aplicarEquipamentos() -> void:
	print("CARTAS EQUIPADAS DE "+self.jogador+":")
	print(maoCartasEquipadas.cartasEquipadas)
	print("CARTAS DA MAO DE "+self.jogador+":")
	print(maoCartas.maoJogador)
	print("-----------------------")
	var array_cartas = self.maoCartas.maoJogador
	var array_equipados = self.maoCartasEquipadas.cartasEquipadas
	var appendDict = {1: [], 2: [], 3: [], 4: [], 5: [], 6: []}
	
	for carta in array_cartas:
		if carta.tipo != 2:
			continue
		appendDict[carta.tipo_equipamento].append(carta)
		
	for i in range(1, appendDict.size() + 1):
		appendDict[i].sort_custom(custom_array_sort)
		
	for carta in array_equipados:
		if carta.tipo != 2:
			continue
		var melhorCartaDict = appendDict[carta.tipo_equipamento][0] if appendDict[carta.tipo_equipamento].size() > 0 else null
		if melhorCartaDict != null:
			if melhorCartaDict.forca > carta.forca:
				self.maoCartasEquipadas.removeDaMao(carta)
				self.maoCartas.addMao(carta)
				if(admitirCarta(melhorCartaDict)):
					self.maoCartas.removeDaMao(melhorCartaDict)
					self.maoCartasEquipadas.addMao(melhorCartaDict)
					appendDict[carta.tipo_equipamento].erase(melhorCartaDict)
				else:
					self.maoCartas.removeDaMao(carta)
					self.maoCartasEquipadas.addMao(carta)
		
	for chave in appendDict:
		var nome = admitirCarta(appendDict[chave][0]) if appendDict[chave].size() > 0 else null
		if appendDict[chave].size() > 0 and admitirCarta(appendDict[chave][0]):
			#print("--------------- CARTA DE "+self.jogador+" --------------- ")
			#print("nome: "+(appendDict[chave][0]).nome)
			#print("força: "+str(appendDict[chave][0].forca))
			#print("Tipo: "+equipDict[appendDict[chave][0].tipo_equipamento])
			self.maoCartas.removeDaMao(appendDict[chave][0])
			self.maoCartasEquipadas.addMao(appendDict[chave][0])
			appendDict[chave].erase(appendDict[chave][0])
	
	print("CARTAS EQUIPADAS DE "+self.jogador+":")		
	print(maoCartasEquipadas.cartasEquipadas)
	print("CARTAS DA MAO DE "+self.jogador+":")
	print(maoCartas.maoJogador)
	print("-----------------------")
func custom_array_sort(a, b):
	return a.forca > b.forca

func _process(delta: float) -> void:
	#print(maoCartas.maoJogador)
	player_box.customize(jogador, classeDict[classe], nivel, forca_turno, racaDict[raca])
