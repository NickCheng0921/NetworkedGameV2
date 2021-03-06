extends Node2D

const connectLocalIP = "127.0.0.1"
const connectServerIP = "34.94.217.163"
const connectPort = 44444;
var Player = load("res://Scenes/Player.tscn")
var Creature = load("res://Scenes/Creature.tscn")
var level #used for removing and changing maps
var victoryScreen = preload("res://Scenes/victoryScreen.tscn")
var humanHUD = preload("res://Scenes/humanHUD.tscn")
var creatureHUD = preload("res://Scenes/creatureHUD.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func _on_connectLanButton_pressed():
	print("Joining network")
	var client = NetworkedMultiplayerENet.new()
	client.create_client(connectLocalIP, connectPort)
	get_tree().set_network_peer(client)
	
func _on_connectServerButton_pressed():
	print("Joining network")
	var client = NetworkedMultiplayerENet.new()
	client.create_client(connectServerIP, connectPort)
	get_tree().set_network_peer(client)

func _connected_ok():
	$connectServerButton.hide()
	$connectServerButton.disabled = true
	$connectLanButton.hide()
	$connectLanButton.disabled = true
	print("Connection Successful")
	
func _connected_fail():
	print("Connection Unsuccessful")
	
func _server_disconnected():
	print("ERROR: Server disconnected")

puppet func pre_start_game():
	print("Pre starting game")
	get_node("/root/Lobby").hide()
	var world = load("res://Scenes/GameIntroLevel.tscn").instance()
	get_tree().get_root().add_child(world)
	level = get_node("/root/GameIntroLevel")
	rpc_id(1, "post_start_game")


puppet func spawn_player(spawn_pos, id):
	print("Spawning a player ", id)
	var player = Player.instance()
	
	player.position = spawn_pos
	player.name = String(id)
	player.set_network_master(id)
	#if this client version "owns" the player, we need to add a camera, spawn keys, and add a HUD
	if(id == get_tree().get_network_unique_id()):
		Gamestate.isHuman = true
		var camera = Camera2D.new()
		camera.make_current()
		camera.set_limit_smoothing_enabled(100)
		player.add_child(camera)
		#make keys if player controls side
		get_node("/root/GameIntroLevel").rpc_id(1, "spawn_keys")
		var hud = humanHUD.instance() #make hud for player
		player.add_child(hud)
	get_node("/root/GameIntroLevel/humans").add_child(player)

puppet func spawn_creature(spawn_pos, id):
	print("Spawning a creature ", id)
	var creature = Creature.instance()
	
	creature.position = spawn_pos
	creature.name = String(id)
	creature.set_network_master(id)
	#if this client version "owns" the creature, we need to add a camera, and add a HUD
	if(id == get_tree().get_network_unique_id()):
		Gamestate.isHuman = false
		get_node("/root/GameIntroLevel/black background").hide()
		var camera = Camera2D.new()
		camera.make_current()
		camera.set_limit_smoothing_enabled(100)
		creature.add_child(camera)
		var hud = creatureHUD.instance()
		creature.add_child(hud)
	
	get_node("/root/GameIntroLevel/creatures").add_child(creature)

remote func gameOver(winCode):
	if level:
		level.call_deferred('free')
	rpc_id(1, "localLevelDeleted") #tell server we deleted level
	print("Victory Screen Displayed")
	get_tree().get_root().add_child(victoryScreen.instance())
	if(winCode == 'c'): #switch statement not yet in Godot?
		get_node("/root/victoryScreen/creatureVictory").show()
		get_node("/root/victoryScreen/humanVictory").hide()
	if(winCode == 'h'):
		get_node("/root/victoryScreen/creatureVictory").hide()
		get_node("/root/victoryScreen/humanVictory").show()
		
		
func _on_Instructions_pressed():
	print("Instructions blah blah")
