extends KinematicBody2D

const MOVE_SPEED = 550
var velocity = Vector2()
var isGreen = false
var hitCounter = 0
export var maxHealth = 2
var canShoot = true
export var swipeCooldown = 0.4
var canMove = true
var isDead = false
var deadTimer = 0
var humanPlayer
var playerPos = Vector2(0, 0)
var canTrack = false
export var meleeDamage = 1 #this is the damage we take on a hit

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()
puppet var look_dir = 0
puppet var currHealth = maxHealth
puppet var arrowDirection = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(0,0,0,1)
	#lock onto player 2s after game starts
	var seekTimer = Timer.new()
	seekTimer.autostart = true
	seekTimer.set_one_shot(true)
	seekTimer.wait_time = 2
	add_child(seekTimer)
	seekTimer.connect("timeout", self, "findPlayer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isGreen):
		hitCounter += 1
		if(hitCounter > 4):
			hitCounter = 0
			modulate = Color(0, 0, 0, 1)
			isGreen = false
	if(canTrack):
		playerPos = humanPlayer.position
	#only move if we're the master of this player
	if is_network_master():
		var look_vec = get_global_mouse_position() - global_position
		
		if Input.is_action_just_pressed("ui_shoot") and canShoot:
			#when creature shoots: play sound locally, ask server to check for collision
			#setup cool down timer, make swipe sprite on HUD "gray"
			creatureSwipeSound()
			rpc_unreliable_id(1, "creature_swipe")
			swipe_cooldown()
			canShoot = false
			if is_network_master():
				get_node("/root/GameIntroLevel/creatures/" + str(get_tree().get_network_unique_id()) + "/creatureHUD/swipeHUD").set_frame(1)
				
		#aim at mouse
		look_dir = atan2(look_vec.y, look_vec.x)
		global_rotation = look_dir
		
		rset_unreliable("look_dir", look_dir)
		
	arrowDirection = atan2(playerPos.x - global_position.x , global_position.y - playerPos.y)
	arrowDirection -= look_dir
	get_node("hintArrow").rotation = arrowDirection
	
	if not is_network_master():
		look_dir = global_rotation

func _physics_process(delta):
	var move_direction = Vector2()
	#movement
	if Input.is_action_pressed("ui_up"):
		move_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		move_direction.y += 1
	if Input.is_action_pressed("ui_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if(is_network_master()):
		if(canMove):
			velocity = move_direction.normalized()*MOVE_SPEED
		else:
			velocity.x = 0
			velocity.y = 0
		rset_unreliable("puppet_pos", position)
		rset_unreliable("puppet_vel", velocity)
	else: 
		position = puppet_pos
		velocity = puppet_vel
	move_and_slide(velocity)

func swipe_cooldown():
	var swipeCooldownTimer = Timer.new()
	swipeCooldownTimer.autostart = true
	swipeCooldownTimer.set_one_shot(true)
	swipeCooldownTimer.wait_time = swipeCooldown
	add_child(swipeCooldownTimer)
	swipeCooldownTimer.connect("timeout", self, "_swipeCooldownTimeout")
	
func _swipeCooldownTimeout():
	#turn swipe image back to "color"
	if is_network_master():
		get_node("/root/GameIntroLevel/creatures/" + str(get_tree().get_network_unique_id()) + "/creatureHUD/swipeHUD").set_frame(0)
	canShoot = true
	
func findPlayer():
	#gets the first human, will work fine for a 2 player game
	#uncomment both if running only a creature and no player
	canTrack = true
	humanPlayer = get_node("/root/GameIntroLevel/humans").get_children()[0]
	
remote func take_damage():
	if not isDead:
		isGreen = true
		modulate = Color(0,255,0)
		currHealth -= meleeDamage
		if is_network_master():
			get_node("/root/GameIntroLevel/creatures/" + str(get_tree().get_network_unique_id()) + "/creatureHUD/hpBar").set_frame(currHealth)
			
		if(currHealth <= 0):
			rpc_id(1, "creature_died")
			canShoot = false
			canMove = false
			isDead = true
			$hintArrow.hide()
			get_node("CollisionShape2D").disabled = true
			hide()

remote func creature_respawn(respawn_pos):
	#on Respawn: reset health, reset position, let creature move and shoot
	#enable creature hurtbox, display creature
	print("Creature Respawned")
	currHealth = maxHealth
	if is_network_master():
		get_node("/root/GameIntroLevel/creatures/" + str(get_tree().get_network_unique_id()) + "/creatureHUD/hpBar").set_frame(currHealth)
	position = respawn_pos
	canMove = true
	canShoot = true
	$hintArrow.show()
	get_node("CollisionShape2D").disabled = false
	isDead = false
	show()

remotesync func creatureSwipeSound():
	$AnimationPlayer.play("creatureSwipeAttack")
