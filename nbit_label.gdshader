shader_type canvas_item;

uniform float flicker_strength = .18;
uniform float flicker_speed = 8.0;

uniform float rgb_shift = 1.0; // pixels-ish
uniform float glitch_intensity = 0.68;
uniform float glitch_speed = 2.0;

float random(vec2 co) {
	return fract(
		sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453
	);
}

void fragment() {
	vec2 uv = UV;

	float t = TIME * glitch_speed;

	// Occasional horizontal slice shift
	float glitch_trigger = step(
		0.88,
		random(vec2(floor(t), 0.0))
	);

	if (glitch_trigger > 0.0) {
		float slice = floor(uv.y * 24.0);

		float offset = (
			random(vec2(slice, floor(t))) - 0.5
		) * glitch_intensity;

		uv.x += offset;
	}

	// Base text sample
	vec4 base = texture(TEXTURE, uv);

	// RGB split
	vec2 shift = vec2(
		rgb_shift / 1024.0,
		0.0
	);

	float r = texture(TEXTURE, uv + shift).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - shift).b;

	vec3 rgb = vec3(r, g, b);

	// Flicker brightness
	float flicker = 1.0 - (
		random(vec2(
			floor(TIME * flicker_speed),
			1.0
		)) * flicker_strength
	);

	rgb *= flicker;

	// Preserve RichTextLabel tint + alpha
	COLOR = vec4(
		rgb * COLOR.rgb,
		base.a * COLOR.a
	);
}