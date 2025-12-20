@tool
extends Module
class_name DoorController

##Module that keeps track of the state of a door and plays animations for opening and closing the door when triggered.

@export var door_opened : bool = false:
	set(x):
		door_opened = x
		
		if Engine.is_editor_hint(): #For fancy animations in editor, not necessary but looks cool
			if x == true:
				open_door_anim()
			else:
				close_door_anim()

@export_enum("Open-Close", "Single", "Armature Actions") var animation_mode : int = 0 ##The way that the animations are controlled.[br][br] - [param Open-Close] assumes that all animations are baked into 1 animation (by setting Split by Object in export settings to false) and that the opening and closing animations are one action and succeed each other within that action. [br] - [param Single] assumes that you only have one animation with one or more objects baked into the scene that you want to play in reverse for the closing animation.[br] - [param Armature Action] assumes all objects are parented to an armature, which then has seperate actions for both opening and closing.
@export var border_time : float = 0 ##Used in the [param Open-Close] animation mode. Determines where the closing animation starts, and also where the opening animation needs to stop playing.

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_slider") var autoclose_time : float = 0 ##If set to anything else than 0, this [DoorController] will automatically close this door [param autoclose_time] seconds after the opening animation has finished.

var _animation_player_instance : AnimationPlayer

var _playing_animation_section : bool = false
signal _animation_section_finished

@onready var _triggers : Array[Trigger] = get_triggers()

func _ready() -> void:
	if !get_parent().has_node("AnimationPlayer"):
		printerr(self, " does not have an AnimationPlayer as sibling and will not function.")
	else:
		_animation_player_instance = get_parent().get_node("AnimationPlayer")
	
	if !Engine.is_editor_hint():
		if _triggers == []:
			no_triggers_error()
		else:
			var _has_enabled_trigger = false
			for _trigger_object : Trigger in _triggers:
				if _trigger_object.enabled:
					_has_enabled_trigger = true
					_trigger_object.toggle.connect(toggle_door)
			
			if !_has_enabled_trigger:
				no_enabled_triggers_error()
	
	if door_opened:
		_animation_player_instance.play("Scene", -1, 0.0) #Make sure "Scene" is loaded before seeking
		_animation_player_instance.stop()
		_animation_player_instance.seek(border_time, true)

func toggle_door(toggled_with_key, state : bool):
	if state == false:
		if _playing_animation_section:
			await _animation_section_finished
		close_door_anim()
		door_opened = false
	else:
		if _playing_animation_section:
			await _animation_section_finished
		open_door_anim()
		door_opened = true

func open_door_anim():
	if animation_mode == 0:
		_animation_player_instance.seek(0.0, true)
		_playing_animation_section = true
		_animation_player_instance.play_section("Scene", 0.0, border_time)
		
		await get_tree().create_timer(border_time).timeout
		_playing_animation_section = false
		_animation_section_finished.emit()

func close_door_anim():
	if animation_mode == 0:
		_animation_player_instance.seek(border_time, true)
		_playing_animation_section = true
		_animation_player_instance.play_section("Scene", border_time)
		
		await get_tree().create_timer(_animation_player_instance.get_animation("Scene").length - border_time).timeout
		_playing_animation_section = false
		_animation_section_finished.emit()
