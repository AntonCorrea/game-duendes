extends Spatial
#extends Camera


export(float) var interpolation_delta

onready var camera_pivot = $Camera
 
export(NodePath) var target_path
onready var target = get_node(target_path)
 
var pers_and_orto_vector : Vector3




# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	global_transform = global_transform.interpolate_with(target.global_transform,(interpolation_delta * delta ))



