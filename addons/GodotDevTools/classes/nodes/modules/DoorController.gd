@tool
extends Module
class_name DoorController

## DoorController (Rotate mode) + simple deterministic Open SFX.
##
## USAGE:
## 1) Add an AudioStreamPlayer3D node anywhere you want (you already have SFX_Door).
## 2) Select DoorController -> Inspector:
##    - Assign `sfx_player` to your AudioStreamPlayer3D (drag SFX_Door onto it)
##    - Assign `door_sfx` to your .ogg/.wav
## 3) Run -> opening plays sound.
##
## Debug:
## - Prints why sound didn't play (missing player/stream/bus muted/etc.)

@export var door_opened : bool = false:
	set(x):
		door_opened = x

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_slider") var autoclose_time : float = 0
@export var open_rotation_offset : float = 90.0
@export var rotation_time : float = 0.4

# --- AUDIO (deterministic) ---
@export var door_sfx : AudioStream
@export var sfx_player : AudioStreamPlayer3D  # <— drag your SFX_Door here in Inspector
@export var debug_audio : bool = true

var _init_rotation : float
@onready var _triggers : Array[Trigger] = get_triggers()

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_init_rotation = rotation_degrees.y

	# Hook triggers
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

	# Audio sanity log once
	if debug_audio:
		_debug_audio_state("ready")

func toggle_door(toggled_with_key, state : bool):
	print("toggle ", state)

	# Play ONLY on opening
	if state:
		_play_open_sfx()

		var _rotate_tween : Tween = create_tween()
		_rotate_tween.tween_property(get_parent(), "rotation_degrees:y", _init_rotation + open_rotation_offset, rotation_time)
	else:
		var _rotate_tween : Tween = create_tween()
		_rotate_tween.tween_property(get_parent(), "rotation_degrees:y", _init_rotation, rotation_time)

func _play_open_sfx() -> void:
	if Engine.is_editor_hint():
		return

	if sfx_player == null:
		if debug_audio:
			printerr("DoorController audio: sfx_player is NULL. Assign it in Inspector (drag SFX_Door onto sfx_player).")
		return

	# Ensure we have a stream
	if door_sfx != null:
		sfx_player.stream = door_sfx

	if sfx_player.stream == null:
		if debug_audio:
			printerr("DoorController audio: No stream set. Assign door_sfx (.ogg/.wav) in Inspector.")
		return

	# Extra: if bus muted/volume too low you won't hear anything
	if debug_audio:
		_debug_audio_state("play")

	# Restart and play
	sfx_player.stop()
	sfx_player.play()

func _debug_audio_state(tag: String) -> void:
	var bus := "?"
	var vol := 0.0
	var playing := false
	var has_stream := false
	var max_dist := 0.0
	var unit_size := 0.0

	if sfx_player != null:
		bus = sfx_player.bus
		vol = sfx_player.volume_db
		playing = sfx_player.playing
		has_stream = (sfx_player.stream != null) or (door_sfx != null)
		max_dist = sfx_player.max_distance
		unit_size = sfx_player.unit_size

	print("[DoorController audio:", tag, "] ",
		"player=", sfx_player,
		" has_stream=", has_stream,
		" bus=", bus,
		" volume_db=", vol,
		" max_distance=", max_dist,
		" unit_size=", unit_size,
		" playing=", playing
	)



# -----------------------------------------
# (Your old animation-player code remains untouched below.)
# -----------------------------------------

#@export_enum("Open-Close", "Single", "Armature Actions", "Rotate") var animation_mode : int = 0
#@export var border_time : float = 0
#
#func open_door_anim():
#	if animation_mode == 0:
#		_animation_player_instance.seek(0.0, true)
#		_playing_animation_section = true
#		_animation_player_instance.play_section("Scene", 0.0, border_time)
#		await get_tree().create_timer(border_time).timeout
#		_playing_animation_section = false
#		_animation_section_finished.emit()
#
#func close_door_anim():
#	if animation_mode == 0:
#		_animation_player_instance.seek(border_time, true)
#		_playing_animation_section = true
#		_animation_player_instance.play_section("Scene", border_time)
#		await get_tree().create_timer(_animation_player_instance.get_animation("Scene").length - border_time).timeout
#		_playing_animation_section = false
#		_animation_section_finished.emit()
