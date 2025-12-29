extends Control

var _timings : Dictionary = {
	"title": {
		"opacity": 1.0,
		"fade": 2.0,
		"wait": 2.0
	},
	"credits": {
		"opacity": 1.0,
		"fade": 2.0,
		"wait": 3.5
	},
	"thanks": {
		"opacity": 1.0,
		"fade": 1.0,
		"wait": 1.5
	},
	"exit": {
		"opacity": 0.3,
		"fade": 1.0,
		"wait": 0.0
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for _child in get_children():
		if _child is Label:
			_child.modulate.a = 0.0
	
	await get_tree().create_timer(1.0).timeout
	
	for _id : String in _timings:
		var _tween : Tween = create_tween()
		_tween.tween_property(get_node(_id), "modulate:a", _timings[_id].opacity, _timings[_id].fade)
		await _tween.finished
		await get_tree().create_timer(_timings[_id].wait).timeout

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		SceneManager.launch_menu("start_menu")
