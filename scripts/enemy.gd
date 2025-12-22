extends CharacterBody3D
class_name Enemy

@export var speed : float = 4.0

@export_range(0.0, 1.0, 0.5, "or_greater") var health_left : float = 10.0
@export_range(0.0, 1.0, 0.5, "or_greater") var max_health : float = 10.0

@export var parent : Enemy
@export var aggression_target : Player
@export var aggression : float

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
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
