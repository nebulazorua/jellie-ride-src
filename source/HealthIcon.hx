package;

import flixel.FlxSprite;
import Paths;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'icon-bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}
	
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon

			frames = Paths.getSparrowAtlas(name);
			if (!char.startsWith('icon-')) {
				animation.addByIndices('bop0', 'icon-' + char, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
				animation.addByIndices('bop1', 'icon-' + char, [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
			} else {
				animation.addByIndices('bop0', char, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
				animation.addByIndices('bop1', char, [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
			}
			scale.set(0.7, 0.7);
			updateHitbox();

			animation.play('bop0', true);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	public function getCharacter():String {
		return char;
	}
}
