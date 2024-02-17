shader_type canvas_item;
render_mode unshaded;

uniform float glitch = 0;
uniform float shift_glitch = 0;
uniform sampler2D shift_glitch_texture;

void fragment() {
	float glitch_scale = glitch / 50.0;
	vec2 screen_uv = SCREEN_UV + (texture(shift_glitch_texture, UV).xy - vec2(0.5)) * shift_glitch;
	COLOR.r = textureLod(SCREEN_TEXTURE, vec2(screen_uv.x - glitch_scale, screen_uv.y), 0.0).r;
	COLOR.g = textureLod(SCREEN_TEXTURE, screen_uv, 0.0).g;
	COLOR.b = textureLod(SCREEN_TEXTURE, vec2(screen_uv.x + glitch_scale, screen_uv.y), 0.0).b;
}