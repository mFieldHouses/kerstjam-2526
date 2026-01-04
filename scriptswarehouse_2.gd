extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveFileManager._unlocked_stages.warehouse_2 = true
	
	$Platform/platform.activate.connect(func(): $soundtrack/Trigger.trigger.emit())
	$Platform/platform.finished.connect($soundtrack.fade_out)

func _reactivate_power() -> void:
	GlobalGameFlags.add_flag("power_enabled")
	
	DialogManager.initiate_remote_dialog("reactivate_power", "Henkie", null, false)
	
	await DialogManager.dialog_ended
	
	SceneManager.launch_stage("warehouse/warehouse_1")
