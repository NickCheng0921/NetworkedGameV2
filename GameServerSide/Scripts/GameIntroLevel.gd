extends Node2D

var Player = load("res://Scenes/Player.tscn")
var Creature = load("res://Scenes/Creature.tscn")
var numKeyPositions = 10
var keyIndex = 0
var numKeysToSpawn = 3
var creatureDeaths = 0
var keyArray = []
	
func _ready():
	randomize()
	pick_keys()
	
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

func pick_keys():
	keyArray = []
	keyIndex = 0
	for i in range(3):
		var num = (randi() % numKeyPositions) + 1
		while num in keyArray:
			num = (randi() % numKeyPositions) + 1
		keyArray.append(num)
	print("Keys chosen: ", keyArray)
	
remote func spawn_keys(): #network call to client to spawn keys
#----Make Client spawn all keys at once
	#for i in keyArray: 
	#	var key_pos = get_node("/root/GameIntroLevel/keyPosition/keyPos" + str(i)).position
	#	rpc("client_spawn_key", key_pos)
#----Spawn a key on client side, then wait til they find it to spawn next
	if not (keyIndex+1 > numKeysToSpawn):
		print("Spawn key ", keyIndex+1)
		var key_pos = get_node("/root/GameIntroLevel/keyPosition/keyPos" + str(keyArray[keyIndex])).position
		rpc("client_spawn_key", key_pos)
		keyIndex += 1
	else:
		print("All keys found")
