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
	print("1. Server up on port: ", openPort)
	
func _player_connected(id):
	print("    P", id, " connected to server")
	ready_players.append(id)
	#start game once 2 players connect
	if ready_players.size() == 2:
		pre_start_game()
	
func _player_disconnected(id):
	print("Client ", id, " disconnected")
	ready_players.erase(id)
	
func pre_start_game():
	print("2. Load map and spawn players locally")
	#load game and spawn players locally before doing it over network for players
	var world = load("res://Scenes/GameIntroLevel.tscn").instance()
	get_tree().get_root().add_child(world)
	#spawn players
	var spawn_pos1 = Vector2(500, 300)
	var spawn_pos2 = Vector2(1000, 1000)
	#right now, spawning is hard coded, make it through loop in future
	if(ready_players.size() == 1):
		get_node("/root/GameIntroLevel").spawn_creature(spawn_pos2, ready_players[0])
	if(ready_players.size() == 2):
		get_node("/root/GameIntroLevel").spawn_creature(spawn_pos2, ready_players[0])
		get_node("/root/GameIntroLevel").spawn_player(spawn_pos1, ready_players[1])
		
	for id in ready_players:
		rpc_id(id, "pre_start_game")
	print("3. Wait for players to set up game")
	
remote func post_start_game():
	var caller_id = get_tree().get_rpc_sender_id()
	print("    P", caller_id, " loaded map")
	#for id in ready_players:
	#	print("        RPC load ", id)
	#	rpc_id( caller_id, "spawn_player", Vector2(500, 300), id )
	if(ready_players.size() == 1):
		rpc_id( caller_id, "spawn_creature", Vector2(1000, 1000), ready_players[0] )
	if(ready_players.size() == 2):
		rpc_id( caller_id, "spawn_creature", Vector2(1000, 1000), ready_players[0] )
		rpc_id( caller_id, "spawn_player", Vector2(500, 300), ready_players[1] )
