extends Node

##Autoload for interfacing with the player at both low and high level. 

var default_max_raycast_length : float = 500

var player_instance : Player = null:
	set(x):
		GameLogger.print_as_autoload(self, "Player instance set")
		player_instance = x
		layer_2_raycast = player_instance.get_node("camera/interact_ray")
		layer_3_raycast = player_instance.get_node("camera/shoot_ray")
		player_set.emit(player_instance)

signal player_set(player_instance)

var layer_2_raycast : RayCast3D = null
var layer_3_raycast : RayCast3D = null

var is_sleeping : bool = false

var weapons : Array[WeaponConfiguration] = [
	load("res://assets/resources/weapon_configurations/santas_gun.tres"),
	load("res://assets/resources/weapon_configurations/axe.tres")
]

var health : float = 30.0

var ammo : Dictionary[AmmoItemDescription, int] = {
	preload("res://assets/resources/items/ammo/snow.tres") : 200,
	preload("res://assets/resources/items/ammo/fast.tres") : 200,
	preload("res://assets/resources/items/ammo/big.tres") : 200,
	preload("res://assets/resources/items/ammo/explode.tres") : 200
	}
@onready var used_ammo : AmmoItemDescription = load("res://assets/resources/items/ammo/snow.tres")

func _save_health() -> void:
	if player_instance:
		health = player_instance._health

func _save_ammo() -> void:
	if player_instance:
		ammo = player_instance._ammo

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func toggle_controls(state : bool = true): ##Whether the player node should listen to user inputs.
	if player_instance:
		player_instance.controls_enabled = state
	else:
		throw_player_not_set_yet_error("toggle_controls()")

func toggle_sleep(state : bool = true): ##Whether the player node should do anything at all, like update prompts and listen to user inputs.
	if player_instance:
		is_sleeping = state
		if state:
			player_instance.sleep()
			GameLogger.print_as_autoload(self, "Player sleep mode enabled")
		else:
			player_instance.awaken()
			GameLogger.print_as_autoload(self, "Player sleep mode disabled")
	else:
		throw_player_not_set_yet_error("toggle_sleep()")

func toggle_flight(state : bool = true, collision : bool = true):
	player_instance.toggle_flight(state, collision)
	match state:
		true:
			if collision:
				GameLogger.print_as_autoload(self, "Enabled flight with collisions enabled")
				GameConsole.print_line("Enabled flight with collisions enabled")
			else:
				GameLogger.print_as_autoload(self, "Enabled flight with collisions disabled")
				GameConsole.print_line("Enabled flight with collisions disabled")
		false:
			GameLogger.print_as_autoload(self, "Disabled flight")
			GameConsole.print_line("Disabled flight")

func teleport(target_position : Vector3) -> void:
	if player_instance:
		player_instance.position = target_position
	
	GameLogger.print_as_autoload(self, "Teleported player to " + str(target_position))

func throw_player_not_set_yet_error(base_func : String):
	GameLogger.printerr_as_autoload(self, base_func + " called although player_instance hasn't been set yet.")

func get_player_global_pos() -> Vector3: ##Returns the global position of the [Player], as set by the [Player] itself.
	if player_instance:
		return player_instance.get_global_position()
	else:
		throw_player_not_set_yet_error("get_player_global_pos()")
		return Vector3(0.0, 0.0, 0.0)

func get_distance_to_player(point : Vector3) -> float: ##Returns the distance between [param point] and [Player], as provided by the [Player] itself.
	if player_instance:
		return player_instance.get_distance_to_player(point)
	else:
		throw_player_not_set_yet_error("get_distance_to_player()")
		return 1000

func get_player_view_origin_global_pos() -> Vector3: ##Returns the origin point of the [Player]s camera, as set by the [Player] itself.
	return Vector3.ZERO

func get_player_global_view_direction() -> Vector3: ##Returns the direction the [Player] is looking in, as set by the [Player] itself.
	return Vector3.ZERO

func get_player_crosshair_projection_raycast_parameters(max_length : float = default_max_raycast_length) -> PhysicsRayQueryParameters3D: ##Returns a [PhysicsRayQueryParameters3D] for raycasts originating from the [Player] cameras position, going through the players projected crosshair point in 3D space.
	return

func is_point_in_player_view(point : Vector3) -> bool: ##Returns whether the provided point is in the [Player]s view, as provided by the player itself.
	return false

func get_player_unit_raycast(layers : Array, bodies : bool = true, areas : bool = false) -> RayCast3D:
	if player_instance:
		return player_instance.get_unit_raycast(layers, bodies, areas)
	else:
		
		return null

func add_item_to_inventory(item : ItemDescription, count : int) -> void:
	if item is AmmoItemDescription:
		player_instance._ammo[item as AmmoItemDescription] += count
