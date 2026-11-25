
shader_type canvas_item;

// ==========================================
// OCEAN COLORS
// ==========================================

uniform vec4 surface_color : source_color = vec4(0.610, 0.335, 0.460, 1.0);
uniform vec4 middle_color : source_color = vec4(0.105, 0.140, 0.290, 1.0);
uniform vec4 deep_color : source_color = vec4(0.035, 0.225, 0.415, 1.0);

uniform float water_speed : hint_range(0.0, 2.0) = 0.25;
uniform float aspect_ratio : hint_range(0.5, 3.0) = 1.0;

// ==========================================
// LIGHT RAYS AND PARTICLES
// ==========================================

uniform float ray_intensity : hint_range(0.0, 0.3) = 0.055;
uniform float ray_density : hint_range(1.0, 20.0) = 8.0;

uniform float particle_intensity : hint_range(0.0, 0.3) = 0.045;
uniform float particle_density : hint_range(5.0, 60.0) = 25.0;

// ==========================================
// MARINE LIFE
// ==========================================

uniform float shark_min_size : hint_range(0.1, 1.0) = 0.25;
uniform float shark_max_size : hint_range(0.5, 2.0) = 1.20;

uniform float megalodon_min_size : hint_range(1.0, 3.0) = 1.50;
uniform float megalodon_max_size : hint_range(1.5, 4.0) = 2.50;
uniform float megalodon_chance : hint_range(0.0, 1.0) = 0.10;

uniform float shark_interval : hint_range(10.0, 25.0) = 20.0;
uniform float shark_travel_time : hint_range(5.0, 40.0) = 22.0;
uniform float shark_opacity : hint_range(0.0, 1.0) = 0.35;

uniform float shark_min_depth : hint_range(0.0, 1.0) = 0.05;
uniform float shark_max_depth : hint_range(0.0, 1.0) = 0.95;

uniform float fish_size : hint_range(0.005, 0.38) = 0.12;
uniform float fish_interval : hint_range(5.0, 20.0) = 10.0;
uniform float fish_travel_time : hint_range(3.0, 20.0) = 10.0;
uniform float fish_opacity : hint_range(0.8, 1.0) = 0.85;

uniform float fish_min_depth : hint_range(0.0, 1.0) = 0.05;
uniform float fish_max_depth : hint_range(0.0, 1.0) = 0.95;

// ==========================================
// UTILITY FUNCTIONS
// ==========================================

float hash(vec2 p) {
	return fract(
		sin(dot(p, vec2(127.1, 311.7))) * 43758.5453
	);
}

float ellipse_mask(vec2 p, vec2 center, vec2 radius) {
	float d = length((p - center) / radius);
	return 1.0 - smoothstep(0.92, 1.0, d);
}

float cross_2d(vec2 a, vec2 b) {
	return a.x * b.y - a.y * b.x;
}

float triangle_mask(vec2 p, vec2 a, vec2 b, vec2 c) {
	float d1 = cross_2d(b - a, p - a);
	float d2 = cross_2d(c - b, p - b);
	float d3 = cross_2d(a - c, p - c);

	float winding = sign(cross_2d(b - a, c - a));

	float edge = min(
		min(d1 * winding, d2 * winding),
		d3 * winding
	);

	return smoothstep(0.0, 0.003, edge);
}

// ==========================================
// SHARK SILHOUETTE
// ==========================================

float shark_shape(vec2 p, float time) {

	// Main body and rounded head.
	float body = ellipse_mask(
		p, vec2(0.03, 0.0), vec2(0.43, 0.115)
	);

	float head = ellipse_mask(
		p, vec2(0.34, 0.005), vec2(0.18, 0.095)
	);

	// Dorsal fin.
	float dorsal = triangle_mask(
		p,
		vec2(-0.13, -0.07),
		vec2(-0.04, -0.32),
		vec2(0.14, -0.07)
	);

	// Pectoral fin.
	float fin = triangle_mask(
		p,
		vec2(-0.08, 0.06),
		vec2(-0.22, 0.24),
		vec2(0.15, 0.07)
	);

	// Gently moving tail.
	float tail_motion = sin(time * 2.8) * 0.045;

	float tail_base = triangle_mask(
		p,
		vec2(-0.25, -0.065),
		vec2(-0.56, tail_motion),
		vec2(-0.25, 0.065)
	);

	float tail_upper = triangle_mask(
		p,
		vec2(-0.43, tail_motion),
		vec2(-0.72, -0.23 + tail_motion),
		vec2(-0.58, tail_motion)
	);

	float tail_lower = triangle_mask(
		p,
		vec2(-0.43, tail_motion),
		vec2(-0.69, 0.19 + tail_motion),
		vec2(-0.58, tail_motion)
	);

	return max(
		max(body, head),
		max(
			max(dorsal, fin),
			max(tail_base, max(tail_upper, tail_lower))
		)
	);
}

