class_name JogadorBot extends Jogador

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isHost = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(maoCartas.maoJogador)
	player_box.customize(jogador, classeDict[classe], nivel, forca, racaDict[raca])
