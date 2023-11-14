shader_type canvas_item;

uniform float power = 1.0;
uniform float time_multiplier = 1.0;

void vertex() {
	VERTEX.y += sin(TIME * time_multiplier + VERTEX.x) * power;
}