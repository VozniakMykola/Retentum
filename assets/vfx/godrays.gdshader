shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_burley, shadows_disabled;

// Основні параметри
uniform float alpha : hint_range(0.0, 1.0) = 0.5;
uniform float rim_power : hint_range(0.0, 5.0) = 1.0;

// Текстури
uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform sampler2D gradient : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform sampler2D noise_texture : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;

// Кольори та енергія
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 1.0) = 0.5;

// Трансформація UV
uniform vec3 uv1_scale = vec3(5.0, 1.0, 0.0);  // Змінено Y-компонент на 1.0
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);  // Змінено offset

// Параметри анімації
uniform float scroll_speed : hint_range(-2.0, 2.0) = 0.1;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float flicker_speed : hint_range(0.0, 5.0) = 2.0;
uniform float flicker_amount : hint_range(0.0, 1.0) = 0.2;
uniform float ray_variation_speed : hint_range(0.0, 2.0) = 0.5;

varying vec2 base_uv;
varying vec3 dynamic_params;

void vertex() {
    // Виправлене обертання UV (90 градусів проти годинникової стрілки)
    base_uv = vec2(UV.y, 1.0 - UV.x);
    
    // Анімація UV з прокруткою (від джерела світла)
    vec2 animated_uv = UV * uv1_scale.xy;
    animated_uv.y -= TIME * scroll_speed;  // Змінено знак для правильного напрямку
    UV = animated_uv;
    
    // Генерація динамічних параметрів
    float pulse = 1.0 + pulse_intensity * sin(TIME * pulse_speed);
    float flicker = 1.0 - flicker_amount * (0.5 + 0.5 * sin(TIME * flicker_speed + UV.x * 10.0));
    float ray_variation = 0.8 + 0.2 * sin(TIME * ray_variation_speed + UV.x * 5.0);
    
    dynamic_params = vec3(pulse, flicker, ray_variation);
}

void fragment() {
    // Виправлення градієнта (перевертаємо по осі Y)
    vec2 corrected_uv = vec2(base_uv.x, 1.0 - base_uv.y);
    vec3 fallof = texture(gradient, corrected_uv).rgb;
    
    vec3 emission_tex = texture(texture_emission, UV).rgb;
    
    // Динамічний шум
    vec2 noise_uv = UV + vec2(TIME * 0.1, 0.0);
    float noise = texture(noise_texture, noise_uv).r;
    
    // Ефект променів з френелем
    float fresnel = pow(1.0 - dot(normalize(NORMAL), normalize(VIEW)), rim_power * dynamic_params.z);
    float fade = mix(1.0, -1.0, fresnel);
    
    // Динамічні параметри
    float pulse = dynamic_params.x;
    float flicker = dynamic_params.y;
    float ray_intensity = mix(0.7, 1.3, noise) * pulse * flicker;
    
    // Налаштування матеріалу
    ROUGHNESS = 0.0;
    SPECULAR = 0.0;
    
    // Емісія з динамічними ефектами
    EMISSION = (emission.rgb + emission_tex) * emission_energy * fallof * ray_intensity;
    
    // Прозорість з анімацією
    ALPHA = clamp(fade, 0.0, 1.0) * length(EMISSION) * alpha * ray_intensity;
}