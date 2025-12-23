extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.dialog_started.connect(func(id : String): mesh.surface_get_material(0).albedo_color = Color(1.0, 1.0, 1.0, 0.3))
	DialogManager.dialog_ended.connect(func(id : String): mesh.surface_get_material(0).albedo_color = Color(1.0, 1.0, 1.0, 1.0))
	DialogManager.dialog_queue.connect(func(id1, id2): mesh.surface_get_material(0).albedo_color = Color(1.0, 0.0, 0.0, 0.5))
