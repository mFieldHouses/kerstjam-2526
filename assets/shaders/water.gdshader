shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

//
// LakeWaterSimple.gdshader
// USAGE:
// 1) Maak een PlaneMesh (genoeg subdivisions, bv 100x100) of een mesh met vertices.
// 2) Maak een ShaderMaterial -> voeg deze shader toe.
// 3) Zet Material -> Transparency aan via shader (albedo alpha), werkt zo.
// 4) Tune uniforms hieronder.
//

uniform vec4 shallow_color : source_color = vec4(0.12, 0.45, 0.45, 0.55);
uniform vec4 deep_color    : source_color = vec4(0.03, 0.12, 0.20, 0.70);

uniform float depth_distance = 6.0;     // hoe snel het naar deep blend (groter = langzamer)
uniform float wave_height = 0.06;       // golf amplitude (meters-ish)
uniform float wave_scale  = 1.2;        // golf grootte (groter = grotere golven)
uniform float wave_speed  = 0.8;        // anim snelheid

uniform float smoothness = 0.85;        // 0..1 (glans)
uniform float metallic = 0.0;           // laat meestal 0
uniform float fresnel_power = 4.0;      // reflect rand sterkte

// 2 simpele "noise" functies (cheap)
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

float noise(vec2 p){
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p){
	float v = 0.0;
	float a = 0.55;
	for (int k = 0; k < 4; k++){
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void vertex() {
	// World-ish coords voor stabiele beweging
	vec3 wp = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float t = TIME * wave_speed;
	vec2 p = (wp.xz / max(wave_scale, 0.0001));

	// 2 lagen, lichte variatie
	float n1 = fbm(p + vec2(t * 0.10, t * 0.07));
	float n2 = fbm(p * 1.8 + vec2(-t * 0.06, t * 0.11));

	float h = (n1 * 0.7 + n2 * 0.3) * 2.0 - 1.0; // -1..1-ish
	VERTEX.y += h * wave_height;
}

void fragment() {
	// Depth blend (werkt mooi bij oevers / objecten onder water)
	float scene_z = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float view_z = -VIEW_POSITION.z;
	float depth = abs( (1.0 / (scene_z + 1e-6)) - view_z ); // cheap-ish benadering

	float d = clamp(depth / max(depth_distance, 0.0001), 0.0, 1.0);
	vec4 water_col = mix(shallow_color, deep_color, d);

	// Fresnel (rand = reflectiever/helderder)
	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(-VIEW)), 0.0, 1.0), fresnel_power);

	ALBEDO = water_col.rgb + fres * 0.08;   // kleine boost aan randen
	ALPHA  = water_col.a;

	ROUGHNESS = 1.0 - clamp(smoothness, 0.0, 1.0);
	METALLIC = metallic;

	// Subtiele spec
	SPECULAR = 0.5 + fres * 0.25;
}
