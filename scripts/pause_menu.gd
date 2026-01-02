extends Control


func _ready() -> void:
	$CenterContainer/MarginContainer/VBoxContainer/settings.button_down.connect($settings.open_settings_page)
	$CenterContainer/MarginContainer/VBoxContainer/continue.button_down.connect(PlayerUIState.toggle_pause_menu)
	$CenterContainer/MarginContainer/VBoxContainer/restart.button_down.connect(SceneManager.restart_stage)
	$CenterContainer/MarginContainer/VBoxContainer/exit.button_down.connect(SceneManager.launch_menu.bind("start_menu"))
