extends Marker3D

var _influence : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _path in DirAccess.get_files_at(DefaultPaths.weapon_configurations_path):
		var _weapon_config : WeaponConfiguration = load(DefaultPaths.weapon_configurations_path + _path) as WeaponConfiguration
		var _model : Node3D = _weapon_config.weapon_model.instantiate()
		add_child(_model)
		_model.position = _weapon_config.weapon_grip_offset_position
		_model.rotation = _weapon_config.weapon_grip_offset_rotation
		_model.scale = _weapon_config.weapon_model_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bob(time : float, magnitude : float) -> void:
	_influence = lerp(_influence, 1.0, 0.1)
	position.y = sin(time * 8) * 0.03 * _influence * magnitude
	rotation.y = sin((time + 0.75*PI) * 10) * 0.015 * _influence * magnitude

func return_to_origin() -> void:
	_influence = 0.0
	position = lerp(position, Vector3(0.0, 0.0, 0.0), 0.1)
	rotation = lerp(rotation, Vector3(0.0, 0.0, 0.0), 0.1)
