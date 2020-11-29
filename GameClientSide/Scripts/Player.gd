extends KinematicBody2D

const MOVE_SPEED = 300
var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#only move if we're the master of this player
	if is_network_master():
		var move_direction = Vector2()
		
		if Input.is_action_pressed("ui_up"):
			move_direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			move_direction.y += 1
		if Input.is_action_pressed("ui_left"):
			move_direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			move_direction.x += 1
		velocity = move_direction.normalized()*MOVE_SPEED
		
		rset_unreliable("puppet_pos", position)
		rset_unreliable("puppet_vel", velocity)
		
	else: 
		position = puppet_pos
		velocity = puppet_vel
	
	position += velocity * delta
	
	if not is_network_master():
		puppet_pos = position #reduces jitter if controlling player doesnt send inputs for a while