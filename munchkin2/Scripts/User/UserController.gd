extends Node
class_name UserController

var lobbyValue = ""
var id : int
var user = User.new()
var peer
var cryptoUtil = UserCrypto.new()

static var _isUserLogged
static var instancia = null

static func _UserController() -> UserController:
	instancia = UserController.new()
	_isUserLogged = false
	return instancia

static func getInstancia() -> UserController:
	if instancia == null:
		instancia = _UserController()
	return instancia

func set_peer(_peer: WebSocketMultiplayerPeer):
	peer = _peer
	
func set_id(_id: int):
	id = _id

func set_username(username: String):
	user.set_username(username)

func get_logged_user_username():
	return user.get_username()

func isUserLogged() -> bool:
	return _isUserLogged

func loginUser(username, password):
	var data = {
		"username" : username.strip_edges(true, true), 
		"password" : cryptoUtil.HashData(password.strip_edges(true, true))
	}

	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" :  Utilities.Message.loginUser,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

	set_username(username.strip_edges(true, true))
	_isUserLogged = true

func createUser(username, password):
	var data = {
		"username" : username.strip_edges(true, true), 
		"password" : cryptoUtil.HashData(password.strip_edges(true, true))
	}
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" : Utilities.Message.createUser,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
