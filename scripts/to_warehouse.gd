extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	DialogManager.initiate_remote_dialog("exit_yeti_hollow", "Henkie", load("res://addons/GodotDevTools/module.svg"))
	
	$discover_warehouse/AreaTrigger.trigger.connect(func(x): $music.fade_out(6.0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
