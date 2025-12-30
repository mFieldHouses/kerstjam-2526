extends Node

##Autoload that manages dialog

signal dialog_started(dialog_id : String)
signal dialog_queue(dialog_id : String, queue_id : String)
signal dialog_ended(dialog_id : String)

func initiate_remote_dialog(dialog_file_name : String, conversor_name : String, thumbnail : Texture2D, freeze : bool = false) -> void:
	var _dialog_file_path : String = _get_dialog_file_path(dialog_file_name)
	if !FileAccess.file_exists(_dialog_file_path):
		GameLogger.printerr_as_autoload(self, "Dialog file at " + _dialog_file_path + " does not exist, cannot initiate dialog. Aborting.")
		return
	else:
		GameLogger.print_as_autoload(self, "Initiating dialog from dialog file at " + _dialog_file_path)
	
	if freeze:
		PlayerState.toggle_sleep(true)
	
	dialog_started.emit(dialog_file_name)
	
	var _file = FileAccess.open(_dialog_file_path, FileAccess.READ)
	var _text = _file.get_as_text()

	var _lines = _text.split("\n", false)
	
	var _idx : int = 0
	for _line in _lines:
		if _line.begins_with("*"):
			dialog_queue.emit(dialog_file_name, _line.lstrip("* "))
			continue
		elif _line.begins_with("\\"):
			_line = _line.lstrip("\\")
			
		#if _line.begins_with(">"):
			#_line = tr(_line.lstrip("> "))
		#
		if _idx == 0:
			_line += ("[br][color=#FFFFFFB0]" + tr("DIALOG_CONTINUE") + "[/color]")
			_line %= Utility.get_action_key("dialog_continue")
		elif _idx == _lines.size() - 2:
			_line += ("[br][color=#FFFFFFB0]" + tr("DIALOG_END") + "[/color]")
		
		PersistentUI.remote_dialog_line(_line, conversor_name, thumbnail)
		
		await PersistentControls.continue_dialog
		_idx += 1
	
	PersistentUI.remote_dialog_line("", conversor_name, thumbnail) #hide again
	dialog_ended.emit(dialog_file_name)
	if freeze:
		PlayerState.toggle_sleep(false)
	
func initiate_dialog_with(dialog_file_name : String, with : Node3D, conversor_name : String, thumbnail : Texture2D) -> void:
	var _dialog_file_path : String = _get_dialog_file_path(dialog_file_name)
	dialog_started.emit(_dialog_file_path.get_file().get_basename())
	PlayerState.toggle_sleep(true)
	PlayerState.player_instance.tween_camera_fov(40, 0.5)
	PlayerUIState.set_ui_visibility(false)
	if !FileAccess.file_exists(_dialog_file_path):
		GameLogger.printerr_as_autoload(self, "Dialog file at " + _dialog_file_path + " does not exist, cannot initiate dialog. Aborting.")
		return
	else:
		GameLogger.print_as_autoload(self, "Initiating dialog from dialog file at " + _dialog_file_path)
	
	var _previous_camera_transform : Transform3D = PlayerState.player_instance.camera.global_transform
	var _target_camera_transform : Transform3D = _previous_camera_transform.looking_at(with.global_position)
	
	#PlayerState.player_instance.camera.top_level = true
	var _transform_in_tween : Tween = create_tween()
	_transform_in_tween.tween_property(PlayerState.player_instance.camera, "global_transform", _target_camera_transform, 0.5)
	await _transform_in_tween.finished
	
	#PlayerState.player_instance.camera.global_transform = _target_camera_transform
	
	var _file = FileAccess.open(_dialog_file_path, FileAccess.READ)
	var _text = _file.get_as_text()
		
	var _lines = _text.split("\n", false)
	
	var _idx : int = 0
	for _line in _lines:
		if _line.begins_with("*"):
			dialog_queue.emit(dialog_file_name, _line.lstrip("* "))
			continue
		elif _line.begins_with("\\"):
			_line = _line.lstrip("\\")
		elif _line.begins_with("set_name"):
			conversor_name = _line.split(" ")[1]
			continue
		elif _line.begins_with("set_thumbnail"):
			thumbnail = load(_line.split(" ")[1])
			continue
		
		#if _line.begins_with(">"):
			#_line = tr(_line.lstrip("> "))
		#
		if _idx == 0:
			_line += ("[br][color=#FFFFFFA0]" + tr("DIALOG_CONTINUE") + "[/color]")
			_line %= Utility.get_action_key("dialog_continue")
		elif _idx == _lines.size() - 2:
			print("last dialog line")
			_line += ("[br][color=#FFFFFFA0]" + tr("DIALOG_END") + "[/color]")
		
		PersistentUI.dialog_line(_line, conversor_name, thumbnail)
		
		await PersistentControls.continue_dialog
		_idx += 1
	
	PersistentUI.dialog_line("", conversor_name, thumbnail) #hide again
	PlayerState.toggle_sleep(false)
	PlayerState.player_instance.tween_camera_fov(PlayerState.player_instance.DEFAULT_FOV, 0.5)
	PlayerUIState.set_ui_visibility(true)
	
	var _transform_out_tween : Tween = create_tween()
	_transform_out_tween.tween_property(PlayerState.player_instance.camera, "global_transform", _previous_camera_transform, 0.5)
	await _transform_out_tween.finished
	
	dialog_ended.emit(dialog_file_name)

func _get_dialog_file_path(file_name : String) -> String:
	return DefaultPaths.dialog_files_path + ProjectSettings.get_setting("internationalization/locale/test").split("_")[0] + "/" + file_name + ".txt"
