shader_type canvas_item;

render_mode unshaded;

uniform sampler2D mapped_texture;

void fragment() {
	COLOR = texture(mapped_texture, texture(TEXTURE, UV).xy);
}