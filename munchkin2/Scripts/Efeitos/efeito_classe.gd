class_name EfeitoRemoveClasse extends Efeito

func _aplicarEfeito() -> void:
	var classe = self.alvoJogadorDoEfeito.getClasseJogador()
	var quantidadeDeNiveis = self.acaoParametro
	if classe != -1:
		self.alvoJogadorDoEfeito.setClasseJogador(-1)
	else:
		self.alvoJogadorDoEfeito.aumentarNivel(acaoParametro)

func _finalizarEfeito():
	var classe = self.alvoJogadorDoEfeito.getClasseJogador()
	if (classe == -1):
		self.textoResultado = "Ficou sem classe!"
	else:
		self.textoResultado = "Perdeu um nível"
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
