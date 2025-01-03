class_name Mesa extends Control

const BOTS_COUNT = 2
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const BOT_PLAYER_PATH = "res://Scenes/JogadorBot.tscn"

# VARIÁVEIS DE JOGO
var momentoDoJogo = 0
var jogadores = []
var jogadores_bot = []
var jogadorAtual = 0
var cartaSorteadaTurno: CartaClass
var cartasInterferenciaTurno = []
var cartasSlotDeAjuda = []
var gerCartas: GerenciadorCartasClass

var useCardSlot = null
@onready var prompt1 = $Confirmation
@onready var prompt2 = $useCardSlotPrompt
@onready var monster_box: MonsterBoxUI = $MonsterBox
@onready var sprite_mesa: TextureRect = $sprite_mesa
@onready var sprite_batalha: TextureRect = $sprite_batalha

func _ready() -> void:
	jogadores.append($Jogador)
	instanciarBots()
	
	# Iniciando primeiro momento do Jogo
	momentoSeEquipar()
	gerCartas = GerenciadorCartasClass.new()
# ---------------------------------------------------
#! MOMENTO PARA O JOGADOR SE EQUIPAR
func momentoSeEquipar() -> void:
	momentoDoJogo = 0
	var equipSlotScene = preload("res://Scenes/Slots/EquipSlot.tscn")
	var equip_slot = equipSlotScene.instantiate()
	var screen = get_viewport_rect().size
	equip_slot.position = Vector2(screen.x/2, screen.y/2 - 80)
	add_child(equip_slot)
	
	var nomeDoJogadorDoTurno = jogadores[jogadorAtual].jogador
	if jogadorAtual == 0:
		prompt1.customize("É o seu Turno!", "Está pronto para chutar a porta? Você pode se equipar antes", "Chutar a porta!", "Me equipar", true, true)
		var jogadorChutouAPorta = await prompt1.prompt(false)
		if jogadorChutouAPorta:
			cartaSorteadaTurno = gerCartas.sortearCartaPorta()
			print(cartaSorteadaTurno.nome)
			monster_box.customizarBox(cartaSorteadaTurno, "Monstro Sorteado", true, "Continuar")
			remove_child(equip_slot)
			var jogadorContinuou = await monster_box.prompt()
			if jogadorContinuou:
				mudarParaBatalha()
	else:
		prompt1.customize("É o turno de "+nomeDoJogadorDoTurno+"!", "Equipe cartas de classe, raça e equipamentos antes de avançar", "Continuar", "", true, true)
		var jogadorChutouAPorta = await prompt1.prompt(false)

# MOMENTO EM QUE O JOGADOR ENTRA NO FLUXO DE BATALHA
func mudarParaBatalha() -> void:
	momentoDoJogo = 1
	
	# MUDANDO O BACKGROUND DA CENA PRINCIPAL
	sprite_mesa.hide()
	sprite_batalha.show()
	
	# TIMER
	await get_tree().create_timer(0.7).timeout
	
	# MOSTRAR CAIXA DAS CARTAS
	monster_box.customizarBox(cartaSorteadaTurno, "Aguardando Interferência de Outros Jogadores", true, "Aguarde", "", true)
	monster_box.setTimerToClose(8)
	var jogadorContinou = await monster_box.prompt()

	# ESCOLHER E MOSTRAR AS CARTAS DOS BOTS
	escolherCartasInterferenciaBots()
	for carta in cartasInterferenciaTurno:
		var nomeDono = carta.donoDaCarta.jogador
		monster_box.customizarBox(carta, nomeDono + " interferiu no seu jogo", true, "Continuar")
		if (carta.acao == 1 and cartaSorteadaTurno.tipo == 3):
			cartaSorteadaTurno.adicionarIncrementoForca(carta.acao_parametro) # Método de carta monstro que adiciona força incremental
		var proximaCarta = await monster_box.prompt()
		await get_tree().create_timer(0.2).timeout # Esperar antes de mostrar a próxima caixa
	
	# PERGUNTAR AO JOGADOR SE ELE QUER USAR ALGUM ITEM PARA SE DEFENDER
	prompt1.customize("Deseja usar algum one-shot item antes da batalha?", "Lembre-se: você não pode mais colocar equipamentos!", "Sim", "Não", false, false)
	var decidiuUsarCartas = await prompt1.prompt(true)
	await get_tree().create_timer(0.2).timeout
	
	if (decidiuUsarCartas):
		momentoInterferencia() # Equipar one shot items
	else:
		mostrarResumoDaBatalha()

