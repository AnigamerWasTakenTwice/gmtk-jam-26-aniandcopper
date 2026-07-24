shader_type canvas_item;

uniform bool is_hurt;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
    
	if (is_hurt) 
	{
		COLOR = vec4(1.0 - tex_color.rgb, tex_color.a);
	}
}

