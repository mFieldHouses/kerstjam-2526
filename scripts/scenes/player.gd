extends CharacterBody3D
class_name Player

# CONFIG -------------------

const SPEED = 3.5
const SPRINT_SPEED_DELTA = 2.0
const JUMP_VELOCITY = 4.5

var _health : float = 30.0:
	set(x):
		_health = x
		if _health <= 0.0:
			_die()
var _max_health : float = 30.0

@export var step_height : float = 0.3

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

var _shoot_button_held : bool = false

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

var _ammo : Dictionary[AmmoItemDescription, int] = {
	preload("res://assets/resources/items/ammo/snow.tres") : 100,
	preload("res://assets/resources/items/ammo/fast.tres") : 100,
	preload("res://assets/resources/items/ammo/big.tres") : 100,
	preload("res://assets/resources/items/ammo/explode.tres") : 100
	}
@onready var _used_ammo : AmmoItemDescription = load("res://assets/resources/items/ammo/snow.tres")

@onready var camera : Camera3D = get_node("camera")
@onready var crosshair_sprite : TextureRect = $gui/CenterContainer/crosshair
@onready var shoot_ray : RayCast3D = $camera/shoot_ray
@onready var enemy_ray : RayCast3D = $camera/enemy_ray

var _bobbing_anim_timer : float = 0.0

var _weapon_use_cooldown_timer : float = 0.0

var _auto_gun_timer : float = 0.0

func _ready():
	
	PlayerState.player_instance = self
	DisplayManager.set_mouse_captured()
	
	camera.fov = ConfigurableValues.fov
	
	_ammo = PlayerState.ammo.duplicate()
	_health = PlayerState.health
	
	_update_ammo_gui(0)

func _physics_process(delta: float) -> void:
	_update_ammo_counts()
	
	_weapon_selection_scroll_timer += delta
	if _weapon_selection_scroll_timer >= _weapon_selection_scroll_timeout_time:
		_weapon_selection_scroll_counter = 0
	
	_weapon_use_cooldown_timer -= delta
	
	$gui/MarginContainer/health_left.text = str(roundi(_health)) + "/30"
	$gui._health_shake_fac = clamp(1.0 - (_health / 12.0), 0.0, 1.0)
	#$gui.size = get_viewport().size
	
	# Add the gravity.
	if not is_on_floor() and flight == false:
		velocity += get_gravity() * delta
	else:
		camera_time += delta

	# Handle jump.
	if Input.is_action_pressed("jump") and controls_enabled:
		if flight:
			position.y += delta * 20
		else:
			if is_on_floor() and controls_enabled:
				velocity.y = JUMP_VELOCITY

	_auto_gun_timer -= delta
	
	if _used_ammo.automatic == true:
		if Input.is_action_pressed("shoot") and _selected_weapon_idx == 0 and _ammo[_used_ammo] > 0 and controls_enabled:
			if _auto_gun_timer < 0.0:
				shoot()
				_auto_gun_timer = _used_ammo.shoot_delay
	
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
			#if sprinting:
				#tween_camera_fov(DEFAULT_FOV + 20, 0.2)
			#else:
				#tween_camera_fov(DEFAULT_FOV, 0.2)
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
	
	if controls_enabled:
		camera.rotation.x = lerp(previous_camera_rotation_x, desired_camera_rotation_x, 0.5)
		rotation.y = lerp(previous_camera_rotation_y, desired_camera_rotation_y, 0.5)
		
	#camera bobbing
	#camera.position.x = (sin(camera_time * (13 + (int(sprinting) * 4))) * ((int(sprinting) * 0.02) + 0.02)) * int(Input.is_action_pressed("forward"))
	#camera.position.y = 0.775 + (sin(camera_time * 16) * (int(sprinting) * 0.02) + 0.02)
	#
	previous_camera_rotation_x = camera.rotation.x
	previous_camera_rotation_y = rotation.y
	
	$gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera.global_rotation.y = camera.global_rotation.y
	
	$CollisionShape3D/step_ray.global_position = Vector3(velocity.x, 0.5, velocity.z).normalized() * 0.4 + $CollisionShape3D.global_position
	if $CollisionShape3D/step_ray.get_collision_point() and $CollisionShape3D/step_ray.get_collider():
		var _colpoint : Vector3 = $CollisionShape3D/step_ray.get_collision_point()
		var _angle_to_up : float = Vector3.UP.angle_to($CollisionShape3D/step_ray.get_collision_normal())
		#print(_angle_to_up / PI)
		if _colpoint.y > global_position.y and _colpoint.y - global_position.y <= step_height and _angle_to_up < 0.05 * PI and is_on_floor():
			global_position.y = _colpoint.y
	
	if !noclip:
		var collision = move_and_slide()
	
	if enemy_ray.get_collider():
		crosshair_sprite.modulate.a = 1.0
		crosshair_sprite.custom_minimum_size = Vector2(25, 25)
	else:
		crosshair_sprite.modulate.a = 0.5
		crosshair_sprite.custom_minimum_size = Vector2(20, 20)

func sleep(): #Disables everything about the player except for idle animations.
	controls_enabled = false

