extends VBoxContainer
var botsReference: OptionButton
var modoReference: CheckButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var antiIndexDict = {
		2: 1,
		3: 2,
		4: 3
	}
	botsReference = $VBoxContainer/quantidadeBots
	modoReference = $VBoxContainer2/jogoRapido
	botsReference.selected = antiIndexDict[VariaveisGlobais.BOTS_COUNT]
	print(VariaveisGlobais.MODO_FACIL)
	modoReference.button_pressed = VariaveisGlobais.MODO_FACIL


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quantidade_bots_item_selected(index: int) -> void:
	var indexDict = {
		1: 2,
		2: 3,
		3: 4
	}
	VariaveisGlobais.BOTS_COUNT = indexDict[index]

func _on_jogo_rapido_toggled(toggled_on: bool) -> void:
	VariaveisGlobais.MODO_FACIL = toggled_on
