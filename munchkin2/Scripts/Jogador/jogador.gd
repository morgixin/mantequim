class_name Jogador
extends Node2D

var UC = UserController.getInstancia()
@export var jogador: String = UC.get_logged_user_username() if UC.isUserLogged() else "Troy"
@export var nivel: int = 5 if VariaveisGlobais.MODO_FACIL else 3
@export var forca: int = 5 if VariaveisGlobais.MODO_FACIL else 3
@export var forca_turno: int = 1
var incrementos_forca: Array[int] = []

var classe: int = -1
var raca: int = 1 #começa como humano
var maoCartas: MaoJogador
var maoCartasEquipadas: MaoEquipados
var isHost = true
var estaMorto = false
var podeFugir = true

const racaDict = {
	-1: "Nenhum",
	1: "Humano",
	2: "Elfo",
	3: "Anão",
	4: "Halfling"
}
const classeDict = {
	-1: "Nenhum",
	1: "Thief",
	2: "Clérigo",
	3: "Mago",
	4: "Guerreiro"
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

func _ready() -> void:
	maoCartas = $"../MaoJogador"
	maoCartasEquipadas = $"../MaoEquipados"
	player_box = $"../HBoxContainer/PlayerBox"
	calcularForcaTurno()

func setForca(novo_valor: int) -> void:
	forca = novo_valor
	
func calcularForcaTurno() -> void:
	maoCartasEquipadas.calcularForca()
	self.forca_turno = forca
	for forcaNova in incrementos_forca:
		self.forca_turno += forcaNova
	
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
	
func getRacaJogador() -> int:
	return self.raca

func getClasseJogador() -> int:
	return self.classe

func verificaEquipadas(carta: CartaItem):
	var tipo = carta.getTipoEquip()
	var arrayEquip = maoCartasEquipadas.cartasEquipadas
	var arrayTiposEquip = []
	for i in range (arrayEquip.size()):
		if (arrayEquip[i].tipo == 2):
			arrayTiposEquip.append(arrayEquip[i].getTipoEquip())
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

func verificarClasseRaca(carta: CartaClass) -> bool:
	var arrayCartasEquipadas = maoCartasEquipadas.cartasEquipadas
	var cartasClassesEquipadas = []
	var cartasRacasEquipadas = []
	for cartaEquipada in arrayCartasEquipadas:
		if cartaEquipada.tipo == 2:
			if carta.tipo == 4 and cartaEquipada.classe_restrita == carta.classe_id:
				return false
			if carta.tipo == 5 and cartaEquipada.raca_restrita == carta.raca_id:
				return false
			if cartaEquipada.classe_exigida != -1:
				if carta.tipo == 4 and cartaEquipada.classe_exigida != carta.classe_id:
					return false
			if cartaEquipada.raca_exigida != -1:
				if carta.tipo == 5 and cartaEquipada.raca_exigida != carta.raca_id:
					return false
		if cartaEquipada.tipo == 4:
			cartasClassesEquipadas.append(cartaEquipada)
		elif cartaEquipada.tipo == 5:
			cartasRacasEquipadas.append(cartaEquipada)
	if carta.tipo == 4 and cartasClassesEquipadas.size() > 0:
		return false
	if carta.tipo == 5 and cartasRacasEquipadas.size() > 0:
		return false	
	return true

func admitirCarta(carta: CartaClass) -> bool:
	if carta.tipo != 2 and carta.tipo != 4 and carta.tipo != 5:
		return false
	if carta.tipo == 2:
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
		print("BBYG")
		if !verificaEquipadas(carta):
			print("FALSO!!!")
			return false
	if carta.tipo == 4 or carta.tipo == 5:
		if !verificarClasseRaca(carta):
			return false		
	return true

func setFuga(value: bool):
	self.podeFugir = value

func _process(_delta: float) -> void:
	player_box.customize(self, jogador, classeDict[classe], nivel, forca_turno, racaDict[raca])
	
	
	
