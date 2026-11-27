
shader_type canvas_item;
render_mode unshaded;

uniform vec4 background_color : source_color = vec4(0.003, 0.005, 0.014, 1.0);
uniform vec4 star_color : source_color = vec4(0.78, 0.88, 1.0, 1.0);

uniform float star_density : hint_range(0.05, 1.0) = 0.32;
uniform float star_brightness : hint_range(0.0, 2.0) = 0.8;
uniform float drift_speed : hint_range(0.0, 0.005, 0.00001) = 0.00015;
uniform float twinkle_speed : hint_range(0.0, 5.0) = 1.2;

// ==========================================
// SHOOTING STAR SETTINGS
// ==========================================

uniform vec4 shooting_star_color : source_color = vec4(0.85, 0.93, 1.0, 1.0);

uniform float shooting_star_interval : hint_range(3.0, 120.0) = 25.0;
uniform float shooting_star_chance : hint_range(0.0, 1.0) = 0.85;

uniform float shooting_star_min_duration : hint_range(0.1, 5.0) = 0.8;
uniform float shooting_star_max_duration : hint_range(0.1, 5.0) = 1.5;

uniform float shooting_star_min_length : hint_range(0.01, 0.5) = 0.08;
uniform float shooting_star_max_length : hint_range(0.01, 0.5) = 0.20;

uniform float shooting_star_size : hint_range(0.001, 0.02, 0.001) = 0.003;
uniform float shooting_star_brightness : hint_range(0.0, 2.0) = 0.85;
uniform float shooting_star_glow : hint_range(0.0, 1.0) = 0.25;

uniform float shooting_star_min_distance : hint_range(0.05, 2.0) = 0.35;
uniform float shooting_star_max_distance : hint_range(0.05, 2.0) = 0.85;

// ==========================================
// BLACK HOLE SETTINGS
// ==========================================

uniform vec4 black_hole_color : source_color = vec4(0.92, 0.95, 1.0, 1.0);

uniform float black_hole_interval : hint_range(10.0, 180.0) = 45.0;
uniform float black_hole_chance : hint_range(0.0, 1.0) = 0.75;

uniform float black_hole_min_duration : hint_range(1.0, 30.0) = 8.0;
uniform float black_hole_max_duration : hint_range(1.0, 30.0) = 12.0;

uniform float black_hole_min_size : hint_range(0.01, 0.2) = 0.035;
uniform float black_hole_max_size : hint_range(0.01, 0.2) = 0.075;

uniform float black_hole_core_ratio : hint_range(0.05, 0.5) = 0.20;

uniform int black_hole_arms : hint_range(1, 6, 1) = 2;

uniform float black_hole_spiral_turns : hint_range(0.5, 4.0) = 1.5;
uniform float black_hole_arm_width : hint_range(0.01, 0.3) = 0.075;

uniform float black_hole_rotation_speed : hint_range(0.0, 5.0) = 0.65;

uniform float black_hole_brightness : hint_range(0.0, 2.0) = 0.70;
uniform float black_hole_glow : hint_range(0.0, 1.0) = 0.15;

uniform float black_hole_fade_time : hint_range(0.1, 5.0) = 2.0;

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


// ==========================================
// SHOOTING STAR ANIMATION
// ==========================================

