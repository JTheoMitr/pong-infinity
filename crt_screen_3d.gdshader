shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_opaque;

uniform sampler2D screen_texture : source_color;
uniform float brightness = 1.2;
uniform float scanline_strength = 0.68;
uniform float scanline_count = 240.0;
uniform float flicker_strength = 0.08;
uniform float glitch_strength = 0.015;
uniform vec4 tint : source_color = vec4(0.55, 0.9, 1.0, 1.0);

float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;

	// Small horizontal glitch bands
	float band = step(0.985, rand(vec2(floor(uv.y * 40.0), floor(TIME * 12.0))));
	uv.x += band * glitch_strength * sin(TIME * 40.0);

	vec4 col = texture(screen_texture, uv);

	// Scanlines
	float scanline = sin(uv.y * scanline_count * 3.14159);
	float scan = 1.0 - scanline_strength * (scanline * 0.5 + 0.5);

	// Flicker
	float flicker = 1.0 - rand(vec2(TIME * 20.0, uv.y)) * flicker_strength;

	col.rgb *= scan * flicker * brightness;
	// col.rgb *= tint.rgb;

	ALBEDO = col.rgb;
	ALPHA = col.a * tint.a;
}