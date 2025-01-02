class_name Mesa extends Control
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const BOT_PLAYER_PATH = "res://Scenes/JogadorBot.tscn"
const BOTS_COUNT = 2
var cartas_monstro = []
var jogadores = []
var jogadores_bot = []
var momentoDoJogo = 0
var jogadorAtual = 0
var cartaSorteadaTurno: CartaClass
var cartasInterferenciaTurno = []
var cartasSlotDeAjuda = []


var useCardSlot = null
@onready var btn = $Confirmation
@onready var use_card_slot_prompt = $useCardSlotPrompt
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
	jogadores.append($Jogador)
	instanciarBots()
	carregarCartasMonstro()
	if jogadorAtual == 0 and momentoDoJogo == 0:
		btn.customize("É o seu Turno!", "Está pronto para chutar a porta? Você pode se equipar antes", "Chutar a porta!", "Me equipar", true, true)
		var jogadorChutouAPorta = await btn.prompt(false)
		if jogadorChutouAPorta:
			sortearCartaPorta()
	pass # Replace with function body.
	
func instanciarBots():
	for i in range(BOTS_COUNT):
		var novoBot = JogadorBot.new()
		var maoEquipadosBot = MaoEquipados.new()
		var maoJogadorBot = MaoJogador.create(novoBot)
		maoEquipadosBot.isBot = true
		maoJogadorBot.isBot = true
		novoBot.maoCartas = maoJogadorBot
		novoBot.maoCartasEquipadas = maoEquipadosBot
		novoBot.jogador = "Bot " + str(i)
		var botPlayerBox = preload("res://Scenes/PlayerBox.tscn").instantiate()
		novoBot.player_box = botPlayerBox
		jogadores.append(novoBot)
		jogadores_bot.append(novoBot)
		add_child(novoBot)
		add_child(maoJogadorBot)
		add_child(maoEquipadosBot)
		$HBoxContainer.add_child(botPlayerBox)
	
func sortearCartaPorta():	#Melhorar Depois
	cartaSorteadaTurno = sortearCartaMonstro()
	monster_box.customizarBox(cartaSorteadaTurno, "Monstro Sorteado", true, "Continuar")
	equip_slot.hide()
	var jogadorContinuou = await monster_box.prompt()
	if jogadorContinuou:
		mudarParaBatalha()
		
func sortearCartaMonstro() -> CartaMonstro:	
	var cardMonsterScene = preload(CARD_MONSTER_PATH)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var selectedCard = cartas_monstro[rng.randi_range(0, cartas_monstro.size()-1)]
	var newCard = cardMonsterScene.instantiate()
	newCard.tesouro = selectedCard.tesouro
	newCard.nome = selectedCard.nome_carta
	newCard.descricao = selectedCard.descricao_carta
	newCard.frame = selectedCard.frame
	newCard.tipo = selectedCard.tipo
	newCard.forca = selectedCard.força
	newCard.força_especifica = selectedCard.força_especifica
	newCard.classe_especifica = selectedCard.classe_especifica
	newCard.raça_especifica = selectedCard.raça_especifica
	newCard.lvl_reward = selectedCard.lvl_reward
	newCard.acao = selectedCard.acao
	newCard.acaoParametro = selectedCard.acao_parametro
	return newCard	
	
func mudarParaBatalha() -> void:
	momentoDoJogo = 1
	sprite_mesa.hide()
	sprite_batalha.show()
	remove_child(equip_slot)
	await get_tree().create_timer(0.7).timeout
	monster_box.customizarBox(cartaSorteadaTurno, "Aguardando Interferência de Outros Jogadores", true, "Aguarde", "", true)
	monster_box.setTimerToClose(8)
	var jogadorContinou = await monster_box.prompt()
	print("Escolhendo cartas")
	escolherCartasInterferenciaBots()
	print(cartasInterferenciaTurno)
	for carta in cartasInterferenciaTurno:
		var nomeDono = carta.donoDaCarta.jogador
		monster_box.customizarBox(carta, nomeDono + " interferiu no seu jogo", true, "Continuar")
		var proximaCarta = await monster_box.prompt()
		await get_tree().create_timer(0.2).timeout #esperar antes de mostrar a próxima caixa
	btn.customize("Deseja usar algum one-shot item antes da batalha?", "Lembre-se: você não pode mais colocar equipamentos!", "Sim", "Não", false, false)
	var isConfirmed = await btn.prompt(true)
	await get_tree().create_timer(0.2).timeout
	if (isConfirmed):
		momentoInterferencia() #equipar one shot items
	else:
		mostrarResumoDaBatalha()
		
		
