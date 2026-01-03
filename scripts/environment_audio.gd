extends AudioStreamPlayer


func _ready() -> void:
	stream.loop_end = stream.mix_rate * stream.get_length()
	stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
	#play()

func _process(delta: float) -> void:
	pass
	#volume_linear = ConfigurableValues.environment_volume
