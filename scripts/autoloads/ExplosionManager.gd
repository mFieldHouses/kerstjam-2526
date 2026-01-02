extends Node

func summon_explosion(at : Vector3, parent_node_3d : Node3D) -> void:
	var _expl : GPUParticles3D = preload("res://scenes/explosion.tscn").instantiate()
	parent_node_3d.add_child(_expl)
	_expl.global_position = at
	_expl.emitting = true
