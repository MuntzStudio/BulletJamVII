shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0, 0.01) = 1.0;
uniform float saturation : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float brightness : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 1.0;

vec3 hsv_to_rgb(float h, float s, float v) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), s);
}

void fragment() {
    float hue = fract(TIME * speed * 0.1);
    vec3 rainbow = hsv_to_rgb(hue, saturation, brightness);
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex * vec4(rainbow, opacity);
}