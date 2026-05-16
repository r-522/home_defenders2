shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;

uniform vec3 grass_a : source_color = vec3(0.18, 0.32, 0.14);
uniform vec3 grass_b : source_color = vec3(0.32, 0.46, 0.22);
uniform vec3 stone   : source_color = vec3(0.55, 0.55, 0.58);
uniform float plaza_radius = 9.0;
uniform float plaza_edge   = 1.8;
uniform float noise_scale  = 0.18;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f*f*(3.0-2.0*f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a,b,f.x), mix(c,d,f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 wp = VERTEX.xz; // local space (plane spans the world)
    float n = fbm(wp * noise_scale);
    vec3 grass = mix(grass_a, grass_b, smoothstep(0.35, 0.75, n));

    // ひび割れ風の暗線
    float crack = smoothstep(0.78, 0.82, vnoise(wp * 0.6));
    grass = mix(grass, grass * 0.65, crack * 0.4);

    // 中央の石畳広場
    float d = length(wp);
    float plaza = 1.0 - smoothstep(plaza_radius - plaza_edge, plaza_radius, d);
    float bricks = step(0.55, fract(wp.x * 0.6) ) * step(0.55, fract(wp.y * 0.6));
    vec3 stone_c = mix(stone * 0.85, stone, bricks);
    vec3 col = mix(grass, stone_c, plaza);

    ALBEDO = col;
    ROUGHNESS = mix(0.92, 0.65, plaza);
}
