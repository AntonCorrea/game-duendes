extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animation_tree = get_node("AnimationTree")

var run_amount=0.0
var is_carrying = false
var going_backwards = false
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.set("parameters/BlendIdleRun/blend_amount",0)
	pass # Replace with function body.

func _process(delta):
	run_amount -= 3 * delta
	if run_amount < 0:
		run_amount = 0
		going_backwards = false
		
	if going_backwards:
		animation_tree.set("parameters/BlendBackwards/blend_amount",run_amount)
	else:
		if is_carrying:
			animation_tree.set("parameters/BlendCarryIdleRun/blend_amount",run_amount)
		else:
			animation_tree.set("parameters/BlendIdleRun/blend_amount",run_amount)


func run(delta):
	animation_tree.set("parameters/BlendBackwards/blend_amount",0)
	run_amount += 5 * delta
	if run_amount > 1:
		run_amount = 1
	pass

func backwards(delta):
	going_backwards = true
	run_amount += 5 * delta
	if run_amount > 1:
		run_amount = 1
	pass


func jump():
	if animation_tree.get("parameters/OneShotJump/active"):
		print("rejump not working")
	else:
		animation_tree.set("parameters/OneShotJump/active",true)
		animation_tree.set("parameters/OneShotFall/active",true)
		animation_tree.set("parameters/OneShotLand/active",true)
		pass
		
func land():
	animation_tree.set("parameters/OneShotFall/active",false)

func carry(_value):
	if _value:
		is_carrying = true
		#animation_tree.set("parameters/OneShotThrow/active",true)
		throw()
		animation_tree.set("parameters/BlendCarry/blend_amount",1)
	else:
		is_carrying = false
		throw()
		animation_tree.set("parameters/BlendCarry/blend_amount",0)

func throw():
	animation_tree.set("parameters/OneShotThrow/active",true)

func hang(_value):
	animation_tree.set("parameters/OneShotHang/active",_value)
	
func climb():
	animation_tree.set("parameters/OneShotClimb/active",true)
