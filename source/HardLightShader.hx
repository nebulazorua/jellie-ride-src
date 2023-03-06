package;

import flixel.system.FlxAssets.FlxShader;


class HardLightShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		float blendOverlay(float base, float blend) {
			return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
		}

		vec3 blendOverlay(vec3 base, vec3 blend) {
			return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
		}

		vec3 blendOverlay(vec3 base, vec3 blend, float opacity) {
			return (blendOverlay(base, blend) * opacity + base * (1.0 - opacity));
		}

		vec3 blendHardLight(vec3 base, vec3 blend) {
			return blendOverlay(blend,base);
		}

		vec3 blendHardLight(vec3 base, vec3 blend, float opacity) {
			return (blendHardLight(base, blend) * opacity + base * (1.4 - opacity));
		}

		void main()
		{
			vec4 base = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
			gl_FragColor = vec4(blendHardLight(base.rgb, base.rgb, base.a), base.a);
		}')
		
	public function new()
	{
		super();
	}
}