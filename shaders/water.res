RSRC                    Shader                                                                       resource_local_to_scene    resource_name    code    custom_defines    script           res://shaders/water.res �          Shader          �  shader_type canvas_item;

render_mode unshaded;

uniform float distortion = 0.01;
uniform float time_multiplier = 0.5;
uniform sampler2D noise0;
uniform sampler2D noise1;

void fragment() {
	float time_m = TIME * time_multiplier;
	float dist0 = texture(noise0, UV + time_m, 0.0).r * distortion;
	float dist1 = texture(noise1, UV - time_m, 0.0).r * distortion;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV - dist1 + dist0, 0.0);
} RSRC