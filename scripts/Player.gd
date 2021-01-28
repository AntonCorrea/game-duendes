extends KinematicBody

signal can_use

export var MOVE_SPEED = 10
export var ROT_SPEED = 2
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

var mov_vec = Vector3()
var y_velo =0

var object_to_use:RigidBody

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	mov_vec = Vector3() * 0
	if Input.is_action_pressed("move_forwards"):
		mov_vec.z -= 1
	if Input.is_action_pressed("move_backwards"):
		mov_vec.z += 1
	if Input.is_action_pressed("turn_right"):
		rotate_y(-1 * delta * ROT_SPEED)
	if Input.is_action_pressed("turn_left"):
		rotate_y(1 * delta * ROT_SPEED)
	if Input.is_action_just_pressed("use"):
		if(object_to_use):
			print("USE" + str(object_to_use))


func _physics_process(_delta):
	_movement_and_jump()

func _movement_and_jump():
	mov_vec.normalized()
	mov_vec = mov_vec.rotated(Vector3(0, 1, 0), rotation.y)
	#print("v2: "+str(mov_vec))
	mov_vec *= MOVE_SPEED 
	
	mov_vec.y = y_velo
	
	move_and_slide(mov_vec, Vector3(0, 1, 0))
	
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	
	if grounded and Input.is_action_just_pressed("jump"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED


func _on_UseArea_area_entered(area):
	if area.is_in_group("use"):
		object_to_use = area.get_parent()
		emit_signal("can_use",true)
	pass # Replace with function body.
func _on_UseArea_area_exited(area):
	if area.is_in_group("use"):
		if area.get_parent() == object_to_use:
			object_to_use = null	
			emit_signal("can_use",false)
	pass # Replace with function body.
