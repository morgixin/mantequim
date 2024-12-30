class_name PlayerBox extends Control

@onready var jogador_ref = $MarginContainer/PanelContainer/MarginContainer/PlayerContainer/NomeJogador
@onready var raca_ref = $MarginContainer/PanelContainer/MarginContainer/PlayerContainer/HBoxContainer2/Raça
@onready var classe_ref = $MarginContainer/PanelContainer/MarginContainer/PlayerContainer/HBoxContainer2/Classe
@onready var nivel_ref = $MarginContainer/PanelContainer/MarginContainer/PlayerContainer/HBoxContainer/NivelText
@onready var forca_ref = $MarginContainer/PanelContainer/MarginContainer/PlayerContainer/HBoxContainer/ForçaText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func customize(jogador: String, classe: String, nivel: int, forca: int, raca: String = "Humano"):
	jogador_ref.text = "Jogador: " + jogador
	raca_ref.text = "Raça: " + raca
	classe_ref.text = "Classe: " + classe
	nivel_ref.text = "Nível: " + str(nivel)
	forca_ref.text = "Força: " + str(forca)
	return self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
