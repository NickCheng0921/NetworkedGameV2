extends Node2D

var Player = load("res://Scenes/Player.tscn")
var Creature = load("res://Scenes/Creature.tscn")
var numKeyPositions = 10
var creatureDeaths = 0
var keyArray = []
	
func _ready():
	randomize()
	for i in range(3):
		var num = (randi() % numKeyPositions) + 1
		while num in keyArray:
			num = (randi() % numKeyPositions) + 1
		keyArray.append(num)
	print("Keys chosen: ", keyArray)
	
func spawn_player(spawn_pos, id):
	var player = Player.instance()
	player.position = spawn_pos
	player.name = String(id)
	player.set_network_master(id)
	get_node("/root/GameIntroLevel/humans").add_child(player)
	print("    Player spawned")

func spawn_creature(spawn_pos, id):
	var creature = Creature.instance()
	creature.position = spawn_pos
	creature.name = String(id)
	creature.set_network_master(id)
	get_node("/root/GameIntroLevel/creatures").add_child(creature)
	print("    Creature spawned")

func spawn_keys(): #network call to client to spawn keys
	for i in keyArray:
		var key_pos = get_node("/root/GameIntroLevel/keyPosition/keyPos" + str(i)).position
		rpc("client_spawn_key", key_pos)
