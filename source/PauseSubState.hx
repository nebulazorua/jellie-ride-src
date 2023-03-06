package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import ClientPrefs;

class PauseSubState extends MusicBeatSubstate
{
	var menuItemsOG:Array<String> = [
		'resume', 
		'restart', 
		'exit'
	];
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		
		var pauseScreen:FlxSprite = new FlxSprite();
		pauseScreen.scale.set(0.5, 0.5);
		pauseScreen.frames = Paths.getSparrowAtlas('pauseScreen');
		pauseScreen.animation.addByPrefix('idle', 'pauseScreen', 24, true);
		pauseScreen.animation.play('idle', true);
		pauseScreen.scrollFactor.set(0, 0);
		pauseScreen.updateHitbox();
		pauseScreen.screenCenter();
		pauseScreen.antialiasing = ClientPrefs.globalAntialiasing;
		pauseScreen.x += 50;
		pauseScreen.y += 20;
		add(pauseScreen);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		for (i in 0...menuItemsOG.length)
		{
			var offset:Float = 268 - (Math.max(menuItemsOG.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 70)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('pause/' + menuItemsOG[i]);
			menuItem.animation.addByPrefix('idle', menuItemsOG[i] + " uns", 24, false);
			menuItem.animation.addByPrefix('selected', menuItemsOG[i] + " s", 24, false);
			menuItem.animation.play('idle');
			menuItem.scale.set(0.7, 0.7);
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
			
			
		}
		changeItem();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeItem(-1);
		}
		if (downP)
		{
			changeItem(1);
		}

		var daSelected:String = menuItemsOG[curSelected];
		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{
			switch (daSelected)
			{
				case "resume":
					close();
				case "restart":
					restartSong();
				case "exit":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					MusicBeatState.switchState(new MainMenuState());
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			spr.x += 20;
		});
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.curAnim.name != 'idle') {
				spr.animation.play('idle');
				spr.updateHitbox();
			}
			spr.scale.x = 0.7;
			spr.scale.y = 0.7;
			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				spr.updateHitbox();
				spr.scale.x = 0.66;
				spr.scale.y = 0.66;
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				spr.centerOffsets();
				FlxTween.tween(spr.scale, {x: 0.7, y: 0.7}, 0.042, {startDelay: spr.animation.curAnim.delay * 2});
			}
			spr.centerOffsets();
			switch (spr.animation.curAnim.name)
			{
				case 'selected':
					// shit code but idc
					if(spr.ID == 1){
						spr.offset.x = 120;
						spr.offset.y = 75;
					}else if (spr.ID == 2){
						spr.offset.x = 80;
						spr.offset.y = 50;
					}else{
						spr.offset.x = 130;
						spr.offset.y = 75;
					}
				default:
			}
			
		});
	}
}
