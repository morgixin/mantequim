class_name Confirmation extends Control
signal confirmed(isConfirmed: bool)
var isOpen: bool = false
var shouldUnpause: bool = false
var cancel_ref
var confirmed_ref
var header_ref
var message_ref
var startOnLeft = false
var posInicial
var screen
@onready var modal = $Modal


func _ready() -> void:
	set_process_unhandled_key_input(false) #Desativa o reconhecimento de input
	get_tree().get_root().size_changed.connect(resize)
	screen = get_viewport().size
	posInicial = Vector2(screen.x/2 - $Modal.size[0]/2, screen.y/2 - $Modal.size[1]/2 - 30)
	$Modal.position = posInicial
	header_ref = $Modal/MarginContainer/VBoxContainer/VBoxContainer/header
	message_ref = $Modal/MarginContainer/VBoxContainer/VBoxContainer/message
	confirmed_ref = $Modal/MarginContainer/VBoxContainer/HBoxContainer/btnConf
	cancel_ref = $Modal/MarginContainer/VBoxContainer/HBoxContainer/btnCanc
	if confirmed_ref:
		confirmed_ref.pressed.connect(onConfirm) # Quando o botão for pressionado, chama a função onConfirm
	if cancel_ref:
		cancel_ref.pressed.connect(onCancel) # Quando o botão for pressionado, chama a função onCancel
	hide() # Apaga o prompt de confirmação

func resize() -> void:
	screen = get_viewport().size
	posInicial = Vector2(screen.x/2 - $Modal.size[0]/2, screen.y/2 - $Modal.size[1]/2 - 30)
	
	if startOnLeft:
		var posLado = Vector2(screen.x - $Modal.size[0] - 30,screen.y/2 - $Modal.size[1]/2 - 30)
		$Modal.position = posLado
	else:
		$Modal.position = posInicial
			

#func _unhandled_key_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#onCancel() # Se o prompt aparecer e o usuário perder esc, vamos fechar o prompt

func close_modal(isConfirmed):
	set_process_unhandled_key_input(false) #Desativa o reconhecimento de input
	confirmed.emit(isConfirmed)
	set_deferred("isOpen", false)
	hide()
	if shouldUnpause:
		get_tree().paused = false
	
func onConfirm():
	close_modal(true)
	
func onCancel():
	close_modal(false)

func customize(header: String, msg: String, confirmText: String = "Confirmar", cancelText: String = "Cancelar", oneButton: bool = false, beOnLeft: bool = false):
	header_ref.text = header
	message_ref.text = msg
	confirmed_ref.text = confirmText
	cancel_ref.text = cancelText
	startOnLeft = beOnLeft
	if (oneButton):
		cancel_ref.hide()
	else:
		cancel_ref.show()
	modal.size= Vector2(0,0)
	return self
	
func prompt(pause: bool = false) -> bool:
	shouldUnpause = (get_tree().paused == false) and pause

	if pause:
		get_tree().paused = true
	$Modal.position = posInicial
	show()
	if startOnLeft:
		var posLado = Vector2(screen.x - $Modal.size[0] - 30,screen.y/2 - $Modal.size[1]/2 - 30)
		$Modal.position = posLado
	else:
		print("tween meio")
		var posMeio =Vector2(screen.x/2 - $Modal.size[0]/2, screen.y/2 - $Modal.size[1]/2 - 30)
	isOpen = true
	set_process_unhandled_key_input(true) #Ativa o reconhecimento de input
	var isConfirmed = await confirmed # Aguareda o sinal que só é enviado na função close
	return isConfirmed

func _process(delta: float) -> void:
	pass
