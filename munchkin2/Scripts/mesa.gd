class_name Mesa extends Control

var bots_count = VariaveisGlobais.BOTS_COUNT
const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const BOT_PLAYER_PATH = "res://Scenes/JogadorBot.tscn"
const DATA_MONSTER = "res://data/cartas_monstro.json"
const DATA_ITEM = "res://data/cartas_tesouro.json"
const DATA_MALDITION = "res://data/cartas_maldicao.json"
const DATA_CLASS = "res://data/cartas_classe.json"
const DATA_RACA = "res://data/cartas_raca.json"

# VARIÁVEIS DE JOGO
var momentoDoJogo = 0
var jogadores: Array[Jogador] = []
var jogadores_bot: Array[JogadorBot] = []
var jogadorAtual = 0
var vencedor = null
var mortes: Array[Jogador] = []
var jogadorMorreuNaRodada: bool = false

var cartaSorteadaTurno: CartaClass
var cartasInterferenciaTurno: Array[CartaClass] = []
var cartasSlotDeAjuda: Array[CartaClass] = []

var gerCartas: GerenciadorCartasClass = GerenciadorCartasClass.getInstancia()
var useCardSlot = null
var monsterCardSlot = null
@onready var prompt1: Prompt = $Confirmation
@onready var prompt2: Prompt = $useCardSlotPrompt
@onready var prompt3: Prompt = $promptESQ
@onready var monster_box: MonsterBoxUI = $MonsterBox
@onready var sprite_mesa: TextureRect = $sprite_mesa
@onready var sprite_batalha: TextureRect = $sprite_batalha

func _ready() -> void:
	print(UC.get_logged_user_username())
	jogadores.append($Jogador)
	instanciarBots()
	
	prompt3.adicionarPromptNaLista(prompt1)
	prompt3.adicionarPromptNaLista(prompt2)
	
	# Iniciando primeiro momento do Jogo
	momentoSeEquipar()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		prompt3.customize("Deseja sair do jogo?", "Escolha a opção desejada", "Fechar Jogo", "Cancelar",false, false, true )
		var isConfirmed = await prompt3.prompt(true)
		if isConfirmed:
			get_tree().quit()
	else:
		pass
# ---------------------------------------------------
#! MOMENTO PARA O JOGADOR SE EQUIPAR
func momentoSeEquipar() -> void:
	jogadorMorreuNaRodada = false
	await verificaSeGanhou()
	#Permitindo uso do deck de equipamentos
	for jogador in jogadores:
		jogador.maoCartasEquipadas.mudarBloqueioDeck(false)
		
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
		
		#Bloqueando uso do deck de equipamentos
		for jogador in jogadores:
			jogador.maoCartasEquipadas.mudarBloqueioDeck(true)
		
		for bot in jogadores_bot:
			bot.aplicarEquipamentos()
			bot.aplicarClassesRacas()
		if jogadorChutouAPorta:
			cartaSorteadaTurno = gerCartas.gerarCartaPorta()
			if (cartaSorteadaTurno.tipo == 3):
				monster_box.customizarBox(cartaSorteadaTurno, "Monstro Sorteado", true, "Continuar")
				remove_child(equip_slot)
				var jogadorContinuou = await monster_box.prompt()
				if jogadorContinuou:
					if cartaSorteadaTurno.min_level > jogadores[jogadorAtual].nivel:
						await get_tree().create_timer(0.2).timeout
						prompt1.customize("O monstro sorteado não luta com gente do seu nível.", "Cresça! Mas enquanto isso, ganhe uma carta de brinde.", "Continuar", "", true, false)
						await prompt1.prompt(false)
						momentoLootarCartas()
					else:	
						mudarParaBatalha()
			if (cartaSorteadaTurno.tipo == 6):
				cartaSorteadaTurno.alvoDoEfeito = 1
				monster_box.customizarBox(cartaSorteadaTurno, "Maldição Sorteada", true, "Continuar")	
				remove_child(equip_slot)
				var jogadorContinuou = await monster_box.prompt()
				if jogadorContinuou:
					momentoReceberMaldicao()
	else:
		prompt1.customize("É o turno de "+nomeDoJogadorDoTurno+"!", "Equipe cartas de classe, raça e equipamentos antes de avançar", "Continuar", "", true, true)
		await prompt1.prompt(false)
		
		#Bloqueando uso do deck de equipamentos
		for jogador in jogadores:
			jogador.maoCartasEquipadas.mudarBloqueioDeck(true)
		
		for bot in jogadores_bot:
			bot.aplicarEquipamentos()
			bot.aplicarClassesRacas()
		cartaSorteadaTurno = gerCartas.gerarCartaPorta()
		if (cartaSorteadaTurno.tipo == 3):
			monster_box.customizarBox(cartaSorteadaTurno, "Monstro Sorteado (Turno de "+nomeDoJogadorDoTurno+")", true, "Aguardando " + nomeDoJogadorDoTurno + " continuar", "", true, true)
			remove_child(equip_slot)
			monster_box.setTimerToClose(5)
			await monster_box.prompt()
			mudarParaBatalha()
		if (cartaSorteadaTurno.tipo == 6):
			cartaSorteadaTurno.alvoDoEfeito = 1
			monster_box.customizarBox(cartaSorteadaTurno, "Maldição Sorteada (Turno de "+nomeDoJogadorDoTurno+")", true, "Aguardando " + nomeDoJogadorDoTurno + " continuar", "", true, true)
			remove_child(equip_slot)
			monster_box.setTimerToClose(5)
			var jogadorContinuou = await monster_box.prompt()
			if jogadorContinuou:
				momentoReceberMaldicao()

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
	await verificarMorte()
	if jogadorMorreuNaRodada:
		jogadorAtual = jogadorAtual%jogadores.size()
		await get_tree().create_timer(0.2).timeout
		await momentoSeEquipar()
	else:
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

