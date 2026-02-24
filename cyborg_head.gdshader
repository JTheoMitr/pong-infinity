shader_type canvas_item;
render_mode blend_mix;

uniform float glitch_intensity = 0.02;   // master control
uniform float glitch_speed = 8.0;
uniform float rgb_shift = 1.5;           // pixels

float random(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * glitch_speed;

	// --- RANDOM GLITCH TRIGGER ---
	float glitch_trigger = step(0.85, random(vec2(floor(t), 0.0)));

	if (glitch_trigger > 0.0) {
		// Horizontal slice shift
		float slice = floor(uv.y * 20.0);
		float offset = (random(vec2(slice, t)) - 0.5) * glitch_intensity;
		uv.x += offset;
	}

	// --- RGB SPLIT ---
	vec2 shift = vec2(rgb_shift / 1024.0, 0.0);

	float r = texture(TEXTURE, uv + shift).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - shift).b;

	vec4 color = vec4(r, g, b, texture(TEXTURE, uv).a);

	COLOR = vec4(color.rgb, color.a * COLOR.a);
}