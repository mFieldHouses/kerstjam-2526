extends Label3D

var velocity : Vector3

func _ready() -> void:
	velocity = Vector3(randf_range(-2, 2), 2, randf_range(-2, 2))

func _process(delta: float) -> void:
	velocity.y -= 9.81 * 1.7 * delta
	position += velocity * delta
	
	transparency += delta / 0.5
	
	if transparency >= 1.0:
		queue_free()
