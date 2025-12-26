extends CharacterBody3D
class_name SnowmanSegment

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var hit_timer : float = 0.0
var hit_timeout : float = 2.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	$navigator.target_position = PlayerState.player_instance.global_position
	var _desired_vel : Vector3 = ($navigator.get_next_path_position() - global_position).normalized() * SPEED
	velocity = Vector3(_desired_vel.x, velocity.y, _desired_vel.z)
	
	hit_timer += delta
	if hit_timer > hit_timeout:
		hit_timer = 0
		if $hit_shape.get_overlapping_bodies():
			PlayerState.player_instance.get_hit(1.0)
	
	move_and_slide()

func hit(damage : float, from : Vector3, knockback : float) -> void:
	queue_free()
