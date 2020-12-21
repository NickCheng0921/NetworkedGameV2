extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_replayButton_pressed():
	get_node("/root/Lobby").rpc_id(1, "replay_call")
	get_node("/root/victoryScreen").call_deferred('free')
