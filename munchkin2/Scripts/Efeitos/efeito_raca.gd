class_name EfeitoMudaRaca extends Efeito
var mudouRaça = false
func _aplicarEfeito() -> void:
	if (alvoMonstroDoEfeito):
		return
	
	var raca = self.alvoJogadorDoEfeito.getRacaJogador()
	var quantidadeDeNiveis = self.acaoParametro
	if raca != 1:
		mudouRaça = true
		var mao_equipados_reference = self.alvoJogadorDoEfeito.maoCartasEquipadas
		var mao_equipados_array = mao_equipados_reference.cartasEquipadas
		var acharCartaRaca: CartaClass = null
		for carta in mao_equipados_array:
			if carta.tipo != 5:
				continue
			acharCartaRaca = carta
			break
		acharCartaRaca.hide()
		acharCartaRaca.scale = Vector2(0,0)
		mao_equipados_reference.removeDaMao(acharCartaRaca)
	else:
		self.alvoJogadorDoEfeito.aumentarNivel(acaoParametro)

func _finalizarEfeito():
	if (alvoMonstroDoEfeito):
		return
		
	if (alvoJogadorDoEfeito.nivel <= 0):
		alvoJogadorDoEfeito.estaMorto = true
	
	var raca = self.alvoJogadorDoEfeito.getRacaJogador()
	if (mudouRaça):
		self.textoResultado = " Voltou a ser humano!"
	else:
		self.textoResultado = " Perdeu um nível"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
