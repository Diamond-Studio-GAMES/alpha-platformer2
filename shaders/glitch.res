RSRC                    Shader                                                                       resource_local_to_scene    resource_name    code    custom_defines    script           res://shaders/glitch.res �          Shader          u  shader_type canvas_item;
render_mode unshaded;

uniform float glitch = 0;

void fragment() {
	float glitch_scale = glitch/50.0;
	COLOR.r = textureLod(SCREEN_TEXTURE, vec2(SCREEN_UV.x - glitch_scale, SCREEN_UV.y), 0.0).r;
	COLOR.g = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).g;
	COLOR.b = textureLod(SCREEN_TEXTURE, vec2(SCREEN_UV.x + glitch_scale, SCREEN_UV.y), 0.0).b;
} RSRC