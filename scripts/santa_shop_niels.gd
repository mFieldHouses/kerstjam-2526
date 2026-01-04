extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalGameFlags.has_flag("game_completed"):
		$Characters/player1.queue_free()
		$Characters/player2._ready()
		
		DialogManager.initiate_dialog_with("final", $Characters/NPC/Henkie2/Marker3D, "Henkie", null)
		
		DialogManager.dialog_queue.connect(_end_game)
	else:
		$Characters/player2.queue_free()
		$Characters/player1._ready()

func _end_game(x,y) -> void:
	
	await get_tree().create_timer(1.0).timeout
	
	SceneManager.launch_menu("credits", true, 3.0)
	
	await get_tree().create_timer(2.0).timeout
	DialogManager.end_dialog()	
