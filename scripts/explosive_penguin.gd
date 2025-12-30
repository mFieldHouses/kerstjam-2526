extends Area3D
class_name ExplosivePenguin

var velocity : Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_explode)

func _physics_process(delta: float) -> void:
	velocity.y -= 9.81 * 1.7 * delta
	position += velocity * delta

func _explode(body) -> void:
	print("explode")
	for _body in $explosion_area.get_overlapping_bodies():
		var _dmg = (1.0 - (global_position.distance_to(_body.global_position) / 3.0)) * 20.0
		if _body is Player:
			pass
		elif _body is not StaticBody3D:
			_body.hit(_dmg, Vector3.ZERO, 0.0)
		HitMarkerManager.hit_at(_body.global_position, _dmg, load("res://scenes/particle_effects/santa_gun_hit_standard.tscn"), get_parent())
	queue_free()
