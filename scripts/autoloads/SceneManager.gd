extends Node

##Autoload that manages loading menus and levels.

#var _last_loaded_stage_id : String = ""

func launch_stage(stage_id : String) -> void: ##Launches the stage with name [param level_id] in [param res://scenes/stages/], replacing the whole scene tree.
	get_tree().paused = false
	#_last_loaded_stage_id = stage_id
	PersistentUI.fade_black_wait(0.5, true)
	PlayerState._save_health()
	PlayerState._save_ammo()
	await PersistentUI.fade_middle
	get_tree().change_scene_to_file(DefaultPaths.stage_scenes_path + stage_id + ".tscn")
	await get_tree().create_timer(0.1).timeout
	PersistentUI.continue_fade.emit()

func restart_stage() -> void:
	PersistentUI.fade_black_wait(0.5, true)
	await PersistentUI.fade_middle
	get_tree().reload_current_scene()
	get_tree().paused = false
	await get_tree().scene_changed
	PersistentUI.continue_fade.emit()
	
func launch_menu(menu_id : String) -> void: ##Launches the menu with name [param menu_id] in [param res://scenes/menus/], replacing the whole scene tree.
	get_tree().paused = false
	get_tree().change_scene_to_file(DefaultPaths.menu_scenes_path + menu_id + ".tscn")
	
func launch_overlay_menu(menu_id : String) -> void: ##Launches the scene with name [param menu_id] in [param res://scenes/overlay_menus/], overlaying it over the current scene, and destroying it when the menu is exited.
	pass
