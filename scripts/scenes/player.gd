extends CharacterBody3D
class_name Player

# CONFIG -------------------

const SPEED = 3.5
const SPRINT_SPEED_DELTA = 2.0
const JUMP_VELOCITY = 4.5

const DEFAULT_FOV = 75

var sensitivity_multipliers : Dictionary[String, float] = {
	"default" : 1.0,
	"in_scope" : 0.5
}

var speed_multipliers : Dictionary[String, float] = {
	"default": 1.0,
	"in_scope": 0.6
}

# END CONFIG -------------------

var sensitivity_multiplier : float = 1.0
var speed_multiplier : float = 1.0

var sprinting : bool = false
var in_scope : bool = false

var camera_offset_x : float = 0.0
var camera_offset_y : float = 0.0

var camera_time : float = 0.0

var camera_offset_scale : float = 1.0

var desired_camera_rotation_x : float = 0
var desired_camera_rotation_y : float = 0

var previous_camera_rotation_x : float = 0
var previous_camera_rotation_y : float = 0

var flight : bool = false
var noclip : bool = false
var freecam : bool = false
var controls_enabled : bool = true

var _selected_weapon_idx : int = 0:
	set(x):
		x = clamp(x, 0, PlayerState.weapons.size() - 1)
		var _model_children = Utility.get_children_of_type($gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera/gun_grip, "Node3D")
		_model_children[_selected_weapon_idx].visible = false
		_model_children[x].visible = true
		_selected_weapon_idx = x
		
		_apply_reach(PlayerState.weapons[x].reach)
		if !_get_currently_selected_weapon().scopeable:
			toggle_scope_mode(false)
		
const _weapon_selection_scroll_step : int = 2 #The amount of scroll events it takes to make the game register one "step"/select a different weapon.
var _weapon_selection_scroll_counter : int = 0
var _weapon_selection_scroll_timer : float = 0.0 #When this reaches the value of _weapon_selection_scroll_timeout_time, _weapon_selection_scroll_counter is set back to 0.
var _weapon_selection_scroll_timeout_time : float = 0.4

@onready var camera : Camera3D = get_node("camera")
@onready var crosshair_sprite : TextureRect = $gui/CenterContainer/crosshair
@onready var shoot_ray : RayCast3D = $camera/shoot_ray
@onready var enemy_ray : RayCast3D = $camera/enemy_ray

var _bobbing_anim_timer : float = 0.0

var _weapon_use_cooldown_timer : float = 0.0

func _ready():
	
	PlayerState.player_instance = self
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	_weapon_selection_scroll_timer += delta
	if _weapon_selection_scroll_timer >= _weapon_selection_scroll_timeout_time:
		_weapon_selection_scroll_counter = 0
	
	_weapon_use_cooldown_timer -= delta
	
	# Add the gravity.
	if not is_on_floor() and flight == false:
		velocity += get_gravity() * delta
	else:
		camera_time += delta

	# Handle jump.
	if Input.is_action_pressed("jump"):
		if flight:
			position.y += delta * 20
		else:
			if is_on_floor() and controls_enabled:
				velocity.y = JUMP_VELOCITY
	
	if Input.is_key_pressed(KEY_CTRL) and flight:
		position.y -= delta * 20

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if freecam:
		camera.global_position += camera.global_transform.basis.z * input_dir.y * delta * 20
		camera.global_position += camera.global_transform.basis.x * input_dir.x * delta * 20
	elif flight:
		position += camera.global_transform.basis.z * input_dir.y * delta * 20
		position += camera.global_transform.basis.x * input_dir.x * delta * 20
		#position.x += direction.x * delta * 20
		#position.y += camera.transform.basis.z.y * delta * input_dir.y * 20
		#position.z += direction.z * delta * 20
	else:
		if direction and controls_enabled:
			_bobbing_anim_timer += delta + (float(sprinting == true) * delta)
			$gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera/gun_grip.bob(_bobbing_anim_timer, 0.7 + (float(sprinting == true) * 0.4))
			velocity.x = lerp(velocity.x, direction.x * SPEED * speed_multiplier + (direction.x * SPRINT_SPEED_DELTA * int(sprinting)), 0.3)
			velocity.z = lerp(velocity.z, direction.z * SPEED * speed_multiplier + (direction.z * SPRINT_SPEED_DELTA * int(sprinting)), 0.3)
		else:
			_bobbing_anim_timer = 0
			$gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera/gun_grip.return_to_origin()
			velocity.x *= 0.8
			velocity.z *= 0.8
	
	var velocity_vector_length = Vector2(velocity.x, velocity.z).length()
	
	camera.rotation.x = lerp(previous_camera_rotation_x, desired_camera_rotation_x, 0.5)
	rotation.y = lerp(previous_camera_rotation_y, desired_camera_rotation_y, 0.5)
	
	#camera bobbing
	#camera.position.x = (sin(camera_time * (13 + (int(sprinting) * 4))) * ((int(sprinting) * 0.02) + 0.02)) * int(Input.is_action_pressed("forward"))
	#camera.position.y = 0.775 + (sin(camera_time * 16) * (int(sprinting) * 0.02) + 0.02)
	#
	previous_camera_rotation_x = camera.rotation.x
	previous_camera_rotation_y = rotation.y
	
	$gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera.global_rotation.y = camera.global_rotation.y
	
	if !noclip:
		var collision = move_and_slide()
	
	if enemy_ray.get_collider():
		crosshair_sprite.modulate.a = 1.0
		crosshair_sprite.custom_minimum_size = Vector2(25, 25)
	else:
		crosshair_sprite.modulate.a = 0.5
		crosshair_sprite.custom_minimum_size = Vector2(20, 20)

