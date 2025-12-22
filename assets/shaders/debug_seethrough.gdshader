shader_type spatial;

uniform sampler2D screen_tex : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = mix(vec3(0), texture(screen_tex, SCREEN_UV).rgb, 0.3);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
