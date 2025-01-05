extends Node

var peer = WebSocketMultiplayerPeer.new()
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var id = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"MarginContainer/VBoxContainer/Botões".LoginUser.connect(loginUser)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func createUser(username, password): 
	var data = {
		"username" : username,
		"password": password
	}
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message": createUser,
		"data": data
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func loginUser(username, password): 
	var data = {
		"username" : username,
		"password": password
	}
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message": loginUser,
		"data": data
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
