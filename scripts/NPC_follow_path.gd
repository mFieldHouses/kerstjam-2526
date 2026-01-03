extends PathFollow3D
class_name NPCPathFollower

# ------------------------------------------------------------
# NPCPathFollower.gd
#
# Doel:
#   Laat een NPC automatisch een Path3D volgen door de progress_ratio
#   van PathFollow3D te verhogen. Geen AnimationPlayer nodig voor bewegen.
#
# Setup (aanrader):
#   Path3D
#     └─ PathFollow3D (DIT script hierop)
#          └─ NPC_Root (Node3D / CharacterBody3D / etc.)
#               └─ Visuals (Mesh/Skeleton/AnimationPlayer met walk-loop autoplay)
#
# Gebruik:
#   1) Maak een Path3D met een Curve.
#   2) Voeg een PathFollow3D toe als child van Path3D.
#   3) Plak dit script op die PathFollow3D.
#   4) Zet je NPC onder de PathFollow3D.
#   5) Zet in de Inspector "Speed Mps" (meters per seconde).
#
# Tips:
#   - Zet je walk-loop anim gewoon op autoplay/loop in je AnimationPlayer.
#   - "Rotate To Path" draait de PathFollow mee met de richting van het pad.
# ------------------------------------------------------------

@export var speed_mps: float = 1.5            # snelheid in meters per seconde
@export var loop_path: bool = true            # blijf rondjes lopen
@export var rotate_to_path: bool = true       # draai mee met de bocht
@export var rotate_lerp_speed: float = 10.0   # hoe snel hij bijdraait (hoger = snappier)

func _ready() -> void:
	# Zorg dat hij niet vanzelf stopt bij het einde als je wilt loopen
	# (In Godot 4 heeft PathFollow3D een 'loop' property)
	loop = loop_path

func _physics_process(delta: float) -> void:
	if speed_mps <= 0.0:
		return

	var curve := get_parent() as Path3D
	if curve == null or curve.curve == null:
		return

	var length := curve.curve.get_baked_length()
	if length <= 0.001:
		return

	# speed_mps (meters/s) omzetten naar ratio per seconde:
	# progress_ratio gaat van 0..1 over de volledige padlengte.
	var ratio_delta := (speed_mps / length) * delta

	progress_ratio += ratio_delta

	if loop_path:
		# netjes wrappen 0..1
		progress_ratio = fposmod(progress_ratio, 1.0)
	else:
		progress_ratio = clamp(progress_ratio, 0.0, 1.0)

	if rotate_to_path:
		# PathFollow3D kan zelf roteren met "rotation_mode",
		# maar hieronder forceren we extra smooth draaien (optioneel).
		# Zet in Inspector van PathFollow3D ook gerust rotation_mode = ORIENTED.
		var target_basis := global_transform.basis
		var current := global_transform
		current.basis = current.basis.slerp(target_basis, clamp(rotate_lerp_speed * delta, 0.0, 1.0))
		global_transform = current