func momentoReceberMaldicao() -> void:
	var efeitoMaldicao = aplicarEfeitoJogador(cartaSorteadaTurno)
	var nomeTratamento = "Você" if jogadores[jogadorAtual].isHost else jogadores[jogadorAtual].jogador
	if (jogadores[jogadorAtual].isHost):
		prompt1.customize("Efeito Aplicado", nomeTratamento+" "+efeitoMaldicao.obterTextoResultado(), "Continuar", "", true, false)	
		await prompt1.prompt(false)
	else:
		prompt1.customize("Efeito Aplicado em "+nomeTratamento, nomeTratamento+" "+efeitoMaldicao.obterTextoResultado(), "Aguarde "+nomeTratamento+" continaur", "", true, false)	
		prompt1.mudarStatusBotao(0, true)
		prompt1.setTimerToClose(6)
		await prompt1.prompt(false)
	await verificarMorte()
	if jogadorMorreuNaRodada:
		jogadorAtual = jogadorAtual%jogadores.size()
		await get_tree().create_timer(0.2).timeout
		await momentoSeEquipar()
	else:
		await get_tree().create_timer(0.2).timeout
		if (jogadores[jogadorAtual].isHost):
			var jogadorTemCartaMonstro = jogadores[jogadorAtual].maoCartas.verificarCartasMonstro(false) != null	
			monster_box.customizarBox(cartaSorteadaTurno, "Escolha o que você irá fazer", false, "Loot the room", "Batalhar com monstro da mão", false, !jogadorTemCartaMonstro)
			var decidiuLootear = await monster_box.prompt()
			if (decidiuLootear):
				await momentoLootarCartas()
			else:
				await momentoBatalharMonstroMao()
		else:
			prompt1.customize("Aguardando decisão de "+jogadores[jogadorAtual].jogador, jogadores[jogadorAtual].jogador+" poderá escolher entre batalhar com um monstro da mão ou lootear a sala", "Aguarde", "", true, false)	
			prompt1.mudarStatusBotao(0, true)
			prompt1.setTimerToClose(6)
			await prompt1.prompt(false)
			var cartaMonstroMenorForca = jogadores[jogadorAtual].maoCartas.verificarCartasMonstro(true)
			if (cartaMonstroMenorForca && cartaMonstroMenorForca.forca < jogadores[jogadorAtual].forca_turno):
				await momentoBatalharMonstroMao()
			else:
				await momentoLootarCartas()		

func momentoLootarCartas() -> void:
	var cartaLootSorteada = gerCartas.gerarCartaPorta(false)
	cartaLootSorteada.donoDaCarta = jogadores[jogadorAtual]
	if (jogadores[jogadorAtual].isHost):
		$cartasDaMesa.add_child(cartaLootSorteada)
	jogadores[jogadorAtual].maoCartas.addMao(cartaLootSorteada)
	await get_tree().create_timer(0.2).timeout
	if (jogadores[jogadorAtual].isHost):
		monster_box.customizarBox(cartaLootSorteada, "Carta Sorteada", true, "Continuar")
		await monster_box.prompt()
	else:
		monster_box.customizarBox(cartaLootSorteada, jogadores[jogadorAtual].jogador+" recebeu um Loot!", true, "Aguardando "+jogadores[jogadorAtual].jogador+" continuar", "",true)	
		monster_box.setTimerToClose(7)
		await monster_box.prompt()
	momentoDescarte()
	
