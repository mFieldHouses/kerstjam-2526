extends Area3D
class_name Snowball

var velocity : Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_splat)

func _physics_process(delta: float) -> void:
	velocity.y -= 9.81 * 1.7 * delta
	position += velocity * delta

func _splat(body) -> void:
	print('splat')
	queue_free()
