package;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class Difference {
	public var shader(default, null):DifferenceShader = new DifferenceShader();

	public function new()
	{
		shader.uBlendColor.value = [1.0, 1.0, 1.0, 1.0];
	}
}


class DifferenceShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec4 uBlendColor;

		vec3 blendDifference(vec3 base, vec3 blend) {
			return abs(base-blend);
		}

		vec3 blendDifference(vec3 base, vec3 blend, float opacity) {
			return (blendDifference(base, blend) * opacity + base * (1.0 - opacity));
		}

		void main()
		{
			vec4 base = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
			gl_FragColor = vec4(blendDifference(base.rgb, uBlendColor.rgb, base.a), base.a);
		}')
		
	public function new()
	{
		super();
	}
}