func sleep(): #Disables everything about the player except for idle animations.
	$first_person_camera/layer_1.enabled = false
	$first_person_camera/layer_5.enabled = false
	controls_enabled = false

func awaken(): #Re-enables everything disabled by sleep().
	$first_person_camera/layer_1.enabled = true
	$first_person_camera/layer_5.enabled = true
	controls_enabled = true

func toggle_flight(state : bool = true, collision : bool = false):
	velocity = Vector3.ZERO
	flight = state
	noclip = !collision

func toggle_freecam(state : bool = true):
	freecam = state

func _input(event):
	if controls_enabled:
		if event is InputEventMouseMotion:
			desired_camera_rotation_x += (event.relative.y / -2000*PI) * sensitivity_multiplier * ConfigurableValues.mouse_sensitivity
			desired_camera_rotation_x = clamp(desired_camera_rotation_x, -0.5 * PI, 0.5 * PI)
			desired_camera_rotation_y += (event.relative.x / -2000*PI) * sensitivity_multiplier * ConfigurableValues.mouse_sensitivity
		
		if event.is_action("sprint") and !in_scope:
			if event.is_pressed():
				sprinting = true
				tween_camera_fov(DEFAULT_FOV + 20, 0.2)
			else:
				sprinting = false
				tween_camera_fov(DEFAULT_FOV, 0.2)
		
		elif event.is_action("shoot") and event.is_pressed() and _weapon_use_cooldown_timer <= 0.0:
			shoot()
		
		elif event.is_action("scope") and _get_currently_selected_weapon().scopeable:
			toggle_scope_mode(event.is_pressed())
		
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_weapon_selection_scroll_counter += 1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: 
				_weapon_selection_scroll_counter -= 1
			
			if _weapon_selection_scroll_counter >= _weapon_selection_scroll_step:
				_selected_weapon_idx += 1
				_weapon_selection_scroll_counter = 0
			elif _weapon_selection_scroll_counter <= -_weapon_selection_scroll_step:
				_selected_weapon_idx -= 1
				_weapon_selection_scroll_counter = 0
			

func tween_camera_fov(desired_fov : float, time : float):
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "fov", desired_fov, time)

func _apply_reach(reach : float) -> void:
	shoot_ray.target_position = Vector3(0.0, 0.0, -reach)
	enemy_ray.target_position = Vector3(0.0, 0.0, -reach)

func toggle_scope_mode(state : bool) -> void:
	sprinting = false
	in_scope = state
	
	if state:
		tween_camera_fov(DEFAULT_FOV - 50, 0.2)
		sensitivity_multiplier = sensitivity_multipliers["in_scope"]
		speed_multiplier = speed_multipliers["in_scope"]
	else:
		tween_camera_fov(DEFAULT_FOV, 0.2)
		sensitivity_multiplier = sensitivity_multipliers["default"]
		speed_multiplier = speed_multipliers["default"]
		
		if Input.is_action_pressed("sprint"):
			sprinting = true
			tween_camera_fov(DEFAULT_FOV + 20, 0.2)

func shoot() -> void:
	var _used_weapon : WeaponConfiguration = _get_currently_selected_weapon()
	_weapon_use_cooldown_timer = _get_currently_selected_weapon().weapon_use_cooldown
	
	var _animplayer : AnimationPlayer = Utility.get_children_of_type($gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera/gun_grip.get_child(_selected_weapon_idx), "AnimationPlayer")[0]
	#_animplayer.play("weapon_use/shoot1")
	
	await get_tree().create_timer(_used_weapon.hit_delay).timeout
	
	var _shot_collider = shoot_ray.get_collider()
	if _shot_collider:
		var _hit_effect : CPUParticles3D = _get_currently_selected_weapon().hit_particle_effect_scene.instantiate()
		_hit_effect.top_level = true
		add_child(_hit_effect)
		_hit_effect.global_position = shoot_ray.get_collision_point()
		
		if _shot_collider is Enemy or _shot_collider is Hittable:
			_shot_collider.hit(_get_currently_selected_weapon().get_hit_damage(), global_position, 1)

func get_distance_to_player(point : Vector3): ##Returns the distance between the player and said point.
	return (global_position - point).length()

func _get_currently_selected_weapon() -> WeaponConfiguration:
	return PlayerState.weapons[_selected_weapon_idx]
