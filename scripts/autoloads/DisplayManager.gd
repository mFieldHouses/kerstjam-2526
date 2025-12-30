extends Node

func set_fullscreen(state : bool = true) -> void:
	if state:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func toggle_fullscreen() -> void:
	set_fullscreen(!DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN)

func set_mouse_captured(state : bool = true) -> void:
	if state:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	else:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
