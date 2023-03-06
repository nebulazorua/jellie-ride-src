package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.GraphicsShader;

// https://www.shadertoy.com/view/ftGyRy
class BlurShader extends GraphicsShader
{
	@:glVertexSource("
		#pragma header
		
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;
		
		void main(void)
		{
			#pragma body
			
			openfl_Alphav = openfl_Alpha * alpha;
			
			if (hasColorTransform)
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}")
	@:glFragmentHeader("
    	uniform bool hasTransform;
		uniform bool hasColorTransform;
		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture(bitmap, coord);
			if (!hasTransform)
			{
				return color;
			}
			if (color.a == 0.0)
			{
				return vec4(0.0, 0.0, 0.0, 0.0);
			}
			if (!hasColorTransform)
			{
				return color * openfl_Alphav;
			}
			color = vec4(color.rgb / color.a, color.a);
			mat4 colorMultiplier = mat4(0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
			color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
			if (color.a > 0.0)
			{
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}

		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias)
		{
			vec4 color = texture(bitmap, coord, bias);
			if (!hasTransform)
			{
				return color;
			}
			if (color.a == 0.0)
			{
				return vec4(0.0, 0.0, 0.0, 0.0);
			}
			if (!hasColorTransform)
			{
				return color * openfl_Alphav;
			}
			color = vec4(color.rgb / color.a, color.a);
			mat4 colorMultiplier = mat4(0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
			color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
			if (color.a > 0.0)
			{
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}
	")
	@:glFragmentSource('
    #pragma header

    uniform float uAmount;
    void main()
    {
        // Normalized pixel coordinates (from 0 to 1)
        vec2 uv = openfl_TextureCoordv;
        float highP = 0.;
        vec4 col = vec4(0.);
        
        float Directions = 24.0 ; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
        float Quality = 12.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
        float Size = 36.0 * uAmount; // BLUR SIZE (Radius)
        
        float Pi = 6.28318530718; // Pi*2
        vec2 Radius = Size/openfl_TextureSize.xy;
        for( float d=0.0; d<Pi; d+=Pi/Directions)
        {
            for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
            {
                col += flixel_texture2D( bitmap, uv+vec2(cos(d),sin(d))*Radius*i);
                highP += 1.0;
            }
        }
        col = col / vec4(highP);

        gl_FragColor = col;
    }
')
	public function new()
	{
		super();
		uAmount.value = [0];
	}

	@:isVar
	public var amount(get, set):Float = 0;

	function get_amount()
		return uAmount.value[0];

	function set_amount(val:Float)
		return uAmount.value[0] = val;
}