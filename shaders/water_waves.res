RSRC                    Shader                                                                       resource_local_to_scene    resource_name    code    custom_defines    script           res://shaders/water_waves.res �          Shader          �   shader_type canvas_item;

uniform float height = 15.0;
uniform float speed = 20.0;
uniform float coefficent = 20.0;

void fragment() {
	COLOR = texture(TEXTURE, UV + vec2(0, sin(TIME * speed + UV.x * coefficent)/height));
} RSRC