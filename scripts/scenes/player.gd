extends CharacterBody3D
class_name Player

const SPEED = 3.5
const SPRINT_SPEED_DELTA = 2.0
const JUMP_VELOCITY = 4.5

const DEFAULT_FOV = 75

var sprinting : bool = false

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

@onready var camera : Camera3D = get_node("camera")

func _ready():
	
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	#ResourceLoader.load_threaded_get()
	
	# Add the gravity.
	if not is_on_floor() and flight == false:
		velocity += get_gravity() * delta * 2
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
			velocity.x = lerp(velocity.x, direction.x * SPEED + (direction.x * SPRINT_SPEED_DELTA * int(sprinting)), 0.3)
			velocity.z = lerp(velocity.z, direction.z * SPEED + (direction.z * SPRINT_SPEED_DELTA * int(sprinting)), 0.3)
		else:
			velocity.x *= 0.8
			velocity.z *= 0.8
	
	var velocity_vector_length = Vector2(velocity.x, velocity.z).length()
	
	camera.rotation.x = lerp(previous_camera_rotation_x, desired_camera_rotation_x, 0.5)
	rotation.y = lerp(previous_camera_rotation_y, desired_camera_rotation_y, 0.5)
	
	#camera.position.x = (sin(camera_time * (13 + (int(sprinting) * 4))) * ((int(sprinting) * 0.02) + 0.02)) * int(Input.is_action_pressed("forward"))
	#camera.position.y = 0.775 + (sin(camera_time * 16) * (int(sprinting) * 0.02) + 0.02)
	#
	previous_camera_rotation_x = camera.rotation.x
	previous_camera_rotation_y = rotation.y
	
	if !noclip:
		var collision = move_and_slide()

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
			desired_camera_rotation_x += event.relative.y / -2000*PI
			desired_camera_rotation_x = clamp(desired_camera_rotation_x, -0.5 * PI, 0.5 * PI)
			desired_camera_rotation_y += event.relative.x / -2000*PI
		
		if event.is_action("sprint"):
			if event.is_pressed():
				sprinting = true
				tween_camera_fov(DEFAULT_FOV + 20, 0.2)
			else:
				sprinting = false
				tween_camera_fov(DEFAULT_FOV, 0.2)

func tween_camera_fov(desired_fov : float, time : float):
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "fov", desired_fov, time)

func get_distance_to_player(point : Vector3): ##Returns the distance between the player and said point.
	return (global_position - point).length()

func get_unit_raycast(layers : Array, bodies : bool = true, areas : bool = false) -> RayCast3D:
	var result : RayCast3D = $Camera/layer_4_bodies.duplicate()
	result.target_position = Vector3(0, 0, -1)
	result.collide_with_areas = areas
	result.collide_with_bodies = bodies
	
	return result

func is_point_in_view(point : Vector3) -> bool: ##NOT IMPLEMENTED YET returns whether a certain point is in the field of view of the player
	print($Camera.unproject_position(point))
	return false
