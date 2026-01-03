extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveFileManager._unlocked_stages.warehouse_2 = true
	
	$Platform/platform.activate.connect(func(): $soundtrack/Trigger.trigger.emit())
	$Platform/platform.finished.connect($soundtrack.fade_out)
