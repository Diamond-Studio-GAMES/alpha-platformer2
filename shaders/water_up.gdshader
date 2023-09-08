shader_type canvas_item;

uniform float distortion = 0.01;
uniform float time_multiplier = 0.5;
uniform sampler2D noise0;
uniform sampler2D noise1;
uniform float height = 15.0;
uniform float speed = 20.0;
uniform float coefficent = 20.0;

void fragment() {
	float time_m = TIME * time_multiplier;
	float dist0 = texture(noise0, UV + time_m, 0.0).r * distortion;
	float dist1 = texture(noise1, UV - time_m, 0.0).r * distortion;
	vec4 tex_clr = texture(TEXTURE, UV + vec2(0, sin(TIME * speed + UV.x * coefficent)/height));
	COLOR.rgb = mix(textureLod(SCREEN_TEXTURE, SCREEN_UV - dist1 + dist0, 0.0).rgb, tex_clr.rgb, tex_clr.a);
	COLOR.a = sign(tex_clr.a);
}