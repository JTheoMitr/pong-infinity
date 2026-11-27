shader_type canvas_item;

// ==========================================
// GENERAL SETTINGS
// ==========================================

uniform float aspect_ratio : hint_range(1.0, 4.0, 0.01) = 1.7778;
uniform float city_seed : hint_range(0.0, 100.0, 1.0) = 12.0;

// ==========================================
// SKY COLORS
// ==========================================

uniform vec4 sky_top : source_color = vec4(0.08, 0.04, 0.19, 1.0);
uniform vec4 sky_middle : source_color = vec4(0.24, 0.09, 0.34, 1.0);
uniform vec4 sky_horizon : source_color = vec4(0.36, 0.13, 0.38, 1.0);

// ==========================================
// NEON SUN
// ==========================================

uniform vec4 sun_top_color : source_color = vec4(1.0, 0.45, 0.65, 1.0);
uniform vec4 sun_bottom_color : source_color = vec4(0.75, 0.06, 0.40, 1.0);

uniform vec2 sun_position = vec2(0.5, 0.32);

uniform float sun_size : hint_range(0.05, 0.6, 0.01) = 0.27;
uniform float sun_brightness : hint_range(0.0, 2.0) = 0.85;
uniform float sun_pulse_speed : hint_range(0.0, 3.0) = 0.45;
uniform float sun_pulse_strength : hint_range(0.0, 0.5) = 0.12;

uniform float sun_glow : hint_range(0.0, 1.0) = 0.20;
uniform float sun_glow_size : hint_range(0.01, 0.5) = 0.16;

uniform float sun_stripe_count : hint_range(3.0, 30.0, 1.0) = 14.0;
uniform float sun_stripe_width : hint_range(0.0, 0.9) = 0.55;

// ==========================================
// CITY LAYERS
// ==========================================

uniform vec4 distant_city_color : source_color = vec4(0.18, 0.10, 0.27, 1.0);
uniform vec4 middle_city_color : source_color = vec4(0.10, 0.055, 0.17, 1.0);
uniform vec4 foreground_city_color : source_color = vec4(0.045, 0.025, 0.09, 1.0);

uniform float distant_density : hint_range(10.0, 80.0, 1.0) = 42.0;
uniform float middle_density : hint_range(5.0, 40.0, 1.0) = 19.0;
uniform float foreground_density : hint_range(4.0, 20.0, 1.0) = 9.0;

uniform float distant_min_height : hint_range(0.05, 0.8) = 0.35;
uniform float distant_max_height : hint_range(0.1, 0.95) = 0.58;

uniform float middle_min_height : hint_range(0.05, 0.8) = 0.30;
uniform float middle_max_height : hint_range(0.1, 0.95) = 0.72;

uniform float foreground_min_height : hint_range(0.05, 0.8) = 0.18;
uniform float foreground_max_height : hint_range(0.1, 0.95) = 0.43;

uniform float center_clearance : hint_range(0.0, 0.8) = 0.35;
uniform float pyramid_chance : hint_range(0.0, 1.0) = 0.35;

// ==========================================
// WINDOWS
// ==========================================

uniform vec4 window_cyan : source_color = vec4(0.12, 0.80, 0.95, 1.0);
uniform vec4 window_magenta : source_color = vec4(0.90, 0.20, 0.65, 1.0);
uniform vec4 window_warm : source_color = vec4(1.0, 0.65, 0.30, 1.0);

uniform float window_brightness : hint_range(0.0, 1.0) = 0.32;
uniform float window_on_chance : hint_range(0.0, 1.0) = 0.55;

uniform float window_change_interval : hint_range(1.0, 30.0) = 7.0;
uniform float window_width : hint_range(0.1, 0.9) = 0.38;
uniform float window_height : hint_range(0.1, 0.9) = 0.42;

uniform float window_spacing : hint_range(0.005, 0.08) = 0.024;

// ==========================================
// NEON LIGHTS AND ANTENNAS
// ==========================================

uniform vec4 neon_cyan : source_color = vec4(0.05, 0.85, 1.0, 1.0);
uniform vec4 neon_magenta : source_color = vec4(1.0, 0.08, 0.55, 1.0);

uniform float neon_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float neon_chance : hint_range(0.0, 1.0) = 0.45;

