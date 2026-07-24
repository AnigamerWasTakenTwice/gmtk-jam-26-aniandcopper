shader_type canvas_item;

uniform sampler2D override_texture;

uniform vec4 clear_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float tolerance = 0.05;

uniform vec2 direction;
uniform float speed;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
    
	bool is_pure_black = (tex_color.r == 0.0 && tex_color.g == 0.0 && tex_color.b == 0.0);
	bool is_near_black = length(tex_color.rgb) < 0.01;

	vec2 move = direction * TIME * speed;


	if (is_near_black) {
		vec4 new_color = texture(override_texture, UV+move);
		COLOR = texture(override_texture, fract(UV+move));
		
	}
	 if (distance(tex_color.rgb, clear_color.rgb) < tolerance) {
        COLOR = vec4(0.0, 1.0, 0.0, 0.0);
    }
	
}

