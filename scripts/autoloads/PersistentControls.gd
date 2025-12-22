extends Node

var _bindings : Dictionary[String, Callable] ={
	"fullscreen_toggled": DisplayManager.toggle_fullscreen
}

func _process(delta: float) -> void:
	for _action_name : String in _bindings:
		if Input.is_action_just_pressed(_action_name):
			_bindings[_action_name].call()
