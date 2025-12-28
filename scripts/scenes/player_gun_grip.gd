extends Marker3D

var _influence : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _weapon_config in PlayerState.weapons:
		var _model : Node3D = _weapon_config.weapon_model.instantiate()
		add_child(_model)
		_model.position = _weapon_config.weapon_grip_offset_position
		_model.rotation = _weapon_config.weapon_grip_offset_rotation
		_model.scale = _weapon_config.weapon_model_scale
		_model.visible = false
		
		#var _animation_player : AnimationPlayer = AnimationPlayer.new()
		#_model.add_child(_animation_player)
		#_animation_player.add_animation_library("weapon_use", _weapon_config.weapon_use_animation_library)
	#
	get_child(0).visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bob(time : float, magnitude : float) -> void:
	_influence = lerp(_influence, 1.0, 0.1)
	position.y = sin(time * 8.3) * 0.03 * _influence * magnitude
	rotation.x = sin((time + 0.75*PI) * 10) * 0.02 * _influence * magnitude

func return_to_origin() -> void:
	_influence = 0.0
	position = lerp(position, Vector3(0.0, 0.0, 0.0), 0.1)
	rotation = lerp(rotation, Vector3(0.0, 0.0, 0.0), 0.1)

func play_shoot_animation(anim_name : String) -> void:
	var _animplayer : AnimationPlayer = get_child(0).get_node("AnimationPlayer")
	print(_animplayer.get_animation_list())
	_animplayer.stop()
	_animplayer.play(anim_name, -1)
