class_name Mesa extends Control

const BOTS_COUNT = 2
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const BOT_PLAYER_PATH = "res://Scenes/JogadorBot.tscn"

# VARIÁVEIS DE JOGO
var momentoDoJogo = 0
var jogadores: Array[Jogador] = []
var jogadores_bot: Array[JogadorBot] = []
var jogadorAtual = 0

var cartaSorteadaTurno: CartaClass
var cartasInterferenciaTurno: Array[CartaClass] = []
var cartasSlotDeAjuda: Array[CartaClass] = []

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
	gerCartas = GerenciadorCartasClass.new()
	
	# Iniciando primeiro momento do Jogo
	momentoSeEquipar()
# ---------------------------------------------------
#! MOMENTO PARA O JOGADOR SE EQUIPAR
func momentoSeEquipar() -> void:
		
	# MUDANDO O BACKGROUND DA CENA PRINCIPAL
	sprite_mesa.show()
	sprite_batalha.hide()
	
	
	momentoDoJogo = 0
	var equipSlotScene = preload("res://Scenes/Slots/EquipSlot.tscn")
	var equip_slot = equipSlotScene.instantiate()
	var screen = get_viewport_rect().size
	equip_slot.position = Vector2(screen.x/2, screen.y/2 - 80)
	add_child(equip_slot)
	
	var nomeDoJogadorDoTurno = jogadores[jogadorAtual].jogador
	if jogadorAtual == 0 and jogadores[jogadorAtual].isHost:
		prompt1.customize("É o seu Turno!", "Está pronto para chutar a porta? Você pode se equipar antes", "Chutar a porta!", "Me equipar", true, true)
		var jogadorChutouAPorta = await prompt1.prompt(false)
		for bot in jogadores_bot:
			bot.aplicarEquipamentos()
		if jogadorChutouAPorta:
			cartaSorteadaTurno = gerCartas.sortearCartaPorta()
			monster_box.customizarBox(cartaSorteadaTurno, "Monstro Sorteado", true, "Continuar")
			remove_child(equip_slot)
			var jogadorContinuou = await monster_box.prompt()
			if jogadorContinuou:
				mudarParaBatalha()
	else:
		prompt1.customize("É o turno de "+nomeDoJogadorDoTurno+"!", "Equipe cartas de classe, raça e equipamentos antes de avançar", "Continuar", "", true, true)
		await prompt1.prompt(false)
		for bot in jogadores_bot:
			bot.aplicarEquipamentos()
		cartaSorteadaTurno = gerCartas.sortearCartaPorta()
		monster_box.customizarBox(cartaSorteadaTurno, "Monstro Sorteado (Turno de "+nomeDoJogadorDoTurno+")", true, "Aguardando " + nomeDoJogadorDoTurno + " continuar", "", true, true)
		remove_child(equip_slot)
		monster_box.setTimerToClose(5)
		await monster_box.prompt()
		mudarParaBatalha()


