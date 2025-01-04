class_name EfeitoFuga extends Efeito

func _aplicarEfeito() -> void:
	self.alvoJogadorDoEfeito.setFuga(false)

func _finalizarEfeito() -> void:
	self.textoResultado = "Você não pode mais fugir!!"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
