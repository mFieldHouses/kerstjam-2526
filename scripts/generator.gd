extends MeshInstance3D


func _ready() -> void:
	get_child(0).trigger.connect(_trigger)

func _trigger(x) -> void:
	GlobalGameFlags.add_flag("power_enabled")
	
	DialogManager.initiate_remote_dialog("reactivate_power", "Henkie", null)
	
	await DialogManager.dialog_ended
	
	SceneManager.launch_stage("warehouse/warehouse_1")
