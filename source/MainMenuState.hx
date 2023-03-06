package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Character;
import Conductor;
import Achievements;
import VividLight;
import Difference;
import flash.display.BlendMode;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

#if VIDEOS_ALLOWED
import hxcodec.VideoHandler;
#end

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxText>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'play',
		'options',
		'exit'
	];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var loadedWeeks:Array<WeekData> = [];
	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		WeekData.setDirectoryFromWeek();
		WeekData.reloadWeekFiles(false);
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;
		
				
		var difference = new Difference();
		var vivid = new VividLight();

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuLayer0'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menuLayer1'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.alpha = 0.749;
		bg.shader = vivid.shader;
		add(bg);
		
		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menuLayer2'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		
		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
		}
		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxText = new FlxText(40, (i * 200)  + offset, optionShit[i], 12);
			menuItem.setFormat(Paths.font("akira.otf"), 102, FlxColor.BLACK, CENTER);
			menuItem.shader = difference.shader;
			menuItem.blend = ADD;
			menuItem.alpha = 0.764;
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{	
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				var video:VideoHandler = new VideoHandler();
				video.playVideo(Paths.video("jelly"));
				video.finishCallback = function()
				{
					selectedSomethin = false;
					return;
				}
			}

			if (controls.ACCEPT)
			{
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (optionShit[curSelected] == 'exit') Sys.exit(0);
						
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'play':
										var songArray:Array<String> = [];
										trace(loadedWeeks[0]);
										var leWeek:Array<Dynamic> = loadedWeeks[0].songs;
										for (i in 0...leWeek.length) {
											songArray.push(leWeek[i][0]);
										}

										PlayState.storyPlaylist = songArray;
										PlayState.isStoryMode = true;
										
										var diffic = CoolUtil.getDifficultyFilePath(1);
										
										if (diffic == null) {
											diffic = '';
										}

										PlayState.storyDifficulty = 1;

										PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
										PlayState.campaignScore = 0;
										PlayState.campaignMisses = 0;
										{
											LoadingState.loadAndSwitchState(new PlayState(), true);
											FreeplayState.destroyFreeplayVocals();
										};
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
									case 'exit':
										Sys.exit(0);
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
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
			spr.updateHitbox();
			
			if (spr.ID == curSelected)
			{
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
				FlxTween.tween(spr, {size: 170, x: 50}, 0.055, {ease: FlxEase.quadOut});
			} else {
				FlxTween.tween(spr, {size: 107, x: 40}, 0.055, {ease: FlxEase.quadOut});
			}
		});
	}
}
