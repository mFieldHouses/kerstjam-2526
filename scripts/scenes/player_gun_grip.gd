extends Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bob(time : float) -> void:
	position.y = sin(time * 10) * 0.03
	rotation.y = sin((time + 0.75*PI) * 10) * 0.03

func return_to_origin() -> void:
	position = lerp(position, Vector3(0.0, 0.0, 0.0), 0.1)
	rotation = lerp(rotation, Vector3(0.0, 0.0, 0.0), 0.1)
