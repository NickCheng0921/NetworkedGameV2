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
	
	position += velocity * delta
	
	if not is_network_master():
		puppet_pos = position #reduces jitter if controlling player doesnt send inputs for a while
		look_dir = global_rotation