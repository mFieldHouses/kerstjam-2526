extends Module
class_name DialogueInitiator

@export var name_in_dialog : String = "" ##Gets translated if a translation exists for it
@export var thumbnail : Texture2D
@export_file("*.txt") var dialog_file_name = ""

func _ready() -> void:
	setup_triggers(_trigger_dialog)

func _trigger_dialog(x) -> void:
	DialogManager.initiate_dialog_with(dialog_file_name, self, tr(name_in_dialog), thumbnail)
	
