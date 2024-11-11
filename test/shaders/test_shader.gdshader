shader_type canvas_item;

uniform sampler2D texture2;
uniform sampler2D colorTexture;

uniform vec2 scroll1 = vec2(0, 0);
uniform vec2 scroll2 = vec2(-0.2, -0.2);

void fragment(){
	float textureColor1 = texture(TEXTURE, UV + scroll1 * TIME).r;
	float textureColor2 = texture(texture2, UV + scroll2 * TIME).r;
	float energy = textureColor1 * textureColor2;
	vec4 color = texture(colorTexture, vec2(energy));
	vec4 test_color = texture(colorTexture, vec2(textureColor2));
	vec4 texture2test = texture(texture2, UV);
	COLOR = test_color;
	// this shit just seemingly doesnt work for some arcane reason
}