vec3 draw_shooting_star(vec2 uv, float time) {

	float aspect = 1152.0 / 648.0;

	float interval = max(shooting_star_interval, 0.1);

	float cycle = floor(time / interval);
	float phase = mod(time, interval);

	vec2 seed = vec2(cycle, 137.0);

	// Occasionally skip a shooting star event.
	float spawn_roll = hash21(
		seed + vec2(7.0, 19.0)
	);

	if (spawn_roll >= shooting_star_chance) {
		return vec3(0.0);
	}

	// Randomized event duration.
	float duration = mix(
		shooting_star_min_duration,
		shooting_star_max_duration,
		hash21(seed + vec2(13.0, 31.0))
	);

	duration = clamp(
		duration,
		0.1,
		interval * 0.9
	);

	// Random departure time within each cycle.
	float departure_delay = hash21(
		seed + vec2(23.0, 61.0)
	) * max(interval - duration, 0.0);

	float active_time = phase - departure_delay;

	// Only calculate the star during an active event.
	if (active_time < 0.0 || active_time >= duration) {
		return vec3(0.0);
	}

	float progress = active_time / duration;

	// Random diagonal travel angle.
	float angle = mix(
		0.25,
		0.95,
		hash21(seed + vec2(41.0, 17.0))
	);

	// Random horizontal direction.
	float horizontal_direction = mix(
		-1.0,
		1.0,
		step(
			0.5,
			hash21(seed + vec2(9.0, 21.0))
		)
	);

	// Random vertical direction.
	float vertical_direction = mix(
		-1.0,
		1.0,
		step(
			0.5,
			hash21(seed + vec2(15.0, 53.0))
		)
	);

	vec2 direction = normalize(vec2(
		cos(angle) * horizontal_direction,
		sin(angle) * vertical_direction
	));

	// Random location across the board.
	vec2 flight_center = vec2(
		mix(
			0.15,
			0.85,
			hash21(seed + vec2(33.0, 11.0))
		) * aspect,

		mix(
			0.15,
			0.85,
			hash21(seed + vec2(51.0, 27.0))
		)
	);

	// Random travel distance.
	float travel_distance = mix(
		shooting_star_min_distance,
		shooting_star_max_distance,
		hash21(seed + vec2(73.0, 5.0))
	);

	// Random trail length.
	float trail_length = mix(
		shooting_star_min_length,
		shooting_star_max_length,
		hash21(seed + vec2(19.0, 83.0))
	);

	trail_length = max(trail_length, 0.001);

	// Random size variation.
	float star_size = shooting_star_size * mix(
		0.65,
		1.35,
		hash21(seed + vec2(37.0, 91.0))
	);

	star_size = max(star_size, 0.0001);

	// Move the shooting star along its flight path.
	vec2 head_position = flight_center
		+ direction
		* (progress - 0.5)
		* travel_distance;

	vec2 relative_uv = uv - head_position;

	// Distance along and perpendicular to the trail.
	float along = dot(relative_uv, direction);

	vec2 perpendicular_direction = vec2(
		-direction.y,
		direction.x
	);

	float perpendicular = abs(
		dot(relative_uv, perpendicular_direction)
	);

	// Skip pixels outside the shooting star's area.
	if (
		along > star_size * 8.0 ||
		along < -trail_length - star_size * 8.0 ||
		perpendicular > star_size * 8.0
	) {
		return vec3(0.0);
	}

	// --------------------------------------
	// Bright shooting star head
	// --------------------------------------

	float head_distance = length(relative_uv);

	float head = 1.0 - smoothstep(
		star_size * 0.25,
		star_size,
		head_distance
	);

	float head_glow = exp(
		-head_distance / (star_size * 2.0)
	);

	// --------------------------------------
	// Tapered luminous trail
	// --------------------------------------

	float trail_progress = clamp(
		-along / trail_length,
		0.0,
		1.0
	);

	float trail_width = mix(
		star_size * 0.65,
		star_size * 0.08,
		trail_progress
	);

	float trail_bounds = step(
		-trail_length,
		along
	) * step(
		along,
		0.0
	);

	float trail = 1.0 - smoothstep(
		0.0,
		trail_width,
		perpendicular
	);

	// Gradually fade toward the end of the tail.
	float trail_fade = pow(
		1.0 - trail_progress,
		1.8
	);

	trail *= trail_fade * trail_bounds;

	// Soft glow surrounding the trail.
	float trail_glow = exp(
		-perpendicular / (star_size * 1.8)
	);

	trail_glow *= trail_fade * trail_bounds;

	// --------------------------------------
	// Smooth appearance and disappearance
	// --------------------------------------

	float fade_in = smoothstep(
		0.0,
		0.12,
		progress
	);

	float fade_out = 1.0 - smoothstep(
		0.65,
		1.0,
		progress
	);

	float visibility = fade_in * fade_out;

	// Combine the head, trail and glow.
	vec3 meteor = shooting_star_color.rgb * (
		head
		+ trail * 0.75
		+ head_glow * shooting_star_glow
		+ trail_glow * shooting_star_glow * 0.5
	);

	return meteor
		* shooting_star_brightness
		* visibility;
}

// ==========================================
// BLACK HOLE / VORTEX ANIMATION
// ==========================================

