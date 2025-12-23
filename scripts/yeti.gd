extends CharacterBody3D
class_name Yeti

const SPEED = 4.0
const JUMP_VELOCITY = 4.5

var _player_last_seen_state : Dictionary = {
	"position" : null, #if null, there is no _player_last_seen that hasn't been checked out already
	"velocity" : null
}
var _can_see_player : bool = false

enum BehaviorState {GO_TO_POINT, PATROL, CHASE, APPROACH_TRAIL, FOLLOW_TRAIL}
var _current_behavior_state : BehaviorState = BehaviorState.GO_TO_POINT

func _ready() -> void:
	$NavigationAgent3D.target_position = Vector3.ZERO

func _physics_process(delta: float) -> void:
	velocity = Vector3(0.0, velocity.y, 0.0)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity = Vector3(($NavigationAgent3D.get_next_path_position().x - global_position.x), velocity.y, ($NavigationAgent3D.get_next_path_position().z - global_position.z)).normalized() * SPEED
	Utility.visualise_point($NavigationAgent3D.get_next_path_position(), get_parent(), delta)
	
	look_at(velocity)
	rotation.x = 0
	rotation.z = 0
	
	var _yeti_to_player : Vector3 = global_position - PlayerState.player_instance.global_position
	var _line_of_sight_angle_to_player : float = rad_to_deg(global_basis.z.angle_to(_yeti_to_player))
	
	_can_see_player = RaycastManager.is_ray_free($eyes.global_position, PlayerState.player_instance.global_position + Vector3(0.0, 1.0, 0.0), 1, true)
	_can_see_player = _can_see_player and _line_of_sight_angle_to_player < 70
	if _can_see_player:
		#_player_last_seen_state = {
			#"position": PlayerState.player_instance.global_position,
			#"velocity": PlayerState.player_instance.velocity
		#}
		$NavigationAgent3D.target_position = PlayerState.player_instance.global_position
	else:
		pass
		#_player_last_seen_state = {
			#"position": null,
			#"velocity": null
		#}
	
	move_and_slide()
