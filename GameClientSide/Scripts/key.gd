extends Sprite

func _process(delta):
	if Gamestate.numkeys == 1:
		queue_free()	
