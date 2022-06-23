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
import flixel.util.FlxTimer;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.display.FPS;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var editable:Bool = false; // DEBUG THING

	public static var zoomvalue:Float = 1; 
	var mouse:FlxSprite; 
    var leText:String = "Press CTRL to open the Gameplay Changers Menu";
	var size:Int = 16;
    var background:FlxSprite;
    var play:FlxSprite;
    var options:FlxSprite;
    var debugKeys:Array<FlxKey>;

    override public function create():Void
    {
		PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		Highscore.load();

        FlxG.mouse.visible = false;

        debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

        FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
        transIn = FlxTransitionableState.defaultTransIn;

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        play = new FlxSprite(394, 123).loadGraphic(Paths.image('play'));
        play.scale.set(1.2, 1.2);
		add(play);

        options = new FlxSprite(334, 461).loadGraphic(Paths.image('options'));
        options.scale.set(1.2, 1.2);
		add(options);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		mouse = new FlxSprite(0,0).loadGraphic(Paths.image('wood'));
		mouse.setGraphicSize(Std.int(mouse.width * zoomvalue));
		mouse.updateHitbox();
		add(mouse);
    }

    var isMouse:Bool = false;
    var lastMousePoint:Float;
    var lastMouseSelect:Int = 88;
    var selectedSomethin:Bool = false;
    override public function update(elapsed:Float):Void
    {
		mouse.x = FlxG.mouse.screenX;
        mouse.y = FlxG.mouse.screenY;

		/*if (FlxG.keys.pressed.SHIFT)
		{
			options.x = FlxG.mouse.screenX;
			options.y = FlxG.mouse.screenY;
		}
		else if (FlxG.keys.justPressed.C)
		{
			trace(options);
		}*/

        if (lastMousePoint != FlxG.mouse.screenX) //bro I completly miss understood what this is used for, im dumb as fuck -- just jack
        {
            lastMousePoint = FlxG.mouse.screenX;
            isMouse = true;
        }

		if(FlxG.keys.justPressed.CONTROL)
        {
            persistentUpdate = false;
            openSubState(new GameplayChangersSubstate());
        }

        #if desktop
        if (FlxG.keys.anyJustPressed(debugKeys))
        {
            MusicBeatState.switchState(new MasterEditorMenu());
        }
        #end

        if (!selectedSomethin)
        {
            if (FlxG.mouse.overlaps(play) && isMouse)
            {
                if (FlxG.mouse.justPressed && isMouse)
                {
                    selectedSomethin = true;
                    FlxFlicker.flicker(play, 1.1, 0.15, false);
                    options.alpha = 0;
                    FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(mouse, {alpha: 0}, 0.5);
                    PlayState.isStoryMode = true;
                    PlayState.storyPlaylist = ['Mm2funk'];
                    trace(PlayState.storyPlaylist);
                    PlayState.SONG = Song.loadFromJson(StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase() + '-hard', StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase());
                    PlayState.storyWeek = 0;
                    PlayState.campaignScore = 0;
                    
                    new FlxTimer().start(1, function(tmr:FlxTimer)
                    {
                        PlayState.isStoryMode = true;
                        LoadingState.loadAndSwitchState(new PlayState(), true);
                        FreeplayState.destroyFreeplayVocals();
                    });
                }
            }

            if (FlxG.mouse.overlaps(options))
            {
                if (FlxG.mouse.justPressed)
                {
                    selectedSomethin = true;
                    FlxFlicker.flicker(options, 1.1, 0.15, false);
                    play.alpha = 0;
                    FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(mouse, {alpha: 0}, 0.5);
                    new FlxTimer().start(1, function(tmr:FlxTimer)
                    {
                        LoadingState.loadAndSwitchState(new options.OptionsState());
						//MusicBeatState.switchState(new FreeplayState());
                    });
                }
            }
        }
    }
}