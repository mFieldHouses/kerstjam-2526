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

signal fade_middle
signal fade_end

func fade_black(slope_time : float = 0.3, halt_time : float = 0.0, show_loading_icon : bool = false):
	PersistentUI.get_node("black/loading").visible = show_loading_icon
	await _fade_in_black(slope_time)
	
	fade_middle.emit()
	await get_tree().create_timer(halt_time).timeout
	
	await _fade_out_black(slope_time)
	fade_end.emit()

signal continue_fade
func fade_black_wait(slope_time : float = 0.3, show_loading_icon : bool = false):
	PersistentUI.get_node("black/loading").visible = show_loading_icon
	await _fade_in_black(slope_time)
	fade_middle.emit()
	
	await continue_fade
	
	await _fade_out_black(slope_time)
	fade_end.emit()
	
func _fade_in_black(time : float):
	var fade_in_tween = create_tween()
	fade_in_tween.set_trans(Tween.TRANS_CUBIC)
	fade_in_tween.set_ease(Tween.EASE_OUT)
	fade_in_tween.tween_property(get_node("black"), "modulate:a", 1.0, time)
	await fade_in_tween.finished
	return 0

func _fade_out_black(time : float): 
	var fade_out_tween = create_tween()
	fade_out_tween.set_parallel(true)
	fade_out_tween.set_trans(Tween.TRANS_CUBIC)
	fade_out_tween.set_ease(Tween.EASE_IN)
	fade_out_tween.tween_property(get_node("black"), "modulate:a", 0.0, time)
	await fade_out_tween.finished
	return 0
