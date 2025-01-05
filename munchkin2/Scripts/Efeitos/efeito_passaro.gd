class_name EfeitoPassaro extends Efeito

func _aplicarEfeito() -> void:
	if (self.alvoDoEfeito == 1):
		return
	self.alvoMonstroDoEfeito.setZerado(true)
	var forcaDoMonstro = self.alvoMonstroDoEfeito.calcularForcaTotal()

func _finalizarEfeito() -> void:
	if (self.alvoDoEfeito == 1):
		self.textoResultado = " Este efeito só é aplicado em monstros."
	else:
		self.textoResultado = " Seu monstro virou um papagaio!"
