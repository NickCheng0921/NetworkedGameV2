extends Sprite

func _process(delta):
	if Gamestate.numkeys == 3:
		queue_free()
