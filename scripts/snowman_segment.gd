extends CharacterBody3D
class_name SnowmanSegment

const SPEED = 4.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	$navigator.target_position = PlayerState.player_instance.global_position
	var _desired_vel : Vector3 = ($navigator.get_next_path_position() - global_position).normalized() * SPEED
	velocity = Vector3(_desired_vel.x, velocity.y, _desired_vel.z)
	
	move_and_slide()
