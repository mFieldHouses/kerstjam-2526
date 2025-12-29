extends Node3D

var possible_contents : Array[Dictionary] = [
	{
		"scene_path": "res://assets/meshes/Misc/Pakjes/pakje-1.tscn",
		"max_rot_offset": 10,
		"min_rot_offset": -10
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _marker : Marker3D in Utility.get_children_of_type(self, "Marker3D"):
		var _content_to_place : Dictionary = possible_contents.pick_random()
		var _new_object : Node3D = load(_content_to_place.scene_path).instantiate()
		_marker.add_child(_new_object)
		_new_object.rotation_degrees.y = randf_range(_content_to_place.min_rot_offset, _content_to_place.max_rot_offset)