#! MOMENTO EM QUE O JOGADOR ENTRA NO FLUXO DE BATALHA
func mudarParaBatalha() -> void:
	momentoDoJogo = 1
	cartasInterferenciaTurno = []
	cartasSlotDeAjuda = []
	var o_turno_e_meu = jogadorAtual == 0 and jogadores[jogadorAtual].isHost
	var nomeDoJogadorDoTurno = jogadores[jogadorAtual].jogador
	
	# MUDANDO O BACKGROUND DA CENA PRINCIPAL
	sprite_mesa.hide()
	sprite_batalha.show()
	
	# TIMER
	await get_tree().create_timer(0.7).timeout

	if (o_turno_e_meu):
		# MOSTRAR CAIXA DAS CARTAS
		monster_box.customizarBox(cartaSorteadaTurno, "Aguardando Interferência de Outros Jogadores", true, "Aguarde", "", true)
		monster_box.setTimerToClose(8)
		await monster_box.prompt()
	else:
		# INICIAR MOMENTO DE INTERFERÊNCIA DO HOST NO JOGO
		prompt1.customize("Deseja interferir no jogo de "+nomeDoJogadorDoTurno+"?", "Você pode jogar cartas de one-shot ou maldições", "Sim", "Não", false, false)
		var vaiInterferir = await prompt1.prompt(false)
		await get_tree().create_timer(0.2).timeout
		if vaiInterferir:
			await momentoInterferencia(false)

	# ESCOLHER E MOSTRAR AS CARTAS DOS BOTS
	escolherCartasInterferenciaBots()
	await mostrarCartasDaLista(cartasInterferenciaTurno)
	
	if o_turno_e_meu:
		# PERGUNTAR AO JOGADOR SE ELE QUER USAR ALGUM ITEM PARA SE DEFENDER
		prompt1.customize("Deseja usar algum one-shot item antes da batalha?", "Lembre-se: você não pode mais colocar equipamentos!", "Sim", "Não", false, false)
		var decidiuUsarCartas = await prompt1.prompt(true)
		await get_tree().create_timer(0.2).timeout
		
		if (decidiuUsarCartas):
			momentoInterferencia() # Equipar one shot items
		else:
			mostrarResumoDaBatalha()
	else:
		# DEIXAR O BOT INTERFERIR O PRÓPRIO TURNO COM UMA CARTA DELE
		monster_box.customizarBox(cartaSorteadaTurno, "Aguardando Interferência de "+nomeDoJogadorDoTurno+" ao próprio Jogo", true, "Aguarde", "", true)
		monster_box.setTimerToClose(5)
		escolherCartaAjudaBot()
		await monster_box.prompt()
		await get_tree().create_timer(0.2).timeout
		await mostrarCartasDaLista(cartasSlotDeAjuda)
		mostrarResumoDaBatalha()

#! MOMENTO DO JOGADOR INTERFERIR NO SEU PRÓPRIO TURNO OU TURNO DE OUTROS JOGADORES
func momentoInterferencia(irParaResumo: bool = true) -> void:
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
	
	if (jogadorAtual == 0 and jogadores[jogadorAtual].isHost):
		newUseCardSlot.slotAjudaJogador = true
	prompt1.customize("Pronto para continuar?", "Você pode jogar mais de uma carta", "Sim", "", true, true)
	await prompt1.prompt(false)
	if (jogadorAtual == 0 and jogadores[jogadorAtual].isHost):
		cartasSlotDeAjuda = newUseCardSlot.cartasUsadas
		for carta in cartasSlotDeAjuda:
			jogadores[jogadorAtual].addIncremento(carta.acao_parametro)
		jogadores[jogadorAtual].calcularForcaTurno()
		
		
	if (jogadorAtual != 0):
		for carta in newUseCardSlot.cartasUsadas:
			cartasInterferenciaTurno.append(carta) 

	await newUseCardSlot.desativarCartas()
	remove_child(newUseCardSlot)
	
	if (irParaResumo):
		mostrarResumoDaBatalha()
	else:
		return

#! MOMENTO DE MOSTRAR RESUMO DA BATALHA
#TODO: VERIFICAR CLASSES E RAÇAS PARA A FORÇA ESPECÍFICA DO MONSTRO
func mostrarResumoDaBatalha() -> void:
	var o_turno_e_meu = jogadorAtual == 0 and jogadores[jogadorAtual].isHost
	var nomeDoJogadorDoTurno = jogadores[jogadorAtual].jogador
	momentoDoJogo = 3
	if o_turno_e_meu:
		monster_box.customizarBox(cartaSorteadaTurno, "Resumo da Batalha de " + nomeDoJogadorDoTurno, false, "Atacar Monstro", "Fugir", false)
	else:
		monster_box.customizarBox(cartaSorteadaTurno, "Resumo da Batalha de " + nomeDoJogadorDoTurno, true, "Aguarde "+nomeDoJogadorDoTurno, "Fugir", true)
		monster_box.setTimerToClose(6)
	var jogadorAtacou = await monster_box.prompt()
	
	if o_turno_e_meu and jogadorAtacou:
		await atacarMonstro()
	elif o_turno_e_meu and !jogadorAtacou:
		await fugirMonstro()
	
	if !o_turno_e_meu:
		if (jogadores[jogadorAtual].forca > cartaSorteadaTurno.forca_total):
			await atacarMonstro()
		else:
			await fugirMonstro()
		
	await get_tree().create_timer(0.2).timeout
	await momentoDescarte()

