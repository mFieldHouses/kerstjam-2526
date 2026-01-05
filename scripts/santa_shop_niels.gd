extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.dialog_queue.connect(_dialog_queue)
	
	if GlobalGameFlags.has_flag("game_completed"):
		$Characters/player1.queue_free()
		$Characters/player2._ready()
		
		DialogManager.initiate_dialog_with("final", $Characters/NPC/Henkie2/Marker3D, "Henkie", null)
		
		DialogManager.dialog_queue.connect(_end_game)
	else:
		$Characters/player2.queue_free()
		$Characters/player1._ready()
		
		PlayerState.toggle_sleep(true)
		PlayerUIState.set_ui_visibility(false)
		
		$intro_cam_path/PathFollow3D/intro_cam_pivot/Camera3D.current = true
		
		var _cam_tween : Tween = create_tween()
		_cam_tween.tween_property($intro_cam_path/PathFollow3D, "progress_ratio", 1.0, 90.0)
		
		DialogManager.initiate_remote_dialog("intro", "", null, false)
		
		await DialogManager.dialog_ended
		
		PersistentUI.fade_black(1.0)
		
		await PersistentUI.fade_middle
		
		PlayerState.toggle_sleep(false)
		PlayerUIState.set_ui_visibility(true)
		$Characters/player1.camera.current = true

func _end_game(x,y) -> void:
	
	await get_tree().create_timer(1.0).timeout
	
	SceneManager.launch_menu("credits", true, 3.0)
	
	await get_tree().create_timer(2.0).timeout
	DialogManager.end_dialog()	

func _dialog_queue(did : String, qid : String) -> void:
	if did == "henkie1" and qid == "show_footsteps":
		$"World/Ground (level 1)/Footsteps (quest)".visible = true
