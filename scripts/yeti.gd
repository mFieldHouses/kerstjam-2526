extends CharacterBody3D
class_name Yeti

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var _player_last_seen_state : Dictionary = {
	"position" : null, #if null, there is no _player_last_seen that hasn't been checked out already
	"velocity" : null
}

func _ready() -> void:
	$NavigationAgent3D.target_position = Vector3.ZERO

func _physics_process(delta: float) -> void:
	velocity = Vector3(0.0, 1.0, 0.0)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity = Vector3(($NavigationAgent3D.get_next_path_position().x - global_position.x), velocity.y, ($NavigationAgent3D.get_next_path_position().z - global_position.z)).normalized() * SPEED
	Utility.visualise_point($NavigationAgent3D.get_next_path_position(), get_parent(), delta)
	
	look_at(velocity)
	rotation.x = 0
	rotation.z = 0

	move_and_slide()
