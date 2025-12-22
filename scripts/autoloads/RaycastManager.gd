extends Node3D

@onready var world_3d : World3D = get_world_3d()

func is_ray_free(from : Vector3, to : Vector3, mask : int = 1) -> bool:
	var _parameters : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	_parameters.from = from
	_parameters.to = to
	_parameters.collision_mask = mask
	
	var _result = world_3d.direct_space_state.intersect_ray(_parameters)
	
	if _result.has("collider"):
		print(_result.collider)
	print(!_result.has("collider"))
	return !_result.has("collider")
