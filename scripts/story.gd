extends Node2D
var timer = 2
var index = 0
var debug = false

@onready var world = get_tree().get_root().get_child(1)

func _process(delta):
	if debug:
		world.game_on()
		return
		
	timer += delta
	
	if timer > 5:
		world.game_on()
	
	if index > 3:
		return
		
	if timer > 2:
		index += 1
		get_child(index).visible = true
		timer = 0
		
