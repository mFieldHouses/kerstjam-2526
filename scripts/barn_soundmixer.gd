extends Area3D

var _inside : bool = false:
	set(x):
		_inside = x
		
		var _wind_tween :Tween = create_tween()
		var _inside_tween : Tween = create_tween()
		
		if _inside:
			_wind_tween.tween_property(%wind, "volume_linear", 0.0, 3.0)
			_inside_tween.tween_property(get_parent(), "volume_linear", 1.0, 3.0)
		else:
			_wind_tween.tween_property(%wind, "volume_linear", 1.0, 3.0)
			_inside_tween.tween_property(get_parent(), "volume_linear", 0.0, 3.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_overlapping_bodies().size() > 0 and _inside == false:
		_inside = true
	elif get_overlapping_bodies().size() == 0 and _inside == true:
		_inside = false
