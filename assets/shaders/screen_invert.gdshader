shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float transparency = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 screen_color = texture(screen_tex, SCREEN_UV).rgb;
	COLOR = vec4(1.0 - screen_color.r, 1.0 - screen_color.g, 1.0 - screen_color.b, COLOR.a * transparency);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
