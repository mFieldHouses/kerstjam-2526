extends Node3D

signal fall_tile

func _ready() -> void:
	var _move_tween : Tween = create_tween()
	_move_tween.tween_property($fire_particles, "position:y", 0.0, 3.0)
	
	var _fade_tween : Tween = create_tween()
	_fade_tween.tween_property($Sprite3D, "transparency", 1.0, 1.5)
	
	await _move_tween.finished
	
	hit()
	
	await get_tree().create_timer($fire_particles.lifetime).timeout
	
	queue_free()	

func hit() -> void:
	ExplosionManager.summon_explosion(global_position, get_parent())
	
	$fire_particles.emitting = false
	$Sprite3D.visible = false
	for _collider : Player in $hit_area.get_overlapping_bodies():
		_collider.get_hit(10)