func momentoInterferencia() -> void:
	momentoDoJogo = 2
	var useCardSlotScene = preload("res://Scenes/Slots/UseSlot.tscn") 
	var newUseCardSlot = useCardSlotScene.instantiate()
	var screen = get_viewport_rect().size
	newUseCardSlot.position = Vector2(screen.x/2, screen.y/2 - 80)
	add_child(newUseCardSlot)
	useCardSlot = newUseCardSlot
	newUseCardSlot.btn = btn
	newUseCardSlot.use_card_confirmation = use_card_slot_prompt
	if (jogadorAtual == 0):
		newUseCardSlot.slotAjudaJogador = true
	btn.customize("Pronto para continuar?", "Você pode jogar mais de uma carta", "Sim", "", true, true)
	var isConfirmed = await btn.prompt(false)
	if (isConfirmed and jogadorAtual == 0):
		cartasSlotDeAjuda = newUseCardSlot.cartasUsadas
	if (isConfirmed): #TODO: salvar cartas para aplicar na batalha do oponente
		await newUseCardSlot.desativarCartas()
		remove_child(newUseCardSlot)
		mostrarResumoDaBatalha()

func atacarMonstro():
	if jogadores[jogadorAtual].forca > cartaSorteadaTurno.forca:
			var lvl_gain = cartaSorteadaTurno.lvl_reward
			var tesouro = cartaSorteadaTurno.tesouro
			btn.customize("Você venceu o combate!", "Você subiu " + str(lvl_gain) + " nível(is)\n e ganhou " + str(tesouro) + " tesouros.", "Continuar", "", true)
			await btn.prompt(false)
			jogadores[jogadorAtual].aumentarNivel(lvl_gain)
	else:
		var vaiDiminuirNivel: bool = cartaSorteadaTurno.acao == 2
		print(cartaSorteadaTurno)
		if vaiDiminuirNivel:
			if (jogadores[jogadorAtual].nivel - abs(cartaSorteadaTurno.acaoParametro) > 0):
				btn.customize("Você perdeu o combate!", "Você perdeu " + str(abs(cartaSorteadaTurno.acaoParametro)) + " nível(is).", "Continuar", "", true)
				await btn.prompt(false)
				jogadores[jogadorAtual].aumentarNivel(cartaSorteadaTurno.acaoParametro)
			else:
				btn.customize("Você perdeu o combate!", "Você morreu", "Continuar", "", true)
				await btn.prompt(false)
				jogadores[jogadorAtual].aumentarNivel(cartaSorteadaTurno.acaoParametro)
		else: 
			btn.customize("Você perdeu o combate!", "", "Continuar", "", true)
			await btn.prompt(false)

func fugir() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var dado = rng.randi_range(1,6)
	btn.customize("Você rolou o dado...", "seu resultado foi: " + str(dado), "Continuar", "", true, false)
	await btn.prompt(false)
	await get_tree().create_timer(0.2).timeout
	#TODO: implementar particularidades das classes e raças quanto ao 'fugir'
	if dado >= 5: 
		btn.customize("Você fugiu do combate", "Você não vai ganhar o tesouro, mas também não perderá níveis", "Continuar", "", true, true)
		await btn.prompt(false)
	else:
		atacarMonstro()

func mostrarResumoDaBatalha() -> void:
	momentoDoJogo = 3
	monster_box.customizarBox(cartaSorteadaTurno, "Resumo da Batalha de " + jogadores[jogadorAtual].jogador, false, "Atacar Monstro", "Fugir", false)
	var jogadorAtacou = await monster_box.prompt()
	if jogadorAtacou:
		atacarMonstro()
	else:
		fugir()
	
func aplicarEfeitos() -> void:
	pass

func escolherCartasInterferenciaBots():
	cartasInterferenciaTurno = []
	print(jogadores_bot)
	for bot in jogadores_bot:
		print(bot.jogador)
		var cartasAtual = bot.maoCartas.maoJogador
		var cartasValidas = []
		for carta in cartasAtual:
			if carta.tipo == 1 and carta.acao == 1:
				cartasValidas.append(carta)
		print(cartasValidas)
		var contadorInterf = 0
		for cartaValida in cartasValidas:
			var num = RandomNumberGenerator.new()
			num.randomize()
			var chance = num.randi_range(1,4)
			if chance == 4 and contadorInterf < 2:
				cartasInterferenciaTurno.append(cartaValida)
				bot.maoCartas.removeDaMao(cartaValida)
				contadorInterf +=1
					 
func carregarCartasMonstro():
	var json_file = FileAccess.open("res://data/cartas_monstro.json", FileAccess.READ)
	cartas_monstro = JSON.parse_string(json_file.get_as_text())
	json_file.close()

	
