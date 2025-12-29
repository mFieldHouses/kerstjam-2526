extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.dialog_queue.connect(_dialog_queue)
	
	await get_tree().create_timer(1.0).timeout
	
	DialogManager.initiate_dialog_with("enter_warehouse", $speaker, "Mysterieuze stem", load("res://addons/GodotDevTools/module.svg"))
	
	await DialogManager.dialog_ended
	
	await get_tree().create_timer(1.0).timeout
	DialogManager.initiate_remote_dialog("enter_warehouse2", "Henkie", load("res://addons/GodotDevTools/module.svg"), true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _dialog_queue(did : String, qid : String) -> void:
	if did == "enter_warehouse2":
		if qid == "power_outage":
			$global_light.visible = false
