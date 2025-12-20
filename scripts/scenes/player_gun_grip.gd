extends Marker3D

var _influence : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bob(time : float, magnitude : float) -> void:
	_influence = lerp(_influence, 1.0, 0.2)
	position.y = sin(time * 8) * 0.03 * _influence * magnitude
	rotation.y = sin((time + 0.75*PI) * 10) * 0.015 * _influence * magnitude

func return_to_origin() -> void:
	_influence = 0.0
	position = lerp(position, Vector3(0.0, 0.0, 0.0), 0.1)
	rotation = lerp(rotation, Vector3(0.0, 0.0, 0.0), 0.1)
