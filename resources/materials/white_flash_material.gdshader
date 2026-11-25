shader_type canvas_item;

instance uniform bool on = false;


void fragment() {
	if (on && COLOR.a > 0.0) {
		COLOR.rgb = vec3(1.0);
	}
}
