extends KinematicBody2D

const MOVE_SPEED = 450
var velocity = Vector2()
var isGreen = false
var hitCounter = 0
var maxHealth = 3
var canShoot = true
var isDead = false
var deadTimer = 0

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
		if(hitCounter > 5):
			hitCounter = 0
			modulate = Color(0, 0, 0, 1)
			isGreen = false
	if(isDead):
		deadTimer += 1
		if(deadTimer > 60):
			position.x = 500
			position.y = 300
			deadTimer = 0
			isDead = false
			currHealth = maxHealth
			show()
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
			rpc_id(1, "player_shoot")
		velocity = move_direction.normalized()*MOVE_SPEED
		
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
		modulate = Color(255,0,0)
		currHealth -= 1 #for now each shot will do 1 damage
		
		if(currHealth <= 0):
			canShoot = false
			isDead = true
			hide()
