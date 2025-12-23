extends Node

signal continue_dialog

var _bindings : Dictionary[String, Callable] ={
	"fullscreen_toggled": DisplayManager.toggle_fullscreen,
	"dialog_continue": _signal_continue_dialog
}

func _process(delta: float) -> void:
	for _action_name : String in _bindings:
		if Input.is_action_just_pressed(_action_name):
			_bindings[_action_name].call()

func _signal_continue_dialog() -> void:
	continue_dialog.emit()
	
