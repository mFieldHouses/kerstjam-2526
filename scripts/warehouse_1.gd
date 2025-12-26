extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	DialogManager.initiate_dialog_with("enter_warehouse", $speaker, "Mysterieuze stem", load("res://addons/GodotDevTools/module.svg"))
	
	await DialogManager.dialog_ended
	
	await get_tree().create_timer(1.0).timeout
	DialogManager.initiate_remote_dialog("enter_warehouse2", "Henkie", load("res://addons/GodotDevTools/module.svg"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
