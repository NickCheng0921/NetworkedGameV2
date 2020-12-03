extends Node2D

var Player = load("res://Scenes/Player.tscn")

func spawn_player(spawn_pos, id):
	var player = Player.instance()
	player.position = spawn_pos
	player.name = String(id)
	player.set_network_master(id)
	get_node("/root/GameIntroLevel").add_child(player)
	print("    Player spawned")
