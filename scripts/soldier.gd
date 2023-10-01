extends CharacterBody2D

@export var movement_data : EnemyMovementData
@onready var raycasts = [$raycast, $raycast2]
@onready var txt = $text

var direction = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 50.0
var acceleration = 800.0
var moving_timer = 0.0
var atk = false
var target

func _ready():
	$sprite.play("run")


func _physics_process(delta):
	moving_timer += delta
	
	if atk:
		handle_atk(delta)
		return
	
	
	if moving_timer > movement_data.flip_time:
		moving_timer = 0
		direction *= -1
		$sprite.flip_h = direction == 1
		for raycast in raycasts:
			raycast.target_position.x *= -1
			
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	
	velocity.y += gravity
	move_and_slide()
	check_collision()
	
func handle_atk(delta):
	var t = delta * 8
	self.position = self.position.lerp(target, t)
	
	
func check_collision():
	for raycast in raycasts:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			
			if collider.name != "Player":
				break
			
			txt.text = collider.name
			raycast.enabled = false
			kill(collider)
			return
			
	txt.text = "null"

func kill(node):
	node.die()
	target = node.position
	atk = true
	$sprite.play("attack")
