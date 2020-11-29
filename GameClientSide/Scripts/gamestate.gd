extends Node

var Player = load("res://Player.tscn")

puppet func spawn_player(spawn_pos, id):
	print("Spawning a player")
	var player = Player.instance()
	
	player.position = spawn_pos
	player.name = String(id) # Important
	player.set_network_master(id) # Important