func momentoBatalharMonstroMao() -> void:
	await get_tree().create_timer(0.2).timeout
	if !jogadores[jogadorAtual].isHost:
		var nome_do_jogador_atual = jogadores[jogadorAtual].jogador
		prompt1.customize("Aguardando "+nome_do_jogador_atual+" escolher um monstro", "", "Aguarde", "", true)
		prompt1.mudarStatusBotao(0,true)
		prompt1.setTimerToClose(5)
		await prompt1.prompt()
		var cartaMonstroMenorForca = jogadores[jogadorAtual].maoCartas.verificarCartasMonstro(true)
		cartaSorteadaTurno = cartaMonstroMenorForca
		monster_box.customizarBox(cartaSorteadaTurno, nome_do_jogador_atual+" escolheu um monstro da mão", true, "Aguarde por "+nome_do_jogador_atual, "", true)
		monster_box.setTimerToClose(5)
		await monster_box.prompt()
		
		await mudarParaBatalha()
	else:
		var monsterCardSlotScene = preload("res://Scenes/Slots/MonsterSlot.tscn")
		var newMonsterCardSlot = monsterCardSlotScene.instantiate()
		var screen = get_viewport_rect().size
		newMonsterCardSlot.position = Vector2(screen.x/2, screen.y/2 - 80)
		add_child(newMonsterCardSlot)
		monsterCardSlot = newMonsterCardSlot
		newMonsterCardSlot.promptBtn = prompt1
		
		prompt1.customize("Pronto para continuar?", "Você pode jogar somente uma carta", "Sim", "", true, true)
		prompt1.mudarStatusBotao(0, true)
		await prompt1.prompt(false)
		
		var cartaEscolhidaParaBatalhar =  monsterCardSlot.cartaEscolhida[0]
		cartaSorteadaTurno = cartaEscolhidaParaBatalhar
		await newMonsterCardSlot.desativarCartas()
		remove_child(newMonsterCardSlot)
		await mudarParaBatalha()
	
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
			aplicarEfeitoJogador(carta)

	if (jogadorAtual != 0):
		for carta in newUseCardSlot.cartasUsadas:
			cartasInterferenciaTurno.append(carta) 

	await newUseCardSlot.desativarCartas()
	remove_child(newUseCardSlot)
	
	if (irParaResumo):
		mostrarResumoDaBatalha()
	else:
		return

func mostrarResumoDaBatalha() -> void:
	var o_turno_e_meu = jogadorAtual == 0 and jogadores[jogadorAtual].isHost
	var nomeDoJogadorDoTurno = jogadores[jogadorAtual].jogador
	momentoDoJogo = 3
	if o_turno_e_meu:
		var podeFugir = jogadores[jogadorAtual].podeFugir
		monster_box.customizarBox(cartaSorteadaTurno, "Resumo da Batalha de " + nomeDoJogadorDoTurno, false, "Atacar Monstro", "Fugir", false, !podeFugir)
	else:
		monster_box.customizarBox(cartaSorteadaTurno, "Resumo da Batalha de " + nomeDoJogadorDoTurno, true, "Aguarde "+nomeDoJogadorDoTurno, "Fugir", true)
		monster_box.setTimerToClose(6)
	var jogadorAtacou = await monster_box.prompt()
	
	if o_turno_e_meu and jogadorAtacou:
		await atacarMonstro()
	elif o_turno_e_meu and !jogadorAtacou:
		await fugirMonstro()
	
	if !o_turno_e_meu:
		if (jogadores[jogadorAtual].forca_turno > cartaSorteadaTurno.forca_total or !jogadores[jogadorAtual].podeFugir):
			await atacarMonstro()
		else:
			await fugirMonstro()
		
	await get_tree().create_timer(0.2).timeout
	await momentoDescarte()
