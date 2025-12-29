extends CharacterBody3D
class_name JumpingMimic

@export var speed : float = 1.0
var field_of_view : float = 70

@export_range(0.0, 1.0, 0.5, "or_greater") var health_left : float = 25.0
@export_range(0.0, 1.0, 0.5, "or_greater") var max_health : float = 25.0

@export var behavior_configuration : EnemyAIConfiguration

@export var parent : Enemy
@export var aggression_pos : Vector3
@export var aggressive : bool = false
@export var aggression : float

var _awaiting_scout : bool = true
var _next_scout_timer : float = 2.0

var _next_jump_timer : float = 1.0
var _will_jump : bool = false

var freeze : bool = false

@onready var navigator : NavigationAgent3D = $navigator


func _ready() -> void:
	$hit_area.body_entered.connect(_hit_area_body_entered)


func _physics_process(delta: float) -> void:
	if freeze:
		return
	
	velocity = Vector3(0, velocity.y, 0)
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if _next_jump_timer <= 0.0 and PlayerState.get_distance_to_player(global_position) < 6.5:
		_jump()
	
	if _can_see_player():
		aggressive = true
		_next_jump_timer -= delta
		aggression_pos = PlayerState.player_instance.global_position
	else:
		_next_jump_timer = 5.0
		if navigator.is_target_reached():
			aggressive = false
	
	if aggression_pos and aggressive:
		navigator.target_position = aggression_pos
		var _dir : Vector3 = (navigator.get_next_path_position() - global_position).normalized() * speed
		velocity = Vector3(_dir.x, velocity.y, _dir.z)

		look_at(aggression_pos)
	else:
		rotation.x = 0
		if _awaiting_scout:
			_next_scout_timer -= delta
		if _next_scout_timer <= 0.0:
			scout()
	
	if !_will_jump:
		move_and_slide()
		

func hit(damage : float, from_pos : Vector3, knockback_intensity : float) -> void:
	health_left -= damage
	if health_left < 0.0:
		die()
		return
	
	print("ouch")
	

func die() -> void:
	print("ooooouch im dying")
	queue_free()

func scout() -> void:
	_awaiting_scout = false
	_next_scout_timer = randf_range(0.5, 4.0)
	var _will_walk : bool = randf_range(0.0, 1.0) > 0.7
	
	var _turn_tween : Tween = create_tween()
	var _amount_to_turn = randf_range(-0.8 * PI, 0.8 * PI)
	_turn_tween.tween_property(self, "rotation:y", rotation.y + _amount_to_turn, _amount_to_turn * 0.3)
	
	await _turn_tween.finished
	
	_awaiting_scout = true

func _can_see_player() -> bool:
	var _snowman_to_player = PlayerState.player_instance.global_position - global_position
	var _angle_to_player = (-1.0 * global_basis.z).angle_to(_snowman_to_player)
	var _distance_to_player = PlayerState.player_instance.global_position.distance_to(global_position) 
	#print(RaycastManager.is_ray_free(global_position, PlayerState.player_instance.global_position, 1, true))
	return (_angle_to_player < field_of_view) and RaycastManager.is_ray_free(global_position + Vector3(0.0, 0.5, 0.0), PlayerState.player_instance.global_position + Vector3(0.0, 1.0, 0.0), 1, true)

func _jump() -> void:
	_will_jump = true
	_next_jump_timer = 6.0
	var _dir : Vector3 = -global_basis.z
	var _squish_tween : Tween = create_tween()
	_squish_tween.tween_property($"Mimic-12", "scale", Vector3(0.7, 0.55, 0.7), 0.3)
	
	await _squish_tween.finished
	
	var _move_tween : Tween = create_tween()
	_move_tween.tween_property(self, "global_position", (global_position + _dir * 6.5) + Vector3(0.0, 1.0, 0.0), 0.65)
	var _unsquish_tween : Tween = create_tween()
	_unsquish_tween.tween_property($"Mimic-12", "scale", Vector3(0.65, 0.65, 0.65), 0.6)
	await _move_tween.finished
	
	_will_jump = false

func _hit_area_body_entered(body) -> void:
	if body is Player:
		if _will_jump:
			body.get_hit(7.0)
		
