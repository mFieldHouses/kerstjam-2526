extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalGameFlags.has_flag("power_enabled"):
		$player.position = Vector3(0.0, 8.0, -62)
		$enemies.queue_free()
		return	
	
	SaveFileManager._unlocked_stages.warehouse_1 = true
	
	DialogManager.dialog_queue.connect(_dialog_queue)
	DialogManager.dialog_started.connect(_dialog_start)
	DialogManager.dialog_ended.connect(_dialog_end)
	
	await get_tree().create_timer(1.0).timeout
	
	DialogManager.initiate_dialog_with("enter_warehouse", $"Speaker-1", "Mysterieuze stem", load("res://addons/GodotDevTools/module.svg"))
	
	await DialogManager.dialog_ended
	
	await get_tree().create_timer(1.0).timeout
	DialogManager.initiate_remote_dialog("enter_warehouse2", "Henkie", load("res://addons/GodotDevTools/module.svg"), true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _dialog_queue(did : String, qid : String) -> void:
	if did == "enter_warehouse2":
		if qid == "power_outage":
			var _tween : Tween = create_tween()
			_tween.tween_property($global_light, "light_energy", 0.0018, 0.2)

func _dialog_start(did : String) -> void:
	if did == "enter_warehouse":
		var _tween : Tween = create_tween()
		_tween.tween_property($global_light, "light_energy", 0.05, 1)

func _dialog_end(did : String) -> void:
	if did == "enter_warehouse":
		var _tween : Tween = create_tween()
		_tween.tween_property($global_light, "light_energy", 0.11, 1)
