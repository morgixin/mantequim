extends Control

var peer = WebSocketMultiplayerPeer.new()
var id = 0
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var hostId : int
var lobbyValue = ""
var lobbyInfo = {}
var cryptoUtil = UserCrypto.new()
var UC = UserController.getInstancia()

# Called when the node enters the scene tree for the first time.
func _ready():	
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)
	connectToServer()
	$"Control/MarginContainer/VBoxContainer/Botões".CreateUser.connect(UC.createUser)
	$"Control/MarginContainer/VBoxContainer/Botões".LoginUser.connect(UC.loginUser)
	pass # Replace with function body.

func connectToServer():
	peer.create_client("ws://127.0.0.1:8915")
	print("started client")
	UC.set_peer(peer)

func _on_connected_to_server():
	print("Connected to the server")
	multiplayer.connect("peer_connected", Callable(self, "RTCPeerConnected"))
	multiplayer.connect("peer_disconnected", Callable(self, "RTCPeerDisconnected"))

func _on_connection_error():
	print("Connection failed")

func _on_connection_closed():
	print("Connection closed")

func RTCServerConnected():
	print("RTC server connected")

func RTCPeerConnected(id):
	print("rtc peer connected " + str(id))
	
func RTCPeerDisconnected(id):
	print("rtc peer disconnected " + str(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			
			if data.message == Utilities.Message.id:
				id = data.id
				connected(id)
				
			if data.message == Utilities.Message.userConnected:
				createPeer(data.id)
				
			if data.message == Utilities.Message.lobby:
				hostId = data.host
				lobbyValue = data.lobbyValue
				
			if data.message == Utilities.Message.candidate:
				if rtcPeer.has_peer(data.orgPeer):
					print("Got Candidate: " + str(data.orgPeer) + " my id is " + str(id))
					rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid, data.index, data.sdp)
			
			if data.message == Utilities.Message.offer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
			
			if data.message == Utilities.Message.answer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("answer", data.data)
			
			if data.message == Utilities.Message.serverLobbyInfo:
				$LobbyBrowser.InstanceLobbyInfo(data.name, data.userCount)
			if data.message == Utilities.Message.playerinfo:
				# altera o valor de nome para o valor em data.username
				UC.set_username(data.username)
				UC.setIsUserLogged(true)
				
			if data.message == Utilities.Message.failedToLogin:
				print(data.text)
				# $LoginWindow.SetSystemErrorLabel(data.text)
	pass

func connected(id):
	rtcPeer.create_mesh(id)
	multiplayer.multiplayer_peer = rtcPeer
	UC.set_id(id)

# web rtc connection
func createPeer(id):
	if id != self.id:
		var peer = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{ "urls": ["stun:stun.l.google.com:19302"] }]
		})
		print("binding id " + str(id) + " my id is " + str(self.id))
		
		peer.session_description_created.connect(self.offerCreated.bind(id))
		peer.ice_candidate_created.connect(self.iceCandidateCreated.bind(id))
		rtcPeer.add_peer(peer, id)
		
		if !hostId == self.id:
			peer.create_offer()
		pass

func offerCreated(type, data, id):
	if !rtcPeer.has_peer(id):
		return
		
	rtcPeer.get_peer(id).connection.set_local_description(type, data)
	
	if type == "offer":
		sendOffer(id, data)
	else:
		sendAnswer(id, data)
	pass

func sendOffer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" : Utilities.Message.offer,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass

func sendAnswer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" : Utilities.Message.answer,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass

func iceCandidateCreated(midName, indexName, sdpName, id):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" : Utilities.Message.candidate,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass
