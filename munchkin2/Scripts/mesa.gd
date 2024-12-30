class_name Mesa extends Control
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
var cartas_monstro = []
var jogadores = []
var momentoDoJogo = 0
var jogadorAtual = 0
var cartaSorteadaTurno: CartaClass

@onready var btn = $Confirmation
@onready var sprite_mesa: TextureRect = $sprite_mesa
@onready var sprite_batalha: TextureRect = $sprite_batalha
@onready var monster_box: MonsterBoxUI = $MonsterBox
@onready var equip_slot: Node2D = $EquipSlot

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		btn.customize("deseja sair do jogo?", "escolha a opção desejada", "Fechar Jogo", "Cancelar",false, false )
		var isConfirmed = await btn.prompt(true)
		if isConfirmed:
			get_tree().quit()
	else:
		pass
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	carregarCartasMonstro()
	if jogadorAtual == 0 and momentoDoJogo == 0:
		btn.customize("É o seu Turno!", "Está pronto para chutar a porta? Você pode se equipar antes", "Chutar a porta!", "Me equipar", true, true)
		var jogadorChutouAPorta = await btn.prompt(false)
		if jogadorChutouAPorta:
			sortearCartaPorta()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func sortearCartaPorta():	#Melhorar Depois
	cartaSorteadaTurno = sortearCartaMonstro()
	monster_box.customizarBox(cartaSorteadaTurno, "Monstro Sorteado", true, "Continuar")
	equip_slot.hide()
	var jogadorContinuou = await monster_box.prompt()
	if jogadorContinuou:
		mudarParaBatalha()
	
	
func sortearCartaMonstro() -> CartaMonstro:	
	var cardMonsterScene = preload(CARD_MONSTER_PATH)
	var selectedCard = cartas_monstro[randi_range(0, cartas_monstro.size()-1)]
	var newCard = cardMonsterScene.instantiate()
	
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.tipo = selectedCard.tipo
	newCard.forca = selectedCard.força
	newCard.força_especifica = selectedCard.força_especifica
	newCard.classe_especifica = selectedCard.classe_especifica
	newCard.raça_especifica = selectedCard.raça_especifica
	
	return newCard	
	
func mudarParaBatalha() -> void:
	sprite_mesa.hide()
	sprite_batalha.show()
	remove_child(equip_slot)
	
	
	await get_tree().create_timer(0.7).timeout
	
	monster_box.customizarBox(cartaSorteadaTurno, "Aguardando Interferência de Outros Jogadores", true, "Aguarde")
	var jogadorContinou = await monster_box.prompt()
	
	
	
	
func carregarCartasMonstro():
	var json_file = FileAccess.open("res://data/cartas_monstro.json", FileAccess.READ)
	cartas_monstro = JSON.parse_string(json_file.get_as_text())
	json_file.close()

	
