shader_type spatial;

uniform vec3 base_color : source_color = vec3(0.8, 0.8, 0.8);
uniform vec3 highlight_center = vec3(0.0, 0.0, 0.0);
uniform float highlight_radius = 1.0;
uniform vec3 highlight_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float highlight_strength = 0.4;

void fragment() {
    ALBEDO = base_color;
    ALPHA = 1.0;

    vec3 local_pos = VERTEX;

    float dist = length(local_pos - highlight_center);
    float norm_dist = clamp(dist / highlight_radius, 0.0, 1.0);

    float mask = smoothstep(1.0, 0.0, norm_dist);

    ALBEDO = mix(ALBEDO, highlight_color, mask * highlight_strength);
}
