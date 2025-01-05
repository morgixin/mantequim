class_name CartaMonstro
extends CartaClass

@export var forca: int = 0
@export var acao = -1
@export var acaoParametro = -1

var forca_total: int = forca
var incremento_forca = []

var força_especifica: int = -1
var classe_especifica: int = -1
var raça_especifica: int = -1
var tesouro: int = 1
var target: int = -1
var lvl_reward: int = 1
var min_level: int = 1

func _ready() -> void:
	get_parent().connect_card_signals(self)
	definirFrame()
	self.isTreasure = false
	self.isMonster = true
	calcularForcaTotal()

func calcularForcaTotal() -> int:
	var somaDasForcas = forca
	for valor_forca in incremento_forca:
		somaDasForcas += valor_forca
	forca_total = somaDasForcas
	return forca_total
	
func adicionarIncrementoForca(valor: int) -> void:
	incremento_forca.append(valor)
	calcularForcaTotal()

func removerIncremento(valor: int) -> void:
	if (valor in incremento_forca):
		incremento_forca.erase(valor)
	calcularForcaTotal()

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
