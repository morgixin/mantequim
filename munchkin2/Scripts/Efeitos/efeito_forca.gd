class_name EfeitoMudaForca
extends Efeito

func _aplicarEfeito() -> void:
	var forcaTemporaria = self.acaoParametro
	if (self.alvoDoEfeito == 0):
		self.alvoMonstroDoEfeito.adicionarIncrementoForca(forcaTemporaria)
	if (self.alvoDoEfeito == 1):
		self.alvoJogadorDoEfeito.addIncremento(forcaTemporaria)
		self.alvoJogadorDoEfeito.calcularForcaTurno()

func _finalizarEfeito() -> void:
	if (self.alvoDoEfeito == 0):
		self.textoResultado = "O monstro recebeu um incremento de " + str(self.acaoParametro) + " de força"
	if (self.alvoDoEfeito == 1):
		self.textoResultado = "Ganhou " + str(self.acaoParametro) + " de força"
