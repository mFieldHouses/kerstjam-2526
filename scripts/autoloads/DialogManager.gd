extends Node

##Autoload that manages dialog

signal dialog_started(dialog_id : String)
signal dialog_queue(dialog_id : String, queue_id : String)
signal dialog_ended(dialog_id : String)

func initiate_remote_dialog(dialog_file_path : String, conversor_name : String, thumbnail : Texture2D) -> void:
	if !FileAccess.file_exists(dialog_file_path):
		GameLogger.printerr_as_autoload(self, "Dialog file at " + dialog_file_path + " does not exist, cannot initiate dialog. Aborting.")
		return
	else:
		GameLogger.print_as_autoload(self, "Initiating dialog from dialog file at " + dialog_file_path)
	
	var _dialog_id : String = dialog_file_path.get_file().get_basename()
	var _file = FileAccess.open(dialog_file_path, FileAccess.READ)
	var _text = _file.get_as_text()
	var _lines = _text.split("\n", false)
	
	for _line in _lines:
		if _line.begins_with("*"):
			dialog_queue.emit(_dialog_id, _line.lstrip("* "))
			continue
			
		if _line.begins_with(">"):
			_line = tr(_line.lstrip("> "))
		
		PersistentUI.remote_dialog_line(_line, conversor_name, thumbnail)
		
		await PersistentControls.continue_dialog
	
	PersistentUI.remote_dialog_line("", conversor_name, thumbnail) #hide again
	
func initiate_dialog_with(dialog_file_path : String, with : Node3D, conversor_name : String, thumbnail : Texture2D) -> void:
	dialog_started.emit(dialog_file_path.get_file().get_basename())
	PlayerState.toggle_sleep(true)
	PlayerState.player_instance.tween_camera_fov(40, 0.5)
	if !FileAccess.file_exists(dialog_file_path):
		GameLogger.printerr_as_autoload(self, "Dialog file at " + dialog_file_path + " does not exist, cannot initiate dialog. Aborting.")
		return
	else:
		GameLogger.print_as_autoload(self, "Initiating dialog from dialog file at " + dialog_file_path)
	
	var _dialog_id : String = dialog_file_path.get_file().get_basename()
	var _file = FileAccess.open(dialog_file_path, FileAccess.READ)
	var _text = _file.get_as_text()
	if _text.begins_with(">>"):
		_text = tr(_text.lstrip("> "))
	
	var _lines = _text.split("\n", false)
	
	for _line in _lines:
		if _line.begins_with("*"):
			dialog_queue.emit(_dialog_id, _line.lstrip("* "))
			continue
		
		if _line.begins_with(">"):
			_line = tr(_line.lstrip("> "))
		
		PersistentUI.dialog_line(_line, conversor_name, thumbnail)
		
		await PersistentControls.continue_dialog
	
	PersistentUI.dialog_line("", conversor_name, thumbnail) #hide again
	PlayerState.toggle_sleep(false)
	PlayerState.player_instance.tween_camera_fov(PlayerState.player_instance.DEFAULT_FOV, 0.5)
	
	dialog_ended.emit(dialog_file_path.get_file().get_basename())
