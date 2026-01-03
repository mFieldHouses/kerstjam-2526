extends AudioStreamPlayer

@export var chase_1_track : AudioStream
@export var chase_2_track : AudioStream

var playing_state : int = 0
var desired_state : int = 0

var _next_switch_opportunity : float = 0.0

func _ready() -> void:
	chase_1_track.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
	chase_1_track.loop_end = chase_1_track.mix_rate * chase_1_track.get_length()
	
	chase_2_track.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
	chase_2_track.loop_end = chase_2_track.mix_rate * chase_2_track.get_length()

func _process(delta: float) -> void:
	_next_switch_opportunity = fmod(snappedf(get_playback_position() / stream.get_length() + 0.125, 0.25), 1.0) * stream.get_length()
	
	if desired_state != playing_state:
		print("states are not equal!")
		if get_playback_position() >= _next_switch_opportunity or playing_state == 0:
			print("switching")
			var _time : float = get_playback_position()
			_set_stream(desired_state, _time)

func _set_stream(idx : int, from_time : float) -> void:
	match idx:
		0:
			stop()
		1:
			stream = chase_1_track
			play(from_time)
		2:
			stream = chase_2_track
			play(from_time)
	
	playing_state = idx
