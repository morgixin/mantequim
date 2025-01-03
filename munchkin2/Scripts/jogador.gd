class_name Jogador
extends Node2D

@export var jogador: String = "Rafael"
@export var nivel: int = 1
@export var forca: int = 1
@export var forca_turno: int = 1
var incrementos_forca: Array[int] = []

var classe: int = -1
var raca: int = 1 #começa como humano
var maoCartas
var maoCartasEquipadas
var isHost = true

const racaDict = {
	-1: "Nenhum",
	1: "Humano",
	2: "Elfo"
}
const classeDict = {
	-1: "Nenhum",
	1: "Ladrão",
	2: "Clérigo"
}
const equipDict = {
	1: "1 Hand",
	2: "2 Hand",
	3: "Headgear",
	4: "Armor",
	5: "Genérico",
	6: "Footgear"
}
var player_box: PlayerBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maoCartas = $"../MaoJogador"
	maoCartasEquipadas = $"../MaoEquipados"
	player_box = $"../HBoxContainer/PlayerBox"

func setForca(novo_valor: int) -> void:
	forca = novo_valor
	
func calcularForcaTurno() -> void:
	maoCartasEquipadas.calcularForca()
	self.forca_turno = forca
	for forcaNova in incrementos_forca:
		self.forca_turno += forcaNova
	print(forca_turno)
	
func aumentarNivel(qtd_niveis: int) -> void:
	nivel += qtd_niveis
	calcularForcaTurno()

func addIncremento(valorIncremento: int):
	self.incrementos_forca.append(valorIncremento)
	
func removeIncremento(valorIncremento: int):
	if valorIncremento in incrementos_forca:
		self.incrementos_forca.erase(valorIncremento)

func setClasseJogador(classe: int) -> void:
	self.classe = classe
	
func setRacaJogador(raca: int) -> void:
	self.raca = raca
	
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

func admitirCarta(carta: CartaClass) -> bool:
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
	if carta.tipo_equipamento == -1:
		return false
	if !verificaEquipadas(carta):
		return false
	return true

func _process(_delta: float) -> void:
	player_box.customize(jogador, classeDict[classe], nivel, forca_turno, racaDict[raca])
	
	
	
