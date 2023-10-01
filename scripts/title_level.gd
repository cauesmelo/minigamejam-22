extends RichTextLabel

var skip = false
var wait = 2.0


func _process(delta):
	if wait > 0:
		wait -= delta
		return
		
	if skip:
		return
	
	var old_color = self.get_theme_color("default_color")
	
	if old_color.a == 0:
		return

	var new_val = old_color.a - (delta)

	if new_val < 0:
		old_color.a = 0
		self.add_theme_color_override("default_color", old_color)
		skip = true
	else:
		old_color.a = new_val
		self.add_theme_color_override("default_color", old_color)
