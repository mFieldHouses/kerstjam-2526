extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$restart.button_down.connect(SceneManager.restart_stage)
	$exit.button_down.connect(SceneManager.launch_menu.bind("start_menu"))
