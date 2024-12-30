class_name Confirmation extends Control
signal confirmed(isConfirmed: bool)
var isOpen: bool = false
var shouldUnpause: bool = false
var cancel_ref
var confirmed_ref
var header_ref
var message_ref

func _ready() -> void:
	set_process_unhandled_key_input(false)
	header_ref = $Modal/MarginContainer/VBoxContainer/header
	message_ref = $Modal/MarginContainer/VBoxContainer/message
	confirmed_ref = $Modal/MarginContainer/VBoxContainer/HBoxContainer/btnConf
	cancel_ref = $Modal/MarginContainer/VBoxContainer/HBoxContainer/btnCanc
	if confirmed_ref:
		confirmed_ref.pressed.connect(onConfirm)
	if cancel_ref:
		cancel_ref.pressed.connect(onCancel)
	hide()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		onCancel()

func close_modal(isConfirmed):
	set_process_unhandled_key_input(false)
	confirmed.emit(isConfirmed)
	set_deferred("isOpen", false)
	hide()
	if shouldUnpause:
		get_tree().paused = false
	
func onConfirm():
	close_modal(true)
	
func onCancel():
	close_modal(false)
	
func close(isConfirmed: bool = false):
	if isConfirmed:
		onConfirm()
	else:
		onCancel()

func customize(header: String, msg: String, confirmText: String = "Confirmar", cancelText: String = "Cancelar"):
	header_ref.text = header
	message_ref.text = msg
	confirmed_ref.text = confirmText
	cancel_ref.text = cancelText
	return self
	
func prompt(pause: bool = false) -> bool:
	shouldUnpause = (get_tree().paused == false) and pause
	if pause:
		get_tree().paused = true
	show()
	isOpen = true
	set_process_unhandled_key_input(true)
	var isConfirmed = await confirmed
	return isConfirmed

func _process(delta: float) -> void:
	pass
