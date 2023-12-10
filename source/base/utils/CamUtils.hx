package base.utils;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxCamera;

@:access(flixel.FlxCamera)
class CamUtils 
{
    public static function updateCamera(camera:FlxCamera, dt:Float)
    {
        var scaleModeX:Float = FlxG.scaleMode.scale.x;
        var scaleModeY:Float = FlxG.scaleMode.scale.y;
        var initialZoom:Float = camera.initialZoom;
        var x:Float = camera.x;
        var y:Float = camera.y;
        var fxShakeI:Float = -999999;

        camera.zoom = camera.zoom;
        camera.angle = camera.angle;
        camera.width = camera.width;
        camera.height = camera.height;

        var rX, rY, rAngle, rSkewX, rSkewY, sX, sY;
        rX = 0.0;
        rY = 0.0;
        rAngle = 0.0;
        rSkewX = 0.0;
        rSkewY = 0.0;
        sX = camera._fxShakeIntensity * camera.width;
        sY = camera._fxShakeIntensity * camera.height;

        var w = (camera._fxShakeDuration / -.15) + 1;
        var ww = FlxMath.bound(w, 0, 1) * (-0.5 + 1);
        var www = FlxMath.bound(w, 0, 1) * 0.5;

        fxShakeI = fxShakeI + (FlxMath.bound((camera._fxShakeIntensity * 7) + .75, 0, 10) * dt * FlxMath.bound(w, 0, 1.5));
        rX = Math.cos(fxShakeI * 97) * sX * ww;
        rY = Math.sin(fxShakeI * 86) * sY * ww;
        rAngle = Math.sin(fxShakeI * 62) * FlxMath.bound(camera._fxShakeIntensity * 66, -60, 60) * ww;
        rSkewX = Math.cos(fxShakeI * 54) * FlxMath.bound(camera._fxShakeIntensity * 12, -4, 4) * ww;
        rSkewY = Math.sin(fxShakeI * 51) * FlxMath.bound(camera._fxShakeIntensity * 12, -1.5, 1.5) * ww;

        rX = rX + (Math.cos(fxShakeI * 165) * sX * www);
        rY = rY + (Math.cos(fxShakeI * 132) * sY * www);
        rAngle = rAngle + (Math.sin(fxShakeI * 111) * FlxMath.bound(camera._fxShakeIntensity * 66, -60, 60) * www);
        rSkewX = rSkewX + (Math.sin(fxShakeI * 123) * FlxMath.bound(camera._fxShakeIntensity * 12, -4, 4) * www);
        rSkewY = rSkewY + (Math.cos(fxShakeI * 101) * FlxMath.bound(camera._fxShakeIntensity * 12, -1.5, 1.5) * www);

        // camera.angle = camera.angle + rAngle;
        camera._flashOffset.x = (camera.width * 0.5) * scaleModeX * initialZoom - (x * scaleModeX);
        camera._flashOffset.y = (camera.height * 0.5) * scaleModeY * initialZoom - (y * scaleModeY);
    } 
}