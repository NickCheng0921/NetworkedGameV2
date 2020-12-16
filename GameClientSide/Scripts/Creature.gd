extends KinematicBody2D

const MOVE_SPEED = 550
var velocity = Vector2()
var isGreen = false
var hitCounter = 0
export var maxHealth = 2
var canShoot = true
var canMove = true
var isDead = false
var deadTimer = 0
export var meleeDamage = 1 #this is the damage we take on a hit

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()
puppet var look_dir = 0
puppet var currHealth = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isGreen):
		hitCounter += 1
		if(hitCounter > 10):
			hitCounter = 0
			modulate = Color(255, 0, 0)
			isGreen = false
	#only move if we're the master of this player
	if is_network_master():
		var move_direction = Vector2()
		var look_vec = get_global_mouse_position() - global_position
		#movement
		if Input.is_action_pressed("ui_up"):
			move_direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			move_direction.y += 1
		if Input.is_action_pressed("ui_left"):
			move_direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			move_direction.x += 1
		if Input.is_action_just_pressed("ui_shoot"):
			rpc_unreliable_id(1, "creature_swipe")
		if(canMove):
			velocity = move_direction.normalized()*MOVE_SPEED
		else:
			velocity.x = 0
			velocity.y = 0
		
		#aim at mouse
		look_dir = atan2(look_vec.y, look_vec.x)
		global_rotation = look_dir
		
		rset_unreliable("puppet_pos", position)
		rset_unreliable("puppet_vel", velocity)
		rset_unreliable("look_dir", look_dir)
		
	else: 
		position = puppet_pos
		velocity = puppet_vel
		global_rotation = look_dir
	
	move_and_collide(velocity*delta)
	
	if not is_network_master():
		puppet_pos = position #reduces jitter if controlling player doesnt send inputs for a while
		look_dir = global_rotation

remote func take_damage():
	if not isDead:
		isGreen = true
		modulate = Color(0,255,0)
		currHealth -= meleeDamage
		
		if(currHealth <= 0):
			rpc_id(1, "creature_died")
			canShoot = false
			canMove = false
			isDead = true
			get_node("CollisionShape2D").disabled = true
			hide()

remote func creature_respawn(respawn_pos):
	print("Creature Respawned")
	currHealth = maxHealth
	position = respawn_pos
	canMove = true
	canShoot = true
	get_node("CollisionShape2D").disabled = false
	isDead = false
	show()
