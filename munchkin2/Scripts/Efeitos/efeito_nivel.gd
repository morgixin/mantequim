class_name EfeitoModificarNivel
extends Efeito

func _aplicarEfeito() -> void:
	var quantidadeDeNiveis = self.acaoParametro
	if (self.alvoDoEfeito == 0):
		self.alvoMonstroDoEfeito.adicionarIncrementoForca(quantidadeDeNiveis)
	if (self.alvoDoEfeito == 1):
		self.alvoJogadorDoEfeito.aumentarNivel(quantidadeDeNiveis)

func _finalizarEfeito() -> void:
	if (alvoDoEfeito == 1):
		if (self.alvoJogadorDoEfeito.nivel - abs(self.acaoParametro) <= 0):
			self.alvoJogadorDoEfeito.estaMorto = true

	if (self.alvoDoEfeito == 0):
		self.textoResultado = "O monstro recebeu um incremento de " + str(self.acaoParametro) + " de força"
	if (self.alvoDoEfeito == 1):
		if (self.acaoParametro < 0):
			self.textoResultado = "Perdeu " + str(abs(self.acaoParametro)) + " de nível"
		else:
			self.textoResultado = "Ganhou " + str(self.acaoParametro) + " de nível"
