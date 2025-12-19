shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 lights[100];
uniform int number_of_lights = 1;
uniform vec4 modulate_color : source_color = vec4(0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

float distance_to_light(vec2 coords) {
	float dist = 1000.0;
	for (int i = 0; i < number_of_lights; i++) {
		float new_dist = distance(coords, lights[i]);
		if(new_dist < dist) {
			dist = new_dist;
		}
	}
	return dist;
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(screen_texture, SCREEN_UV);
	float dist = distance_to_light(FRAGCOORD.xy);
	if(dist > 94.0) COLOR = COLOR * modulate_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
