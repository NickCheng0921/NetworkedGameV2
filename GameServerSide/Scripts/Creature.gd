extends KinematicBody2D

const MOVE_SPEED = 550
var velocity = Vector2()
onready var attackRayCast = $attackRayCast
var attackCollision
var sender_id = 0
var maxHealth = 2
var creatureDeaths = 0

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()
puppet var look_dir = 0
puppet var currHealth = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#no network master check because server owns no players
	position = puppet_pos
	velocity = puppet_vel
	global_rotation = look_dir
	
	var collision = move_and_collide(velocity*delta)
	
	puppet_pos = position #reduces jitter if controlling player doesnt send inputs for a while
	look_dir = global_rotation

remote func creature_swipe():
	sender_id = get_tree().get_rpc_sender_id()
	if attackRayCast.is_colliding() != false:
		attackCollision = attackRayCast.get_collider()
		print("C", sender_id, " hit ", attackCollision.get_name())
		attackCollision.rpc("take_damage")

remote func creature_died():
	creatureDeaths += 1
	if(creatureDeaths > 2): #player wins on 3 creature kills
		print("------------------\nPlayer Won\n------------------")
		creatureDeaths = 0
	#create timer for respawn
	var respawnTimer = Timer.new()
	respawnTimer.autostart = true
	respawnTimer.set_one_shot(true)
	respawnTimer.wait_time = 1.5
	add_child(respawnTimer)
	respawnTimer.connect("timeout", self, "_respawnTimeout")

func _respawnTimeout():
	print("Respawn Creature")
	var respawn_pos = Vector2()
	respawn_pos.x = 1000
	respawn_pos.y = 1000
	currHealth = maxHealth
	rpc("creature_respawn", respawn_pos)
