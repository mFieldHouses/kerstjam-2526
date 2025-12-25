extends Node3D

func hit_at(at : Vector3, for_damage : float, particle_effect : PackedScene, root_node_3d : Node3D) -> void:
	var _marker : Label3D = preload("res://scenes/particle_effects/hitmarker_text.tscn").instantiate()
	_marker.text = str(snappedf(for_damage, 0.1))
	root_node_3d.add_child(_marker)
	_marker.global_position = at
