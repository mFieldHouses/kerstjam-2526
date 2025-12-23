extends Control

var _top_dialog_open : bool = false
var _bottom_dialog_open : bool = false

func dialog_line(line : String, conversor_name : String, thumbnail : Texture2D) -> void: ##Pass an empty line to hide the dialog box again.
	var _move_tween : Tween = create_tween()
	if !_bottom_dialog_open and line != "":
		_bottom_dialog_open = true
		_move_tween.tween_property($dialog, "position:y", get_viewport_rect().size.y - $dialog.size.y, 0.3)
		await _move_tween.finished
		
	elif _bottom_dialog_open and line =="":
		_bottom_dialog_open = false
		_move_tween.tween_property($dialog, "position:y", get_viewport_rect().size.y, 0.3)
		await _move_tween.finished
	
	$dialog/MarginContainer/HBoxContainer/VBoxContainer/contents.text = line
	$dialog/MarginContainer/HBoxContainer/VBoxContainer/name.text = conversor_name
	$dialog/MarginContainer/HBoxContainer/VBoxContainer/contents.visible_ratio = 0
	$dialog/MarginContainer/HBoxContainer/thumbnail.texture = thumbnail
	
	var _text_tween : Tween = create_tween()
	_text_tween.tween_property($dialog/MarginContainer/HBoxContainer/VBoxContainer/contents, "visible_ratio", 1.0, 0.01 * line.length())


func remote_dialog_line(line : String, conversor_name : String, thumbnail : Texture2D) -> void: ##Pass an empty line to hide the dialog box again.
	$remote_dialog/MarginContainer/HBoxContainer/VBoxContainer/contents.text = line
	$remote_dialog/MarginContainer/HBoxContainer/VBoxContainer/name.text = conversor_name
	$remote_dialog/MarginContainer/HBoxContainer/VBoxContainer/contents.visible_ratio = 0
	$remote_dialog/MarginContainer/HBoxContainer/thumbnail.texture = thumbnail
	
	var _move_tween : Tween = create_tween()
	if !_bottom_dialog_open and line != "":
		_bottom_dialog_open = true
		_move_tween.tween_property($remote_dialog, "position:y", 0.0, 0.3)
		await _move_tween.finished
	
	elif _bottom_dialog_open and line =="":
		_bottom_dialog_open = false
		_move_tween.tween_property($remote_dialog, "position:y", - $remote_dialog.size.y, 0.3)
		await _move_tween.finished
	
	var _text_tween : Tween = create_tween()
	_text_tween.tween_property($remote_dialog/MarginContainer/HBoxContainer/VBoxContainer/contents, "visible_ratio", 1.0, 0.01 * line.length())
