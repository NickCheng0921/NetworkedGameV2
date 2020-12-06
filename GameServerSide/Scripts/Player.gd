extends KinematicBody2D

const MOVE_SPEED = 300
var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()
puppet var look_dir = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#no network master check because server owns no players
	position = puppet_pos
	velocity = puppet_vel
	global_rotation = look_dir
	
	position += velocity * delta
	
	puppet_pos = position #reduces jitter if controlling player doesnt send inputs for a while
	look_dir = global_rotation
