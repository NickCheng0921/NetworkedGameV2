extends Node2D

var openPort = 4242;
var max_clients = 2;

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	var server = NetworkedMultiplayerENet.new()
	server.create_server(openPort, max_clients)
	displayServerInfo()
	get_tree().set_network_peer(server)

func displayServerInfo():
	print("IP: ", IP.get_local_addresses()[1])
	print("Port: ", openPort)
	
func _player_connected(id):
	print("Player ", id, " connected to server")

func _player_disconnected(id):
	print("Client ", id, " disconnected")
#func _process(delta):
#	pass
