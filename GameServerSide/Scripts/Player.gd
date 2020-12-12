extends KinematicBody2D

const MOVE_SPEED = 450
var velocity = Vector2()
onready var shootRayCast = $shootRayCast
var shootCollision
var sender_id = 0
var maxHealth = 8

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()
puppet var look_dir = 0
puppet var currHealth = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	#no network master check because server owns no players
	position = puppet_pos
	velocity = puppet_vel
	global_rotation = look_dir
	
	var collision = move_and_collide(velocity*delta)
	
	puppet_pos = position #reduces jitter if controlling player doesnt send inputs for a while
	look_dir = global_rotation

remote func player_shoot():
	sender_id = get_tree().get_rpc_sender_id()  
	if shootRayCast.is_colliding() != false:
		shootCollision = shootRayCast.get_collider()
		print("P", sender_id, " hit ", shootCollision.get_name())
		shootCollision.rpc("take_damage")
		
remote func player_died():
	print("------------------\nCreature Won\n------------------")
	var respawnTimer = Timer.new()
	respawnTimer.autostart = true
	respawnTimer.set_one_shot(true)
	respawnTimer.wait_time = 10
	add_child(respawnTimer)
	respawnTimer.connect("timeout", self, "_respawnTimeout")

func _respawnTimeout():
	print("Respawn Player")
	var respawn_pos = Vector2()
	respawn_pos.x = 500
	respawn_pos.y = 300
	currHealth = maxHealth
	rpc("player_respawn", respawn_pos)
