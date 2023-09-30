extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("mv_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("mv_left", "mv_right")
	if direction:
		velocity.x = direction * SPEED		
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if velocity.y != 0:
		$sprite.play("jump")
	elif velocity.x != 0:
		$sprite.play("run")
	else:
		$sprite.play("idle")
		
	if velocity.x > 0:
		$sprite.flip_h = false
	elif velocity.x < 0:
		$sprite.flip_h = true

	move_and_slide()
