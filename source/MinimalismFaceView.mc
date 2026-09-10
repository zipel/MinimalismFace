import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Math as Math;
import Toybox.WatchUi;

class MinimalismFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // No static layout required; we'll draw directly in onUpdate/onPartialUpdate.
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Draw full analog clock (includes seconds hand)
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var clockTime = System.getClockTime();
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var radius = (w < h ? w : h) / 2 - 6;

        // Draw outer circle
        dc.setPenWidth(2);
        dc.drawCircle(cx, cy, radius);

        // Draw hour numbers 1..12
        dc.setPenWidth(1);
        for (var i = 1; i <= 12; i += 1) {
            var angleDeg = 90 - ((i % 12) * 30);
            var rad = angleDeg * Math.PI / 180.0;
            var tx = cx + Math.cos(rad) * (radius * 0.78);
            var ty = cy - Math.sin(rad) * (radius * 0.78);
            var s = i.toString();
            dc.drawText(tx, ty, Graphics.FONT_SMALL, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Compute hand angles
        var hour = clockTime.hour % 12;
        var minute = clockTime.min;
        var second = clockTime.sec;

        var hourAngleDeg = 90 - (hour * 30 + minute * 0.5);
        var minuteAngleDeg = 90 - (minute * 6 + second * 0.1);
        var secondAngleDeg = 90 - (second * 6);

        // Hour hand
        var ha = hourAngleDeg * Math.PI / 180.0;
        var hx = cx + Math.cos(ha) * (radius * 0.5);
        var hy = cy - Math.sin(ha) * (radius * 0.5);
        dc.setPenWidth(4);
        dc.drawLine(cx, cy, hx, hy);

        // Minute hand
        var ma = minuteAngleDeg * Math.PI / 180.0;
        var mx = cx + Math.cos(ma) * (radius * 0.75);
        var my = cy - Math.sin(ma) * (radius * 0.75);
        dc.setPenWidth(3);
        dc.drawLine(cx, cy, mx, my);

        // Seconds hand (do not draw in low-power/always-on partial updates)
        var sa = secondAngleDeg * Math.PI / 180.0;
        var sx = cx + Math.cos(sa) * (radius * 0.85);
        var sy = cy - Math.sin(sa) * (radius * 0.85);
        dc.setPenWidth(1);
        dc.drawLine(cx, cy, sx, sy);

        // center cap
        dc.fillCircle(cx, cy, 3);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    // Partial updates are used in low power / always-on display modes.
    // Only draw hour and minute hands here (no seconds) to save power.
    function onPartialUpdate(dc as Dc) as Void {
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        // Note: partial updates should restrict drawing to changed regions when possible.
        dc.clear();

        var clockTime = System.getClockTime();
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var radius = (w < h ? w : h) / 2 - 6;

        // Draw outer circle and numbers (static)
        dc.setPenWidth(2);
        dc.drawCircle(cx, cy, radius);
        dc.setPenWidth(1);
        for (var i = 1; i <= 12; i += 1) {
            var angleDeg = 90 - ((i % 12) * 30);
            var rad = angleDeg * Math.PI / 180.0;
            var tx = cx + Math.cos(rad) * (radius * 0.78);
            var ty = cy - Math.sin(rad) * (radius * 0.78);
            var s = i.toString();
            dc.drawText(tx, ty, Graphics.FONT_SMALL, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Draw hour and minute hands only
        var hour = clockTime.hour % 12;
        var minute = clockTime.min;

        var hourAngleDeg = 90 - (hour * 30 + minute * 0.5);
        var minuteAngleDeg = 90 - (minute * 6);

        var ha = hourAngleDeg * Math.PI / 180.0;
        var hx = cx + Math.cos(ha) * (radius * 0.5);
        var hy = cy - Math.sin(ha) * (radius * 0.5);
        dc.setPenWidth(4);
        dc.drawLine(cx, cy, hx, hy);

        var ma = minuteAngleDeg * Math.PI / 180.0;
        var mx = cx + Math.cos(ma) * (radius * 0.75);
        var my = cy - Math.sin(ma) * (radius * 0.75);
        dc.setPenWidth(3);
        dc.drawLine(cx, cy, mx, my);

        dc.fillCircle(cx, cy, 3);
    }

}
