extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dead = false
var wait_death = 0.2
var wait_respawn = 1.5
var is_storming = false
var storm_from
var storm_to
var storm_timer = 0
var switch_cooldown = 0

@onready var world = get_tree().get_root().get_child(1)
@onready var global_cam = world.get_node("global_cam")
@onready var animated_sprite_2d = $sprite_white
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var sprites = [$sprite_white, $sprite_green, $sprite_blue]

var color = "white"

func _physics_process(delta):
	if switch_cooldown > 0:
		switch_cooldown -= delta
	
	if is_dead:
		handle_death(delta)
		return
		
	apply_gravity(delta)
	
	if not is_storming:
		handle_jump()
		
	var input_axis = Input.get_axis("mv_left", "mv_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	handle_switch_color()
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	
	if just_left_ledge:
		coyote_jump_timer.start()
	
	if not is_storming:	
		update_animations(input_axis)
	
	if position.y > 300:
		die()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_pressed("mv_up"):
			velocity.y = movement_data.jump_velocity
			coyote_jump_timer.stop()
	elif not is_on_floor():
		if Input.is_action_just_released("mv_up") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animations(input_axis):
	if input_axis != 0:
		
		for sprite in sprites:
			sprite.flip_h = (input_axis < 0)	
		
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func _on_hazard_detector_area_entered(_area):
	global_position = starting_position
	
func handle_death(delta):
	wait_death -= delta
	wait_respawn -= delta
	
	if wait_respawn < 0:
		respawn()
		return
	
	if wait_death < 0:
		velocity.y += gravity * movement_data.gravity_scale * delta
		velocity.x = 0
		move_and_slide()
	

func die():
	is_dead = true
	
	if is_storming:
		animated_sprite_2d.visible = false
		
		if storm_to == "green":
			animated_sprite_2d = $sprite_green
		
		if storm_to == "white":
			animated_sprite_2d = $sprite_white
		
		animated_sprite_2d.visible = true
		is_storming = false
		
	$collision.call_deferred("set_disabled", true)
	velocity.y = movement_data.jump_velocity
	animated_sprite_2d.stop()
	$cam.enabled = false
	global_cam.position = position
	global_cam.enabled = true


func respawn():
	var pos = get_parent().get_node("respawn").position
	position = pos
	is_dead = false
	$collision.disabled = false
	animated_sprite_2d.play("idle")
	$cam.enabled = true
	global_cam.enabled = false
	velocity.y = 0
	wait_respawn = 1.5
	wait_death = 0.2
	
func handle_switch_color():
	if switch_cooldown > 0:
		# TODO play error sound
		return
		
	if Input.is_action_just_pressed("mv_action"):
		if color == "white":
			switch_color("green")
		elif color == "green":
			switch_color("blue")
		elif color == "blue":
			switch_color("white")
	
		switch_cooldown = 5.0
			
	
func switch_color(color_to):
	is_storming = true
	storm_from = color
	storm_to = color_to
		
	animated_sprite_2d.play("storm_in")
	
	
func _on_sprite_animation_finished():
	if is_dead:
		return
		
	if is_storming:
		var curr = animated_sprite_2d.get_animation()
		
		if curr == "storm_in":
			animated_sprite_2d.play("storm")
			
		if curr == "storm":
			animated_sprite_2d.visible = false
			color = storm_to
				
			if storm_to == "green":
				animated_sprite_2d = $sprite_green
			
			if storm_to == "white":
				animated_sprite_2d = $sprite_white
				
			if storm_to == "blue":
				animated_sprite_2d = $sprite_blue
				
				
			animated_sprite_2d.visible = true
			animated_sprite_2d.play("storm_out")
				
		if curr == "storm_out":
			is_storming = false
			animated_sprite_2d.play("idle")
