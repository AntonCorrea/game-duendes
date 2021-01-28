extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tween_pick_object:Tween

export(int, 
"TRANS_LINEAR" 
,"TRANS_SINE"  
,"TRANS_QUINT"
,"TRANS_QUART"
,"TRANS_QUAD"
,"TRANS_EXPO"
,"TRANS_ELASTIC"
,"TRANS_CUBIC"
,"TRANS_CIRC"
,"TRANS_BOUNCE"
,"TRANS_BACK") var tween_type
export (int,
"EASE_IN",
"EASE_OUT",
"EASE_IN_OUT",
"EASE_OUT_IN") var easing_jump

var picked = false
var container:Spatial
var follow_container = false

var mov_vec :Vector3
# Called when the node enters the scene tree for the first time.
func _ready():
	tween_pick_object = Tween.new()
# warning-ignore:return_value_discarded
	tween_pick_object.connect("tween_all_completed",self,"set_follow")
	add_child(tween_pick_object)
	pass # Replace with function body.

func _process(_delta):
	mov_vec = Vector3.ZERO
	if follow_container:
		self.global_transform = container.global_transform

func pick_up(from:Spatial):
	container = from
	self.mode = MODE_KINEMATIC
# warning-ignore:return_value_discarded
	tween_pick_object.interpolate_property(self,"translation",self.global_transform.origin,container.global_transform.origin,
	.25,
	tween_type,
	easing_jump)
	
# warning-ignore:return_value_discarded
	tween_pick_object.start()
	
func set_follow():
	follow_container = true
	container.get_parent().can_throw = true
	container.get_parent().emit_signal("can_throw",true)

func throw():
	follow_container = false
	container.get_parent().can_throw = false
	container.get_parent().emit_signal("can_throw",false)
	self.mode = MODE_RIGID
	apply_impulse(Vector3(0, 0, 0), Vector3(0, 10, -10).rotated(Vector3(0, 1, 0), rotation.y))

func drop():
	follow_container = false
	container.get_parent().can_throw = false
	self.mode = MODE_RIGID
	apply_impulse(Vector3(0, 0, 0), Vector3(15, 0, 0).rotated(Vector3(0, 1, 0), rotation.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
