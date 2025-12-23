extends CharacterBody3D
class_name Yeti

const SPEED = 4.0
const JUMP_VELOCITY = 4.5

var _player_last_seen_state : Dictionary = {
	"position" : null, #if null, there is no _player_last_seen that hasn't been checked out already
	"velocity" : null
}
var _can_see_player : bool = false

enum BehaviorState {GO_TO_POINT, PATROL, CHASE, FOLLOW_TRAIL}
var _current_behavior_state : BehaviorState = BehaviorState.GO_TO_POINT

func _ready() -> void:
	$NavigationAgent3D.target_position = Vector3.ZERO

func _physics_process(delta: float) -> void:
	
	var _yeti_to_player : Vector3 = global_position - PlayerState.player_instance.global_position
	var _line_of_sight_angle_to_player : float = rad_to_deg(global_basis.z.angle_to(_yeti_to_player))
	
	_can_see_player = RaycastManager.is_ray_free($eyes.global_position, PlayerState.player_instance.global_position + Vector3(0.0, 1.0, 0.0), 1, true)
	_can_see_player = _can_see_player and _line_of_sight_angle_to_player < 70
	
	if _can_see_player:
		_current_behavior_state = BehaviorState.CHASE
		$NavigationAgent3D.target_position = PlayerState.player_instance.global_position
	elif _get_visible_trail_points().size() > 0: #can see trail points
		_current_behavior_state = BehaviorState.FOLLOW_TRAIL
		$NavigationAgent3D.target_position = _get_closest_visible_trail_point().global_position
	
	if _current_behavior_state == BehaviorState.GO_TO_POINT:
		print("go to point")
		print($NavigationAgent3D.is_navigation_finished())
	
	elif _current_behavior_state == BehaviorState.CHASE:
		print("chase ", $NavigationAgent3D.target_position)
		if !_can_see_player:
			if $NavigationAgent3D.is_navigation_finished():
				_current_behavior_state = BehaviorState.PATROL
		
	
	elif _current_behavior_state == BehaviorState.FOLLOW_TRAIL:
		print("follow trail")
		if $NavigationAgent3D.is_navigation_finished():
			if _get_visible_trail_points().size() > 0:
				print("follow next trail point")
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
	Utility.visualise_point($eyes.global_position + velocity, get_parent(), delta)
	
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