uniform float antenna_chance : hint_range(0.0, 1.0) = 0.40;
uniform float antenna_brightness : hint_range(0.0, 1.0) = 0.65;

// ==========================================
// HELICOPTER SETTINGS
// ==========================================

uniform vec4 helicopter_color : source_color = vec4(0.025, 0.015, 0.045, 1.0);

uniform float helicopter_min_size : hint_range(0.01, 0.2) = 0.06;
uniform float helicopter_max_size : hint_range(0.01, 0.3) = 0.12;

uniform float helicopter_interval : hint_range(5.0, 120.0) = 35.0;
uniform float helicopter_travel_time : hint_range(3.0, 30.0) = 12.0;
uniform float helicopter_spawn_chance : hint_range(0.0, 1.0) = 0.85;

uniform float helicopter_min_height : hint_range(0.0, 1.0) = 0.12;
uniform float helicopter_max_height : hint_range(0.0, 1.0) = 0.38;

uniform float helicopter_opacity : hint_range(0.0, 1.0) = 0.90;
uniform float helicopter_rotor_speed : hint_range(1.0, 60.0) = 24.0;
uniform float helicopter_bob : hint_range(0.0, 0.05) = 0.008;

// ==========================================
// ATMOSPHERIC HAZE
// ==========================================

uniform vec4 haze_color : source_color = vec4(0.42, 0.15, 0.45, 1.0);

uniform float haze_intensity : hint_range(0.0, 0.5) = 0.065;
uniform float haze_speed : hint_range(0.0, 1.0) = 0.08;

// ==========================================
// UTILITY FUNCTIONS
// ==========================================

float hash(vec2 p) {
	return fract(
		sin(dot(p, vec2(127.1, 311.7))) * 43758.5453
	);
}

float noise_2d(vec2 p) {

	vec2 cell = floor(p);
	vec2 f = fract(p);

	vec2 blend = f * f * (3.0 - 2.0 * f);

	float a = hash(cell);
	float b = hash(cell + vec2(1.0, 0.0));
	float c = hash(cell + vec2(0.0, 1.0));
	float d = hash(cell + vec2(1.0, 1.0));

	return mix(
		mix(a, b, blend.x),
		mix(c, d, blend.x),
		blend.y
	);
}

float box_mask(vec2 p, vec2 half_size) {

	vec2 distance_to_edge = abs(p) - half_size;

	float distance_field = max(
		distance_to_edge.x,
		distance_to_edge.y
	);

	return 1.0 - smoothstep(
		0.0,
		0.0015,
		distance_field
	);
}

// ==========================================
// NEON SUN
// ==========================================

vec3 draw_sun(vec2 uv, vec3 background, float time) {

	vec2 sun_uv = uv - sun_position;
	sun_uv.x *= aspect_ratio;

	float distance_to_sun = length(sun_uv);

	float pulse = 1.0 + sin(
		time * sun_pulse_speed
	) * sun_pulse_strength;

	// Soft atmospheric halo.
	float glow = exp(
		-max(distance_to_sun - sun_size, 0.0)
		/ max(sun_glow_size, 0.001)
	);

	background += sun_bottom_color.rgb
		* glow
		* sun_glow
		* pulse;

	// Circular sun.
	float sun_mask = 1.0 - smoothstep(
		sun_size - 0.002,
		sun_size + 0.002,
		distance_to_sun
	);

	float sun_depth = clamp(
		(sun_uv.y + sun_size) / (sun_size * 2.0),
		0.0,
		1.0
	);

	vec3 sun_color = mix(
		sun_top_color.rgb,
		sun_bottom_color.rgb,
		sun_depth
	);

	// Synthwave horizontal stripes.
	// Stripes become wider toward the bottom.
	float stripe_position = fract(
		sun_depth * sun_stripe_count
	);

	float stripe_strength = smoothstep(
		0.38,
		1.0,
		sun_depth
	) * sun_stripe_width;

	float stripe_mask = smoothstep(
		stripe_strength,
		stripe_strength + 0.025,
		stripe_position
	);

	sun_mask *= stripe_mask;

	return mix(
		background,
		sun_color * sun_brightness * pulse,
		sun_mask
	);
}

// ==========================================
// ANIMATED BUILDING WINDOWS
// ==========================================

