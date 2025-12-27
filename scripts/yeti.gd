extends CharacterBody3D
class_name Yeti

const SPEED = 4.5
const JUMP_VELOCITY = 4.5

var _player_last_seen_state : Dictionary = {
	"position" : null, #if null, there is no _player_last_seen that hasn't been checked out already
	"velocity" : null
}
var _can_see_player : bool = false
var _flags : Array[bool] = [false, false, false, false] #array of flags to keep track of when to play specific dialogs

@onready var _model_scene = $"Yeti-2-1"
@onready var _animation_player : AnimationPlayer = $"Yeti-2-1/Yeti-2-1/AnimationPlayer"

enum BehaviorState {PATROL, CHASE, FOLLOW_TRAIL, SLEEP}
var _current_behavior_state : BehaviorState = BehaviorState.SLEEP:
	set(x):
		
		match x:
			BehaviorState.PATROL:
				%yeti_state.text = "Patrol"
			BehaviorState.CHASE:
				%yeti_state.text = "Chase"
			BehaviorState.FOLLOW_TRAIL:
				if _flags[0] == true and _flags[1] == false and _flags[2] == false:
					DialogManager.initiate_remote_dialog("discover_yeti2", "Henkie", load("res://icon.svg"))
					_flags[2] = true
				%yeti_state.text = "Follow Trail"
		
		_current_behavior_state = x

func _ready() -> void:
	$NavigationAgent3D.target_position = Vector3.ZERO
	DialogManager.dialog_queue.connect(func(did : String, qid : String): if did == "enter_yeti_hollow" and qid == "release_yeti": _current_behavior_state = BehaviorState.PATROL)
	DialogManager.dialog_ended.connect(_dialog_end)
	
	_animation_player.play("Global/Idle-3")
	_animation_player.get_animation("Global/Idle-3").loop_mode = Animation.LOOP_PINGPONG
	
func _dialog_end(did: String) -> void:
	if did == "discover_yeti":
		print("allow discover_yeti2")
		_flags[1] = false

func _physics_process(delta: float) -> void:
	
	if _current_behavior_state == BehaviorState.SLEEP:
		return
	
	var _yeti_to_player : Vector3 = global_position - PlayerState.player_instance.global_position
	var _line_of_sight_angle_to_player : float = rad_to_deg(global_basis.z.angle_to(_yeti_to_player))
	
	_can_see_player = RaycastManager.is_ray_free($eyes.global_position, PlayerState.player_instance.global_position + Vector3(0.0, 1.0, 0.0), 1, true)
	_can_see_player = _can_see_player and _line_of_sight_angle_to_player < 70
	
	if _can_see_player:
		if !_flags[0]:
			_flags[0] = true
			_flags[1] = true
			DialogManager.initiate_remote_dialog("discover_yeti", "Henkie", load("res://icon.svg"))
		if _current_behavior_state != BehaviorState.CHASE:
			_current_behavior_state = BehaviorState.CHASE
		$NavigationAgent3D.target_position = PlayerState.player_instance.global_position
	elif _get_visible_trail_points().size() > 0 and _current_behavior_state != BehaviorState.FOLLOW_TRAIL: #can see trail points
		_current_behavior_state = BehaviorState.FOLLOW_TRAIL
		$NavigationAgent3D.target_position = _get_closest_visible_trail_point().global_position
	
	elif _current_behavior_state == BehaviorState.CHASE:
		if !_can_see_player:
			if $NavigationAgent3D.is_navigation_finished():
				_current_behavior_state = BehaviorState.PATROL
		
	
	elif _current_behavior_state == BehaviorState.FOLLOW_TRAIL:
		if $NavigationAgent3D.is_navigation_finished():
			if _get_visible_trail_points().size() > 0:
				$NavigationAgent3D.target_position = get_parent()._player_trail_points[0].global_position
			else:
				_current_behavior_state = BehaviorState.PATROL
	
	elif _current_behavior_state == BehaviorState.PATROL:
		if $NavigationAgent3D.is_navigation_finished():
			$NavigationAgent3D.target_position = get_parent().get_random_patrol_waypoint().global_position
	
	velocity = Vector3(0.0, velocity.y, 0.0)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity = Vector3(($NavigationAgent3D.get_next_path_position().x - global_position.x), velocity.y, ($NavigationAgent3D.get_next_path_position().z - global_position.z)).normalized() * SPEED
	#Utility.visualise_point($eyes.global_position + velocity, get_parent(), delta)
	
	look_at($NavigationAgent3D.get_next_path_position())
	rotation.x = 0
	rotation.z = 0
	
	move_and_slide()

func _get_visible_trail_points() -> Array[PlayerTrailPoint]:
	var _result : Array[PlayerTrailPoint] = []
	for _point : PlayerTrailPoint in get_parent()._player_trail_points:
		if RaycastManager.is_ray_free(_point.global_position + Vector3(0.0, 0.5, 0.0), $eyes.global_position, 1):
			_result.append(_point)
	
	return _result

func _get_closest_visible_trail_point() -> PlayerTrailPoint:
	var _candidates : Array[PlayerTrailPoint] = _get_visible_trail_points()
	var _result : PlayerTrailPoint = _candidates[0]
	for _candidate_trail_point : PlayerTrailPoint in _candidates:
		if _candidate_trail_point.global_position.distance_to(global_position) < _result.global_position.distance_to(global_position):
			_result = _candidate_trail_point
	
	return _result
