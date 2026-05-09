shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 shade_color : source_color = vec4(0.3, 0.3, 0.4, 1.0);
uniform float shade_threshold : hint_range(-1.0, 1.0, 0.001) = 0.0;
uniform float shade_softness : hint_range(0.0, 1.0, 0.001) = 0.05;
uniform vec3 light_direction = vec3(0.0, 1.0, 0.0); // fake light dir, tweak in inspector

void fragment() {
    vec4 tex = texture(albedo_texture, UV);
    vec3 normal_world = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
    
    float NdotL = dot(normalize(normal_world), normalize(light_direction));
    float is_shaded = smoothstep(shade_threshold - shade_softness, shade_threshold + shade_softness, NdotL);
    
    vec3 cel = mix(shade_color.rgb, base_color.rgb, is_shaded);
    ALBEDO = tex.rgb * cel;
    ALPHA = tex.a;
}