vec3 draw_windows(
	vec2 uv,
	float building_id,
	float layer_seed,
	float time
) {

	vec2 window_uv = vec2(
		uv.x * aspect_ratio,
		uv.y
	) / max(window_spacing, 0.001);

	vec2 window_cell = floor(window_uv);
	vec2 window_local = fract(window_uv);

	vec2 window_seed = window_cell + vec2(
		building_id * 17.0,
		layer_seed * 23.0
	);

	float window_shape = box_mask(
		window_local - vec2(0.5),
		vec2(window_width, window_height) * 0.5
	);

	// Each window changes at a different time.
	float time_offset = hash(
		window_seed + vec2(7.0, 13.0)
	) * window_change_interval;

	float window_time = (
		time + time_offset
	) / max(window_change_interval, 0.1);

	float current_cycle = floor(window_time);
	float next_cycle = current_cycle + 1.0;

	float current_state = step(
		1.0 - window_on_chance,
		hash(window_seed + vec2(current_cycle, 0.0))
	);

	float next_state = step(
		1.0 - window_on_chance,
		hash(window_seed + vec2(next_cycle, 0.0))
	);

	// Smooth transition between on and off.
	float transition = smoothstep(
		0.85,
		1.0,
		fract(window_time)
	);

	float light_state = mix(
		current_state,
		next_state,
		transition
	);

	float color_roll = hash(
		window_seed + vec2(42.0, 19.0)
	);

	vec3 light_color = window_cyan.rgb;

	if (color_roll > 0.45) {
		light_color = window_magenta.rgb;
	}

	if (color_roll > 0.88) {
		light_color = window_warm.rgb;
	}

	return light_color
		* window_shape
		* light_state
		* window_brightness;
}

// ==========================================
// PROCEDURAL CITY LAYER
// ==========================================

