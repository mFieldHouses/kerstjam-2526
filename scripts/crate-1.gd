@tool
extends Node3D
class_name CrateOptions

@export_group("Lid")
@export var enable_lid: bool = true : set = _set_enable_lid
@export var randomize_lid_y_rotation: bool = false : set = _set_randomize_lid_y_rotation
@export_range(0.0, 360.0, 0.1) var random_y_min_deg: float = 0.0
@export_range(0.0, 360.0, 0.1) var random_y_max_deg: float = 360.0

@export_group("Snow")
@export var enable_snow_material: bool = false : set = _set_enable_snow_material
@export var snow_material: Material
@export var restore_original_materials_on_disable: bool = true

const LID_NODE_NAME := "Crate-Lid-1"
const SNOW_TARGETS_GROUP := "snow_targets"

var _lid: Node3D = null
var _original_materials := {}  # Dictionary

func _enter_tree() -> void:
	# In editor is dit betrouwbaarder dan alleen _ready()
	call_deferred("_refresh")

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	randomize()
	_lid = _find_descendant_node3d_by_name(self, LID_NODE_NAME)
	_apply_lid_state()
	_apply_snow_state()

func _set_enable_lid(v: bool) -> void:
	enable_lid = v
	if is_inside_tree():
		_apply_lid_state()

func _set_randomize_lid_y_rotation(v: bool) -> void:
	randomize_lid_y_rotation = v
	if is_inside_tree():
		_apply_lid_state()

func _set_enable_snow_material(v: bool) -> void:
	enable_snow_material = v
	if is_inside_tree():
		_apply_snow_state()

func _apply_lid_state() -> void:
	# Als we 'm nog niet hebben, probeer nog een keer (handig bij editor refresh)
	if _lid == null:
		_lid = _find_descendant_node3d_by_name(self, LID_NODE_NAME)

	if _lid == null:
		if !Engine.is_editor_hint():
			push_warning("[CrateOptions] Lid node not found anywhere under '%s' (looking for '%s')" % [name, LID_NODE_NAME])
		return

	_lid.visible = enable_lid

	if enable_lid and randomize_lid_y_rotation:
		var deg := randf_range(min(random_y_min_deg, random_y_max_deg), max(random_y_min_deg, random_y_max_deg))
		_lid.rotation.y = deg_to_rad(deg)

func _apply_snow_state() -> void:
	if enable_snow_material and snow_material == null:
		if !Engine.is_editor_hint():
			push_warning("[CrateOptions] Snow enabled but snow_material not assigned on %s" % name)
		return

	var meshes := _get_snow_target_meshes()

	if enable_snow_material:
		for mi in meshes:
			_store_originals_if_needed(mi)
			_apply_material_to_all_surfaces(mi, snow_material)
	else:
		if restore_original_materials_on_disable:
			for mi in meshes:
				_restore_originals(mi)

func _get_snow_target_meshes() -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []

	var grouped := get_tree().get_nodes_in_group(SNOW_TARGETS_GROUP)
	for n in grouped:
		if n is MeshInstance3D and is_ancestor_of(n):
			out.append(n)

	if out.is_empty():
		out = _get_descendant_meshes(self)

	return out

func _get_descendant_meshes(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for c in root.get_children():
		if c is MeshInstance3D:
			result.append(c)
		if c.get_child_count() > 0:
			result.append_array(_get_descendant_meshes(c))
	return result

func _find_descendant_node3d_by_name(root: Node, target_name: String) -> Node3D:
	for c in root.get_children():
		if c is Node3D and c.name == target_name:
			return c
		if c.get_child_count() > 0:
			var found := _find_descendant_node3d_by_name(c, target_name)
			if found != null:
				return found
	return null

func _store_originals_if_needed(mi: MeshInstance3D) -> void:
	if _original_materials.has(mi) or mi.mesh == null:
		return

	var originals: Array[Material] = []
	var surfaces := mi.mesh.get_surface_count()
	originals.resize(surfaces)

	for i in surfaces:
		var mat := mi.get_surface_override_material(i)
		if mat == null:
			mat = mi.mesh.surface_get_material(i)
		originals[i] = mat

	_original_materials[mi] = originals

func _apply_material_to_all_surfaces(mi: MeshInstance3D, mat: Material) -> void:
	if mi.mesh == null:
		return
	var surfaces := mi.mesh.get_surface_count()
	for i in surfaces:
		mi.set_surface_override_material(i, mat)

func _restore_originals(mi: MeshInstance3D) -> void:
	if !_original_materials.has(mi) or mi.mesh == null:
		return

	var originals: Array = _original_materials[mi]
	var surfaces := mi.mesh.get_surface_count()
	for i in surfaces:
		var mat: Material = null
		if i < originals.size():
			mat = originals[i]
		mi.set_surface_override_material(i, mat)
