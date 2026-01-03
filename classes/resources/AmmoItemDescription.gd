extends ItemDescription
class_name AmmoItemDescription

@export var shoot_audio_stream : AudioStream

@export var ammo_type_identifier : String
@export var shot_particle_scene : PackedScene
@export var hit_particle_scene : PackedScene

@export var automatic : bool = false
@export var shoot_delay : float = 0.2

@export var max_damage : float = 1.0
@export var min_damage : float = 0.0

func get_damage() -> float:
	return snappedf(randf_range(min_damage, max_damage), 0.1)
