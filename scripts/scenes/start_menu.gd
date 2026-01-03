extends Control


func _on_play_button_down() -> void:
	SceneManager.launch_stage("confrontation")


func _on_exit_button_down() -> void:
	SaveFileManager.save_game()
	
	#await SaveFileManager.done_saving
	
	get_tree().quit()
