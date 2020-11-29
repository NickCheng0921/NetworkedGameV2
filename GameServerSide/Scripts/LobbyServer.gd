extends Node2D

var openPort = 44444;
var max_clients = 4;
var playerReady = 0;
var ready_players = []

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	var server = NetworkedMultiplayerENet.new()
	server.create_server(openPort, max_clients)
	displayServerInfo()
	get_tree().set_network_peer(server)

func displayServerInfo():
	print("IP: ", IP.get_local_addresses()[1])
	print("Port: ", openPort, '\n')
	
func _player_connected(id):
	print("Player ", id, " connected to server")
	ready_players.append(id)
	#start game once a player connects
	if ready_players.size() == 1:
		pre_start_game()
	
func _player_disconnected(id):
	print("Client ", id, " disconnected")
	
func pre_start_game():
	#load game and spawn players locally before doing it over network for players
	var world = load("res://Scenes/GameIntroLevel.tscn").instance()
	get_tree().get_root().add_child(world)
	#spawn players
	for id in ready_players:
		get_node("/root/GameIntroLevel").spawn_player(Vector2(0,0), id)
		
	rpc("pre_start_game")
	
remote func post_start_game():
	print("Player ", get_tree().get_rpc_sender_id(), " loaded world")
	var caller_id = get_tree().get_rpc_sender_id()
	var world = get_node("/root/GameIntroLevel")
	
	for player in ready_players:
		#world.rpc_id(player, "spawn_player", Vector2(0,0), player.get_network_master())
		print("RPC load ", player)
