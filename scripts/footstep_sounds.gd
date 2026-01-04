extends AudioStreamPlayer

@export var footstep_delay : float = 0.5
@export var material_links : Dictionary[Material, AudioStreamRandomizer]

@export var misc_footsteps : AudioStreamRandomizer

var _selected_stream : AudioStreamRandomizer

var _timer : float = 0.0
var is_walking : bool = false
var timer_mult : float = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_walking and %floor_ray.is_colliding() and get_parent().is_on_floor():
		_timer += delta * timer_mult
		
	if !get_parent().is_on_floor():
		_timer = 0.0
	
	if _timer >= footstep_delay and get_parent().is_on_floor():
		_play_sound()
		_timer = 0
	
	if %floor_ray.is_colliding():
		var _mat : Material
		
		#print(%floor_ray.get_collider(), %floor_ray.get_collider().get_parent())
		
		if %floor_ray.get_collider().get_parent() is MeshInstance3D:
			_mat = %floor_ray.get_collider().get_parent().get_active_material(0)
		elif Utility.get_children_of_type(%floor_ray.get_collider(), "MeshInstance3D").size() != 0:
			_mat = Utility.get_children_of_type(%floor_ray.get_collider(), "MeshInstance3D")[0].get_active_material(0)
		else:
			_selected_stream = misc_footsteps
			return
		
		#print(_mat.resource_path, material_links.has(_mat))
		if !material_links.has(_mat):
			_selected_stream = misc_footsteps
			return
		
		_selected_stream = material_links[_mat]

func _play_sound() -> void:
	stream = _selected_stream
	play()
