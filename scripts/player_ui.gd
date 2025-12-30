extends Control

func set_prompt(key : String, prefix : String = "", subject : String = "", suffix : String = "", show : bool = true):
	if key != "":
		$prompt_label.text = key + ") " + prefix + " [b]" + subject + "[/b] " + suffix
	
	if show:
		show_prompt()
	else:
		hide_prompt()

func show_prompt():
	var fade_tween = create_tween()
	Color(1,1,1,0)
	fade_tween.tween_property($prompt_label, "modulate", Color(1,1,1,1), 0.075)

func hide_prompt():
	var fade_tween = create_tween()
	Color(1,1,1,1)
	fade_tween.tween_property($prompt_label, "modulate", Color(1,1,1,0), 0.075)

func toggle_inventory(state : bool = true):
	$inventory.visible = state

func _die_prompt() -> void:
	$weapon_viewport.visible = false
	$you_died.visible = true
