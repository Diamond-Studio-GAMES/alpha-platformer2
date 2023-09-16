shader_type canvas_item;

uniform float wind_power = 1;
uniform float wind_speed = 1;
uniform float time_offset = 0;

void vertex() {
	VERTEX.x += sin(TIME * wind_speed + time_offset) * wind_power * (1.0-UV.y);
}