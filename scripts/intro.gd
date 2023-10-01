extends Node2D

@onready var world = get_tree().get_root().get_child(1)

func _input(event):
	if event is InputEventKey and event.pressed:
		world.start()
