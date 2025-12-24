extends Module
class_name StageLauncher

@export var stage_id : String = ""

func _ready() -> void:
	setup_triggers(_trigger)
	get_child(0).toggle.connect(_trigger)

func _trigger(x, y) -> void:
	SceneManager.launch_stage(stage_id)
