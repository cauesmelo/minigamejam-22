extends Node2D

var curr
var debug = false
var debug_scene = load("res://scenes/level_blue.tscn")
var death_count = 0
@onready var canvas = $canvas
var start_time = 0


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
			
func start():
	if debug:
		curr = debug_scene
		add_child(curr.instantiate())
		get_node("intro").queue_free()
		return
		
	curr = load("res://scenes/level_green.tscn")
	add_child(curr.instantiate())
	get_node("intro").queue_free()
	
	start_time = Time.get_ticks_msec()
	$canvas.visible = true
	
func _process(_delta):
	var elapsed = Time.get_ticks_msec() - start_time
	var seconds = elapsed / 1000
	var minutes = seconds / 60
	var hours = minutes / 60
	
	if seconds < 10:
		seconds = str("0", seconds)
		
	if minutes < 10:
		minutes = str("0", minutes)
		
	if hours < 10:
		hours = str("0", hours)
	
	$canvas.get_node("timer").text = "{a}:{b}:{c}".format({"a": hours, "b": minutes, "c": seconds})
	


func reload():
	death_count += 1
	$canvas.get_node("deaths").text = "[right]{a}[/right]".format({"a": death_count})
	
	get_child(2).queue_free()
	add_child(curr.instantiate())
	$global_cam.enabled = false
