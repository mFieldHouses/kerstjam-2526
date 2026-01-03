extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	PlayerState.player_set.connect(func (player_instance): player_fp_ui_root_instance = player_instance.get_node("gui"))
	player_persistent_ui_root_instance = get_node("/root/PersistentUI")
	
var player_fp_ui_root_instance : Control
var player_persistent_ui_root_instance : Control

signal fade_middle
signal fade_end

func set_prompt(key : String, prompt_prefix : String, prompt_subject : String, prompt_suffix : String, show : bool = true):
	if player_fp_ui_root_instance:
		player_fp_ui_root_instance.set_prompt(key, prompt_prefix, prompt_subject, prompt_suffix, show)

func hide_prompt():
	if player_fp_ui_root_instance:
		player_fp_ui_root_instance.hide_prompt()

func set_ui_visibility(state : bool) -> void:
	player_fp_ui_root_instance.visible = state 

func toggle_player_menu(state : bool = true):
	var player_menu_ui = player_fp_ui_root_instance.get_node("player_menu")
	player_menu_ui.toggle(state)

func toggle_pause_menu():
	var _state : bool = !player_fp_ui_root_instance.get_node("PauseMenu").visible
	get_tree().paused = _state
	player_fp_ui_root_instance.get_node("PauseMenu").visible = _state
	PlayerState.toggle_sleep(_state)
	DisplayManager.set_mouse_captured(!_state)

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
	fade_in_tween.tween_property(player_persistent_ui_root_instance.get_node("black"), "modulate:a", 1.0, time)
	await fade_in_tween.finished
	return 0

func _fade_out_black(time : float): 
	var fade_out_tween = create_tween()
	fade_out_tween.set_parallel(true)
	fade_out_tween.set_trans(Tween.TRANS_CUBIC)
	fade_out_tween.set_ease(Tween.EASE_IN)
	fade_out_tween.tween_property(player_persistent_ui_root_instance.get_node("black"), "modulate:a", 0.0, time)
	await fade_out_tween.finished
	return 0
