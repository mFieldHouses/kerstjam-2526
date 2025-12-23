extends Module
class_name DialogueInitiator

@export_file("*.txt") var dialog_file_path = ""

func _ready() -> void:
	setup_triggers(_trigger_dialog)

func _trigger_dialog(x) -> void:
	DialogManager.initiate_dialog_with(dialog_file_path, self, "Sentient Cube", load("res://addons/GodotDevTools/module.svg"))
	
