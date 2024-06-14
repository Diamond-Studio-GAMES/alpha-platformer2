shader_type canvas_item;

render_mode unshaded;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float color = (tex.r + tex.g + tex.b) / 3.0;
	tex.rgb = vec3(color);
	COLOR = tex;
}