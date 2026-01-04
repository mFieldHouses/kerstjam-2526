extends Node3D

var _first_round : bool = true
var _wave_idx : int = 0

var _floor_panels_left : Array[Node3D] = []

func _ready() -> void:
	SaveFileManager._unlocked_stages.confrontation = true
	DialogManager.dialog_queue.connect(dialog_queue)
	
	for _platform : MeshInstance3D in $"RD-1-DroppingPlatforms".get_children():
		_floor_panels_left.append(_platform)
	
	await $start_fight.body_entered
	
	await get_tree().create_timer(1.0).timeout
	
	DialogManager.initiate_dialog_with("confrontation1", $Nutcracker_Eindbaas/philip_head, "???", load("res://icon.svg"))
	
	await DialogManager.dialog_ended
	
	$"World/Base_MapLayout/RD-Lab".open_roof()
	$open_roof.play()
	
	while $Nutcracker_Eindbaas._health_left > 10:
		if _first_round:
			DialogManager.initiate_remote_dialog("fireballs", "Philip", null)
		await $Nutcracker_Eindbaas.shoot_up()
		
		await fireballs(2.5 + (_wave_idx * 1.5), 3.0)
		
		await get_tree().create_timer(2).timeout
		
		if _first_round:
			DialogManager.initiate_remote_dialog("lasers", "Philip", null)
		await $Nutcracker_Eindbaas.laser_shoot(_wave_idx)
		
		if _first_round:
			DialogManager.initiate_remote_dialog("timeout", "Philip", null)
			await DialogManager.dialog_ended
			DialogManager.initiate_remote_dialog("timeout_henkie", "Henkie", null)
		await $Nutcracker_Eindbaas.spawn_monsters_timeout()
		
		await get_tree().create_timer(1).timeout
		
		DialogManager.initiate_remote_dialog("back_from_timeout", "Philip", null)
		
		_wave_idx += 1
		
		_first_round = false
	
	DialogManager.initiate_remote_dialog("nutcracker_ascend", "Philip", null)
	await DialogManager.dialog_ended
	
	$Nutcracker_Eindbaas.ascend()
	

func _process(delta: float) -> void:
	$gui/Panel/MarginContainer/health_bar.size.x = ($gui/Panel/MarginContainer.size.x - 14) * ($Nutcracker_Eindbaas._health_left / 200.0)


func _floor_fall(count : int) -> void:
	for _idx in count:
		var _panel = _floor_panels_left.pick_random()
		var _tween : Tween = create_tween()
		_tween.set_trans(Tween.TRANS_QUINT)
		_tween.set_ease(Tween.EASE_IN)
		_tween.tween_property(_panel, "position:y", -10, 0.75)
		await _tween.finished
		_panel.visible = false
		_panel.reparent(self)
		_panel.queue_free()
	
	return


func _fall_single_panel(panel : Node3D, delay : float) -> void:
	
	_floor_panels_left.erase(panel)
	
	await get_tree().create_timer(delay).timeout
	
	var _tween : Tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUINT)
	_tween.set_ease(Tween.EASE_IN)
	
	if !panel:
		return
	
	_tween.tween_property(panel, "position:y", -10, 0.75)
	await _tween.finished
	
	if !panel:
		return
	
	panel.visible = false
	panel.reparent(self)
	panel.queue_free()

func fireballs(frequency : float, time : float) -> void:
	for _idx in int(frequency * time):
		var _new_fireball = preload("res://scenes/fireball.tscn").instantiate()
		add_child(_new_fireball)
		var _panel = _floor_panels_left.pick_random()
		var _pos : Vector3 = _panel.global_position
		_new_fireball.position = Vector3(_pos.x, 1.8, _pos.z)
		
		await get_tree().create_timer(1.0 / frequency).timeout
		
		_fall_single_panel(_panel, 3.0)
	
	await get_tree().create_timer(4.0)
	return

func get_closest_floor_panel_distance() -> float:
	var _closest_distance : float = 1000.0
	
	for _panel in $floor_panels.get_children():
		var _dist : float = PlayerState.get_distance_to_player(_panel.global_position)
		if _dist < _closest_distance and _panel != PlayerState.player_instance.get_node("floor_ray").get_collider():
			_closest_distance = _dist
	
	return _closest_distance


func dialog_queue(did : String, qid : String) -> void:
	if did == "nutcracker_ascend" and qid == "end":
		GlobalGameFlags.add_flag("game_completed")
		
		await get_tree().create_timer(2.0).timeout
		
		SceneManager.launch_stage("SantaShop_Niels")


func _on_fall_area_body_entered(body: Node3D) -> void:
	PlayerState.player_instance._die()
