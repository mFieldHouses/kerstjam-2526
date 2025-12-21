extends Resource
class_name WeaponConfiguration

##Resource for describing weapons, like their name, model and grip position

@export var weapon_name : String = ""
@export var weapon_model : PackedScene
@export var weapon_model_scale : Vector3
@export var weapon_grip_offset_position : Vector3
@export var weapon_grip_offset_rotation : Vector3
