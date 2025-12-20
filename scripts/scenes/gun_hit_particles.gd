extends CPUParticles3D

@export var auto_remove_delay : float = 0.2

func _ready() -> void:
	await get_tree().create_timer(auto_remove_delay).timeout
	queue_free()
