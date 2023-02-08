RSRC                    Shader                                                                       resource_local_to_scene    resource_name    code    custom_defines    script           res://shaders/fire.res �          Shader          �  shader_type canvas_item;

uniform sampler2D noise;
uniform float uv_dist = 0.9;
uniform float pixels = 32.;
uniform vec4 col1 = vec4(1., 0.5, 0., 1.);
uniform vec4 col2 = vec4(1., 1., 0., 1.);
uniform vec4 col3 = vec4(1., 1., 1., 1.);
uniform vec2 wind_speed = vec2(0.25, 0.15);
uniform float step1 = 0.7;
uniform float step2 = 0.5;
uniform float step3 = 0.3;

void fragment() {
//	vec2 uv = UV;
//	uv = round(uv * pixels) / pixels;
//	vec2 coord1 = uv * 10.0 + speed1 * TIME;
//	vec2 coord2 = uv * 10.0 + speed2 * TIME;
//
//	float noise_perlin;
//	float noise_voronoi;
//	noise_perlin = noise(coord1);
//	vec2 noise_uv = mix(uv, vec2(noise_perlin), uv_dist);
//	vec4 texr = texture(TEXTURE, noise_uv);
//
//	float a = texr.r * mix(1, noise_voronoi, voron_am);
//	float a1 = step(1. - step1, a);
//	float a2 = step(1. - step2, a);
//	float a3 = step(1. - step3, a);
//	vec4 c1 = vec4(a1 - a2) * col1;
//	vec4 c2 = vec4(a2 - a3) * col2;
//	vec4 c3 = vec4(a3) * col3;
//	vec4 c = c1 + c2 + c3;
//	COLOR = c;
	vec2 uv = UV;
	uv = round(uv * pixels) / pixels;
	vec4 noiset = texture(noise, uv  + wind_speed * TIME);
	vec2 noise_uv = mix(uv, noiset.rg, uv_dist);
	vec4 texr = texture(TEXTURE, noise_uv);
	
	float a = texr.r;
	float a1 = step(1. - step1, a);
	float a2 = step(1. - step2, a);
	float a3 = step(1. - step3, a);
	vec4 c1 = vec4(a1 - a2) * col1;
	vec4 c2 = vec4(a2 - a3) * col2;
	vec4 c3 = vec4(a3) * col3;
	vec4 c = c1 + c2 + c3;
	COLOR = c;
}
 RSRC