extends CharacterBody3D
class_name Enemy

@export var speed : float = 2.0

@export_range(0.0, 1.0, 0.5, "or_greater") var health_left : float = 10.0
@export_range(0.0, 1.0, 0.5, "or_greater") var max_health : float = 10.0

@export var behavior_configuration : EnemyAIConfiguration

@export var parent : Enemy
@export var aggression_target : Player
@export var aggression : float

var _awaiting_scout : bool = true
var _next_scout_timer : float = 2.0

@onready var navigator : NavigationAgent3D = $navigator

func _physics_process(delta: float) -> void:
	velocity = Vector3(0, velocity.y, 0)
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	_evaluate_aggression()
	
	if aggression > behavior_configuration.aggression_threshold:
		aggression_target = PlayerState.player_instance
	else:
		aggression_target = null
	
	if aggression_target:
		navigator.target_position = aggression_target.global_position
		velocity = (navigator.get_next_path_position() - global_position).normalized() * speed
		look_at(aggression_target.global_position)
	else:
		rotation.x = 0
		if _awaiting_scout:
			_next_scout_timer -= delta
		if _next_scout_timer <= 0.0:
			scout()
	
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

func _evaluate_aggression() -> void:
	aggression = 0
	for _modifier : AggressionModifier in behavior_configuration.aggression_modifiers:
		aggression += _modifier.get_aggression_factor(self)
