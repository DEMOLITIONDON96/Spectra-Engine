package objects.ui;

import base.song.Conductor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxSort;
import objects.ui.Strumline;
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
			var strumline:Strumline = (dunceNote.mustPress ? strum : mustPressStrum);

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
		var downscrollMultiplier:Int = (strumline.downscroll ? -1 : 1) * FlxMath.signOf(PlayState.songSpeed);

		var roundedSpeed = FlxMath.roundDecimal(daNote.noteSpeed, 2);
		var receptorPosX:Float = strumline.receptors.members[Math.floor(daNote.noteData)].x;
		var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y /* + Note.swagWidth / 6 */;
		//
		var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
		var psuedoX = 25 + daNote.noteVisualOffset;

		daNote.y = receptorPosY
			+ daNote.offsetY
			+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
			+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
		// painful math equation
		daNote.x = receptorPosX
			+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
			+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

		// also set note rotation
		daNote.angle = -daNote.noteDirection;

		// shitty note hack I hate it so much
		var center:Float = receptorPosY + Note.swagWidth / 2;
		if (daNote.isSustainNote)
		{
			var stringSect = Receptor.colors[daNote.noteData];

			daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
			if ((daNote.animation.getByName(stringSect + 'holdend') != null && daNote.animation.curAnim.name.endsWith('holdend'))
				&& (daNote.prevNote != null))
			{
				daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
				if (strumline.downscroll)
				{
					daNote.y += (daNote.height * 2);
					if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY)
					{
						// set the end hold offset yeah I hate that I fix this like this
						daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
					}
					else
						daNote.y += daNote.endHoldOffset;
				}
				else // this system is funny like that
					daNote.y += ((daNote.height / 2) * downscrollMultiplier);
			}

			if (downscrollMultiplier < 0)
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
			else if (downscrollMultiplier > 0)
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
		}
	}
}
