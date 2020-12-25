extends Node2D

var openPort = 44444
var max_clients = 4
var playerReady = 0
var playersToStartGame = 2
var ready_players = []
var level
var victoryScreen = preload("res://Scenes/victoryScreen.tscn")
var numFinishedPlayers = 0
var canDeleteLevel = true
	
func _ready():
	print("Server up")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	var server = NetworkedMultiplayerENet.new()
	server.create_server(openPort, max_clients)
	get_tree().set_network_peer(server)

func _player_connected(id):
	print("    P", id, " connected to server")
	ready_players.append(id)
	#start game once 2 players connect
	if ready_players.size() == playersToStartGame:
		pre_start_game()
		get_tree().set_refuse_new_network_connections(true)
	
func _player_disconnected(id):
	print("Client ", id, " disconnected")
	ready_players.erase(id)
	
remote func replay_call():
	playerReady += 1
	if(playerReady == playersToStartGame):
		print("Setting up new game")
		get_node("/root/victoryScreen").call_deferred('free')
		playerReady = 0
		pre_start_game()
	
func pre_start_game():
	print("Load map and spawn players locally")
	#load game and spawn players locally before doing it over network for players
	var world = load("res://Scenes/GameIntroLevel.tscn").instance()
	get_tree().get_root().add_child(world)
	level = get_node("/root/GameIntroLevel")
	canDeleteLevel = true
	#spawn players
	var spawn_pos1 = Vector2(-3000, 650)
	var spawn_pos2 = Vector2(1000, 1000)
	#right now, spawning is hard coded, make it through loop in future
	if(ready_players.size() == 1):
		get_node("/root/GameIntroLevel").spawn_creature(spawn_pos2, ready_players[0])
	if(ready_players.size() == 2):
		get_node("/root/GameIntroLevel").spawn_creature(spawn_pos2, ready_players[0])
		get_node("/root/GameIntroLevel").spawn_player(spawn_pos1, ready_players[1])
		
	for id in ready_players:
		rpc_id(id, "pre_start_game")
	print("Wait for players to set up game")
	
remote func post_start_game(): #spawn players and objects
	var caller_id = get_tree().get_rpc_sender_id()
	print("    P", caller_id, " loaded map")
	#for id in ready_players:
	#	print("        RPC load ", id)
	#	rpc_id( caller_id, "spawn_player", Vector2(500, 300), id )
	if(ready_players.size() == 1):
		rpc_id( caller_id, "spawn_creature", Vector2(1000, 1000), ready_players[0] )
	if(ready_players.size() == 2):
		rpc_id( caller_id, "spawn_creature", Vector2(1000, 1000), ready_players[0] )
		rpc_id( caller_id, "spawn_player", Vector2(-3000, 650), ready_players[1] )
		#for 2 player system, get creature and set up the hint arrow
	get_node("/root/GameIntroLevel").spawn_keys()
	
func gameOver(winCode): #used when server ends game
	print("Match Over")
	get_node("/root/Lobby").rpc("gameOver", winCode)
	
remote func remoteGameOver(winCode): #used when clients end game
	print("Match Over")
	get_node("/root/Lobby").rpc("gameOver", winCode)
	
remote func localLevelDeleted(): #server removes level once all clients remove level
	numFinishedPlayers += 1

	if(numFinishedPlayers >= ready_players.size()):
		print(numFinishedPlayers, " Players deleted level")
		numFinishedPlayers = 0
		if level and canDeleteLevel:
			print("Server deleted level")
			canDeleteLevel = false #handles duplicate network call
			#deleteLevel set to true again when new level made
			level.queue_free()
			get_tree().get_root().add_child(victoryScreen.instance())
