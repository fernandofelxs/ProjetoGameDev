shader_type canvas_item;

uniform int use_swap = 0;

uniform float flash_progress : hint_range(0, 1) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Default to white

uniform vec4 target_color_1 : source_color;
uniform vec4 replace_color_1 : source_color;

uniform vec4 target_color_2 : source_color;
uniform vec4 replace_color_2 : source_color;

uniform vec4 target_color_3 : source_color;
uniform vec4 replace_color_3 : source_color;

uniform vec4 target_color_4 : source_color;
uniform vec4 replace_color_4 : source_color;

uniform float tolerance : hint_range(0.0, 1.0);

void fragment() {
	if(use_swap == 1) {
	    vec4 tex_color = texture(TEXTURE, UV);
	    vec3 rgb = tex_color.rgb;

	    if (distance(rgb, target_color_1.rgb) < tolerance) {
	        rgb = replace_color_1.rgb;
	    } 
	    else if (distance(rgb, target_color_2.rgb) < tolerance) {
	        rgb = replace_color_2.rgb;
	    }
	    else if (distance(rgb, target_color_3.rgb) < tolerance) {
	        rgb = replace_color_3.rgb;
	    }
	    else if (distance(rgb, target_color_4.rgb) < tolerance) {
	        rgb = replace_color_4.rgb;
	    }

	    tex_color.rgb = rgb;
	    COLOR = tex_color;
	} else {
	    vec4 original_color = texture(TEXTURE, UV);
	    // Mix the original color with the flash color based on the progress value
	    COLOR.rgb = mix(original_color.rgb, flash_color.rgb, flash_progress);
	    COLOR.a = original_color.a;
	}
}