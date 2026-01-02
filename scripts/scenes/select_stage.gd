extends Control



func _on_tutorial_button_down() -> void:
	SceneManager.launch_stage("SantaShop_Niels")


func _on_back_button_down() -> void:
	SceneManager.launch_menu("start_menu")
