package objects.ui.notes;

import base.song.Conductor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxSort;
import objects.ui.notes.Strumline.Receptor;
import objects.ui.notes.Strumline;
import states.PlayState;

/**
 * the Notefield class manages spawned notes
 * having neat little functions to control how notes should behave during gameplay
 */
class Notefield extends FlxTypedGroup<Note>
{
	inline public function callNotes(strum:Strumline, mustPressStrum:Strumline, groupStrums:FlxTypedGroup<Strumline>)
	{
		if ((members[0] != null) && ((members[0].strumTime - Conductor.songPosition) < 3500))
		{
			var dunceNote:Note = members[0];
			var strumline:Strumline;

			strumline = (dunceNote.mustPress ? strum : mustPressStrum);

			PlayState.main.callFunc('noteSpawn', [dunceNote, dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

			// push note to its correct strumline
			groupStrums.members[
				Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / strumline.keyAmount)
			].addNote(dunceNote);
			members.splice(members.indexOf(dunceNote), 1);
		}
	}

	inline public function noteSorting()
	{
		sort(function(noteData:Int, note1:Note, note2:Note)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, note1.strumTime, note2.strumTime);
		});
	}

	public function noteCalls(daNote:Note, strumline:Strumline)
	{
		// set the notes x and y
		var downscrollMultiplier:Float = (strumline.downscroll ? -1: 1) * (FlxMath.signOf(PlayState.main.songSpeed) * daNote.speedMult);

		var roundedSpeed = FlxMath.roundDecimal((daNote.customScrollspeed ? daNote.noteSpeed : PlayState.main.songSpeed), 2);
		
		var receptorPosX:Float = strumline.receptors.members[Math.floor(daNote.noteData)].x;
		var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 6;
		
		if (daNote.flipDownscroll) downscrollMultiplier = (strumline.downscroll ? 1: -1) * (FlxMath.signOf(PlayState.main.songSpeed) * daNote.speedMult);

		var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
		var psuedoX = 25 + daNote.noteVisualOffset;

		daNote.noteDirection = strumline.receptors.members[Math.floor(daNote.noteData)].strumDirection;

		if (downscrollMultiplier == -1) // Downscroll
			{
				// daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.noteSpeed);
			}
			else // Upscroll
			{
				// daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.noteSpeed);
			}

			daNote.y = receptorPosY
				+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
				+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
			// painful math equation
			daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
				+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
				+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

			// also set note rotation
			daNote.angle = -daNote.noteDirection;

			var center:Float = receptorPosY + daNote.offsetY + Note.swagWidth / 2;
			if(daNote.isSustainNote)
			{
				var swagRect:FlxRect = daNote.clipRect;
				if(swagRect == null) swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);

				if (Init.trueSettings.get('Downscroll'))
				{
					daNote.flipY = true;
					if(daNote.y - daNote.offsetY * daNote.scale.y + daNote.height >= center)
					{
						swagRect.width = daNote.frameWidth;
						swagRect.height = (center - daNote.y) / daNote.scale.y;
						swagRect.y = daNote.frameHeight - swagRect.height;
					}
				}
				else if (daNote.y + daNote.offsetY * daNote.scale.y <= center)
				{
					swagRect.y = (center - daNote.y) / daNote.scale.y;
					swagRect.width = daNote.width / daNote.scale.x;
					swagRect.height = (daNote.height / daNote.scale.y) - swagRect.y;
				}
				daNote.clipRect = swagRect;
			}
			/*// shitty note hack I hate it so much
			var center:Float = receptorPosY + Note.swagWidth / 2;
			if (daNote.isSustainNote)
			{
				daNote.y -= ((daNote.height / 2) * downscrollMultiplier - 15);
				if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
				{
					daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
					if (Init.trueSettings.get('Downscroll'))
					{
						daNote.y += (daNote.height * 2);
						if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY)
						{
							// set the end hold offset yeah I hate that I fix this like this
							daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
							trace(daNote.endHoldOffset);
						}
						else
							daNote.y += daNote.endHoldOffset;
					}
					else // this system is funny like that
						daNote.y += ((daNote.height / 2) * downscrollMultiplier);
				}

				if (Init.trueSettings.get('Downscroll'))
				{
					daNote.flipY = true;
					if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
						&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
						&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
						swagRect.height = (center - daNote.y) / daNote.scale.y;
						swagRect.y = daNote.frameHeight - swagRect.height;
						daNote.clipRect = swagRect;
					}
				}
				else
				{
					if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}
			}*/

		daNote.updateHitbox();
	}
}
