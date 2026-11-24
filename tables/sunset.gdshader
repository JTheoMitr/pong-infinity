
shader_type canvas_item;
render_mode unshaded;

uniform float cycle_duration : hint_range(20.0, 180.0, 1.0) = 120.0;
uniform float cloud_speed : hint_range(0.0, 0.1, 0.001) = 0.015;
uniform float cloud_opacity : hint_range(0.0, 1.0) = 0.35;

uniform vec4 day_top : source_color = vec4(0.08, 0.43, 0.83, 1.0);
uniform vec4 day_bottom : source_color = vec4(0.42, 0.76, 0.95, 1.0);

uniform vec4 sunset_top : source_color = vec4(0.40, 0.26, 0.65, 1.0);
uniform vec4 sunset_bottom : source_color = vec4(0.98, 0.43, 0.55, 1.0);

uniform vec4 night_top : source_color = vec4(0.035, 0.018, 0.12, 1.0);
uniform vec4 night_bottom : source_color = vec4(0.19, 0.08, 0.32, 1.0);

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(
        mix(a, b, f.x),
        mix(c, d, f.x),
        f.y
    );
}

float clouds(vec2 uv, float time) {
    // Drift across the screen in UV coordinates.
    // 0.01 = 1% of screen width per second.
    vec2 moving_uv = uv;
    moving_uv.x += time * cloud_speed;

    vec2 p = moving_uv * vec2(4.0, 6.0);

    // Warp coordinates to hide the underlying noise grid.
    vec2 warp = vec2(
        noise2d(p * 0.45 + vec2(12.7, 4.3)),
        noise2d(p * 0.45 + vec2(3.1, 19.8))
    );

    p += (warp - 0.5) * 1.8;

    float n = noise2d(p) * 0.50;
    n += noise2d(p * 2.03 + 7.3) * 0.30;
    n += noise2d(p * 4.07 + 13.1) * 0.20;

    return smoothstep(0.62, 0.76, n);
}

void fragment() {
    vec2 uv = UV;

    // 0 = day, 0.5 = night, 1 = day.
    float phase = mod(TIME, cycle_duration) / cycle_duration;
    float transition = 0.5 - 0.5 * cos(phase * 6.2831853);

    vec3 top_color;
    vec3 bottom_color;

    if (transition < 0.5) {
        float t = smoothstep(0.0, 0.5, transition);

        top_color = mix(day_top.rgb, sunset_top.rgb, t);
        bottom_color = mix(day_bottom.rgb, sunset_bottom.rgb, t);
    } else {
        float t = smoothstep(0.5, 1.0, transition);

        top_color = mix(sunset_top.rgb, night_top.rgb, t);
        bottom_color = mix(sunset_bottom.rgb, night_bottom.rgb, t);
    }

    vec3 sky = mix(top_color, bottom_color, uv.y);

    // Clouds drift slowly across the sky.
    float cloud = clouds(uv, TIME);

    vec3 cloud_color = mix(
        vec3(1.0),
        vec3(0.60, 0.43, 0.68),
        transition
    );

    sky = mix(
        sky,
        cloud_color,
        cloud * cloud_opacity
    );

    // Small distant celestial body.
    vec2 body_position = vec2(0.77, 0.25);
    float body_distance = length(
        (uv - body_position) * vec2(1152.0 / 648.0, 1.0)
    );

    float body = 1.0 - smoothstep(
	    0.080,
	    0.084,
	    body_distance
	);

    // Warm sun gradually becomes a pale moon.
    vec3 sun_color = vec3(1.0, 0.84, 0.42);
    vec3 moon_color = vec3(0.82, 0.87, 1.0);

    vec3 body_color = mix(
        sun_color,
        moon_color,
        transition
    );

    sky = mix(sky, body_color, body);

    COLOR = vec4(sky, 1.0);
}
