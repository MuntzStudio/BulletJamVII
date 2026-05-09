shader_type canvas_item;

uniform float speed_x : hint_range(-5.0, 5.0, 0.01) = 0.5;
uniform float speed_y : hint_range(-5.0, 5.0, 0.01) = 0.0;
uniform float scale : hint_range(0.1, 10.0, 0.01) = 1.0;
uniform float rotation_deg : hint_range(0.0, 360.0, 0.1) = 0.0;
uniform vec4 tint : source_color = vec4(1.0);
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
    float angle = rotation_deg * (PI / 180.0);
    mat2 rot = mat2(
        vec2(cos(angle), -sin(angle)),
        vec2(sin(angle),  cos(angle))
    );

    vec2 center = vec2(0.5, 0.5);
    vec2 uv = UV - center;
    uv = rot * uv;
    uv += center;

    uv *= scale;
    uv += vec2(TIME * speed_x, TIME * speed_y);

    vec4 tex = texture(TEXTURE, fract(uv));
    COLOR = tex * tint * vec4(1.0, 1.0, 1.0, opacity);
}