// ==========================================
// SMALL FISH SILHOUETTE
// ==========================================

float fish_shape(vec2 p, float time) {

	float body = ellipse_mask(
		p,
		vec2(0.06, 0.0),
		vec2(0.32, 0.15)
	);

	float tail_motion = sin(time * 5.0) * 0.06;

	float tail = triangle_mask(
		p,
		vec2(-0.15, 0.0),
		vec2(-0.48, -0.20 + tail_motion),
		vec2(-0.48, 0.20 + tail_motion)
	);

	return max(body, tail);
}

// ==========================================
// MAIN SHADER
// ==========================================

void fragment() {

	vec2 uv = UV;
	float time = TIME;
	float depth = uv.y;

	// --------------------------------------
	// Layered ocean gradient
	// --------------------------------------

	vec3 color = mix(
		surface_color.rgb,
		middle_color.rgb,
		smoothstep(0.0, 0.55, depth)
	);

	color = mix(
		color,
		deep_color.rgb,
		smoothstep(0.35, 1.0, depth)
	);

	float water_motion = sin(
		uv.x * 8.0 +
		uv.y * 5.0 +
		time * water_speed
	);

	color += vec3(0.005, 0.012, 0.022)
		* water_motion;

	// --------------------------------------
	// Underwater light rays
	// --------------------------------------

	float ray_x = uv.x
		+ uv.y * 0.28
		+ sin(time * water_speed * 0.3) * 0.05;

	float rays = sin(
		ray_x * ray_density * 6.28318
		+ sin(ray_x * 11.0)
	);

	rays = pow(max(rays, 0.0), 5.0);

	float ray_fade = pow(
		max(1.0 - depth, 0.0), 2.5
	);

	color += vec3(0.20, 0.65, 1.0)
		* rays
		* ray_fade
		* ray_intensity;

	// --------------------------------------
	// Suspended particles
	// --------------------------------------

	vec2 particle_uv = uv * particle_density;

	particle_uv.x *= aspect_ratio;
	particle_uv.x += time * 0.045;
	particle_uv.y += time * 0.065;

	vec2 cell = floor(particle_uv);
	vec2 local = fract(particle_uv);

	vec2 particle_center = vec2(
		0.2 + hash(cell) * 0.6,
		0.2 + hash(cell + vec2(13.7, 8.3)) * 0.6
	);

	float particle = 1.0 - smoothstep(
		0.025,
		0.075,
		length(local - particle_center)
	);

	float particle_exists = step(
		0.65,
		hash(cell + vec2(9.0, 3.0))
	);

	color += vec3(0.3, 0.65, 0.9)
		* particle
		* particle_exists
		* particle_intensity;

// --------------------------------------
// Randomized sharks and rare Megalodons
// --------------------------------------

float shark_cycle = floor(time / shark_interval);
float shark_phase = mod(time, shark_interval);

// Determine the shark's size class.
float size_roll = hash(vec2(shark_cycle, 17.0));
float size_variation = hash(vec2(shark_cycle, 31.0));

bool is_megalodon = size_roll < megalodon_chance;

float current_shark_size;
float current_shark_opacity;
float current_travel_time;
float tail_speed;

if (is_megalodon) {

	// Rare, enormous shark.
	current_shark_size = mix(
		megalodon_min_size,
		megalodon_max_size,
		size_variation
	);

	current_shark_opacity = shark_opacity * 0.85;
	current_travel_time = shark_travel_time * 1.5;
	tail_speed = 0.45;

} else {

	// Randomize between small and large sharks.
	float normal_roll = hash(vec2(shark_cycle, 42.0));

	float size_split = mix(
		shark_min_size,
		shark_max_size,
		0.37
	);

	if (normal_roll < 0.61) {

		current_shark_size = mix(
			shark_min_size,
			size_split,
			size_variation
		);

	} else {

		current_shark_size = mix(
			size_split,
			shark_max_size,
			size_variation
		);
	}

	current_shark_opacity = shark_opacity;

	current_travel_time = shark_travel_time * mix(
		0.65,
		1.0,
		size_variation
	);

	tail_speed = mix(1.3, 0.8, size_variation);
}

// Leave a small gap between appearances.
float shark_duration = min(
	current_travel_time,
	shark_interval * 0.95
);

if (shark_phase < shark_duration) {

	float progress = shark_phase / shark_duration;

	// Random swimming direction.
	float direction = mix(
		-1.0,
		1.0,
		step(0.5, hash(vec2(shark_cycle, 7.0)))
	);

	// Scale the offscreen distance to the shark's size.
	// Even enormous sharks enter and exit naturally.
	float travel_margin = (
		current_shark_size * 0.8 / aspect_ratio
	) + 0.05;

	float shark_x = mix(
		-travel_margin,
		1.0 + travel_margin,
		progress
	);

	if (direction < 0.0) {
		shark_x = 1.0 - shark_x;
	}

	// Swim at different heights throughout the table.
	float shark_y = mix(
		shark_min_depth,
		shark_max_depth,
		hash(vec2(shark_cycle, 4.0))
	);

	// Gentle vertical movement while swimming.
	shark_y += sin(
		time * 0.4 + shark_cycle
	) * 0.018;

	// Slight vertical change during the crossing.
	shark_y += sin(progress * 3.14159) * (
		hash(vec2(shark_cycle, 53.0)) - 0.5
	) * 0.12;

	vec2 shark_uv = uv - vec2(shark_x, shark_y);

	shark_uv.x *= aspect_ratio * direction;
	shark_uv /= current_shark_size;

	float shark = shark_shape(
		shark_uv,
		time * tail_speed
	);

	color = mix(
		color,
		color * 0.12,
		shark * current_shark_opacity
	);
}

	// --------------------------------------
	// Schools of fish
	// --------------------------------------

	float fish_time = time + 7.0;
	float fish_cycle = floor(fish_time / fish_interval);
	float fish_phase = mod(fish_time, fish_interval);

	float fish_duration = min(
		fish_travel_time,
		fish_interval
	);

	if (fish_phase < fish_duration) {

		float progress = fish_phase / fish_duration;

		float direction = mix(
			-1.0,
			1.0,
			step(0.5, hash(vec2(fish_cycle, 12.0)))
		);

		float school_margin = 0.16 + (
			fish_size * 1.5 * 0.5 / aspect_ratio
		);

		float school_x = mix(
			-school_margin,
			1.0 + school_margin,
			progress
		);

		if (direction < 0.0) {
			school_x = 1.0 - school_x;
		}

		float school_y = mix(
			fish_min_depth,
			fish_max_depth,
			hash(vec2(fish_cycle, 23.0))
		);

		// Gentle vertical movement of the entire school.
		school_y += sin(
			progress * 6.28318 + fish_cycle
		) * 0.035;

		float school = 0.0;

		for (int i = 0; i < 20; i++) {

			float index = float(i);

			float offset_x = (
				hash(vec2(index, fish_cycle)) - 0.5
			) * 0.28;

			float offset_y = (
				hash(vec2(index + 19.0, fish_cycle)) - 0.5
			) * 0.12;

			vec2 fish_position = vec2(
				school_x + offset_x,
				school_y + offset_y
			);

			fish_position.y += sin(
				time * 1.4 + index * 0.7
			) * 0.008;

			float individual_size = fish_size * mix(
				0.45,
				1.50,
				hash(vec2(index, fish_cycle + 5.0))
			);

			vec2 fish_uv = uv - fish_position;

			fish_uv.x *= aspect_ratio * direction;
			fish_uv /= individual_size;

			school = max(
				school,
				fish_shape(fish_uv, time + index)
			);
		}

		color = mix(
			color,
			color * 0.15,
			school * fish_opacity
		);
	}

	COLOR = vec4(color, 1.0);
}
