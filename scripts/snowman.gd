extends CharacterBody3D
class_name Snowman

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var shoot_timer : float = 0.0
var shoot_cooldown : float = 2.0

var field_of_view : float = 90.0
var sight_distance : float = 20.0

var _frozen : bool = true
var _target : Player

var _strafe_dir : int = 0
var _strafe_timer : float = 1.0

var _health_left : float = 25.0:
	set(x):
		_health_left = x
		
		if _health_left <= 0.0:
			_die()

func _physics_process(delta: float) -> void:
	#print(_can_see_player())
	if _frozen:
		if(_can_see_player()):
			_frozen = false
			_target = PlayerState.player_instance
		else:
			return
	
	
	shoot_timer += delta
	_strafe_timer -= delta
	
	var _speed_mod : float = clamp(5.0 / PlayerState.get_distance_to_player(global_position) / (_health_left / 15.0), 0.1, 1.4)
	
	if shoot_timer >= shoot_cooldown:
		_shoot()
		shoot_timer = 0.0
	
	if _strafe_timer <= 0.0:
		_strafe_dir = [-1, 1].pick_random()
		_strafe_timer = randf_range(0.5, 2.0 / _speed_mod)
	
	if _can_see_player():
		look_at(PlayerState.player_instance.global_position)
		rotation.x = 0
		rotation.z = 0
		
		velocity = Vector3((global_basis.x * _strafe_dir * SPEED * _speed_mod).x, velocity.y, (global_basis.x * _strafe_dir * SPEED * _speed_mod).z)
	else:
		_strafe_dir = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_can_see_player()
	
	move_and_slide()

func hit(damage : float, from : Vector3, knockback : float) -> void:
	_health_left -= damage
	if _frozen:
		_frozen = false

func _die() -> void:
	for idx in 3:
		var _new_segment : SnowmanSegment = preload("res://scenes/characters/snowman_segment.tscn").instantiate()
		get_parent().add_child(_new_segment)
		_new_segment.global_position = global_position + Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	queue_free()

func _shoot() -> void:
	$shoot.play()
	var _new_snowball : Snowball = preload("res://scenes/projectiles/snowball.tscn").instantiate()
	var _to_player : Vector3 = Vector3(PlayerState.player_instance.global_position - global_position)
	get_parent().add_child(_new_snowball)
	_new_snowball.global_position = $"snowball-origin".global_position
	_new_snowball.velocity = _to_player * 2 + Vector3(0.0, PlayerState.player_instance.global_position.distance_to(global_position) * 0.15, 0.0)
	print("shoot snowball")

func _can_see_player() -> bool:
	var _snowman_to_player = PlayerState.player_instance.global_position - global_position
	var _angle_to_player = (-1.0 * global_basis.z).angle_to(_snowman_to_player)
	var _distance_to_player = PlayerState.player_instance.global_position.distance_to(global_position) 
	#print(RaycastManager.is_ray_free(global_position, PlayerState.player_instance.global_position, 1, true))
	return (_angle_to_player < field_of_view) and RaycastManager.is_ray_free($"snowball-origin".global_position, PlayerState.player_instance.global_position + Vector3(0.0, 1.0, 0.0), 1, true) and _distance_to_player <= sight_distance
