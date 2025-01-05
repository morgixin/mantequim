extends Node
class_name UserController

# var _isUserLogged : bool
var lobbyValue = ""
var id : int
var user = User.new()
var peer
var cryptoUtil = UserCrypto.new()


func set_peer(_peer: WebSocketMultiplayerPeer):
	peer = _peer
	
func set_id(_id: int):
	id = _id

func set_username(username: String):
	user.set_username(username)

func get_logged_user_username():
	# if _isUserLogged:
	return user.get_username()
	
func isUserLogged() -> bool:
	return user.get_username() != ""
	
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