#! MOMENTO DE DESCARTAR CARTAS
func momentoDescarte() -> void:
	momentoDoJogo = 4
	jogadores[jogadorAtual].incrementos_forca = []
	jogadores[jogadorAtual].calcularForcaTurno()
	var useDiscardScene = preload("res://Scenes/Slots/DiscardSlot.tscn") 
	var newDiscard = useDiscardScene.instantiate()
	var screen = get_viewport_rect().size
	newDiscard.position = Vector2(screen.x/2, screen.y/2 - 80)
	add_child(newDiscard)
	newDiscard.btn = prompt1
	newDiscard.discard_confirmation = prompt2
	newDiscard.maoDoJogador = jogadores[0].maoCartas.maoJogador
	prompt1.customize("Descarte de Cartas", "Para avançar você deve ter no máximo cinco cartas na sua mão", "Continuar", "", true, true)
	if (jogadores[0].maoCartas.maoJogador.size() > 5):
		prompt1.mudarStatusBotao(0, true)
	await prompt1.prompt(false)
	
	jogadorAtual = (jogadorAtual+1)%(BOTS_COUNT+1)
	remove_child(newDiscard)
	await get_tree().create_timer(0.2).timeout
	momentoSeEquipar()
# ---------------------------------------------------

#! FUNÇÕES DE ESCOLHAS DO JOGADOR
func atacarMonstro() -> void:
	var nomeTratamento = "Você" if jogadores[jogadorAtual].isHost else jogadores[jogadorAtual].jogador
	if jogadores[jogadorAtual].forca_turno > cartaSorteadaTurno.forca_total:
			var lvl_gain = cartaSorteadaTurno.lvl_reward
			var tesouro = cartaSorteadaTurno.tesouro
			prompt1.customize(nomeTratamento+" venceu o combate!", "Você subiu " + str(lvl_gain) + " nível(is)\n e ganhou " + str(tesouro) + " tesouros.", "Continuar", "", true)
			await prompt1.prompt(false)
			jogadores[jogadorAtual].aumentarNivel(lvl_gain)
			jogadores[jogadorAtual].maoCartas.gerarCartasTesouro(tesouro)
	else:
		var vaiDiminuirNivel: bool = cartaSorteadaTurno.acao == 2
		print(cartaSorteadaTurno)
		if vaiDiminuirNivel:
			if (jogadores[jogadorAtual].nivel - abs(cartaSorteadaTurno.acaoParametro) > 0):
				prompt1.customize(nomeTratamento+" perdeu o combate!", nomeTratamento+" perdeu " + str(abs(cartaSorteadaTurno.acaoParametro)) + " nível(is).", "Continuar", "", true)
				await prompt1.prompt(false)
				jogadores[jogadorAtual].aumentarNivel(cartaSorteadaTurno.acaoParametro)
			else:
				prompt1.customize(nomeTratamento+" perdeu o combate!", nomeTratamento+" morreu", "Continuar", "", true)
				await prompt1.prompt(false)
				jogadores[jogadorAtual].aumentarNivel(cartaSorteadaTurno.acaoParametro)
		else: 
			prompt1.customize(nomeTratamento+" perdeu o combate!", "", "Continuar", "", true)
			await prompt1.prompt(false)

