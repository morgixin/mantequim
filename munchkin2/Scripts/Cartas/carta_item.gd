class_name CartaItem extends CartaClass
@export var tipo_equipamento: int = -1
@export var isBig: bool = false
@export var forca: int = 0
@export var classe_exigida = -1
@export var raca_exigida = -1
@export var classe_restrita = -1
@export var raca_restrita = -1
@export var acao = -1
@export var acao_parametro = -1
var alvoDoEfeito = -1 # -1: Não definido; 0: Monstro; 1: Jogador 

func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()
	self.isTreasure = true
	pass

func _process(delta: float) -> void:
	pass

func getTipoEquip() -> int:
	return self.tipo_equipamento

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
