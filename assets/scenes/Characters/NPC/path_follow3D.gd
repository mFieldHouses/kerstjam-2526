extends CharacterBody3D

# ------------------------------------------------------------
# NPCFollowPathSmooth.gd
#
# Strak en smooth volgen van een Path3D curve (baked sampling).
# - Continous offset in meters, geen waypoint hops
# - Collisions via move_and_slide()
# - Kijkt vooruit langs de curve (lookahead)
#
# Attach: CharacterBody3D
# Inspector:
#   - assign 'path' (Path3D)
# ------------------------------------------------------------

@export var path: Path3D

@export var speed_mps: float = 1.3
@export var gravity: float = 18.0

@export var loop_path: bool = true

# Hoe ver vooruit hij “kijkt” op de curve (meters)
@export var lookahead_meters: float = 0.8

# Hoe snel hij bijdraait richting lookahead
@export var turn_speed: float = 10.0

# Hoe strak hij naar het pad corrigeert (0..1). Hoger = strakker maar kan stug voelen.
@export var steer_strength: float = 1.0

# Start altijd op begin van pad en zet NPC daar ook neer
@export var snap_to_path_start_on_ready: bool = true

var _offset: float = 0.0
var _path_length: float = 0.0

func _ready() -> void:
	if path == null or path.curve == null:
		push_warning("NPCFollowPathSmooth: Path3D not assigned or curve missing.")
		return

	_path_length = path.curve.get_baked_length()
	if _path_length <= 0.001:
		push_warning("NPCFollowPathSmooth: Path length is 0. Check curve / bake.")
		return

	_offset = 0.0

	if snap_to_path_start_on_ready:
		var p0_local := path.curve.sample_baked(0.0)
		global_position = path.to_global(p0_local)

func _physics_process(delta: float) -> void:
	if path == null or path.curve == null or _path_length <= 0.001:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# 1) Offset loopt continu vooruit
	_offset += speed_mps * delta
	if loop_path:
		_offset = fposmod(_offset, _path_length)
	else:
		_offset = clamp(_offset, 0.0, _path_length)

	# 2) Target op de curve (world)
	var target_local := path.curve.sample_baked(_offset)
	var target_world := path.to_global(target_local)

	# 3) Richting naar target (XZ)
	var to_target := target_world - global_position
	to_target.y = 0.0

	# Als we heel dicht bij target zijn kan to_target ~ 0 worden.
	# Dan kijken we alvast naar lookahead.
	var look_offset := _offset + lookahead_meters
	if loop_path:
		look_offset = fposmod(look_offset, _path_length)
	else:
		look_offset = clamp(look_offset, 0.0, _path_length)

	var look_world := path.to_global(path.curve.sample_baked(look_offset))
	var to_look := look_world - global_position
	to_look.y = 0.0

	# 4) Sturen: combineer "naar target" met "vooruit kijken" voor stabiliteit
	var desired_dir := Vector3.ZERO
	if to_look.length() > 0.001:
		desired_dir = to_look.normalized()
	elif to_target.length() > 0.001:
		desired_dir = to_target.normalized()

	# 5) Bewegen met collisions (strakheid via steer_strength)
	# steer_strength=1: volledig richting desired_dir
	# lager: meer behoud van huidige velocity richting (soms natuurlijker)
	var current_h := Vector3(velocity.x, 0.0, velocity.z)
	var desired_h := desired_dir * speed_mps
	var blended := current_h.lerp(desired_h, clamp(steer_strength, 0.0, 1.0))

	velocity.x = blended.x
	velocity.z = blended.z

	move_and_slide()

	# 6) Kijken naar lookahead (altijd "ziet" waar hij heen loopt)
	if to_look.length() > 0.001:
		var desired_yaw := atan2(-to_look.x, -to_look.z) # Godot forward = -Z
		rotation.y = lerp_angle(rotation.y, desired_yaw, clamp(turn_speed * delta, 0.0, 1.0))
