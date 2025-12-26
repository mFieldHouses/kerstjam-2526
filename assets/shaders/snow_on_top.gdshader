shader_type spatial;

render_mode depth_prepass_alpha;

varying vec3 world_normal;
varying vec3 world_pos;
varying float snow_fac;
varying float snow_ramp_fac;

uniform float snow_thickness = 0.2;

//uniform sampler2D base_texture : source_color;
uniform sampler2D snow_texture : source_color;
uniform sampler2D snow_strength_ramp : source_color;
uniform sampler2D snow_strength_noise : hint_default_white;
uniform float snow_strength_noise_scale = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	world_pos = NODE_POSITION_WORLD + VERTEX.xyz;
	snow_fac = clamp(dot(vec3(0.0, 1.0, 0.0), world_normal), 0.0, 1.0);
	snow_ramp_fac = texture(snow_strength_ramp, vec2(snow_fac * 0.98 + 0.01, 0.0)).r * texture(snow_strength_noise, world_pos.xz / snow_strength_noise_scale).r;
	
	VERTEX.y += pow(snow_ramp_fac, 1.5) * snow_thickness;
}

void fragment() {
	//ALPHA = snow_fac;
	
	ALBEDO = texture(snow_texture, UV).rgb;
	ALPHA = pow(snow_ramp_fac, 0.1);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
