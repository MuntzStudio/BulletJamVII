shader_type spatial;

uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.1, 1.0);
uniform float glow_strength = 2.0;

void fragment() {
	EMISSION = glow_color.rgb * glow_strength;
}