extends Module
class_name DialogueInitiator

@export_enum("With parent", "Remote") var dialog_mode : int = 0

@export var name_in_dialog : String = "" ##Gets translated if a translation exists for it
@export var thumbnail : Texture2D
@export_file("*.txt") var dialog_file_name = ""

func _ready() -> void:
	setup_triggers(_trigger_dialog)

func _trigger_dialog(x) -> void:
	if dialog_mode == 0:
		DialogManager.initiate_dialog_with(dialog_file_name, self, tr(name_in_dialog), thumbnail)
	elif dialog_mode == 1:
		DialogManager.initiate_remote_dialog(dialog_file_name, tr(name_in_dialog), thumbnail)
