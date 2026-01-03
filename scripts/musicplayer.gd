extends AudioStreamPlayer

@export var intro_stream : AudioStream
@export var loop_stream : AudioStream

@export var auto : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = intro_stream
	
	if !auto:
		await get_child(0).trigger
	
	play()
	
	await finished

	stream = loop_stream
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = stream.mix_rate * stream.get_length()
	play()

func fade_out(time : float = 10.0) -> void:
	var _fade_tween : Tween = create_tween()
	_fade_tween.tween_property(self, "volume_linear", 0.0, time)
