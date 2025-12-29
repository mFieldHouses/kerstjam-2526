extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$StaticBody3D/CollisionShape3D/Plane_843.visible = false
	$StaticBody3D/CollisionShape3D/Plane_844.visible = false
	$"StaticBody3D/CollisionShape3D/Pakje-Krul".visible = false
	$"StaticBody3D/CollisionShape3D/Pakje-Krul2".visible = false
	$"StaticBody3D/CollisionShape3D/Pakje-Krul3".visible = false
	$"StaticBody3D/CollisionShape3D/Pakje-Krul4".visible = false
	
	var _scale : float = randf_range(0.3, 1.0)
	scale = Vector3(_scale, _scale, _scale)
	
	var _krul_type : int = randi_range(0, 4)
	
	match _krul_type:
		0:
			$"StaticBody3D/CollisionShape3D/Pakje-Krul".visible = true
			$"StaticBody3D/CollisionShape3D/Pakje-Krul2".visible = true
			$"StaticBody3D/CollisionShape3D/Pakje-Krul3".visible = true
			$"StaticBody3D/CollisionShape3D/Pakje-Krul4".visible = true
		1:
			$"StaticBody3D/CollisionShape3D/Pakje-Krul2".visible = true
			$"StaticBody3D/CollisionShape3D/Pakje-Krul4".visible = true
		2:
			$"StaticBody3D/CollisionShape3D/Pakje-Krul".visible = true
			$"StaticBody3D/CollisionShape3D/Pakje-Krul3".visible = true
		3:
			$StaticBody3D/CollisionShape3D/Plane_843.visible = true
		4:
			$StaticBody3D/CollisionShape3D/Plane_844.visible = true
	
	
	
	var _color1 : int = randi_range(0,5)
	var _color2 : int = randi_range(0,5)
	
	var _mat1 : StandardMaterial3D = $"StaticBody3D/CollisionShape3D/Pakje-1-2x2x2".get_surface_override_material(0).duplicate()
	var _mat2 : StandardMaterial3D = $"StaticBody3D/CollisionShape3D/Pakje-1-2x2x2".get_surface_override_material(1).duplicate()
	$"StaticBody3D/CollisionShape3D/Pakje-1-2x2x2".set_surface_override_material(0, _mat1)
	$"StaticBody3D/CollisionShape3D/Pakje-1-2x2x2".set_surface_override_material(1, _mat2)
	
	match _color1:
		0:
			_mat1.albedo_color = Color(1.0, 0.0, 0.0)
		1:
			_mat2.albedo_color = Color(0.0, 0.6, 0.0)
		2:	
			_mat1.albedo_color = Color(0.0, 0.0, 1.0)
		3:
			_mat1.albedo_color = Color(0.5, 0.0, 0.7)
		4:
			_mat1.albedo_color = Color(1.0, 0.8, 0.0)
		5:
			_mat1.albedo_color = Color(1.0, 1.0, 1.0)
	
	match _color2:
		0:
			_mat2.albedo_color = Color(1.0, 0.0, 0.0)
		1:
			_mat2.albedo_color = Color(0.0, 0.6, 0.0)
		2:	
			_mat2.albedo_color = Color(0.0, 0.0, 1.0)
		3:
			_mat2.albedo_color = Color(0.5, 0.0, 0.7)
		4:
			_mat2.albedo_color = Color(1.0, 0.8, 0.0)
		5:
			_mat2.albedo_color = Color(1.0, 1.0, 1.0)
