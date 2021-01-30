extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player
var ui

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	ui = get_parent().get_node("UI")
	player.connect("show_ui_can_pick",ui,"show_can_pick")
	player.connect("show_ui_can_throw",ui,"show_can_throw")
	player.connect("show_ui_can_climb",ui,"show_can_climb")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
