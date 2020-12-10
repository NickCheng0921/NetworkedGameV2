extends KinematicBody2D

const MOVE_SPEED = 300
var velocity = Vector2()
onready var shootRayCast = $shootRayCast
var shootCollision
var sender_id = 0

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
	
	#position += velocity * delta
	var collision = move_and_collide(velocity*delta)
	if collision:
		print("HIT")
	
	puppet_pos = position #reduces jitter if controlling player doesnt send inputs for a while
	look_dir = global_rotation

remote func player_shoot():
	sender_id = get_tree().get_rpc_sender_id()  
	if shootRayCast.is_colliding() != false:
		shootCollision = shootRayCast.get_collider()
		print("P", sender_id, " hit ", shootCollision.get_name())
		shootCollision.rpc("take_damage")
