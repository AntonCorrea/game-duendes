extends Spatial
#extends Camera


export var interpolation_delta = 2.5

onready var camera_pivot = $Camera
 
export(NodePath) var player_path
onready var player = get_node(player_path)

var target

var cam_init_pos : Vector3



# Called when the node enters the scene tree for the first time.
func _ready():
	cam_init_pos = $Camera.transform.origin
	target = player
	pass

func _physics_process(delta):
	global_transform = global_transform.interpolate_with(target.global_transform,(interpolation_delta * delta ))


func _on_Area_body_entered(body):
	if body.is_in_group("scenario"):
		set_cam_mode("FPS")
		pass
	pass # Replace with function body.


func _on_Area_body_exited(body):
	if body.is_in_group("scenario"):
		set_cam_mode("TPS")

func set_cam_mode(mode:String):
	if mode=="FPS":
		$Camera.transform.origin = Vector3(0,6,1)
		interpolation_delta = 10
	if mode=="TPS":
		$Camera.transform.origin = Vector3(0,6,10)
		interpolation_delta = 2.5
	pass
