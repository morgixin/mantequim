extends Node

var peer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}
var dao = DAO.new()
# var Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
@export var hostPort = 8915

var cryptoUtil = UserCrypto.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	if "--server" in OS.get_cmdline_args():
		print("hosting on " + str(hostPort))
		peer.create_server(hostPort)
		
	peer.connect("peer_connected", peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)
	pass # Replace with function body.

func _init() -> void:
	startServer()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			print(data)
			
			#if data.message ==  Utilities.Message.lobby:
				#JoinLobby(data)
			
			if data.message == Utilities.Message.loginUser:
				login(data)
				
			if data.message == Utilities.Message.createUser:
				createUser(data)
				
			if data.message ==  Utilities.Message.offer || data.message ==  Utilities.Message.answer || data.message ==  Utilities.Message.candidate:
				print("source id is " + str(data.orgPeer))
				sendToPlayer(data.peer, data)
				
			if data.message ==  Utilities.Message.removeLobby:
				if lobbies.has(data.lobbyID):
					lobbies.erase(data.lobbyID)
	pass

func peer_connected(id):
	print("Peer Connected: " + str(id))
	users[id] = {
		"id" : id,
		"message" :  Utilities.Message.id
	}
	peer.get_peer(id).put_packet(JSON.stringify(users[id]).to_utf8_buffer())
	pass
	
func peer_disconnected(id):
	users.erase(id)
	pass


func createUser(data):
	var salt = cryptoUtil.GenerateSalt()
	var hashedPassword = cryptoUtil.HashPassword(data.data.password, salt)
	dao.InsertUserData(data.data.username, hashedPassword, salt)
	#login(data)
	
func login(data):
	var userData = dao.GetUserFromDB(data.data.username)
	if(userData != null and userData.hashedPassword == cryptoUtil.HashPassword(data.data.password, userData.salt)):
		var returnData = {
			"username" : userData.username,
			"id" : userData.id,
			"message" : Utilities.Message.playerinfo,
			# "score" : userData.score
		}
		peer.get_peer(data.peer).put_packet(JSON.stringify(returnData).to_utf8_buffer())
	else:
		var returnData ={
			"message" : Utilities.Message.failedToLogin,
			"text" : "Failed to login invalid username or password"
		}
		peer.get_peer(data.peer).put_packet(JSON.stringify(returnData).to_utf8_buffer())
		
func sendToPlayer(userId, data):
	peer.get_peer(userId).put_packet(JSON.stringify(data).to_utf8_buffer())

func startServer():
	peer.create_server(8915)
	print("Started Server")