#! MOMENTO DE DESCARTAR CARTAS
func momentoDescarte() -> void:
	momentoDoJogo = 4
	if(jogadorAtual < jogadores.size()):
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
	for bot in jogadores_bot:
		bot.descartarCartas()
	if jogadorMorreuNaRodada:
		jogadorAtual = jogadorAtual%jogadores.size()
	else:
		jogadorAtual = (jogadorAtual+1)%(jogadores.size())
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
		# FUNÇÃO DE BADSTUFF QUE RETORNA O TEXTO PARA ADICIONAR NO PROMPT
		var efeitoBadStuff = Efeito.create(cartaSorteadaTurno.acao)
		efeitoBadStuff.processarEfeito(1, jogadores[jogadorAtual], cartaSorteadaTurno.acaoParametro, cartaSorteadaTurno.target)

		prompt1.customize(nomeTratamento+" perdeu o combate!", efeitoBadStuff.obterTextoResultado(), "Continuar", "", true)
		await prompt1.prompt(false)

		await verificarMorte()

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
		var cartasAtual = bot.maoCartas.maoJogador
		var cartasValidas = []
		for carta in cartasAtual:
			if carta.tipo == 1 and (carta.acao == 1 or carta.acao == 2):
				print("Aplicando carta "+carta.nome+" no monstro")
				carta.alvoDoEfeito = 0
				cartasValidas.append(carta)
			if carta.tipo == 6:
				print("Aplicando carta "+carta.nome+" no jogador")
				carta.alvoDoEfeito = 1
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
		if contadorInterf < 2 and chance > 2:
			cartasSlotDeAjuda.append(cartaValida)
			bot.maoCartas.removeDaMao(cartaValida)
			contadorInterf +=1	

func instanciarBots():
	for i in range(bots_count):
		var novoBot = JogadorBot.new()
		var maoEquipadosBot = MaoEquipados.create(novoBot)
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
func verificarMorte():
	if (jogadores[jogadorAtual].estaMorto):
		mortes.insert(0, jogadores[jogadorAtual])
		jogadorMorreuNaRodada = true
		var nomeTratamento = "Você" if jogadores[jogadorAtual].isHost else jogadores[jogadorAtual].jogador
		await get_tree().create_timer(0.2).timeout
		if jogadores[jogadorAtual].isHost:
			prompt1.customize(nomeTratamento+" morreu!", "", "Ir para o Menu", "", true)
			await prompt1.prompt(false)
			get_tree().change_scene_to_file.bind("res://Scenes/Menu.tscn").call_deferred()
		else:
			prompt1.customize(nomeTratamento+" morreu!", "", "Continuar", "", true)
			await prompt1.prompt(false)
			var bot = jogadores[jogadorAtual]
			jogadores.erase(bot)
			jogadores_bot.erase(bot)

func aplicarEfeitoJogador(carta: CartaClass) -> Efeito:
	var jogadorAlvo = jogadores[jogadorAtual]
	var objetoDoEfeito = jogadorAlvo
	if (cartaSorteadaTurno.tipo == 3):
		objetoDoEfeito = jogadorAlvo if carta.alvoDoEfeito == 1 else cartaSorteadaTurno
	var target = carta.target if ("target" in carta) else -1
	var efeitoInterferencia = Efeito.create(carta.acao)
	efeitoInterferencia.processarEfeito(carta.alvoDoEfeito, objetoDoEfeito, carta.acao_parametro, target)
	return efeitoInterferencia
	
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
		aplicarEfeitoJogador(carta)
		await monster_box.prompt()
		await get_tree().create_timer(0.2).timeout # Esperar antes de mostrar a próxima caixa

func verificaSeGanhou():
	if jogadores.size() == 1:
		vencedor = jogadores[0]
	for jogador in self.jogadores:
		if jogador.nivel >=10:
			vencedor = jogador
	if vencedor != null:
		var colocacoes = jogadores.duplicate(true)
		colocacoes.sort_custom(func(a,b): return a.nivel > b.nivel)
		if colocacoes.size() < 3:
			var qtd = 3 - colocacoes.size()
			for i in range(0,qtd):
				if mortes.size() > i:
					colocacoes.append(mortes[i])
				else:
					break
		await get_tree().create_timer(0.2).timeout
		var textoColocacoes = ""
		for i in range(0, colocacoes.size()):
			textoColocacoes += str(i+1) + "° lugar: " + colocacoes[i].jogador + "\n"
		prompt1.customize(vencedor.jogador + " ganhou!!!!!!!!", textoColocacoes, "Ir para o menu", "", true, false)
		await prompt1.prompt(false)
		get_tree().change_scene_to_file.bind("res://Scenes/Menu.tscn").call_deferred()
		
		
