extends Control


func _ready() -> void:
	$CenterContainer/MarginContainer/VBoxContainer/settings.button_down.connect($settings.open_settings_page)
	$CenterContainer/MarginContainer/VBoxContainer/continue.button_down.connect(PlayerUIState.toggle_pause_menu.unbind(0))
