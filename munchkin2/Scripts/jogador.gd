class_name Jogador
extends Node2D

@export var jogador: String = "Rafael"
@export var nivel: int = 1
@export var força: int = 1
var classe: int = -1
var raça: int = -1
var maoCartas
var maoCartasEquipadas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maoCartas = $"../MaoJogador"
	maoCartasEquipadas = $"../MaoEquipados"
	$"../VBoxContainer/RichTextLabel".text = "Jogador: " + jogador

func setForca(novo_valor: int) -> void:
	força = novo_valor
	
func aumentarNivel(qtd_niveis: int) -> void:
	nivel += qtd_niveis

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"../VBoxContainer/HSplitContainer/RichTextLabel2".text = "Nível: " + str(nivel)
	$"../VBoxContainer/HSplitContainer/RichTextLabel3".text = "Força: " + str(força)
	
