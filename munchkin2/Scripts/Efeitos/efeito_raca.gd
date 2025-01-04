class_name EfeitoMudaRaca extends Efeito

func _aplicarEfeito() -> void:
	var raca = self.alvoJogadorDoEfeito.getRacaJogador()
	var quantidadeDeNiveis = self.acaoParametro
	if raca != 1:
		self.alvoJogadorDoEfeito.setRacaJogador(1)
	else:
		self.alvoJogadorDoEfeito.aumentarNivel(acaoParametro)

func _finalizarEfeito():
	var raca = self.alvoJogadorDoEfeito.getRacaJogador()
	if (raca == 1):
		self.textoResultado = "Voltou a ser humano!"
	else:
		self.textoResultado = "Perdeu um nível"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
