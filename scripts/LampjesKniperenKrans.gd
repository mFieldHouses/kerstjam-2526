extends Node

## LampjesRandomColors
## Attach dit script aan de parent node "Lampjes".
## Het script zoekt (recursief) MeshInstance3D/GeometryInstance3D children en wisselt hun kleur random.
##
## USAGE:
## 1) Attach aan node: Lampjes
## 2) Zorg dat je lampjes meshes een materiaal hebben op surface 0
## 3) Stel in Inspector je `colors`, `interval_min/max` en `target` in
##
## Notes:
## - Materiaal wordt per lampje uniek gemaakt (duplicate) zodat instances niet elkaar beïnvloeden.

enum ColorTarget { ALBEDO, EMISSION }

@export var colors: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE]
@export var interval_min: float = 0.15
@export var interval_max: float = 0.6
@export var target: ColorTarget = ColorTarget.ALBEDO
@export var include_children_recursive: bool = true
@export var independent_timing: bool = true
@export var material_index: int = 1

# Optioneel: zet lampjes in een group (bv "lampje") en vul dit in.
# Leeg = alles meenemen
@export var required_group: StringName = &""

class LampEntry:
	var node: GeometryInstance3D
	var mat: Material
	var t: float = 0.0
	var next: float = 0.0

	func _init(n: GeometryInstance3D, m: Material, next_time: float) -> void:
		node = n
		mat = m
		next = next_time

var _lamps: Array[LampEntry] = []

func _ready() -> void:
	randomize()

	if colors.is_empty():
		push_warning("[LampjesRandomColors] colors is leeg. Voeg kleuren toe in de Inspector.")
		return

	if interval_max < interval_min:
		var tmp := interval_min
		interval_min = interval_max
		interval_max = tmp

	_lamps.clear()

	var nodes: Array[Node] = []
	if include_children_recursive:
		nodes = _collect_nodes(self)
	else:
		for c in get_children():
			nodes.append(c)

	for n in nodes:
		if required_group != &"" and not n.is_in_group(required_group):
			continue

		var entry := _try_bind_lamp(n)
		if entry != null:
			_lamps.append(entry)

	if _lamps.is_empty():
		push_warning("[LampjesRandomColors] Geen lampjes gevonden met materiaal op surface 0 (GeometryInstance3D).")
		return

	# Start direct met kleur
	for e in _lamps:
		_apply_random_color(e)

func _process(delta: float) -> void:
	if _lamps.is_empty():
		return

	if independent_timing:
		for e in _lamps:
			e.t += delta
			if e.t >= e.next:
				e.t = 0.0
				e.next = randf_range(interval_min, interval_max)
				_apply_random_color(e)
	else:
		# sync knipperen
		_lamps[0].t += delta
		if _lamps[0].t >= _lamps[0].next:
			_lamps[0].t = 0.0
			_lamps[0].next = randf_range(interval_min, interval_max)
			for e in _lamps:
				_apply_random_color(e)

# -------------------------
# Internals
# -------------------------

func _collect_nodes(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	for c in root.get_children():
		out.append(c)
		out.append_array(_collect_nodes(c))
	return out

func _try_bind_lamp(n: Node) -> LampEntry:
	if n is GeometryInstance3D:
		var gi := n as GeometryInstance3D

		var base_mat: Material = gi.get_active_material(material_index)
		if base_mat == null:
			return null

		var unique_mat: Material = base_mat.duplicate()
		gi.set_surface_override_material(material_index, unique_mat)

		return LampEntry.new(gi, unique_mat, randf_range(interval_min, interval_max))

	return null



func _apply_random_color(e: LampEntry) -> void:
	var c: Color = colors.pick_random()
	var mat: Material = e.mat
	if mat == null:
		return

	if mat is StandardMaterial3D:
		var sm := mat as StandardMaterial3D
		match target:
			ColorTarget.ALBEDO:
				sm.albedo_color = c
			ColorTarget.EMISSION:
				sm.emission_enabled = true
				sm.emission = c

	elif mat is ShaderMaterial:
		var sh := mat as ShaderMaterial
		# Pas hier je shader param naam aan als jij iets als "u_color" gebruikt
		if sh.shader != null:
			# Veel voorkomende namen
			if sh.get_shader_parameter("albedo_color") != null:
				sh.set_shader_parameter("albedo_color", c)
			elif sh.get_shader_parameter("color") != null:
				sh.set_shader_parameter("color", c)
			elif sh.get_shader_parameter("u_color") != null:
				sh.set_shader_parameter("u_color", c)
