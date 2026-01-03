extends Hittable

func hit(damage : float, from : Vector3, knockback : float) -> void:
	got_hit.emit(damage)
	print("oei auw")
