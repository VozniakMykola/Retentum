shader_type spatial;
render_mode unshaded;

uniform sampler2D source_texture : source_color;
uniform vec2 texture_size = vec2(1024.0, 1024.0);

uniform bool use_polar_coordinates = false;
uniform vec2 polar_center = vec2(0.5);
uniform float polar_zoom = 1.0;
uniform float polar_repeat = 1.0;

uniform highp float spin_rotation; 
uniform highp float spin_speed = 2.0;
uniform highp vec2 texture_offset = vec2(0.0, 0.0); 
uniform highp vec4 extreme_color : source_color = vec4(0.0235, 0.1137, 0.3020, 1.0); // #061d4d
uniform highp vec4 central_color : source_color = vec4(0.5333, 0.6980, 0.3059, 1.0); // #88b24e
uniform highp vec4 intermediate_color : source_color = vec4(0.0627, 0.1725, 0.7608, 1.0); // #102cc2
uniform highp float color_contrast = 1.0;
uniform highp float spin_intensity = 0.36;
uniform highp float pixelation_factor = 1024.0;
#define SPIN_EASE 1.0

vec4 apply_effect(vec2 screen_size, vec2 screen_coords) {
	highp float pixel_size = length(screen_size) / pixelation_factor;
	highp vec2 uv = (floor(screen_coords * (1.0 / pixel_size)) * pixel_size - 0.5 * screen_size) / length(screen_size) - texture_offset;
	highp float uv_length = length(uv);
	
	highp float rotation_speed = (spin_rotation * SPIN_EASE * 0.2) + 302.2;
	highp float pixel_angle = atan(uv.y, uv.x) + rotation_speed - SPIN_EASE * 20.0 * (spin_intensity * uv_length + (1.0 - spin_intensity));
	highp vec2 screen_center = (screen_size / length(screen_size)) / 2.0;
	uv = vec2(uv_length * cos(pixel_angle) + screen_center.x, uv_length * sin(pixel_angle) + screen_center.y) - screen_center;
	
	uv *= 30.0;
	rotation_speed = TIME * spin_speed;
	highp vec2 uv_distortion = vec2(uv.x + uv.y);
	
	for (int i = 0; i < 5; i++) {
		uv_distortion += sin(max(uv.x, uv.y)) + uv;
		uv += 0.5 * vec2(cos(5.1123314 + 0.353 * uv_distortion.y + rotation_speed * 0.131121), sin(uv_distortion.x - 0.113 * rotation_speed));
		uv -= cos(uv.x + uv.y) - sin(uv.x * 0.711 - uv.y);
	}
	
	highp float contrast_modifier = (0.25 * color_contrast + 0.5 * spin_intensity + 1.2);
	highp float paint_result = clamp(length(uv) * 0.035 * contrast_modifier, 0.0, 2.0);
	highp float extreme_weight = max(0.0, 1.0 - contrast_modifier * abs(1.0 - paint_result));
	highp float central_weight = max(0.0, 1.0 - contrast_modifier * abs(paint_result));
	highp float intermediate_weight = 1.0 - min(1.0, extreme_weight + central_weight);
	
	return (0.3 / color_contrast) * extreme_color +
	       (1.0 - 0.3 / color_contrast) * (extreme_color * extreme_weight + central_color * central_weight + vec4(intermediate_weight * intermediate_color.rgb, intermediate_weight * extreme_color.a));
}

vec2 calculate_polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat) {
	vec2 direction = uv - center;
	float radius = length(direction) * 2.0;
	float angle = atan(direction.y, direction.x) / (PI * 2.0);
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

void fragment() {
	vec2 texture_uv = UV;
	if (use_polar_coordinates) {
		texture_uv = calculate_polar_coordinates(UV, polar_center, polar_zoom, polar_repeat);
	}
	vec2 pixel_coordinates = texture_uv * texture_size;
	vec4 color = apply_effect(texture_size, pixel_coordinates);
	ALBEDO = color.rgb;
	ALPHA = color.a;
}