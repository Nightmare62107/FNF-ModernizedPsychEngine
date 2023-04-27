package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class DiscordState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var serversStuff:Array<Array<String>> = [];

	var bg:FlxSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.color = 0xFF5165F6;
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = // Server Name - Link
		[
			['Discord Servers'],
			["Radioactive's Server 3: The Trilogy",						'https://discord.gg/UxVSARJHHR'],
			["kirbey's lounge",											'https://discord.gg/Uwc5DMa7b7'],
			['Psych Engine',											'https://discord.gg/2ka77eMXDv']
		];
		
		for (i in pisspoop)
		{
			serversStuff.push(i);
		}

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if (FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if (leMods.length > 1 && leMods[0].length > 0)
				{
					var modSplit:Array<String> = leMods[i].split('|');
					if (!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if (modSplit[1] == '1')
						{
							pushModServersToList(modSplit[0]);
						}
						else
						{
							modsAdded.push(modSplit[0]);
						}
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModServersToList(folder);
		}
		#end
	
		for (i in 0...serversStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, serversStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if (isSelectable)
			{
				if (serversStuff[i][5] != null)
				{
					Paths.currentModDirectory = serversStuff[i][5];
				}

				Paths.currentModDirectory = '';

				if (curSelected == -1)
				{
					curSelected = i;
				}
			}
			else
			{
				optionText.alignment = CENTERED;
			}
		}

		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#end
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
		{
			if (serversStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
				{
					shiftMult = 1;
				}

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}

				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}

				if (FlxG.mouse.wheel != 0)
				{
					changeSelection(-shiftMult * FlxG.mouse.wheel);
				}
			}

			if (controls.ACCEPT && (serversStuff[curSelected][1] == null || serversStuff[curSelected][1].length > 4))
			{
				CoolUtil.browserLoad(serversStuff[curSelected][1]);
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if (!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = serversStuff.length - 1;
			if (curSelected >= serversStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit-1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModServersToList(folder:String)
	{
		if (modsAdded.contains(folder))
		{
			return;
		}

		var serversFile:String = null;
		if (folder != null && folder.trim().length > 0)
		{
			serversFile = Paths.mods(folder + '/data/servers.txt');
		}
		else
		{
			serversFile = Paths.mods('data/servers.txt');
		}

		if (FileSystem.exists(serversFile))
		{
			var firstarray:Array<String> = File.getContent(serversFile).split('\n');
			for (i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if (arr.length >= 2)
				{
					arr.push(folder);
				}
				serversStuff.push(arr);
			}
			serversStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	private function unselectableCheck(num:Int):Bool
	{
		return serversStuff[num].length <= 1;
	}
}