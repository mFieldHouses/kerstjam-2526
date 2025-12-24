extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).trigger.connect(_trigger)

func _trigger(x) -> void:
	DialogManager.initiate_remote_dialog("find_part_1", "Henkie", load("res://icon.svg"))
	queue_free()
