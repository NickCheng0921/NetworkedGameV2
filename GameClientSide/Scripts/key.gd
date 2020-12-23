extends Sprite

func _process(delta):
	if Gamestate.numkeys >= 6:
		queue_free()
