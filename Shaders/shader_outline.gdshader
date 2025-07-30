shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always, blend_mix;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
}
