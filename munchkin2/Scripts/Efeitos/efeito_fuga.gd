class_name EfeitoFuga extends Efeito

func _aplicarEfeito() -> void:
	if (alvoMonstroDoEfeito):
		return
	self.alvoJogadorDoEfeito.setFuga(false)

func _finalizarEfeito() -> void:
	if (alvoMonstroDoEfeito):
		return
	self.textoResultado = " não pode mais fugir!!"
