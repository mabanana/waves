shader_type spatial;
///////////////// NORMAL RECONSTRUCT ALGORITHM ////////////////

vec3 GerstnerWave_CalculateNormal(
float input_wave_sin, 
float input_wave_cos, 
float input_wave_height_scaled,
vec3 input_wave_direction_normalized,
float input_steepness_ratio)
{
    
    // Normal calculation
    float sin_component = input_wave_sin * input_wave_height_scaled;
    float cos_component = input_wave_cos * input_wave_height_scaled;

    vec3 normal_lateral = input_wave_direction_normalized * sin_component;
    float normal_vertical = input_steepness_ratio * cos_component;

    vec3 wave_normal = vec3(normal_lateral.x, -normal_vertical , normal_lateral.z);
    return wave_normal;
}

void vertex() {
	// === Gerstner Wave Node ===
	vec3 input_wave_direction = vec3(1.0, 0.0, 1.0);       // Shader Parameter
	float input_wave_length = 14.5;         // Shader Parameter
	float input_wave_height = 0.5;         // Shader Parameter
	float input_wave_peak_sharpness = 0.1; // Shader Parameter
	// Called for every vertex the material is visible on.
	vec3 vertex_position = VERTEX;
	float gravity = 9.807;
	float time = TIME;
	float tau = 6.28319;

	// Calculate wave properties
	float wave_number = tau / input_wave_length;
	float wave_speed = sqrt(gravity * wave_number);
	float wave_phase_time = time * wave_speed;

	vec3 wave_direction_normalized = normalize(input_wave_direction);
	vec3 wave_vector = wave_direction_normalized * wave_number;

	float phase_offset = dot(vertex_position, wave_vector);
	float wave_phase = phase_offset - wave_phase_time;

	// Trigonometric wave response
	float wave_cos = cos(wave_phase);
	float wave_sin = sin(wave_phase);

	// Vertical displacement
	vec3 up_vector = vec3(0.0, 1.0, 0.0);
	vec3 vertical_displacement = wave_cos * up_vector * input_wave_height;

	// Horizontal displacement
	float wave_height_scaled = input_wave_height * wave_number;
	float steepness_ratio = input_wave_peak_sharpness / wave_height_scaled;
	float horizontal_amplitude = steepness_ratio * input_wave_height;
	float horizontal_displacement_magnitude = wave_sin * horizontal_amplitude;
	vec3 horizontal_displacement = horizontal_displacement_magnitude * wave_direction_normalized;

	// Final vertex offset
	vec3 wave_vertex_offset = vertical_displacement - horizontal_displacement;
	
	// Final Normal Reconsctruct
	vec3 normal_reconstruct = GerstnerWave_CalculateNormal(
	    wave_sin,
	    wave_cos,
	    wave_height_scaled,
	    wave_direction_normalized,
	    steepness_ratio);
	
	VERTEX += wave_vertex_offset;
	NORMAL += normal_reconstruct;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ROUGHNESS = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
