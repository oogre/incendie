shader_type spatial;

uniform float red : hint_range(0.0, 3.0);
uniform float green : hint_range(0.0, 3.0);
uniform float blue : hint_range(0.0, 3.0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(red, green, blue);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
