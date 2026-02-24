shader_type canvas_item;
render_mode blend_mix;

uniform float noise_scale = 300.0;
uniform float noise_speed = 5.0;
uniform float static_intensity = 9.0;
uniform float roll_speed = 0.5;

uniform float opacity : hint_range(0.0, 1.0) = 1.0;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float time = TIME;

	// --- Rolling vertical motion ---
	uv.y += time * roll_speed;

	// --- High frequency noise ---
	float noise = random(vec2(
		floor(uv.x * noise_scale),
		floor(uv.y * noise_scale + time * noise_speed)
	));

	// --- Grain variation ---
	float grain = random(uv * noise_scale * 1.5 + time);

	float static_value = mix(noise, grain, 215.7) * static_intensity;

	COLOR = vec4(vec3(static_value), opacity);
}