extends KinematicBody


signal show_ui_can_pick
# warning-ignore:unused_signal
signal show_ui_can_throw
signal show_ui_can_climb

signal animator_backwards
signal animator_is_running
signal animator_has_jumped
signal animator_carry
# warning-ignore:unused_signal
signal animator_throw
signal animator_hang
signal animator_climb
signal animator_land

signal activate_wall_cam

export var MOVE_SPEED = 10
export var ROT_SPEED = 2
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

var mov_vec = Vector3()

var y_velo = 0
var z_velo = 0
const Z_DOWN_FORCE = 1
const Z_MAX_FORCE = 0

var object_to_pick:RigidBody
var object_picked:RigidBody

var can_throw = false
var is_grabbing_ledge = false

var tween_climb_edge:Tween
var twee_climb_in_progress = false

var is_tank_controls = false
var tank_controls_dir = -1

func _ready():
	tween_climb_edge = Tween.new()
# warning-ignore:return_value_discarded
	tween_climb_edge.connect("tween_all_completed",self,"_edge_completed_climb")
	add_child(tween_climb_edge)
# warning-ignore:return_value_discarded
	connect("animator_has_jumped",get_node("duende3001"),"jump")
# warning-ignore:return_value_discarded
	connect("animator_is_running",get_node("duende3001"),"run")
# warning-ignore:return_value_discarded
	connect("animator_carry",get_node("duende3001"),"carry")
# warning-ignore:return_value_discarded
	connect("animator_throw",get_node("duende3001"),"throw")
# warning-ignore:return_value_discarded
	connect("animator_hang",get_node("duende3001"),"hang")
# warning-ignore:return_value_discarded
	connect("animator_climb",get_node("duende3001"),"climb")
# warning-ignore:return_value_discarded
	connect("animator_backwards",get_node("duende3001"),"backwards")
# warning-ignore:return_value_discarded
	connect("animator_land",get_node("duende3001"),"land")
	pass # Replace with function body.

func _process(delta):
	mov_vec = Vector3.ZERO
	if is_grabbing_ledge:
		if Input.is_action_just_pressed("pressed_w"):
			_edge_tween_climb()
		if Input.is_action_pressed("pressed_s"):
			emit_signal("animator_hang",false)
			is_grabbing_ledge = false
			emit_signal("show_ui_can_climb",false)
	else:
		if is_tank_controls:
			if Input.is_action_pressed("pressed_w"):
				if tank_controls_dir == -1:
					mov_vec.x += 1
				else:
					mov_vec.x -= 1
				pass
			if Input.is_action_pressed("pressed_s"):
				if tank_controls_dir == -1:
					mov_vec.x -= 1
				else:
					mov_vec.x += 1
				pass
			if Input.is_action_pressed("pressed_d"):
				mov_vec.z -= 1
				#tank_controls_dir = +1		
				if tank_controls_dir == -1:
					rotate_y(PI)
					tank_controls_dir = 1
				pass
			if Input.is_action_pressed("pressed_a"):
				mov_vec.z -= 1
				if tank_controls_dir == 1:
					rotate_y(PI)
					tank_controls_dir = -1
				#tank_controls_dir = -1
				pass
		else:
			if Input.is_action_pressed("pressed_w"):
				mov_vec.z -= 1
				emit_signal("animator_is_running",delta)
			if Input.is_action_pressed("pressed_s"):
				mov_vec.z += 1
				emit_signal("animator_backwards",delta)
			if Input.is_action_pressed("pressed_d"):
				rotate_y(-1 * delta * ROT_SPEED)
			if Input.is_action_pressed("pressed_a"):
				rotate_y(1 * delta * ROT_SPEED)
		if Input.is_action_just_pressed("use"):
			if(object_to_pick):
				emit_signal("animator_carry",true)
				if(can_throw):
					object_picked.drop()
				object_picked = object_to_pick
				object_to_pick.pick_up($"SpatialObjectsContainer")
			elif can_throw:
				emit_signal("animator_carry",false)
				object_picked.throw()


func _physics_process(_delta):
	
	mov_vec.normalized()
	mov_vec.z += z_velo
	mov_vec = mov_vec.rotated(Vector3(0, 1, 0), rotation.y)

	mov_vec *= MOVE_SPEED 
	mov_vec.y = y_velo
	
	if is_grabbing_ledge:
		mov_vec = Vector3.ZERO
	mov_vec = move_and_slide(mov_vec, Vector3(0, 1, 0))
	
	y_velo -= GRAVITY
	z_velo -= Z_DOWN_FORCE
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		_jump()
	if is_on_floor() and y_velo <= 0:
		y_velo = -0.1
		emit_signal("animator_land")
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
		
	if z_velo < 0:
		z_velo = 0
		
	if is_on_wall() and not(is_on_floor()) and Input.is_action_just_pressed("jump"):
		_wall_jump()

func _on_UseArea_area_entered(area):
	if area.is_in_group("use"):
		object_to_pick = area.get_parent()
		emit_signal("show_ui_can_pick",true)
	pass # Replace with function body.

func _on_UseArea_area_exited(area):
	if area.is_in_group("use"):
		if area.get_parent() == object_to_pick:
			object_to_pick = null	
			emit_signal("show_ui_can_pick",false)
	pass # Replace with function body.

func _on_GrabArea_area_entered(area):
	if area.is_in_group("grab"):
		if twee_climb_in_progress == false:
			emit_signal("animator_hang",true)
		is_grabbing_ledge = true
		emit_signal("show_ui_can_climb",true)
	pass # Replace with function body.

func _edge_tween_climb():
	emit_signal("animator_hang",false)
	if twee_climb_in_progress == false:
		emit_signal("animator_climb")
		twee_climb_in_progress = true
		# warning-ignore:return_value_discarded
		tween_climb_edge.interpolate_property(self,
		"translation",
		self.global_transform.origin,
		self.global_transform.origin + Vector3(0,3,-1).rotated(Vector3(0, 1, 0), rotation.y),
		1,
		1,
		1)
	# warning-ignore:return_value_discarded
		tween_climb_edge.start()

func _edge_completed_climb():
	emit_signal("show_ui_can_climb",false)
	is_grabbing_ledge = false
	twee_climb_in_progress = false

func _jump():
	emit_signal("animator_has_jumped")
	y_velo = JUMP_FORCE
	
func _wall_jump():
	emit_signal("animator_has_jumped")
	#rotate_y(PI)
	y_velo = JUMP_FORCE
	z_velo = Z_MAX_FORCE
	if !is_tank_controls:
		rotate_y(PI)
	else:
		rotate_y(PI)
		tank_controls_dir = -tank_controls_dir
func _on_PlayerArea_area_entered(area):
	if area.is_in_group("cam_wall"):
		emit_signal("activate_wall_cam",true,area)
#		yield(get_tree().create_timer(.5),"timeout")
#		is_tank_controls = true
#		rotation_degrees = Vector3(0,90,0)
#		tank_controls_dir = -1
	pass # Replace with function body.

func _on_PlayerArea_area_exited(area):
	if area.is_in_group("cam_wall"):
		emit_signal("activate_wall_cam",false,area)
#		yield(get_tree().create_timer(.5),"timeout")
#		is_tank_controls = false
#		rotation_degrees = Vector3(0,360,0)
	pass # Replace with function body.
	
