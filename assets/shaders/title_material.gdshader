shader_type canvas_item;

uniform sampler2D override_texture_sky;
uniform sampler2D override_texture_tentacle;

uniform vec4 sky_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 tentacle_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float tolerance = 0.05;

uniform vec2 direction_sky;
uniform vec2 direction_tentacle;
uniform float speed_sky;
uniform float speed_tentacle;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	bool is_pure_black = (tex_color.r == 0.0 && tex_color.g == 0.0 && tex_color.b == 0.0);
	bool is_near_black = length(tex_color.rgb) < 0.01;



	if (distance(tex_color.rgb, sky_color.rgb) < tolerance) {
		vec2 move = direction_sky * TIME * speed_sky;
		
		vec4 new_color = texture(override_texture_sky, UV+move);
		COLOR = texture(override_texture_sky, fract(UV+move));

	}
	 if (distance(tex_color.rgb, tentacle_color.rgb) < tolerance) {
		vec2 move = direction_tentacle * TIME * speed_tentacle;
		
		vec4 new_color = texture(override_texture_tentacle, UV+move);
		COLOR = texture(override_texture_tentacle, fract(UV+move));
    }

}
