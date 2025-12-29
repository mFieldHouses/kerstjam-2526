extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _marker : Marker3D in Utility.get_children_of_type(self, "Marker3D"):
		print("add present mesh")
