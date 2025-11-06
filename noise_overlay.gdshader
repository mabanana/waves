shader_type spatial;
uniform sampler2D noise ;

void vertex() {
	NORMAL += texture(noise, UV.xy).r;
	// Called for every vertex the material is visible on.
}

void fragment() {
	ROUGHNESS *= texture(noise, UV.xy).r;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
