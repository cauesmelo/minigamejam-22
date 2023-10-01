extends CharacterBody2D

@export var movement_data : EnemyMovementData
@onready var raycasts = [$raycast, $raycast2]
@onready var txt = $text
@onready var sprite = get_node(movement_data.color)

var direction = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 50.0
var acceleration = 800.0
var moving_timer = 0.0
var atk = false
var target

var opacity_mult = 1

func _ready():
	sprite.visible = true
	
	if movement_data.no_walking:
		sprite.play("idle")
		return
		
	sprite.play("run")
	

func _process(delta):
	var cone
	
	if $cone_right.visible:
		cone = $cone_right
	else:
		cone = $cone_left
		
	var new_val = cone.modulate.a + (delta * opacity_mult)
	
	if new_val > 1:
		cone.modulate.a = 1
		opacity_mult = -1
	elif new_val < 0:
		cone.modulate.a = 0
		opacity_mult = 1
	else:
		cone.modulate.a = new_val


func _physics_process(delta):
	if movement_data.no_walking:
		velocity.y += gravity
		move_and_slide()
		check_collision()
		
		if atk:
			handle_atk(delta)
			move_and_slide()
			
		return
		
	moving_timer += delta
	
	if atk:
		handle_atk(delta)
		return
	
	
	if moving_timer > movement_data.flip_time:
		moving_timer = 0
		direction *= -1
		sprite.flip_h = direction == 1
		for raycast in raycasts:
			raycast.target_position.x *= -1
			
		if direction == -1:
			$cone_right.visible = false
			$cone_left.visible = true
		else:
			$cone_left.visible = false
			$cone_right.visible = true
			
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	
	velocity.y += gravity
	move_and_slide()
	check_collision()
	
func handle_atk(delta):
	var t = delta * 8
	self.position = self.position.lerp(target, t)
	$cone_left.visible = false
	$cone_right.visible = false
	
	
func check_collision():
	for raycast in raycasts:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			
			if !(collider is CharacterBody2D):
				break
			
			if collider.name != "Player":
				break
				
			if collider.color == movement_data.color:
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
	sprite.play("attack")
