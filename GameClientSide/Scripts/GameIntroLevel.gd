extends Node2D


# Declare member variables here. Examples:
var path
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = load("res://Scenes/key.tscn")
	var array = []
	for i in range(3):
		var num = (randi() % 5) + 1
		while num in array:
			num = (randi() % 5) + 1
		array.append(num)
<<<<<<< Updated upstream
		
=======

>>>>>>> Stashed changes
	print(array)
	for i in array:
		var key = scene.instance()
		var key_pos = get_node("/root/GameIntroLevel/keyPosition/keyPos" + str(i)).position
		print("key position is ")
		print(i)
		key.position = key_pos
		add_child(key)
