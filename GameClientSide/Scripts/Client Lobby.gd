extends Node2D

const connectIP = "34.94.217.163"
#const connectIP = "127.0.0.1"
const connectPort = 44444;
var Player = load("res://Scenes/Player.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func _on_connectButton_pressed():
	print("Joining network")
	var client = NetworkedMultiplayerENet.new()
	client.create_client(connectIP, connectPort)
	get_tree().set_network_peer(client)
	
func _connected_ok():
	$connectButton.hide()
	$connectButton.disabled = true
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
	
	rpc_id(1, "post_start_game")


puppet func spawn_player(spawn_pos, id):
	print("Spawning a player")
	var player = Player.instance()
	
	player.position = spawn_pos
	player.name = String(id)
	player.set_network_master(id)
	get_node("/root/GameIntroLevel").add_child(player)
