extends OmniLight3D
#
# USAGE:
# 1) Attach this script to an OmniLight3D node (Godot 4).
# 2) Tweak the exported variables in the Inspector:
#    - min_energy / max_energy: the intensity range
#    - flicker_speed: how fast the flicker changes
#    - noise_strength: how strong/chaotic the flicker is
#
# WHAT IT DOES:
# Uses Smooth Noise (FastNoiseLite Simplex) to vary light_energy over time.
# This looks more natural than using pure random every frame.
#

@export var min_energy: float = 2.5        # Lowest light intensity (darkest point)
@export var max_energy: float = 4.0        # Highest light intensity (brightest point)
@export var flicker_speed: float = 1.5     # How fast the flicker evolves over time
@export var noise_strength: float = 1.0    # Multiplier for how "wild" the flicker is (0..1+)

var noise := FastNoiseLite.new()           # Noise generator for smooth flicker
var time := 0.0                            # Internal time accumulator

func _ready() -> void:
	# Configure the noise generator.
	# Simplex gives smooth-ish variation that works well for flicker.
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	# Frequency controls how "busy" the noise is.
	# Higher = more rapid changes, lower = slower, smoother changes.
	noise.frequency = 1.0

func _process(delta: float) -> void:
	# Advance internal time, scaled by flicker_speed.
	time += delta * flicker_speed

	# Get 1D noise value based on time:
	# returns roughly in range [-1 .. 1]
	var n: float = noise.get_noise_1d(time)

	# Remap noise from [-1 .. 1] to [0 .. 1]
	n = (n + 1.0) * 0.5

	# Apply noise_strength (lets you dampen or exaggerate the effect)
	var t: float = clamp(n * noise_strength, 0.0, 1.0)

	# Interpolate between min and max intensity using the noise value
	var energy_value: float = lerp(min_energy, max_energy, t)

	# Finally set the light intensity
	light_energy = energy_value
