extends CharacterBody3D
class_name Snowman

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var shoot_timer : float = 0.0
var shoot_cooldown : float = 1.0

var _health_left : float = 15.0:
	set(x):
		_health_left = x
		
		if _health_left <= 0.0:
			_die()

func _physics_process(delta: float) -> void:
	shoot_timer += delta
	
	if shoot_timer >= shoot_cooldown:
		_shoot()
		shoot_timer = 0.0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func hit(damage : float, from : Vector3, knockback : float) -> void:
	print("snowman hit")
	_health_left -= damage

func _die() -> void:
	print("im dying")
	queue_free()

func _shoot() -> void:
	pass
