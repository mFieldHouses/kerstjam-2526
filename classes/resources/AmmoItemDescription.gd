extends ItemDescription
class_name AmmoItemDescription

@export var ammo_type_identifier : String
@export var shot_particle_scene : PackedScene
@export var hit_particle_scene : PackedScene

@export var automatic : bool = false
@export var shoot_delay : float = 0.2
