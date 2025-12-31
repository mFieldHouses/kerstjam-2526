extends Area3D
class_name EnvironmentSwitcher

"""
USAGE / INSTALL
1) Hang dit script aan een Area3D (bij de grot-ingang).
2) Voeg een CollisionShape3D toe als child van de Area3D en schaal 'm zodat je overgang-gebied klopt.
3) Sleep in de Inspector:
   - world_env_path -> je WorldEnvironment node
   - outside_env -> je normale Environment resource (Outside.tres)
   - cave_env -> je grot Environment resource (Cave.tres)
4) Zorg dat je Player body in deze Area kan triggeren (collision layers/masks).
5) Zorg dat je Player in group "player" zit (aanrader).
6) Test: inlopen = donkerder, teruglopen = lichter.

DEBUG
- Zet debug_enabled = true om prints te zien in Output.
- Zet debug_force_extreme_values = true om het verschil overdreven zichtbaar te maken (handig om te bewijzen dat het werkt).
"""

@export var world_env_path: NodePath
@export var outside_env: Environment
@export var cave_env: Environment

@export_range(0.05, 5.0, 0.05) var transition_seconds: float = 1.0
@export var player_group_name: String = "player"

# Debug toggles
@export var debug_enabled: bool = true
@export var debug_force_extreme_values: bool = false

var _world_env: WorldEnvironment
var _tween: Tween
var _current_t: float = 0.0

# Runtime env die we continu aanpassen (zodat Outside/Cave resources intact blijven)
var _runtime_env: Environment


func _ready() -> void:
	if debug_enabled:
		print("[EnvironmentSwitcher] _ready on: ", get_path())

	_world_env = get_node_or_null(world_env_path) as WorldEnvironment
	if _world_env == null:
		push_error("EnvironmentSwitcher: world_env_path wijst niet naar een WorldEnvironment.")
		if debug_enabled:
			print("[EnvironmentSwitcher] world_env_path = ", world_env_path)
		return

	if outside_env == null or cave_env == null:
		push_error("EnvironmentSwitcher: outside_env en/of cave_env is niet ingevuld.")
		return

	# Maak een runtime copy zodat we je .tres niet aanpassen
	_runtime_env = outside_env.duplicate(true) as Environment
	_world_env.environment = _runtime_env

	# Zorg dat de Area ook echt monitort
	monitoring = true
	monitorable = true

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Start state: outside
	_apply_blend(0.0)

	if debug_enabled:
		print("[EnvironmentSwitcher] WorldEnvironment node: ", _world_env.get_path())
		print("[EnvironmentSwitcher] Monitoring: ", monitoring, " | Monitorable: ", monitorable)
		print("[EnvironmentSwitcher] Outside exposure: ", outside_env.tonemap_exposure, " | Cave exposure: ", cave_env.tonemap_exposure)
		print("[EnvironmentSwitcher] Outside ambient: ", outside_env.ambient_light_energy, " | Cave ambient: ", cave_env.ambient_light_energy)
		print("[EnvironmentSwitcher] Cave fog_enabled: ", cave_env.fog_enabled, " | Cave fog_density: ", cave_env.fog_density)


func _on_body_entered(body: Node) -> void:
	if debug_enabled:
		print("[EnvironmentSwitcher] body_entered: ", body.name, " (", body.get_class(), ") groups=", body.get_groups())

	if not _is_player(body):
		if debug_enabled:
			print("[EnvironmentSwitcher] -> ignored (not player). Tip: zet je player in group '", player_group_name, "'.")
		return

	if debug_enabled:
		print("[EnvironmentSwitcher] -> player detected, blending to CAVE (t=1.0)")

	_blend_to(1.0)


func _on_body_exited(body: Node) -> void:
	if debug_enabled:
		print("[EnvironmentSwitcher] body_exited: ", body.name, " (", body.get_class(), ")")

	if not _is_player(body):
		if debug_enabled:
			print("[EnvironmentSwitcher] -> ignored (not player)")
		return

	if debug_enabled:
		print("[EnvironmentSwitcher] -> player detected, blending to OUTSIDE (t=0.0)")

	_blend_to(0.0)


func _is_player(body: Node) -> bool:
	# Beste practice: zet je Player in group "player"
	if body.is_in_group(player_group_name):
		return true
	# Fallback: CharacterBody3D check
	return body is CharacterBody3D


func _blend_to(target_t: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
		if debug_enabled:
			print("[EnvironmentSwitcher] killed previous tween")

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)

	var start_t := _current_t
	if debug_enabled:
		print("[EnvironmentSwitcher] tween from ", start_t, " -> ", target_t, " in ", transition_seconds, "s")

	# Gebruik geen lambda (scheelt parser issues)
	_tween.tween_method(Callable(self, "_on_tween_value"), start_t, target_t, transition_seconds)


func _on_tween_value(v: float) -> void:
	_current_t = v
	_apply_blend(_current_t)

	# Debug: print alleen rond 0/0.5/1 zodat je console niet volloopt
	if debug_enabled:
		if absf(_current_t - 0.0) < 0.01 or absf(_current_t - 1.0) < 0.01 or absf(_current_t - 0.5) < 0.02:
			print("[EnvironmentSwitcher] t=", snappedf(_current_t, 0.01),
				" exposure=", snappedf(_runtime_env.tonemap_exposure, 0.01),
				" ambient=", snappedf(_runtime_env.ambient_light_energy, 0.01),
				" fog_enabled=", _runtime_env.fog_enabled)


func _apply_blend(t: float) -> void:
	if _runtime_env == null:
		if debug_enabled:
			print("[EnvironmentSwitcher] _apply_blend skipped: runtime_env is null")
		return

	# Optionele brute test: maak het verschil extreem zichtbaar zonder je .tres te wijzigen
	var out_exposure := outside_env.tonemap_exposure
	var cave_exposure := cave_env.tonemap_exposure
	var out_amb := outside_env.ambient_light_energy
	var cave_amb := cave_env.ambient_light_energy

	if debug_force_extreme_values:
		out_exposure = 1.2
		cave_exposure = 0.2
		out_amb = 1.0
		cave_amb = 0.15

	# --- Exposure (Tonemap) ---
	_runtime_env.tonemap_exposure = lerp(out_exposure, cave_exposure, t)

	# --- Ambient light ---
	_runtime_env.ambient_light_energy = lerp(out_amb, cave_amb, t)
	_runtime_env.ambient_light_color = outside_env.ambient_light_color.lerp(cave_env.ambient_light_color, t)

	# --- Fog (optioneel) ---
	var fog_should_enable := t > 0.02
	_runtime_env.fog_enabled = fog_should_enable and cave_env.fog_enabled
	_runtime_env.fog_density = lerp(outside_env.fog_density, cave_env.fog_density, t)
	_runtime_env.fog_light_color = outside_env.fog_light_color.lerp(cave_env.fog_light_color, t)
	_runtime_env.fog_sky_affect = lerp(outside_env.fog_sky_affect, cave_env.fog_sky_affect, t)
