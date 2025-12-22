extends Resource
class_name WeaponConfiguration

##Resource for describing weapons, like their name, model and grip position

@export var weapon_name : String = "" ##The name of this weapon.

@export var scopeable : bool = false ##Whether the player can rightclick to zoom in and land more accurate hits with this weapon.
@export var reach : float = 1000.0 ##How far away this weapon can hit enemies, in Godot meters. Make this larger for guns, and small for meelee.

@export var min_damage_per_hit : float = 1.0
@export var max_damage_per_hit : float = 2.0

@export var hit_delay : float = 0.0 ##Time to wait before damaging a target. Useful for weapons that use a swing animation.
@export var hit_particle_effect_scene : PackedScene ##Particle effect scene that will be instantiated when this weapon hits something

@export var weapon_model : PackedScene
@export var weapon_model_scale : Vector3
@export var weapon_grip_offset_position : Vector3
@export var weapon_grip_offset_rotation : Vector3

@export var weapon_use_animation_library : AnimationLibrary
@export var weapon_use_cooldown : float = 0.3 
@export var weapon_use_sounds : Array[AudioStreamWAV]

func get_hit_damage() -> float:
	return randf_range(min_damage_per_hit, max_damage_per_hit)
