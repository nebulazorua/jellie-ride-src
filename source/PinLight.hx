package;

import flixel.system.FlxAssets.FlxShader;

class PinLight {
	public var shader(default, null):PinLightShader = new PinLightShader();

	public function new(character:Bool = false)
	{
		shader.uBlendColor.value = [0, 0, 0, 1.0];
	}
}

class PinLightShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec4 uBlendColor;
		
		float blendDarken(float base, float blend) {
			return min(blend,base);
		}

		vec3 blendDarken(vec3 base, vec3 blend) {
			return vec3(blendDarken(base.r,blend.r),blendDarken(base.g,blend.g),blendDarken(base.b,blend.b));
		}

		vec3 blendDarken(vec3 base, vec3 blend, float opacity) {
			return (blendDarken(base, blend) * opacity + base * (1.0 - opacity));
		}
		
		float blendLighten(float base, float blend) {
			return max(blend,base);
		}

		vec3 blendLighten(vec3 base, vec3 blend) {
			return vec3(blendLighten(base.r,blend.r),blendLighten(base.g,blend.g),blendLighten(base.b,blend.b));
		}

		vec3 blendLighten(vec3 base, vec3 blend, float opacity) {
			return (blendLighten(base, blend) * opacity + base * (1.0 - opacity));
		}
		
		float blendPinLight(float base, float blend) {
			return (blend<0.5)?blendDarken(base,(2.0*blend)):blendLighten(base,(2.0*(blend-0.5)));
		}

		vec3 blendPinLight(vec3 base, vec3 blend) {
			return vec3(blendPinLight(base.r,blend.r),blendPinLight(base.g,blend.g),blendPinLight(base.b,blend.b));
		}

		vec3 blendPinLight(vec3 base, vec3 blend, float opacity) {
			return (blendPinLight(base, blend) * opacity + base * (1.0 - opacity));
		}

		void main()
		{
			vec4 base = texture2D(bitmap, openfl_TextureCoordv);
			 gl_FragColor = vec4(blendPinLight(base.rgb, uBlendColor.rgb, base.a), base.a);
		}')
	public function new()
	{
		super();
	}
}