vec3 draw_black_hole(
	vec2 uv,
	vec3 background,
	float time
) {

	float aspect = 1152.0 / 648.0;
	float tau = 6.2831853;

	float interval = max(black_hole_interval, 0.1);

	// Offset the timing from the shooting stars.
	float event_time = time + 17.0;

	float cycle = floor(event_time / interval);
	float phase = mod(event_time, interval);

	vec2 seed = vec2(cycle, 283.0);

	// Occasionally skip a black hole event.
	float spawn_roll = hash21(
		seed + vec2(7.0, 19.0)
	);

	if (spawn_roll >= black_hole_chance) {
		return background;
	}

	// Randomized lifespan.
	float duration = mix(
		black_hole_min_duration,
		black_hole_max_duration,
		hash21(seed + vec2(13.0, 31.0))
	);

	duration = clamp(
		duration,
		0.1,
		interval * 0.9
	);

	// Random appearance time within each cycle.
	float departure_delay = hash21(
		seed + vec2(23.0, 61.0)
	) * max(interval - duration, 0.0);

	float active_time = phase - departure_delay;

	// Skip rendering when no vortex is active.
	if (
		active_time < 0.0 ||
		active_time >= duration
	) {
		return background;
	}

	// --------------------------------------
	// Randomized position and size
	// --------------------------------------

	float radius = mix(
		black_hole_min_size,
		black_hole_max_size,
		hash21(seed + vec2(17.0, 43.0))
	);

	radius = max(radius, 0.001);

	vec2 center = vec2(
		mix(
			0.15,
			0.85,
			hash21(seed + vec2(33.0, 11.0))
		) * aspect,

		mix(
			0.15,
			0.85,
			hash21(seed + vec2(51.0, 27.0))
		)
	);

	// Random clockwise or anticlockwise rotation.
	float direction = mix(
		-1.0,
		1.0,
		step(
			0.5,
			hash21(seed + vec2(9.0, 21.0))
		)
	);

	// --------------------------------------
	// Appearance and disappearance
	// --------------------------------------

	float fade_time = min(
		black_hole_fade_time,
		duration * 0.45
	);

	float fade_in = smoothstep(
		0.0,
		fade_time,
		active_time
	);

	float fade_out = 1.0 - smoothstep(
		duration - fade_time,
		duration,
		active_time
	);

	float visibility = fade_in * fade_out;

	// Gradually grow and shrink the vortex.
	float growth = mix(
		0.15,
		1.0,
		visibility
	);

	radius *= growth;

	vec2 p = uv - center;

	float distance_to_center = length(p);

	// Performance optimization:
	// Skip pixels outside the vortex area.
	if (distance_to_center > radius * 1.35) {
		return background;
	}

	float normalized_radius =
		distance_to_center / radius;

	float core_ratio = clamp(
		black_hole_core_ratio,
		0.05,
		0.5
	);

	// --------------------------------------
	// Rotating spiral arms
	// --------------------------------------

	float angle = atan(p.y, p.x + 0.000001);

	float rotation = active_time
		* black_hole_rotation_speed
		* direction;

	float radial_progress = clamp(
		(normalized_radius - core_ratio)
		/ (1.0 - core_ratio),
		0.0,
		1.0
	);

	// Spiral curvature.
	float spiral_angle = angle
		- rotation
		- radial_progress
		* black_hole_spiral_turns
		* tau
		* direction;

	// Two evenly spaced spiral arms by default.
	float arm_count = float(
		max(black_hole_arms, 1)
	);

	float spiral_phase = fract(
		spiral_angle * arm_count / tau + 0.5
	);

	float arm_distance = abs(
		spiral_phase - 0.5
	);

	// Arms become thinner toward their tips.
	float arm_width = black_hole_arm_width
		* mix(
			1.0,
			0.25,
			radial_progress
		);

	float spiral = 1.0 - smoothstep(
		arm_width * 0.35,
		arm_width,
		arm_distance
	);

	// Fade the outer ends of the spiral.
	float spiral_fade = pow(
		1.0 - radial_progress,
		1.25
	);

	// Keep the spiral outside the black core.
	float inner_mask = smoothstep(
		core_ratio,
		core_ratio + 0.025,
		normalized_radius
	);

	float outer_mask = 1.0 - smoothstep(
		0.85,
		1.0,
		normalized_radius
	);

	spiral *= spiral_fade
		* inner_mask
		* outer_mask;

	// --------------------------------------
	// Soft spiral glow
	// --------------------------------------

	float glow = exp(
		-arm_distance
		/ max(arm_width * 2.5, 0.001)
	);

	glow *= spiral_fade
		* inner_mask
		* outer_mask;

	// Subtle atmospheric halo.
	float halo = exp(
		-normalized_radius * 4.0
	);

	halo *= 1.0 - smoothstep(
		1.0,
		1.35,
		normalized_radius
	);

	// Combine spiral lighting.
	vec3 vortex_light = black_hole_color.rgb * (
		spiral * black_hole_brightness
		+ glow * black_hole_glow
		+ halo * black_hole_glow * 0.25
	);

	background += vortex_light * visibility;

	// --------------------------------------
	// Completely black central core
	// --------------------------------------

	float core = 1.0 - smoothstep(
		core_ratio * 0.90,
		core_ratio,
		normalized_radius
	);

	// Hide the stars behind the black hole.
	background = mix(
		background,
		vec3(0.0),
		core * visibility
	);

	return background;
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

	// Occasional shooting star.
	final_color += draw_shooting_star(
		aspect_uv,
		TIME
	);

	// Occasional black hole.
	final_color = draw_black_hole(
		aspect_uv,
		final_color,
		TIME
	);

	COLOR = vec4(final_color, 1.0);
}
