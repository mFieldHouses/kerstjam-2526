extends Node3D


func _ready() -> void:
	#DialogManager.initiate_dialog_with("confrontation1", $philip, "???", load("res://icon.svg"))
	#pass
	for x in 10:
		for y in 10:
			var _new_colshape = $floor_panels/floor.duplicate()
			$floor_panels.add_child(_new_colshape)
			_new_colshape.position = Vector3(x * 2 - 9, 0.0, y * 2 - 9)
	
	$floor_panels/floor.queue_free()
	
	_floor_fall()

func _floor_fall() -> void:
	pass
	#for _idx in $floor_panels.get_child_count():
		#if get_closest_floor_panel_distance() > 3.0 and $player.is_on_floor():
			#print("on island")
			#return
		#
		#var _panel = $floor_panels.get_children().pick_random()
		#var _tween : Tween = create_tween()
		#_tween.set_trans(Tween.TRANS_QUINT)
		#_tween.set_ease(Tween.EASE_IN)
		#_tween.tween_property(_panel, "position:y", -10, 0.5)
		#await _tween.finished
		#_panel.visible = false
		#_panel.reparent(self)
		#_panel.queue_free()

func get_closest_floor_panel_distance() -> float:
	var _closest_distance : float = 1000.0
	
	for _panel in $floor_panels.get_children():
		var _dist : float = PlayerState.get_distance_to_player(_panel.global_position)
		if _dist < _closest_distance and _panel != PlayerState.player_instance.get_node("floor_ray").get_collider():
			_closest_distance = _dist
	
	return _closest_distance
