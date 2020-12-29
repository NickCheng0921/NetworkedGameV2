extends KinematicBody2D

const MOVE_SPEED = 450
var velocity = Vector2()
var isGreen = false
var hitCounter = 0
export var maxHealth = 8
var canShoot = true
export var shootCooldown = .3
var canMove = true
var isDead = false
var deadTimer = 0
export var bulletDamage = 1 #this is the damage we take on a hit

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
		if(hitCounter > 4):
			hitCounter = 0
			modulate = Color(0, 0, 0, 1)
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
		if Input.is_action_just_pressed("ui_shoot") and canShoot:
			rpc("playerShootSound")
			rpc_unreliable_id(1, "player_shoot")
			shoot_cooldown()
			canShoot = false
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

func shoot_cooldown():
	var shootCooldownTimer = Timer.new()
	shootCooldownTimer.autostart = true
	shootCooldownTimer.set_one_shot(true)
	shootCooldownTimer.wait_time = shootCooldown
	add_child(shootCooldownTimer)
	shootCooldownTimer.connect("timeout", self, "_shootCooldownTimeout")
	
func _shootCooldownTimeout():
	canShoot = true
	
remote func take_damage():
	if not isDead:
		isGreen = true
		modulate = Color(255,0,0)
		currHealth -= bulletDamage
		
		if(currHealth <= 0):
			rpc_id(1, "player_died")
			canShoot = false
			canMove = false
			isDead = true
			hide()

remote func player_respawn(respawn_pos):
	print("Player Respawned")
	currHealth = maxHealth
	position = respawn_pos
	canMove = true
	canShoot = true
	isDead = false
	show()

remotesync func playerShootSound():
	$AnimationPlayer.play("pistolBlast")

func _on_Area2D_area_entered(area):
	if area.is_in_group("Keys"):
		Gamestate.numkeys = Gamestate.numkeys + 1
		area.get_parent().queue_free()
		print(Gamestate.numkeys)
		get_node("/root/GameIntroLevel").rpc_id(1, "spawn_keys")
	if area.is_in_group("SPED"):
		print("Humans Win")
		Gamestate.numkeys = 0
		get_node("/root/Lobby").rpc_id(1,"remoteGameOver", "h")
