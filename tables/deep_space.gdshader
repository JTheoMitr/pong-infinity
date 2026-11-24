
shader_type canvas_item;
render_mode unshaded;

uniform vec4 background_color : source_color = vec4(0.003, 0.005, 0.014, 1.0);
uniform vec4 star_color : source_color = vec4(0.78, 0.88, 1.0, 1.0);

uniform float star_density : hint_range(0.05, 1.0) = 0.32;
uniform float star_brightness : hint_range(0.0, 2.0) = 0.8;
uniform float drift_speed : hint_range(0.0, 0.005, 0.00001) = 0.00015;
uniform float twinkle_speed : hint_range(0.0, 5.0) = 1.2;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

vec3 star_layer(
	vec2 uv,
	float grid_size,
	float density,
	float speed,
	float seed
) {
	vec2 moving_uv = uv + vec2(
		TIME * speed,
		TIME * speed * 0.35
	);

	vec2 grid_uv = moving_uv * grid_size;
	vec2 cell = floor(grid_uv);
	vec2 local_uv = fract(grid_uv);

	float random_value = hash21(cell + vec2(seed));

	if (random_value > density) {
		return vec3(0.0);
	}

	vec2 star_position = vec2(
		0.2 + hash21(cell + vec2(seed + 11.0)) * 0.6,
		0.2 + hash21(cell + vec2(seed + 29.0)) * 0.6
	);

	float distance_to_star = length(local_uv - star_position);

	float size_variation = hash21(cell + vec2(seed + 47.0));
	float radius = mix(0.045, 0.09, size_variation);

	float star = 1.0 - smoothstep(
		radius * 0.35,
		radius,
		distance_to_star
	);

	float twinkle_phase = hash21(cell + vec2(seed + 83.0)) * 6.2831853;

	float twinkle = 0.72 + 0.28 * sin(
		TIME * twinkle_speed + twinkle_phase
	);

	float brightness_variation = mix(0.35, 1.0, size_variation);

	return star_color.rgb
		* star
		* twinkle
		* brightness_variation;
}

void fragment() {
	vec2 uv = UV;

	// Correct for the 1152x648 viewport aspect ratio.
	vec2 aspect_uv = vec2(
		uv.x * (1152.0 / 648.0),
		uv.y
	);

	vec3 stars = vec3(0.0);

	// Three layers drifting at different speeds.
	stars += star_layer(
		aspect_uv,
		18.0,
		star_density * 0.7,
		drift_speed * 0.35,
		13.0
	) * 0.45;

	stars += star_layer(
		aspect_uv,
		30.0,
		star_density,
		drift_speed * 0.7,
		37.0
	) * 0.65;

	stars += star_layer(
		aspect_uv,
		45.0,
		star_density * 0.75,
		drift_speed,
		71.0
	);

	vec3 final_color = background_color.rgb
		+ stars * star_brightness;

	COLOR = vec4(final_color, 1.0);
}
