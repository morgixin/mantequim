class_name EfeitoRemoveClasse extends Efeito

func _aplicarEfeito() -> void:
	if (alvoMonstroDoEfeito):
		return
	var classe = self.alvoJogadorDoEfeito.getClasseJogador()
	var quantidadeDeNiveis = self.acaoParametro
	if classe != -1:
		var mao_equipados_reference = self.alvoJogadorDoEfeito.maoCartasEquipadas
		var mao_equipados_array = mao_equipados_reference.cartasEquipadas
		var acharCartaClasse: CartaClass = null
		for carta in mao_equipados_array:
			if carta.tipo != 4:
				continue
			acharCartaClasse = carta
			break
		mao_equipados_reference.removeDaMao(acharCartaClasse)
	else:
		self.alvoJogadorDoEfeito.aumentarNivel(acaoParametro)

func _finalizarEfeito():
	if (alvoMonstroDoEfeito):
		return
	if (alvoJogadorDoEfeito.nivel <= 0):
		alvoJogadorDoEfeito.estaMorto = true
	var classe = self.alvoJogadorDoEfeito.getClasseJogador()
	if (classe == -1):
		self.textoResultado = " ficou sem classe!"
	else:
		self.textoResultado = " perdeu um nível"
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