func awaken(): #Re-enables everything disabled by sleep().
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
				tween_camera_fov(ConfigurableValues.fov * 1.3, 0.2)
			else:
				sprinting = false
				tween_camera_fov(ConfigurableValues.fov, 0.2)
		
		elif event.is_action("shoot"):
			if event.is_pressed() and (_used_ammo.automatic == false or _selected_weapon_idx != 0) and _ammo[_used_ammo] > 0:
				if _weapon_use_cooldown_timer <= 0.0 and (_auto_gun_timer <= 0.0 or _selected_weapon_idx != 0):
					shoot()
		
		elif event.is_action("scope") and _get_currently_selected_weapon().scopeable:
			toggle_scope_mode(event.is_pressed())
		
		elif event.is_action("toggle_flashlight") and event.is_pressed():
			$camera/flashlight.visible = !$camera/flashlight.visible
		
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
		
		elif event is InputEventKey and event.is_pressed():
			match event.keycode:
				KEY_1:
					_used_ammo = preload("res://assets/resources/items/ammo/fast.tres")
					_update_ammo_gui(0)
				KEY_2:
					_used_ammo = preload("res://assets/resources/items/ammo/big.tres")
					_update_ammo_gui(1)
				KEY_3:
					_used_ammo = preload("res://assets/resources/items/ammo/explode.tres")
					_update_ammo_gui(2)
				KEY_4:
					_used_ammo = preload("res://assets/resources/items/ammo/snow.tres")
					_update_ammo_gui(3)
			 

func _update_ammo_gui(selected_idx : int) -> void:
	var _idx : int = 0
	for _child in $gui/ammo_left.get_children():
		if _idx == selected_idx:
			_child.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			_child.modulate = Color(1.0, 1.0, 1.0, 0.3)
		
		_idx += 1

func _update_ammo_counts() -> void:
	for _child in $gui/ammo_left.get_children():
		var _ammo_id : String = _child.name
		_child.get_node("amount").text = str(_ammo[load("res://assets/resources/items/ammo/" + _ammo_id + ".tres") as AmmoItemDescription])

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
		tween_camera_fov(ConfigurableValues.fov * 0.2, 0.2)
		sensitivity_multiplier = sensitivity_multipliers["in_scope"]
		speed_multiplier = speed_multipliers["in_scope"]
	else:
		tween_camera_fov(ConfigurableValues.fov, 0.2)
		sensitivity_multiplier = sensitivity_multipliers["default"]
		speed_multiplier = speed_multipliers["default"]
		
		if Input.is_action_pressed("sprint"):
			sprinting = true
			tween_camera_fov(ConfigurableValues.fov + 8, 0.2)

func get_hit(damage : float) -> void:
	_health -= damage
	$gui._dmg_animation()
	

func shoot() -> void:
	
	if _selected_weapon_idx == 0:
		%gun_sounds.stream = _used_ammo.shoot_audio_stream
		
		if _used_ammo.ammo_type_identifier == "snow":
			%gun_sounds.pitch_scale = 3.0
			%gun_sounds.play(0.1)
		else:
			%gun_sounds.pitch_scale = 1.0
			%gun_sounds.play()
	
	_ammo[_used_ammo] -= 1
	var _used_weapon : WeaponConfiguration = _get_currently_selected_weapon()
	_weapon_use_cooldown_timer = _get_currently_selected_weapon().weapon_use_cooldown
	if _used_ammo.automatic == false:
		_auto_gun_timer = _used_ammo.shoot_delay
		$gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera/gun_grip.play_shoot_animation("Plane_001Action_001")
	else:
		$gui/weapon_viewport/SubViewport/Node3D/weapon_viewport_camera/gun_grip.play_shoot_animation("Plane_001Action")

	await get_tree().create_timer(_used_weapon.hit_delay).timeout
	
	if _used_ammo.ammo_type_identifier == "snow" and _selected_weapon_idx == 0:
		var _new_snowball : Snowball = load("res://scenes/projectiles/snowball.tscn").instantiate()
		get_parent().add_child(_new_snowball)
		
		_new_snowball.position = $camera.global_position - $camera.global_basis.z
		_new_snowball.velocity = -$camera.global_basis.z * 20
		return
		
	elif _used_ammo.ammo_type_identifier == "explode" and _selected_weapon_idx == 0:
		var _new_penguin : ExplosivePenguin = load("res://scenes/projectiles/explosive_penguin.tscn").instantiate()
		get_parent().add_child(_new_penguin)
		
		_new_penguin.position = $camera.global_position - $camera.global_basis.z
		_new_penguin.velocity = -$camera.global_basis.z * 30
		return
	
	var _shot_collider = shoot_ray.get_collider()
	if _shot_collider:
		var _hit_effect : CPUParticles3D = _get_currently_selected_weapon().hit_particle_effect_scene.instantiate()
		_hit_effect.top_level = true
		add_child(_hit_effect)
		_hit_effect.global_position = shoot_ray.get_collision_point()
		
		if _shot_collider is Enemy or _shot_collider is Hittable or _shot_collider is Snowman or _shot_collider is SnowmanSegment or _shot_collider is JumpingMimic:
			var _dmg = _used_ammo.get_damage()
			_shot_collider.hit(_dmg, shoot_ray.get_collision_point(), 1)
			HitMarkerManager.hit_at(shoot_ray.get_collision_point(), _dmg, preload("res://scenes/particle_effects/santa_gun_hit_standard.tscn"), get_parent())

func _die() -> void:
	DisplayManager.set_mouse_captured(false)
	$gui._die_prompt()
	#_health = 0.0
	PlayerState.toggle_sleep(true)
	get_tree().set_deferred("paused", true)

func get_distance_to_player(point : Vector3): ##Returns the distance between the player and said point.
	return (global_position - point).length()

func _get_currently_selected_weapon() -> WeaponConfiguration:
	return PlayerState.weapons[_selected_weapon_idx]
