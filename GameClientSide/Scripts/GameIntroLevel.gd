extends Node2D


# Declare member variables here. Examples:
var path
onready var keyScene = load("res://Scenes/key.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

remote func client_spawn_key(key_pos):
	if Gamestate.isHuman: #for now, don't let creature see keys
		var key = keyScene.instance()
		key.position = key_pos
		add_child(key)
		print(get_tree().get_network_unique_id(), " made key")
