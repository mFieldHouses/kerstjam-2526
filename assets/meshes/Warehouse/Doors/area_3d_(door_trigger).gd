extends Area3D

## LiftDoorAreaTrigger
## Simpele liftdeur trigger:
## - Player enters -> open
## - Player exits  -> close
##
## USAGE:
## 1) Attach dit script aan DoorTrigger (Area3D)
## 2) Assign `doors` naar je LiftDoorController (node LiftDeuren)
## 3) Zorg dat je player een CollisionBody heeft (CharacterBody3D)
## 4) Stel collision layers/masks goed: Area moet player bodies detecten

@export var doors: LiftDoorController
@export var close_delay: float = 0.25  # kleine delay zodat het niet "flikkert" op rand

var _player_count: int = 0
var _close_timer: SceneTreeTimer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not (body is CharacterBody3D):
		return

	_player_count += 1

	# Cancel pending close
	_close_timer = null

	if doors:
		doors.open_doors()

func _on_body_exited(body: Node) -> void:
	if not (body is CharacterBody3D):
		return

	_player_count = max(0, _player_count - 1)

	if _player_count == 0:
		# kleine delay voordat hij sluit
		if close_delay <= 0.0:
			if doors:
				doors.close_doors()
		else:
			_close_timer = get_tree().create_timer(close_delay)
			_close_timer.timeout.connect(func():
				# alleen sluiten als er nog steeds niemand staat
				if _player_count == 0 and doors:
					doors.close_doors()
			)
