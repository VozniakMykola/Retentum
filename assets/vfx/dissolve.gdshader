shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;

uniform sampler2D albedo_texture : source_color;

uniform vec4 modulate_color : source_color = vec4(1.0);
uniform sampler2D dissolve_texture;
uniform float dissolve_value = 0.0;
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float edge_width = 0.05;

void fragment() {
    vec4 albedo_tex = texture(albedo_texture, UV);
    float noise_val = texture(dissolve_texture, UV).r;

    albedo_tex.rgb *= modulate_color.rgb;
    albedo_tex.a *= modulate_color.a;

    float threshold = dissolve_value;
    float dissolve_factor = smoothstep(threshold - edge_width, threshold + edge_width, noise_val);
    
    vec3 final_color = mix(edge_color.rgb, albedo_tex.rgb, dissolve_factor);
    float final_alpha = albedo_tex.a * step(threshold, noise_val);
    
    ALBEDO = final_color;
    ALPHA = final_alpha;
}