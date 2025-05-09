shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 dark = tex.rgb * (1.0 - darkness);
	COLOR = vec4(dark, tex.a);
}