#! MOMENTO DO JOGADOR INTERFERIR NO SEU PRÓPRIO TURNO OU TURNO DE OUTROS JOGADORES
func momentoInterferencia() -> void:
	momentoDoJogo = 2
	
	# INSTANCIANDO USECARDSLOT
	var useCardSlotScene = preload("res://Scenes/Slots/UseSlot.tscn") 
	var newUseCardSlot = useCardSlotScene.instantiate()
	var screen = get_viewport_rect().size
	newUseCardSlot.position = Vector2(screen.x/2, screen.y/2 - 80)
	add_child(newUseCardSlot)
	useCardSlot = newUseCardSlot
	newUseCardSlot.btn = prompt1
	newUseCardSlot.use_card_confirmation = prompt2
	
	if (jogadorAtual == 0):
		newUseCardSlot.slotAjudaJogador = true
	prompt1.customize("Pronto para continuar?", "Você pode jogar mais de uma carta", "Sim", "", true, true)
	var isConfirmed = await prompt1.prompt(false)
	if (isConfirmed and jogadorAtual == 0):
		cartasSlotDeAjuda = newUseCardSlot.cartasUsadas
	if (isConfirmed): 
		#TODO: SALVAR NO ARRAY DE cartasInterferenciaTurno
		await newUseCardSlot.desativarCartas()
		remove_child(newUseCardSlot)
		mostrarResumoDaBatalha()

#! MOMENTO DE MOSTRAR RESUMO DA BATALHA
#TODO: VERIFICAR CLASSES E RAÇAS PARA A FORÇA ESPECÍFICA DO MONSTRO
func mostrarResumoDaBatalha() -> void:
	momentoDoJogo = 3
	monster_box.customizarBox(cartaSorteadaTurno, "Resumo da Batalha de " + jogadores[jogadorAtual].jogador, false, "Atacar Monstro", "Fugir", false)
	var jogadorAtacou = await monster_box.prompt()
	if jogadorAtacou:
		await atacarMonstro()
	else:
		await fugirMonstro()
	await get_tree().create_timer(0.2).timeout
	await momentoDescarte()

#! MOMENTO DE DESCARTAR CARTAS
func momentoDescarte() -> void:
	momentoDoJogo = 4
	var useDiscardScene = preload("res://Scenes/Slots/DiscardSlot.tscn") 
	var newDiscard = useDiscardScene.instantiate()
	var screen = get_viewport_rect().size
	newDiscard.position = Vector2(screen.x/2, screen.y/2 - 80)
	add_child(newDiscard)
	newDiscard.btn = prompt1
	newDiscard.discard_confirmation = prompt2
	newDiscard.maoDoJogador = jogadores[jogadorAtual].maoCartas.maoJogador
	prompt1.customize("Descarte de Cartas", "Para avançar você deve ter no máximo cinco cartas na sua mão", "Continuar", "", true, true)
	if (jogadores[jogadorAtual].maoCartas.maoJogador.size() > 5):
		prompt1.mudarStatusBotao(0, true)
	var isConfirmed = await prompt1.prompt(false)
# ---------------------------------------------------

#! FUNÇÕES DE ESCOLHAS DO JOGADOR
func atacarMonstro() -> void:
	if jogadores[jogadorAtual].forca > cartaSorteadaTurno.forca_total:
			var lvl_gain = cartaSorteadaTurno.lvl_reward
			var tesouro = cartaSorteadaTurno.tesouro
			prompt1.customize("Você venceu o combate!", "Você subiu " + str(lvl_gain) + " nível(is)\n e ganhou " + str(tesouro) + " tesouros.", "Continuar", "", true)
			await prompt1.prompt(false)
			jogadores[jogadorAtual].aumentarNivel(lvl_gain)
	else:
		var vaiDiminuirNivel: bool = cartaSorteadaTurno.acao == 2
		print(cartaSorteadaTurno)
		if vaiDiminuirNivel:
			if (jogadores[jogadorAtual].nivel - abs(cartaSorteadaTurno.acaoParametro) > 0):
				prompt1.customize("Você perdeu o combate!", "Você perdeu " + str(abs(cartaSorteadaTurno.acaoParametro)) + " nível(is).", "Continuar", "", true)
				await prompt1.prompt(false)
				jogadores[jogadorAtual].aumentarNivel(cartaSorteadaTurno.acaoParametro)
			else:
				prompt1.customize("Você perdeu o combate!", "Você morreu", "Continuar", "", true)
				await prompt1.prompt(false)
				jogadores[jogadorAtual].aumentarNivel(cartaSorteadaTurno.acaoParametro)
		else: 
			prompt1.customize("Você perdeu o combate!", "", "Continuar", "", true)
			await prompt1.prompt(false)

func fugirMonstro() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var dado = rng.randi_range(1,6)
	prompt1.customize("Você rolou o dado...", "seu resultado foi: " + str(dado), "Continuar", "", true, false)
	await prompt1.prompt(false)
	await get_tree().create_timer(0.2).timeout
	#TODO: implementar particularidades das classes e raças quanto ao 'fugir'
	if dado >= 5: 
		prompt1.customize("Você fugiu do combate", "Você não vai ganhar o tesouro, mas também não perderá níveis", "Continuar", "", true, false)
		await prompt1.prompt(false)
	else:
		await atacarMonstro()

#! FUNÇÕES DE BOTS
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
			if contadorInterf < 2:
				cartasInterferenciaTurno.append(cartaValida)
				bot.maoCartas.removeDaMao(cartaValida)
				contadorInterf +=1

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
	
	