vec3 draw_city_layer(
	vec2 uv,
	vec3 background,
	float density,
	float min_height,
	float max_height,
	vec3 building_color,
	float layer_seed,
	float detail_level,
	float allow_pyramids,
	float time
) {

	float city_x = uv.x * density
		+ layer_seed * 0.37;

	float building_id = floor(city_x);
	float building_x = fract(city_x);

	vec2 seed = vec2(
		building_id + city_seed,
		layer_seed
	);

	// Random building dimensions.
	float building_height = mix(
		min_height,
		max_height,
		hash(seed + vec2(4.0, 7.0))
	);

	float building_width = mix(
		0.65,
		0.94,
		hash(seed + vec2(8.0, 3.0))
	);

	// Keep the central skyline lower.
	float center_zone = 1.0 - smoothstep(
		0.0,
		0.38,
		abs(uv.x - 0.5)
	);

	building_height *= 1.0
		- center_zone * center_clearance;

	float building_top = 1.0 - building_height;

	float x_distance = abs(building_x - 0.5);

	float building_type = hash(
		seed + vec2(15.0, 27.0)
	);

	bool is_pyramid = allow_pyramids > 0.5
		&& building_type < pyramid_chance;

	float building_mask = 0.0;

	// --------------------------------------
	// Pyramid factories
	// --------------------------------------

	if (is_pyramid) {

		float pyramid_depth = clamp(
			(uv.y - building_top)
			/ max(building_height, 0.001),
			0.0,
			1.0
		);

		float pyramid_width = pyramid_depth
			* building_width * 0.5;

		building_mask = step(
			building_top,
			uv.y
		) * (
			1.0 - smoothstep(
				pyramid_width,
				pyramid_width + 0.012,
				x_distance
			)
		);

	// --------------------------------------
	// Skyscrapers and monoliths
	// --------------------------------------

	} else {

		float body_top = building_top;

		// Some buildings have stepped roofs.
		if (building_type > 0.65) {

			float roof_height = building_height * 0.12;

			body_top += roof_height;

			float roof_mask = step(
				building_top,
				uv.y
			) * step(
				uv.y,
				body_top
			) * step(
				x_distance,
				building_width * 0.28
			);

			building_mask = roof_mask;
		}

		float body_mask = step(
			body_top,
			uv.y
		) * step(
			x_distance,
			building_width * 0.5
		);

		building_mask = max(
			building_mask,
			body_mask
		);
	}

	// Slight variation between building colors.
	float shade = mix(
		0.80,
		1.18,
		hash(seed + vec2(32.0, 9.0))
	);

	vec3 structure_color = building_color * shade;

	// Subtle vertical shading.
	structure_color *= mix(
		1.0,
		0.78,
		building_x
	);

	// --------------------------------------
	// Windows and architectural lighting
	// --------------------------------------

	if (detail_level > 0.0 && building_mask > 0.0) {

		if (!is_pyramid) {

			float window_border = step(
				x_distance,
				building_width * 0.39
			);

			window_border *= step(
				building_top + 0.025,
				uv.y
			);

			structure_color += draw_windows(
				uv,
				building_id,
				layer_seed,
				time
			) * detail_level * window_border;
		}

		float neon_roll = hash(
			seed + vec2(31.0, 41.0)
		);

		if (neon_roll < neon_chance) {

			vec3 neon_color = mix(
				neon_cyan.rgb,
				neon_magenta.rgb,
				step(
					0.5,
					hash(seed + vec2(5.0, 61.0))
				)
			);

			float neon_mask = 0.0;

			if (is_pyramid) {

				float pyramid_depth = clamp(
					(uv.y - building_top)
					/ max(building_height, 0.001),
					0.0,
					1.0
				);

				float edge_position = pyramid_depth
					* building_width * 0.43;

				neon_mask = 1.0 - smoothstep(
					0.006,
					0.018,
					abs(x_distance - edge_position)
				);

			} else {

				float strip_position = building_width * 0.38;

				neon_mask = 1.0 - smoothstep(
					0.006,
					0.018,
					abs(x_distance - strip_position)
				);

				neon_mask *= step(
					building_top + 0.04,
					uv.y
				);
			}

			// Occasional asynchronous flickering.
			float flicker_time = floor(
				time * 3.0
				+ hash(seed) * 100.0
			);

			float flicker = mix(
				0.45,
				1.0,
				step(
					0.06,
					hash(seed + vec2(flicker_time, 8.0))
				)
			);

			structure_color += neon_color
				* neon_mask
				* neon_intensity
				* detail_level
				* flicker;
		}
	}

	background = mix(
		background,
		structure_color,
		building_mask
	);

	// --------------------------------------
	// Rooftop antennas
	// --------------------------------------

	if (!is_pyramid && detail_level > 0.0) {

		float antenna_roll = hash(
			seed + vec2(71.0, 13.0)
		);

		if (antenna_roll < antenna_chance) {

			float antenna_height = mix(
				0.025,
				0.075,
				hash(seed + vec2(19.0, 8.0))
			);

			float antenna_top = building_top
				- antenna_height;

			float antenna_mask = step(
				x_distance,
				0.018
			) * step(
				antenna_top,
				uv.y
			) * step(
				uv.y,
				building_top
			);

			background = mix(
				background,
				building_color,
				antenna_mask
			);

			// Blinking warning light.
			vec2 light_uv = vec2(
				(building_x - 0.5)
				* aspect_ratio / density,
				uv.y - antenna_top
			);

			float light_distance = length(light_uv);

			float antenna_light = 1.0 - smoothstep(
				0.002,
				0.005,
				light_distance
			);

			float blink = smoothstep(
				0.2,
				0.5,
				sin(
					time * 2.0
					+ hash(seed) * 30.0
				)
			);

			background += vec3(1.0, 0.12, 0.32)
				* antenna_light
				* blink
				* antenna_brightness
				* detail_level;
		}
	}

	return background;
}


// ==========================================
// HELICOPTER SHAPE
// ==========================================

float helicopter_ellipse(
	vec2 p,
	vec2 center,
	vec2 radius
) {
	float d = length((p - center) / radius);
	return 1.0 - smoothstep(0.94, 1.0, d);
}

float helicopter_segment(
	vec2 p,
	vec2 a,
	vec2 b,
	float thickness
) {
	vec2 pa = p - a;
	vec2 ba = b - a;

	float h = clamp(
		dot(pa, ba) / max(dot(ba, ba), 0.00001),
		0.0,
		1.0
	);

	float d = length(pa - ba * h);

	return 1.0 - smoothstep(
		thickness * 0.75,
		thickness,
		d
	);
}

