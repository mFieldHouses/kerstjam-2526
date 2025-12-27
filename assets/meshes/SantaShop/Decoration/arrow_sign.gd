extends Node3D
class_name ArrowSignChase

@export var lamp_prefix := "SignLamp-"
@export_range(1, 64, 1) var lamp_count := 8
@export var surface_index := 0

@export_group("Timing")
@export var fade_in_time := 0.15
@export var step_delay := 0.08
@export var hold_time := 0.10
@export var fade_out_time := 0.20

@export_group("Intensity")
@export var intensity := 6.0
@export var min_intensity := 0.0

@export_group("Behavior")
@export var loop := true
@export var fade_out_sequential := false

var _lamps: Array[MeshInstance3D] = []
var _mats: Array[StandardMaterial3D] = []
var _running := false

func _ready() -> void:
	_collect_lamps()
	#print("ArrowSignChase: gevonden lamps = ", _lamps.size())

	_prepare_unique_materials()
	#print("ArrowSignChase: voorbereid mats = ", _mats.size())

	if _mats.is_empty():
		push_warning("Geen lamp-materials gevonden (check names/surface_index/material type).")
		return

	_set_all_emission(min_intensity)

	_running = true
	call_deferred("_run_sequence")

func _exit_tree() -> void:
	_running = false

func _collect_lamps() -> void:
	_lamps.clear()
	for i in range(1, lamp_count + 1):
		var n := get_node_or_null(lamp_prefix + str(i))
		if n == null:
			push_warning("Lamp ontbreekt: " + lamp_prefix + str(i))
			continue
		if n is MeshInstance3D:
			_lamps.append(n)
		else:
			var mi := _find_first_meshinstance(n)
			if mi != null:
				_lamps.append(mi)
			else:
				push_warning("Geen MeshInstance3D gevonden onder: " + n.name)

func _find_first_meshinstance(root: Node) -> MeshInstance3D:
	for c in root.get_children():
		if c is MeshInstance3D:
			return c
		var deeper := _find_first_meshinstance(c)
		if deeper != null:
			return deeper
	return null

func _prepare_unique_materials() -> void:
	_mats.clear()
	for lamp in _lamps:
		var mat: Material = lamp.get_surface_override_material(surface_index)
		if mat == null and lamp.mesh != null:
			mat = lamp.mesh.surface_get_material(surface_index)
		if mat == null:
			push_warning("Geen material op %s surface %d" % [lamp.name, surface_index])
			continue

		var unique := mat.duplicate(true)
		lamp.set_surface_override_material(surface_index, unique)

		if unique is StandardMaterial3D:
			var sm := unique as StandardMaterial3D
			sm.emission_enabled = true
			_mats.append(sm)
		else:
			push_warning("Material is geen StandardMaterial3D op %s (%s)" % [lamp.name, unique.get_class()])

func _set_all_emission(value: float) -> void:
	for sm in _mats:
		sm.emission_energy_multiplier = value

func _tween_emission(sm: StandardMaterial3D, from_val: float, to_val: float, time: float) -> void:
	if time <= 0.0:
		sm.emission_energy_multiplier = to_val
		return
	var t := create_tween()
	t.tween_method(func(v: float) -> void:
		sm.emission_energy_multiplier = v,
		from_val, to_val, time
	)

func _run_sequence() -> void:
	while _running:
		_set_all_emission(min_intensity)

		for i in range(_mats.size()):
			_tween_emission(_mats[i], min_intensity, intensity, fade_in_time)
			await get_tree().create_timer(step_delay).timeout

		if hold_time > 0.0:
			await get_tree().create_timer(hold_time).timeout

		if fade_out_sequential:
			for i in range(_mats.size()):
				_tween_emission(_mats[i], intensity, min_intensity, fade_out_time)
				await get_tree().create_timer(step_delay).timeout
		else:
			for sm in _mats:
				_tween_emission(sm, intensity, min_intensity, fade_out_time)
			await get_tree().create_timer(max(fade_out_time, 0.001)).timeout

		if not loop:
			break
