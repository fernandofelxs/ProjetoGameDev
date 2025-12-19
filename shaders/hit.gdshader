shader_type canvas_item;

uniform float flash_progress : hint_range(0, 1) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Default to white

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    // Mix the original color with the flash color based on the progress value
    COLOR.rgb = mix(original_color.rgb, flash_color.rgb, flash_progress);
    COLOR.a = original_color.a;
}