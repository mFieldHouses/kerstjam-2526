extends Node

##Autoload that manages loading menus and levels.

func launch_stage(stage_id : String) -> void: ##Launches the stage with name [param level_id] in [param res://scenes/stages/], replacing the whole scene tree.
	get_tree().change_scene_to_file(DefaultPaths.stage_scenes_path + stage_id + ".tscn")

func launch_menu(menu_id : String) -> void: ##Launches the menu with name [param menu_id] in [param res://scenes/menus/], replacing the whole scene tree.
	get_tree().change_scene_to_file(DefaultPaths.menu_scenes_path + menu_id + ".tscn")

func launch_overlay_menu(menu_id : String) -> void: ##Launches the scene with name [param menu_id] in [param res://scenes/overlay_menus/], overlaying it over the current scene, and destroying it when the menu is exited.
	pass
