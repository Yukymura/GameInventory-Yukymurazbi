shader_type canvas_item;

uniform int pixel_size = 8;

void fragment() {
	// 直接对屏幕坐标进行像素化
	vec2 pixel_uv = floor(UV * float(pixel_size)) / float(pixel_size);
	COLOR = texture(TEXTURE, pixel_uv);
}