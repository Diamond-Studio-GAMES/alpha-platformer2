shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise;
uniform float uv_dist = 0.9;
uniform float pixels = 32.0;
uniform vec4 col1 : hint_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform vec4 col2 : hint_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 col3 : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 wind_speed = vec2(0.25, 0.15);
uniform float step1 = 0.7;
uniform float step2 = 0.5;
uniform float step3 = 0.3;

void fragment() {
	vec2 uv = UV;
	uv = round(uv * pixels) / pixels;
	float a = texture(TEXTURE, mix(uv, texture(noise, uv + wind_speed * TIME).rg, uv_dist)).r;
	
	float a1 = step(1.0 - step1, a);
	float a2 = step(1.0 - step2, a);
	float a3 = step(1.0 - step3, a);
	vec4 c1 = vec4(a1 - a2) * col1;
	vec4 c2 = vec4(a2 - a3) * col2;
	vec4 c3 = vec4(a3) * col3;
	vec4 c = c1 + c2 + c3;
	COLOR = c;
}