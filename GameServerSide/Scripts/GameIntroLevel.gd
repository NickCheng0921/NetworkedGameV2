extends Node2D

var Player = load("res://Scenes/Player.tscn")
var Creature = load("res://Scenes/Creature.tscn")
var creatureDeaths = 0

func spawn_player(spawn_pos, id):
	var player = Player.instance()
	player.position = spawn_pos
	player.name = String(id)
	player.set_network_master(id)
	get_node("/root/GameIntroLevel").add_child(player)
	print("    Player spawned")

func spawn_creature(spawn_pos, id):
	var creature = Creature.instance()
	creature.position = spawn_pos
	creature.name = String(id)
	creature.set_network_master(id)
	get_node("/root/GameIntroLevel").add_child(creature)
	print("    Creature spawned")

func creature_died():
	creatureDeaths += 1
	if(creatureDeaths > 3): #end game with player win 
		print("Player Won")
		creatureDeaths = 0

func player_died():
	print("Creature Won")
