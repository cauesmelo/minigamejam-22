extends CharacterBody2D

@export var movement_data : EnemyMovementData
@onready var raycast = $raycast
@onready var raycast2 = $raycast2
@onready var txt = $text

var direction = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 50.0
var acceleration = 800.0
var moving_timer = 0.0

func _ready():
	$sprite.play("run")


func _physics_process(delta):
	moving_timer += delta
	
	
	if moving_timer > movement_data.flip_time:
		moving_timer = 0
		direction *= -1
		$sprite.flip_h = direction == 1
		raycast.target_position.x *= -1
		raycast2.target_position.x *= -1
	
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	
	velocity.y += gravity
	move_and_slide()
	check_collision()
	
	
func check_collision():
	if raycast.is_colliding():
		txt.text = raycast.get_collider().name
	elif raycast2.is_colliding():
		txt.text = raycast2.get_collider().name
	else:
		txt.text = "null"
