class_name JogadorBot extends Jogador

func _ready() -> void:
	isHost = false
	calcularForcaTurno()

func aplicarClassesRacas() -> void:
	var array_cartas = self.maoCartas.maoJogador
	for carta in array_cartas:
		if carta.tipo != 4 and carta.tipo != 5:
			continue
		if admitirCarta(carta):
			self.maoCartas.removeDaMao(carta)
			self.maoCartasEquipadas.addMao(carta)
	
func aplicarEquipamentos() -> void:
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
		if appendDict[chave].size() > 0 and admitirCarta(appendDict[chave][0]):
			self.maoCartas.removeDaMao(appendDict[chave][0])
			self.maoCartasEquipadas.addMao(appendDict[chave][0])
			appendDict[chave].erase(appendDict[chave][0])
func custom_array_sort(a, b):
	return a.forca > b.forca

func descartarCartas() -> void:
	var array_cartas = self.maoCartas.maoJogador
	var array_equipados = self.maoCartasEquipadas.cartasEquipadas
	
	if array_cartas.size() <= 5:
		return
	
	# Descarta cartas com força menor das que estão equipadas
	for carta in array_cartas:
		if carta.tipo != 2:
			continue
		for carta_equipada in array_equipados:
			if carta_equipada.tipo != 2:
				continue
			if carta_equipada.tipo_equipamento != carta.tipo_equipamento:
				continue
			if carta_equipada.forca > carta.forca:
				self.maoCartas.removeDaMao(carta)
				break
		if array_cartas.size() <= 5:
			break

	if array_cartas.size() <= 5:
		return

	# Se eu já tiver uma classe ou raça aplicadas, descarta as cartas de classe e raça
	if self.classe != -1:
		for carta in array_cartas:
			if carta.tipo == 4:
				self.maoCartas.removeDaMao(carta)
				if array_cartas.size() <= 5:
					break
	
	if array_cartas.size() <= 5:
		return

	if self.raca != -1:
		for carta in array_cartas:
			if carta.tipo == 5:
				self.maoCartas.removeDaMao(carta)
				if array_cartas.size() <= 5:
					break
	
	if array_cartas.size() <= 5:
		return

	# Descartar cartas aleatoriamente 
	while array_cartas.size() > 5:
		var index = randi() % array_cartas.size()
		self.maoCartas.removeDaMao(array_cartas[index])

func _process(_delta: float) -> void:
	player_box.customize(self, jogador, classeDict[classe], nivel, forca_turno, racaDict[raca])
