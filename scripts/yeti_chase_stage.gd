extends Node3D

var _player_trail_points : Array[PlayerTrailPoint] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_new_trail_point(Vector3.ZERO)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerState.player_instance.global_position.distance_to(_player_trail_points.back().position) > 1.5:
		_create_new_trail_point(PlayerState.player_instance.global_position)

func _create_new_trail_point(at_position : Vector3) -> void:
	print("added new point")
	var _new_point : PlayerTrailPoint = preload("res://scenes/player_trail_point.tscn").instantiate()
	$player_trail_points.add_child(_new_point)
	_new_point.position = at_position
	_player_trail_points.append(_new_point)
	_new_point.wipe_out_from_point.connect(_wipe_trail_from_point.bind(_new_point))
	_new_point.wipe_out_this_point.connect(_wipe_out_point.bind(_new_point))

func _wipe_trail_from_point(point : PlayerTrailPoint) -> void:
	var _point_idx : int = _player_trail_points.find(point)
	print("wiping trail from idx ", _point_idx)
	for _idx in _point_idx + 1:
		_player_trail_points[_idx].queue_free()
		_player_trail_points.remove_at(_idx)

func _wipe_out_point(point : PlayerTrailPoint) -> void:
	_player_trail_points.erase(point)
	point.queue_free()
