extends Control

var direction: Vector2
var was_pressed
var pivot: Vector2

var label_press

func _ready():
	label_press = get_node("Node2D/Press")
	label_press.get_node("PressF").hide()
	label_press.get_node("PressF/ToPick").hide()
	label_press.get_node("PressF/ToThrow").hide()
	label_press.get_node("PressClimb").hide()
	
	
func _process(_delta):
#	if(manager.paused == true):
#		direction = Vector2.ZERO
#		set_joystic_pos()
#	else:
	if was_pressed:
		#yield(get_tree().create_timer(4.0), "timeout")
		direction = get_viewport().get_mouse_position() - pivot
		#set_joystic_pos()
		pass

	pass

func _on_Screen_mouse_exited(_event):
	was_pressed = false
	direction = Vector2.ZERO
	pivot = Vector2.ZERO

func set_joystic_pos():
	if get_parent().get_viewport().get_mouse_position().distance_to(pivot) > 256 * self.scale.x:
		var ui_dir = direction.normalized()*256
		$Dir.transform.origin = ui_dir
	else:
		$Dir.global_transform.origin = get_viewport().get_mouse_position()
	pass

func _on_UI_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			if !was_pressed:
				was_pressed = true
				pivot = get_viewport().get_mouse_position()
				#self.visible = true
				#self.global_transform.origin = pivot
			else:
				direction = get_viewport().get_mouse_position()
				direction -= pivot
		else:
			was_pressed = false
			direction = Vector2.ZERO
			pivot = Vector2.ZERO
			self.visible = false
	pass # Replace with function body.
	pass # Replace with function body.

func show_can_pick(value):
	if value:
		label_press.get_node("PressF").show()
		if(label_press.get_node("PressF/ToThrow")).is_visible():
			label_press.get_node("PressF/ToThrow").hide()
		label_press.show()
		label_press.get_node("PressF/ToPick").show()
	else:
		label_press.hide()
		label_press.get_node("PressF").hide()
		label_press.get_node("PressF/ToPick").hide()

func show_can_throw(value):
	if value:
		label_press.show()
		label_press.get_node("PressF").show()
		label_press.get_node("PressF/ToThrow").show()
	else:
		label_press.hide()
		label_press.get_node("PressF").hide()
		label_press.get_node("PressF/ToThrow").hide()
		
func show_can_climb(value):
	if value:
		label_press.show()
		label_press.get_node("PressClimb").show()
	else:
		label_press.hide()
		label_press.get_node("PressClimb").hide()
	pass

func _on_UI_resized():
	pass # Replace with function body.