float helicopter_shape(vec2 p, float time) {

	// Main fuselage.
	float body = helicopter_ellipse(
		p,
		vec2(0.08, 0.0),
		vec2(0.32, 0.14)
	);

	// Rounded cockpit.
	float cockpit = helicopter_ellipse(
		p,
		vec2(0.29, 0.015),
		vec2(0.17, 0.115)
	);

	// Upper engine housing.
	float engine = box_mask(
		p - vec2(0.0, -0.12),
		vec2(0.13, 0.055)
	);

	// Tail boom.
	float tail = helicopter_segment(
		p,
		vec2(-0.18, -0.025),
		vec2(-0.68, -0.09),
		0.035
	);

	// Vertical tail stabilizer.
	float tail_fin = helicopter_segment(
		p,
		vec2(-0.66, -0.09),
		vec2(-0.69, -0.23),
		0.035
	);

	// Main rotor mast.
	float mast = helicopter_segment(
		p,
		vec2(0.0, -0.14),
		vec2(0.0, -0.24),
		0.018
	);

	// Animated main rotor.
	float rotor_width = mix(
		0.12,
		0.57,
		abs(sin(time * helicopter_rotor_speed))
	);

	float rotor = box_mask(
		p - vec2(0.0, -0.25),
		vec2(rotor_width, 0.012)
	);

	// Animated tail rotor.
	float tail_angle = time * helicopter_rotor_speed * 1.7;

	vec2 tail_center = vec2(-0.68, -0.10);

	vec2 tail_blade = vec2(
		cos(tail_angle),
		sin(tail_angle)
	) * 0.085;

	float tail_rotor = helicopter_segment(
		p,
		tail_center - tail_blade,
		tail_center + tail_blade,
		0.012
	);

	// Landing skid supports.
	float front_support = helicopter_segment(
		p,
		vec2(0.23, 0.10),
		vec2(0.27, 0.22),
		0.016
	);

	float rear_support = helicopter_segment(
		p,
		vec2(-0.10, 0.10),
		vec2(-0.14, 0.22),
		0.016
	);

	// Landing skid.
	float skid = helicopter_segment(
		p,
		vec2(-0.23, 0.22),
		vec2(0.39, 0.22),
		0.018
	);

	// Curved front of the landing skid.
	float skid_tip = helicopter_segment(
		p,
		vec2(0.39, 0.22),
		vec2(0.44, 0.17),
		0.018
	);

	// Combine the silhouette.
	float shape = max(body, cockpit);

	shape = max(shape, engine);
	shape = max(shape, tail);
	shape = max(shape, tail_fin);
	shape = max(shape, mast);
	shape = max(shape, rotor);
	shape = max(shape, tail_rotor);
	shape = max(shape, front_support);
	shape = max(shape, rear_support);
	shape = max(shape, skid);
	shape = max(shape, skid_tip);

	return shape;
}

// ==========================================
// HELICOPTER FLIGHT ANIMATION
// ==========================================

