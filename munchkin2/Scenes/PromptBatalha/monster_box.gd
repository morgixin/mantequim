class_name MonsterBoxUI extends Control
signal apertarUmBotao(acaoEscolhida: bool)

var screen
var posInicial
@onready var btn_acao_1_ref: Button = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/Opções/Botões/Acao1"
@onready var btn_acao_2_ref: Button = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/Opções/Botões/Acao2"

@onready var texto_do_momento: RichTextLabel = $"Panel/MarginContainer/ContainerMonstro/Texto do Momento"

@onready var nome_monstro_label: Label = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/Opções/Propriedades Monstro/Nome Monstro"
@onready var descricao_monstro_label: Label = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/Opções/Propriedades Monstro/Descrição Monstro"
@onready var forca_monstro_label: Label = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/Opções/Propriedades Monstro/Força Monstro"
@onready var tesouro_label: Label = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/Opções/Propriedades Monstro/Tesouro"

@onready var framesDoor = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/TextureDoor"
@onready var framesTesouro = $"Panel/MarginContainer/ContainerMonstro/Informações Monstro/TextureTesouro"

@onready var texture_rect: TextureRect = framesDoor
@onready var panel: PanelContainer = $Panel

var timer: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_key_input(false) #Desativa o reconhecimento de input
	screen = get_viewport().size
	#posInicial = Vector2(screen.x/2 - panel.size[0]/2, screen.y/2 - panel.size[1]/2 - 30)
	#panel.position = posInicial

	if btn_acao_1_ref:
		btn_acao_1_ref.pressed.connect(apertouBotao1) # Quando o botão for pressionado, chama a função onConfirm
	if btn_acao_2_ref:
		btn_acao_2_ref.pressed.connect(apertouBotao2) # Quando o botão for pressionado, chama a função onCancel
	hide() # Deixa o prompt de confirmação invisível

func apertouBotao1():
	fecharBox(true)
	
func apertouBotao2():
	fecharBox(false)

func fecharBox(acaoEscolhida: bool):
	set_process_unhandled_key_input(false) #Desativa o reconhecimento de input
	apertarUmBotao.emit(acaoEscolhida)
	hide()
	
func customizarBox(carta: CartaClass, titulo: String = "", mostrarApenasUmBotao: bool = true, btn1Label: String = "Continuar", btn2Label: String = "", desativarbtn1: bool = false, desativarbtn2: bool = false):
	timer = 0
	nome_monstro_label.text = "NOME: " + carta.nome
	descricao_monstro_label.text = "DESCRIÇÃO: " + carta.descricao
	texto_do_momento.text = "[wave][center]"+titulo
	btn_acao_1_ref.text = btn1Label
	btn_acao_2_ref.text = btn2Label
	
	if (carta.tipo == 3):
		if (carta.forca_total-carta.forca == 0):
			forca_monstro_label.text = "FORÇA: " + str(carta.forca_total)
		else:
			forca_monstro_label.text = "FORÇA: " + str(carta.forca_total) + " ("+str(carta.forca)+" + "+str(carta.forca_total-carta.forca)+")" #Adicionar força específica
		tesouro_label.text = "TESOURO: " + str(carta.tesouro)
		forca_monstro_label.show()
		tesouro_label.show()
		texture_rect = framesDoor
		framesTesouro.hide()
		framesDoor.show()
	else:
		forca_monstro_label.hide()
		tesouro_label.hide()
	
	if (carta.tipo == 1 or carta.tipo == 2):
		texture_rect = framesTesouro
		framesTesouro.show()
		framesDoor.hide()
	
	btn_acao_1_ref.disabled = desativarbtn1
	btn_acao_2_ref.disabled = desativarbtn2
	
	var frame_carta = carta.frame

	var x_atlas = 146*(frame_carta%6)
	var linha_atlas_y: int = (frame_carta/6)
	var y_atlas:int = 225*linha_atlas_y
	
	texture_rect.texture.region = Rect2(x_atlas,y_atlas,146,228)
	
	if (mostrarApenasUmBotao):
		btn_acao_2_ref.hide()
	else:
		btn_acao_2_ref.show()
	
func setTimerToClose(tempo: int) -> void:
	timer = tempo
	
func prompt():
	show()
	set_process_unhandled_key_input(true) #Ativa o reconhecimento de input
	# IMPLEMENTAR https://github.com/ava-cassiopeia/gdscript-signals NO FUTURO PARA ESPERAR QUALQUER UM
	if (timer != 0):
		await get_tree().create_timer(timer).timeout
		fecharBox(true)
		return true
	else:
		var botaoEscolhido = await apertarUmBotao # Aguareda o sinal que só é enviado na função close
		return botaoEscolhido


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
