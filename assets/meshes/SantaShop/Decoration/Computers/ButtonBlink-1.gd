extends MeshInstance3D

## RandomMaterialColor
## Laat het materiaal willekeurig wisselen tussen rood, groen en blauw.
##
## USAGE:
## 1. Attach dit script aan een MeshInstance3D
## 2. Zorg dat de mesh een StandardMaterial3D heeft
## 3. Pas eventueel het interval aan

@export var interval : float = 1.0

var _timer : float = 0.0
var _material : StandardMaterial3D

func _ready():
	if mesh == null:
		push_warning("Geen mesh gevonden")
		return

	var mat = get_active_material(0)
	if mat == null:
		push_warning("Geen materiaal gevonden op surface 0")
		return

	# Zorg dat dit materiaal uniek is per instance
	_material = mat.duplicate()
	set_surface_override_material(0, _material)

	_randomize_color()

func _process(delta):
	_timer += delta
	if _timer >= interval:
		_timer = 0.0
		_randomize_color()

func _randomize_color():
	var colors = [
		Color.RED,
		Color.GREEN,
		Color.BLUE
	]

	_material.albedo_color = colors.pick_random()