vec3 draw_helicopter(
	vec2 uv,
	vec3 background,
	float time
) {

	float interval = max(helicopter_interval, 0.1);

	float cycle = floor(time / interval);
	float phase = mod(time, interval);

	vec2 seed = vec2(cycle, city_seed + 83.0);

	// Occasionally skip a flight.
	float spawn_roll = hash(seed + vec2(7.0, 12.0));

	if (spawn_roll >= helicopter_spawn_chance) {
		return background;
	}

	// Randomized helicopter size.
	float size = mix(
		helicopter_min_size,
		helicopter_max_size,
		hash(seed + vec2(17.0, 31.0))
	);

	// Randomized flight direction.
	float direction = mix(
		-1.0,
		1.0,
		step(
			0.5,
			hash(seed + vec2(9.0, 21.0))
		)
	);

	// Randomized flight duration.
	float duration = helicopter_travel_time * mix(
		0.85,
		1.15,
		hash(seed + vec2(41.0, 3.0))
	);

	duration = min(duration, interval * 0.90);
	duration = max(duration, 0.1);

	// Random departure time within the cycle.
	float departure_delay = hash(
		seed + vec2(23.0, 61.0)
	) * max(interval - duration, 0.0);

	float flight_phase = phase - departure_delay;

	// Only render during an active flight.
	if (flight_phase < 0.0 || flight_phase >= duration) {
		return background;
	}

	float progress = flight_phase / duration;

	// Ensure the entire helicopter starts and ends offscreen.
	float margin = size * 0.85 / aspect_ratio + 0.03;

	float helicopter_x = mix(
		-margin,
		1.0 + margin,
		progress
	);

	if (direction < 0.0) {
		helicopter_x = 1.0 - helicopter_x;
	}

	// Random flight altitude.
	float helicopter_y = mix(
		helicopter_min_height,
		helicopter_max_height,
		hash(seed + vec2(53.0, 11.0))
	);

	// Gentle vertical movement.
	helicopter_y += sin(
		time * 1.2 + cycle
	) * helicopter_bob;

	// Slight altitude change during the flight.
	helicopter_y += sin(progress * 3.14159)
		* (hash(seed + vec2(8.0, 73.0)) - 0.5)
		* 0.035;

	vec2 helicopter_uv = uv - vec2(
		helicopter_x,
		helicopter_y
	);

	// Correct proportions and face the direction of travel.
	helicopter_uv.x *= aspect_ratio * direction;
	helicopter_uv /= max(size, 0.001);

	// Skip silhouette calculations outside its bounding area.
	if (
		abs(helicopter_uv.x) > 0.85 ||
		abs(helicopter_uv.y) > 0.35
	) {
		return background;
	}

	float helicopter = helicopter_shape(
		helicopter_uv,
		time
	);

	return mix(
		background,
		helicopter_color.rgb,
		helicopter * helicopter_opacity
	);
}

// ==========================================
// MAIN SHADER
// ==========================================

void fragment() {

	vec2 uv = UV;
	float time = TIME;

	// --------------------------------------
	// Purple atmospheric sky
	// --------------------------------------

	vec3 color = mix(
		sky_top.rgb,
		sky_middle.rgb,
		smoothstep(0.0, 0.65, uv.y)
	);

	color = mix(
		color,
		sky_horizon.rgb,
		smoothstep(0.45, 1.0, uv.y)
	);

	// --------------------------------------
	// Neon sun behind the city
	// --------------------------------------

	color = draw_sun(
		uv,
		color,
		time
	);
	
	// --------------------------------------
	// Passing helicopter
	// --------------------------------------

	color = draw_helicopter(
		uv,
		color,
		time
	);

	// --------------------------------------
	// Distant skyline
	// --------------------------------------

	color = draw_city_layer(
		uv,
		color,
		distant_density,
		distant_min_height,
		distant_max_height,
		distant_city_color.rgb,
		10.0,
		0.0,
		0.0,
		time
	);

	// --------------------------------------
	// Distant atmospheric haze
	// --------------------------------------

	float distant_haze = noise_2d(
		vec2(
			uv.x * 5.0 + time * haze_speed,
			uv.y * 8.0
		)
	);

	float haze_band = exp(
		-pow((uv.y - 0.65) * 5.0, 2.0)
	);

	color = mix(
		color,
		haze_color.rgb,
		distant_haze
		* haze_band
		* haze_intensity
	);

	// --------------------------------------
	// Middle city
	// --------------------------------------

	color = draw_city_layer(
		uv,
		color,
		middle_density,
		middle_min_height,
		middle_max_height,
		middle_city_color.rgb,
		25.0,
		0.65,
		0.0,
		time
	);

	// --------------------------------------
	// Foreground industrial city
	// --------------------------------------

	color = draw_city_layer(
		uv,
		color,
		foreground_density,
		foreground_min_height,
		foreground_max_height,
		foreground_city_color.rgb,
		50.0,
		1.0,
		1.0,
		time
	);

	// --------------------------------------
	// Foreground drifting haze
	// --------------------------------------

	float foreground_haze = noise_2d(
		vec2(
			uv.x * 7.0 - time * haze_speed,
			uv.y * 12.0
		)
	);

	float foreground_band = exp(
		-pow((uv.y - 0.88) * 6.0, 2.0)
	);

	color = mix(
		color,
		haze_color.rgb,
		foreground_haze
		* foreground_band
		* haze_intensity
		* 0.65
	);

	COLOR = vec4(color, 1.0);
}