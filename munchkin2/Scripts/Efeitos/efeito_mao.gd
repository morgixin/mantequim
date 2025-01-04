class_name EfeitoRemoveCartas extends Efeito

func _aplicarEfeito() -> void:
	var mao = self.alvoJogadorDoEfeito.maoCartas
	if mao.maoJogador.size() > 0:
		var qtd = self.acaoParametro
		mao.limpaMao(qtd)
	else:
		self.alvoJogadorDoEfeito.aumentarNivel(-1)

func _finalizarEfeito() -> void:
	self.textoResultado = "Acho que sua mão deu uma esvaziada..."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
