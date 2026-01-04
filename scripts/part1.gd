extends Node3D

var found : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("AreaTrigger").toggle.connect(_trigger)

func _trigger(x,y) -> void:
	if found:
		return
	DialogManager.initiate_remote_dialog("find_part_1", "Henkie", load("res://icon.svg"))
	found = true
	visible = false
