shader_type spatial;

render_mode wireframe;
uniform float slide_speed = 0.3;
uniform float wobble_speed = 1.0;
uniform float wobble_intensity = 0.4;
uniform float texture_scale = 0.2;
uniform float wave_height = 0.4;
uniform float curvature = 20.0;
uniform sampler2D water : repeat_enable;

void vertex() {

	VERTEX.y += sin(TIME * wobble_speed + (VERTEX.x + VERTEX.z) * 0.3) * wave_height;
	NORMAL -= cos(TIME * wobble_speed + (VERTEX.x + VERTEX.z) * 0.3) * wave_height;
	VERTEX.y += sin(TIME * wobble_speed + (VERTEX.x - VERTEX.z) / 12.0) * wave_height;
	NORMAL -= cos(TIME * wobble_speed + (VERTEX.x - VERTEX.z) / 12.0) * wave_height;
	vec2 mid = vec2(0.5, 0.5);
	VERTEX.y += (distance(mid, UV) * distance(mid, UV)) * curvature;
	VERTEX.y += (distance(mid.x, UV.x) * distance(mid.x, UV.x)) * curvature;
	NORMAL.y += (distance(mid, UV) * distance(mid, UV)) * curvature;
	NORMAL.y += (distance(mid.x, UV.x) * distance(mid.x, UV.x)) * curvature;
}


void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
