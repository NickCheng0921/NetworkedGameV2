extends KinematicBody2D

const MOVE_SPEED = 550
var velocity = Vector2()
onready var attackRayCast = $attackRayCast
var attackCollision
var sender_id = 0
export var maxHealth = 2
var creatureDeaths = 0
export var numSpawns = 5

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()
puppet var look_dir = 0
puppet var currHealth = maxHealth
puppet var arrowDirection = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_rotation = look_dir
	
	
func _physics_process(delta):
	position = puppet_pos
	velocity = puppet_vel
	move_and_slide(velocity)

remote func creature_swipe():
	sender_id = get_tree().get_rpc_sender_id()
	if attackRayCast.is_colliding() != false:
		attackCollision = attackRayCast.get_collider()
		if attackCollision.is_in_group("playerDamageable"):
			print("C", sender_id, " hit ", attackCollision.get_name())
			attackCollision.rpc("take_damage")

remote func creature_died():
	var respawnTimer = Timer.new()
	respawnTimer.autostart = true
	respawnTimer.set_one_shot(true)
	respawnTimer.wait_time = 1.5
	add_child(respawnTimer)
	respawnTimer.connect("timeout", self, "_respawnTimeout")

func _respawnTimeout():
	print("Respawn Creature")
	var respawn_pos = get_node("/root/GameIntroLevel/creatureRespawns/pos" + str((randi() % numSpawns) + 1)).position
	currHealth = maxHealth
	rpc("creature_respawn", respawn_pos)

remotesync func creatureSwipeSound():
	pass #we don't need server to play a sound on creature swipe
