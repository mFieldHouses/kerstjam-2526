extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).trigger.connect(_trigger)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _trigger(x) -> void:
	DialogManager.initiate_remote_dialog("discover_elevator", "Henkie", load("res://icon.svg"))
	$"../large_doorway/StageLauncher/ActionPromptTrigger".enabled = true
