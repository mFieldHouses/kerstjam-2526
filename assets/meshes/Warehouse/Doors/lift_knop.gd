extends Node3D
class_name LiftButton

## LiftButton
## Interactie knop voor liftdeuren.
##
## USAGE:
## 1) Zet dit script op: LiftKnop
## 2) Zet een Area3D + CollisionShape3D op LiftKnop
## 3) Assign lift_doors (LiftDoorController)
## 4) Speler moet in de Area staan en op E drukken

@export var lift_doors: LiftDoorController
@export var interaction_distance: float = 2.0
@export var require_facing: bool = true   # speler moet richting knop kijken

var _player: Node3D
var _player_camera: Camera3D
var _player_in_area: bool = false

func _ready() -> void:
	# Verwacht een Area3D als child
	var area := get_node_or_null("Area3D")
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
	else:
		push_warning("[LiftButton] Geen Area3D gevonden onder LiftKnop.")

func _process(_delta: float) -> void:
	if not _player_in_area:
		return

	if Input.is_action_just_pressed("interact"):
		if _can_interact():
			_activate()

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		_player = body
		_player_camera = _find_camera(body)
		_player_in_area = true

func _on_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
		_player_camera = null
		_player_in_area = false

func _can_interact() -> bool:
	if _player == null:
		return false

	# Afstand check
	var dist := global_position.distance_to(_player.global_position)
	if dist > interaction_distance:
		return false

	# Richting check (optioneel, maar voelt beter)
	if require_facing and _player_camera:
		var to_button := (global_position - _player_camera.global_position).normalized()
		var cam_forward := -_player_camera.global_transform.basis.z
		if cam_forward.dot(to_button) < 0.6:
			return false

	return true

func _activate() -> void:
	if lift_doors == null:
		push_warning("[LiftButton] lift_doors niet toegewezen.")
		return

	lift_doors.toggle_doors()

	# Hier kun je later:
	# - sound afspelen
	# - knop animatie doen
	# - lampje laten oplichten

func _find_camera(root: Node) -> Camera3D:
	for c in root.get_children():
		if c is Camera3D:
			return c
		var nested := _find_camera(c)
		if nested:
			return nested
	return null
