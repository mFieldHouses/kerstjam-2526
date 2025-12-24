extends Node3D

var _player_trail_points : Array[PlayerTrailPoint] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_new_trail_point(Vector3.ZERO)
	
	await get_tree().create_timer(1.0).timeout
	
	DialogManager.initiate_remote_dialog("enter_yeti_hollow", "Henkie", load("res://addons/GodotDevTools/module.svg"))
	DialogManager.dialog_queue.connect(_queue)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _player_trail_points.size() == 0:
		_create_new_trail_point(PlayerState.player_instance.global_position)
	elif PlayerState.player_instance.global_position.distance_to(_player_trail_points.back().position) > 1.5:
		_create_new_trail_point(PlayerState.player_instance.global_position)
	
	var _distance_fac : float = 1.0 - PlayerState.player_instance.global_position.distance_to($part.global_position) / 100.0
	$Control/distance_indicator/MarginContainer/ColorRect.custom_minimum_size.x = ($Control/distance_indicator.size.x - 10) * _distance_fac

func _queue(did: String, qid: String) -> void:
	if did == "enter_yeti_hollow" and qid == "show_distance_indicator":
		$Control/distance_indicator.visible = true

func _create_new_trail_point(at_position : Vector3) -> void:
	#print("added new point")
	var _new_point : PlayerTrailPoint = preload("res://scenes/player_trail_point.tscn").instantiate()
	$player_trail_points.add_child(_new_point)
	_new_point.position = at_position
	_player_trail_points.append(_new_point)
	_new_point.wipe_out_from_point.connect(_wipe_trail_from_point.bind(_new_point))
	_new_point.wipe_out_this_point.connect(_wipe_out_point.bind(_new_point))

func _wipe_trail_from_point(point : PlayerTrailPoint) -> void:
	var _point_idx : int = _player_trail_points.find(point)
	for _idx in _point_idx + 1:
		_player_trail_points[0].queue_free()
		_player_trail_points.remove_at(0)

func _wipe_out_point(point : PlayerTrailPoint) -> void:
	_player_trail_points.erase(point)
	point.queue_free()

func get_random_patrol_waypoint() -> Marker3D:
	return $yeti_patrol_waypoints.get_child(randi_range(0, $yeti_patrol_waypoints.get_child_count() - 1))
