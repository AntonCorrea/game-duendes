extends KinematicBody


signal can_pick
signal can_throw

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
# Called when the node enters the scene tree for the first time.
func _ready():
	tween_climb_edge = Tween.new()
	tween_climb_edge.connect("tween_all_completed",self,"_edge_completed_climb")
	add_child(tween_climb_edge)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	mov_vec = Vector3.ZERO
	if !is_grabbing_ledge:
		if Input.is_action_pressed("move_forwards"):
			mov_vec.z -= 1
		if Input.is_action_pressed("move_backwards"):
			mov_vec.z += 1
		if Input.is_action_pressed("turn_right"):
			rotate_y(-1 * delta * ROT_SPEED)
		if Input.is_action_pressed("turn_left"):
			rotate_y(1 * delta * ROT_SPEED)
		if Input.is_action_just_pressed("use"):
			if(object_to_pick):
				if(can_throw):
					object_picked.drop()
				object_picked = object_to_pick
				object_to_pick.pick_up($"SpatialObjectsContainer")
			elif can_throw:
				object_picked.throw()
	else:
		if Input.is_action_just_pressed("move_forwards"):
			_edge_tween_climb()
		if Input.is_action_pressed("move_backwards"):
			is_grabbing_ledge = false

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
		y_velo = JUMP_FORCE
	if is_on_floor() and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
		
	if z_velo < 0:
		z_velo = 0
		
	if is_on_wall() and not(is_on_floor()) and Input.is_action_just_pressed("jump"):
		#rotate_y(30 * ROT_SPEED)
		#yield(get_tree().create_timer(0.1), "timeout")
		rotate_y(PI)
		y_velo = JUMP_FORCE
		z_velo = Z_MAX_FORCE


func _on_UseArea_area_entered(area):
	if area.is_in_group("use"):
		object_to_pick = area.get_parent()
		emit_signal("can_pick",true)
	pass # Replace with function body.

func _on_UseArea_area_exited(area):
	if area.is_in_group("use"):
		if area.get_parent() == object_to_pick:
			object_to_pick = null	
			emit_signal("can_pick",false)
	pass # Replace with function body.

func _on_GrabArea_area_entered(area):
	if area.is_in_group("grab"):
		is_grabbing_ledge = true
		#print("grab")
	pass # Replace with function body.

func _edge_tween_climb():
	print("tween climb")
	# warning-ignore:return_value_discarded
	tween_climb_edge.interpolate_property(self,
	"translation",
	self.global_transform.origin,
	self.global_transform.origin + Vector3(0,5,0),
	.5,
	1,
	1)
# warning-ignore:return_value_discarded
	tween_climb_edge.start()

func _edge_completed_climb():
	print("climb completed")
	is_grabbing_ledge = false