func fugirMonstro() -> void:
	var nomeTratamento = "Você" if jogadores[jogadorAtual].isHost else jogadores[jogadorAtual].jogador
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var dado = rng.randi_range(1,6)
	prompt1.customize(nomeTratamento+" rolou o dado...", "seu resultado foi: " + str(dado), "Continuar", "", true, false)
	await prompt1.prompt(false)
	await get_tree().create_timer(0.2).timeout
	#TODO: implementar particularidades das classes e raças quanto ao 'fugir'
	if dado >= 5: 
		prompt1.customize(nomeTratamento+" fugiu do combate", nomeTratamento+" não vai ganhar o tesouro, mas também não perderá níveis", "Continuar", "", true, false)
		await prompt1.prompt(false)
	else:
		await atacarMonstro()

#! FUNÇÕES DE BOTS
func escolherCartasInterferenciaBots():
	for bot in jogadores_bot:
		if (bot == jogadores[jogadorAtual]):
			continue
		print(bot.jogador)
		var cartasAtual = bot.maoCartas.maoJogador
		var cartasValidas = []
		for carta in cartasAtual:
			if carta.tipo == 1 and carta.acao == 1:
				carta.alvoDoEfeito = 0
				cartasValidas.append(carta)
		print(cartasValidas)
		var contadorInterf = 0
		for cartaValida in cartasValidas:
			var num = RandomNumberGenerator.new()
			num.randomize()
			var chance = num.randi_range(1,4)
			if contadorInterf < 2 and chance > 2:
				cartasInterferenciaTurno.append(cartaValida)
				bot.maoCartas.removeDaMao(cartaValida)
				contadorInterf +=1
func escolherCartaAjudaBot():
	#cartasSlotDeAjuda
	if (jogadores[jogadorAtual] not in jogadores_bot):
		return
	var bot = jogadores[jogadorAtual]
	var cartasAtual = bot.maoCartas.maoJogador
	var cartasValidas = []
	for carta in cartasAtual:
		if carta.tipo == 1 and (carta.acao == 1 or carta.acao == 2):
			carta.alvoDoEfeito = 1
			cartasValidas.append(carta)
	var contadorInterf = 0
	for cartaValida in cartasValidas:
		var num = RandomNumberGenerator.new()
		num.randomize()
		var chance = num.randi_range(1,4)
		if contadorInterf < 2:
			cartasSlotDeAjuda.append(cartaValida)
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

#! FUNÇOES AUXILIARES
func aplicarEfeitoJogador(carta: CartaItem):
	var jogadorAlvo = jogadores[jogadorAtual]
	
	
func mostrarCartasDaLista(lista_cartas: Array[CartaClass]) -> void:
	var nomeDoJogadorDoTurno = jogadores[jogadorAtual].jogador
	for carta in lista_cartas:
		var nomeDono = carta.donoDaCarta.jogador
		if (nomeDono == nomeDoJogadorDoTurno):
			monster_box.customizarBox(carta, nomeDono + " interferiu no próprio jogo", true, "Continuar")
		elif (jogadorAtual == 0 and jogadores[jogadorAtual].isHost):
			monster_box.customizarBox(carta, nomeDono + " interferiu no seu jogo", true, "Continuar")
		else:
			monster_box.customizarBox(carta, nomeDono + " interferiu no jogo de "+nomeDoJogadorDoTurno, true, "Continuar")
		if (carta.acao == 1 and cartaSorteadaTurno.tipo == 3):
			if (carta.alvoDoEfeito == 0):
				cartaSorteadaTurno.adicionarIncrementoForca(carta.acao_parametro) # Método de carta monstro que adiciona força incremental
			elif(carta.alvoDoEfeito == 1):
				jogadores[jogadorAtual].addIncremento(carta.acao_parametro)
				jogadores[jogadorAtual].calcularForcaTurno()
		await monster_box.prompt()
		await get_tree().create_timer(0.2).timeout # Esperar antes de mostrar a próxima caixa
	
	
