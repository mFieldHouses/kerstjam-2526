extends Control


func _on_play_button_down() -> void:
	SceneManager.launch_menu("select_stage")


func _on_exit_button_down() -> void:
	SaveFileManager.save_game()
	
	#await SaveFileManager.done_saving
	
	get_tree().quit()
