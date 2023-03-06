package;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class VividLight {
	public var shader(default, null):VividLightShader = new VividLightShader();

	public function new()
	{
		shader.uBlendColor.value = [1.0, 0.882, 0.302, 0.799];
	}
}

class VividLightShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec4 uBlendColor;
		
		float blendColorDodge(float base, float blend) {
			return (blend==1.0)?blend:min(base/(1.0-blend),1.0);
		}

		vec3 blendColorDodge(vec3 base, vec3 blend) {
			return vec3(blendColorDodge(base.r,blend.r),blendColorDodge(base.g,blend.g),blendColorDodge(base.b,blend.b));
		}

		vec3 blendColorDodge(vec3 base, vec3 blend, float opacity) {
			return (blendColorDodge(base, blend) * opacity + base * (1.0 - opacity));
		}
		
		float blendColorBurn(float base, float blend) {
			return (blend==0.0)?blend:max((1.0-((1.0-base)/blend)),0.0);
		}

		vec3 blendColorBurn(vec3 base, vec3 blend) {
			return vec3(blendColorBurn(base.r,blend.r),blendColorBurn(base.g,blend.g),blendColorBurn(base.b,blend.b));
		}

		vec3 blendColorBurn(vec3 base, vec3 blend, float opacity) {
			return (blendColorBurn(base, blend) * opacity + base * (1.0 - opacity));
		}
		
		float blendVividLight(float base, float blend) {
			return (blend<0.5)?blendColorBurn(base,(2.0*blend)):blendColorDodge(base,(2.0*(blend-0.5)));
		}

		vec3 blendVividLight(vec3 base, vec3 blend) {
			return vec3(blendVividLight(base.r,blend.r),blendVividLight(base.g,blend.g),blendVividLight(base.b,blend.b));
		}

		vec3 blendVividLight(vec3 base, vec3 blend, float opacity) {
			return (blendVividLight(base, blend) * opacity + base * (1.0 - opacity));
		}

		void main()
		{
			vec4 base = texture2D(bitmap, openfl_TextureCoordv);
			gl_FragColor = vec4(blendVividLight(base.rgb, uBlendColor.rgb, base.a), base.a);
		}')
	public function new()
	{
		super();
	}
}
