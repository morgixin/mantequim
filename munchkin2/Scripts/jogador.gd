class_name Jogador
extends Node2D

@export var jogador: String = "Rafael"
@export var nivel: int = 1
@export var força: int = 1
var classe: int = 1
var raca: int = 1
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
	
func verificaEquipadas(carta: CartaItem):
	var tipo = carta.getTipoEquip()
	var arrayEquip = maoCartasEquipadas.cartasEquipadas
	var arrayTiposEquip = []
	for i in range (arrayEquip.size()):
		arrayTiposEquip.insert(i, arrayEquip[i].getTipoEquip())
	if tipo == 1:
		if arrayTiposEquip.count(1) == 2 or arrayTiposEquip.count(2) == 1:
			return false
		elif arrayTiposEquip.count(1) == 1:
			return true
	elif tipo == 2:
		if arrayTiposEquip.count(1) != 0 or arrayTiposEquip.count(2) == 1:
			return false
	elif arrayTiposEquip.count(tipo) >= 1:
		return false
	return true

func admitirCarta(carta: CartaItem) -> bool:
	if !carta.isTreasure:
		return false
	if carta.tipo != 2:
		return false
	if carta.classe_exigida != -1 and classe != carta.classe_exigida:
		return false
	if carta.raca_exigida != -1 and raca != carta.raca_exigida:
		return false
	if carta.classe_restrita != -1 and classe == carta.classe_restrita:
		return false
	if carta.raca_restrita != -1 and raca == carta.raca_restrita:
		return false
	print(carta.tipo_equipamento)
	if carta.tipo_equipamento == -1:
		return false
	print(verificaEquipadas(carta))
	if !verificaEquipadas(carta):
		return false
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"../VBoxContainer/HSplitContainer/RichTextLabel2".text = "Nível: " + str(nivel)
	$"../VBoxContainer/HSplitContainer/RichTextLabel3".text = "Força: " + str(força)
	
