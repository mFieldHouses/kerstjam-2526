extends Node3D

var _first_round : bool = true
var _wave_idx : int = 0

func _ready() -> void:
	
	SaveFileManager._unlocked_stages.confrontation = true
	
	for x in 10:
		for y in 10:
			var _new_colshape = $floor_panels/floor.duplicate()
			$floor_panels.add_child(_new_colshape)
			_new_colshape.position = Vector3(x * 2 - 9, 0.0, y * 2 - 9)
	
	await get_tree().create_timer(1.0).timeout
	
	DialogManager.initiate_dialog_with("confrontation1", $Nutcracker_Eindbaas/philip_head, "???", load("res://icon.svg"))
	
	await DialogManager.dialog_ended
	
	$floor_panels/floor.queue_free()
	
	for i in 1:
		
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
		await $Nutcracker_Eindbaas.spawn_monsters_timeout()
		
		await get_tree().create_timer(1).timeout
		
		DialogManager.initiate_remote_dialog("back_from_timeout", "Philip", null)
		
		_wave_idx += 1
		
		_first_round = false
	
	$Nutcracker_Eindbaas.ascend()
		
func _floor_fall(count : int) -> void:
	for _idx in count:
		if get_closest_floor_panel_distance() > 3.0 and $player.is_on_floor():
			print("on island")
			return
		
		var _panel = $floor_panels.get_children().pick_random()
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
	
	await get_tree().create_timer(delay).timeout
	
	var _tween : Tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUINT)
	_tween.set_ease(Tween.EASE_IN)
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
		var _panel = $floor_panels.get_children().pick_random()
		var _pos : Vector3 = _panel.global_position
		_new_fireball.position = Vector3(_pos.x, 0.126, _pos.z)
		
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
