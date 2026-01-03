extends Node3D

@onready var _animplayer : AnimationPlayer = $"NutCracker-1/AnimationPlayer"

var _lasers : Node3D
var _lasers_mat : StandardMaterial3D

var _health_left : float = 200.0:
	set(x):
		_health_left = x
		
		_destruction_level = int((200.0 - _health_left) / 70.0)
		
var _destruction_level : int = 0:
	set(x):
		_destruction_level = x
		
		if _destruction_level > 0 and _destruction_level < 2:
			var _particles = get_node("destruct_" + str(_destruction_level))
			
			for _child : GPUParticles3D in _particles.get_children():
				_child.emitting = true
				ExplosionManager.summon_explosion(_child.global_position, _child.get_parent())

func _ready() -> void:
	_lasers = preload("res://scenes/characters/nutcracker_lasers.tscn").instantiate()
	_lasers.player_entered.connect(PlayerState.player_instance.get_hit.bind(5))
	_lasers.get_node("meshes").visible = false
	_lasers.get_node("button").got_hit.connect(func(dmg_amount : float): _health_left -= dmg_amount)
	_lasers_mat = _lasers.get_node("meshes/right_mesh").get_active_material(0)
	$"NutCracker-1/robot/Skeleton3D/head_top/Cube_049/Eyes_001".add_child(_lasers)

func shoot_up() -> void:
	_animplayer.play("shoot_up")
	
	await _animplayer.animation_finished
	return

func laser_shoot(mult : float) -> void:
	_lasers.get_node("meshes").visible = true
	
	var _tween : Tween = create_tween()
	_tween.tween_property(self, "position:y", -4, 2.2)
	
	_animplayer.play("laser_shoot1", -1, 1.0 + (mult * 0.5))
	
	await get_tree().create_timer(2.5 * (1.0 - (2.0 * mult))).timeout
	
	_lasers_mat.emission_energy_multiplier = 1.0
	_lasers.get_node("particles").emitting = true
	_lasers.get_node("hit").enabled = true
	
	#_tween = create_tween()
	#_tween.tween_property(self, "position:y", 4, 2.2)
	#await _tween.finished
	
	await _animplayer.animation_finished
	
	_tween = create_tween()
	_tween.tween_property(self, "position:y", 4, 2.2)
	
	_lasers_mat.emission_energy_multiplier = 0.0
	_lasers.get_node("particles").emitting = false
	_lasers.get_node("meshes").visible = false
	_lasers.get_node("hit").enabled = false
	
	await get_tree().create_timer(4.0).timeout
	
	return

func spawn_monsters_timeout() -> void:
	for i in 4:
		_animplayer.play("timeout", -1, 2)
		
		await _animplayer.animation_finished
	
	return

func ascend() -> void:
	_animplayer.play("ascend")
