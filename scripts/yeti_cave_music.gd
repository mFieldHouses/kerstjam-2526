extends AudioStreamPlayer

@export var chase_1_track : AudioStream
@export var chase_2_track : AudioStream

var playing_state : int = 0
var desired_state : int = 0

var _next_switch_opportunity : float = 0.0

func _ready() -> void:
	
	volume_linear = 0.0
	
	chase_1_track.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
	chase_1_track.loop_end = chase_1_track.mix_rate * chase_1_track.get_length()
	
	chase_2_track.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
	chase_2_track.loop_end = chase_2_track.mix_rate * chase_2_track.get_length()

func _process(delta: float) -> void:
	if desired_state != playing_state:
		#print("states are not equal! ", _next_switch_opportunity, " / ", get_playback_position())
		if get_playback_position() >= _next_switch_opportunity or playing_state == 0:
		#	print("switching")
			var _time : float = get_playback_position()
			_set_stream(desired_state, _time)
	else:
		_next_switch_opportunity = fmod(snappedf(get_playback_position() / stream.get_length() + 0.125, 0.25), 1.0) * stream.get_length()

func _set_stream(idx : int, from_time : float) -> void:
	match idx:
		1:
			stream = chase_1_track
			play(from_time)
		2:
			stream = chase_2_track
			play(from_time)
	
	if playing_state != 0 and idx == 0:
		var _volume_tween : Tween = create_tween()
		_volume_tween.tween_property(self, "volume_linear", 0.0, 1.5)
	elif playing_state == 0 and idx != 0:
		var _time : float = 1.5
		if idx == 2:
			_time = 0.2
		var _volume_tween : Tween = create_tween()
		_volume_tween.tween_property(self, "volume_linear", 1.0, _time)	
	
	playing_state = idx
