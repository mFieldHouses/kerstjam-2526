shader_type spatial;
render_mode cull_back, depth_draw_opaque;

//
// snow_top_DEBUG_full.gdshader
//
// USAGE (Godot 4.5.1):
// 1) Maak een ShaderMaterial en kies deze shader.
// 2) Zet die ShaderMaterial op MeshInstance3D -> Material Override (debug-friendly).
// 3) (Optioneel) Koppel je SnowGrower.gd script en stuur snow_amount. Voor debug staat snow_amount default op 1.
// 4) Tweaken in Inspector:
//    - base_color / snow_color
//    - grain_strength / grain_contrast
//    - sparkle_density / sparkle_intensity / sparkle_sharpness
//
// DEBUG NOTES:
// - Als je geen sneeuw ziet: check normals + mesh orientation (world normal Y).
// - Als je sneeuw ziet maar geen grain: zet grain_strength omhoog, grain_scale omlaag.
// - Als je geen glitters ziet: zet sparkle_density omlaag (meer glitters) + sparkle_intensity omhoog.
//

// --- Snow growth control (komt normaal van script) ---
uniform float snow_amount : hint_range(0.0, 1.0) = 1.0; // debug default = 1
uniform float snow_max    : hint_range(0.0, 1.0) = 1.0;

// Sneeuw alleen op surfaces die naar boven wijzen
uniform float slope_start : hint_range(0.0, 1.0) = 0.20; // vanaf welke up-ness sneeuw begint
uniform float slope_full  : hint_range(0.0, 1.0) = 0.60; // bij welke up-ness volledig sneeuw

// Displacement (wordt blocky op low-poly, maar debug ok)
uniform float snow_height : hint_range(0.0, 0.3) = 0.08;

// --- KLEUREN: jij bepaalt ze ---
uniform vec3 base_color : source_color = vec3(0.25, 0.25, 0.25);
uniform vec3 snow_color : source_color = vec3(0.95, 0.95, 0.95);

// --- Grain / ophoping (world-space noise) ---
uniform float grain_scale     : hint_range(1.0, 300.0) = 30.0; // lager = grotere korrels zichtbaar
uniform float clump_scale     : hint_range(1.0, 80.0)  = 8.0;  // lager = grotere ophopingen

uniform float grain_strength  : hint_range(0.0, 0.5)   = 0.12; // hoeveel kleur-variatie
uniform float grain_contrast  : hint_range(0.5, 3.0)   = 1.6;  // contrast in grain

// --- Sparkles / twinkle (camera-based) ---
uniform float sparkle_density   : hint_range(0.90, 0.999) = 0.97; // lager = MEER sparkles
uniform float sparkle_intensity : hint_range(0.0, 2.0)    = 0.8;  // debug: hoog
uniform float sparkle_sharpness : hint_range(1.0, 120.0)  = 18.0; // lager = breder zichtbaar
uniform float sparkle_scale     : hint_range(1.0, 200.0)  = 20.0;

// --- Output varyings ---
varying float v_snow_mask;
varying vec3  v_world_pos;
varying vec3  v_world_n;

// ---- noise helpers ----
float hash31(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float value_noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	// smoothstep
	f = f * f * (3.0 - 2.0 * f);

	float n000 = hash31(i + vec3(0,0,0));
	float n100 = hash31(i + vec3(1,0,0));
	float n010 = hash31(i + vec3(0,1,0));
	float n110 = hash31(i + vec3(1,1,0));
	float n001 = hash31(i + vec3(0,0,1));
	float n101 = hash31(i + vec3(1,0,1));
	float n011 = hash31(i + vec3(0,1,1));
	float n111 = hash31(i + vec3(1,1,1));

	float nx00 = mix(n000, n100, f.x);
	float nx10 = mix(n010, n110, f.x);
	float nx01 = mix(n001, n101, f.x);
	float nx11 = mix(n011, n111, f.x);

	float nxy0 = mix(nx00, nx10, f.y);
	float nxy1 = mix(nx01, nx11, f.y);

	return mix(nxy0, nxy1, f.z); // 0..1
}

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_n   = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);

	float upness = clamp(v_world_n.y, 0.0, 1.0);
	float slope_mask = smoothstep(slope_start, slope_full, upness);

	float a = clamp(snow_amount, 0.0, snow_max);
	v_snow_mask = slope_mask * a;

	// displacement omhoog (world up)
	VERTEX += vec3(0.0, 1.0, 0.0) * (v_snow_mask * snow_height);
}

void fragment() {
	// --- World-space detail noise ---
	float g = value_noise(v_world_pos * grain_scale);
	float c = value_noise(v_world_pos * clump_scale);
	float detail = mix(g, c, 0.5); // 0..1

	// Center + contrast
	float d = (detail - 0.5) * grain_contrast; // around -..+

	// Sneeuwkleur + variatie
	vec3 snow_col = snow_color + (d * grain_strength);
	snow_col = clamp(snow_col, 0.0, 1.0);

	// Mix base en sneeuw
	ALBEDO = mix(base_color, snow_col, v_snow_mask);

	// --- Sparkles (overduidelijk debug) ---
	vec3 V = normalize(CAMERA_POSITION_WORLD - v_world_pos);
	vec3 N = normalize(v_world_n);

	// Seed: sparse noise threshold
	float sparkle_seed = step(sparkle_density, value_noise(v_world_pos * sparkle_scale));

	// Spec/glint term (camera-driven)
	vec3 R = reflect(-V, N);
	float glint = pow(clamp(dot(R, V), 0.0, 1.0), sparkle_sharpness);

	float sparkle = sparkle_seed * glint * v_snow_mask;

	// Emission = white sparkles (debug sterk)
	EMISSION = snow_col * sparkle * sparkle_intensity;


	// Material feel
	ROUGHNESS = 0.85;
	METALLIC = 0.0;
}
