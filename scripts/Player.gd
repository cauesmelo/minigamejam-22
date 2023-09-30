extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -400.0
var jump_timer = 0.0
var coyote_timer = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func handle_ground(delta):	
	if jump_timer != -1:
		jump_timer = -1
		velocity.y = 0
		
	if Input.is_action_just_pressed("mv_up"):
		velocity.y = JUMP_VELOCITY / 4
		jump_timer = 0
		
	if Input.is_action_pressed("mv_left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("mv_right"):
		velocity.x = SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	
		
	if velocity.x > 0:
		$sprite.flip_h = false
	elif velocity.x < 0:
		$sprite.flip_h = true
		

func handle_air(delta):
	velocity.y += gravity * delta
	var is_fall = velocity.y > 0
	var is_limit_vel = velocity.y < JUMP_VELOCITY
	jump_timer += delta
	
	if velocity.x <= 0 && Input.is_action_pressed("mv_right"):
		velocity.x += (SPEED * 2) * delta
		$sprite.flip_h = false
		
	if velocity.x >= 0 && Input.is_action_pressed("mv_left"):
		velocity.x -= (SPEED * 2) * delta
		$sprite.flip_h = true
		
	if Input.is_action_pressed("mv_up") && jump_timer <= 0.1 && not is_fall && not is_limit_vel:
		velocity.y += (JUMP_VELOCITY * (delta * 8))
		
	if Input.is_action_pressed("mv_right"):
		$sprite.flip_h = false
		
	if Input.is_action_pressed("mv_left"):
		$sprite.flip_h = true


func _physics_process(delta):
	var ground = is_on_floor()
	
	if not ground:
		handle_air(delta)
	
	if ground:
		handle_ground(delta)
	
	#Sprite animations
	if velocity.y != 0:
		$sprite.play("jump")
	elif velocity.x != 0:
		$sprite.play("run")
	else:
		$sprite.play("idle")

	move_and_slide()
	
	## TODO
	# Coyote jump
	# Jump queue
