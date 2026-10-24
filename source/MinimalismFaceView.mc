import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class MinimalismFaceView extends WatchUi.WatchFace {

    // True while the watch is in high-power mode (about 10 seconds after a wrist gesture).
    // While asleep, onUpdate() is only called once a minute.
    private var _isAwake as Boolean = true;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // No static layout required; we draw directly in onUpdate.
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var clockTime = System.getClockTime();
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var radius = (w < h ? w : h) / 2 - 6;

        // Hand angles in degrees: 90 is 12 o'clock, decreasing clockwise
        var hourAngleDeg = 90 - ((clockTime.hour % 12) * 30 + clockTime.min * 0.5);
        var minuteAngleDeg = 90 - (clockTime.min * 6 + clockTime.sec * 0.1);

        // AMOLED always-on mode has burn-in rules, so draw the reduced face instead
        if (!_isAwake && needsBurnInProtection()) {
            drawAlwaysOn(dc, cx, cy, radius, hourAngleDeg, minuteAngleDeg, clockTime.min);
            return;
        }

        drawDial(dc, cx, cy, radius);
        drawDate(dc, cx, cy, radius);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Hour hand
        dc.setPenWidth(4);
        drawRadialLine(dc, cx, cy, hourAngleDeg, 0, radius * 0.5);

        // Minute hand
        dc.setPenWidth(3);
        drawRadialLine(dc, cx, cy, minuteAngleDeg, 0, radius * 0.75);

        // Seconds hand only while awake; asleep it would sit frozen between once-a-minute updates.
        // Red, with a short tail behind the centre like on a classic watch.
        if (_isAwake) {
            var secondAngleDeg = 90 - clockTime.sec * 6;
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            drawRadialLine(dc, cx, cy, secondAngleDeg, 0, radius * 0.88);
            drawRadialLine(dc, cx, cy, secondAngleDeg + 180, 0, radius * 0.15);
        }

        // center cap, with a red dot on top while the seconds hand is showing
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 6);
        if (_isAwake) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy, 3);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch: back to the full face, updated every second.
    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }

    // The watch is entering low-power mode. Redraw right away so the always-on
    // face replaces the bright one immediately, not at the next minute.
    function onEnterSleep() as Void {
        _isAwake = false;
        WatchUi.requestUpdate();
    }

    // Outer circle and a mark for every hour
    private function drawDial(dc as Dc, cx as Number, cy as Number, radius as Number) as Void {
        dc.setPenWidth(2);
        dc.drawCircle(cx, cy, radius);

        // Hour marks just inside the ring
        dc.setPenWidth(3);
        for (var i = 0; i < 12; i += 1) {
            drawRadialLine(dc, cx, cy, i * 30, radius * 0.90, radius * 0.97);
        }
    }

    // Weekday and day of the month below the centre, e.g. "Thu 23"
    private function drawDate(dc as Dc, cx as Number, cy as Number, radius as Number) as Void {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day]);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + radius * 0.4, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Always-on face for AMOLED screens. Garmin requires it to stay under 10% of the
    // screen's brightness and recommends avoiding pixels that stay lit, so this draws
    // only thin grey hour and minute hands that start away from the pivot, and moves
    // them to a different spot (within 2 px) every minute.
    private function drawAlwaysOn(dc as Dc, cx as Number, cy as Number, radius as Number, hourAngleDeg as Numeric, minuteAngleDeg as Numeric, minute as Number) as Void {
        var shift = minute % 9;
        var x = cx + (shift % 3 - 1) * 2;
        var y = cy + (shift / 3 - 1) * 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        drawRadialLine(dc, x, y, hourAngleDeg, 10, radius * 0.5);
        dc.setPenWidth(2);
        drawRadialLine(dc, x, y, minuteAngleDeg, 10, radius * 0.75);
    }

    // Draws a line along angleDeg (hands, hour marks), from `inner` to `outer` pixels out from the centre
    private function drawRadialLine(dc as Dc, cx as Numeric, cy as Numeric, angleDeg as Numeric, inner as Numeric, outer as Numeric) as Void {
        var rad = angleDeg * Math.PI / 180.0;
        var cos = Math.cos(rad);
        var sin = Math.sin(rad);
        dc.drawLine(cx + cos * inner, cy - sin * inner, cx + cos * outer, cy - sin * outer);
    }

    // True on screens (AMOLED) that need the always-on burn-in rules
    private function needsBurnInProtection() as Boolean {
        var settings = System.getDeviceSettings();
        return (settings has :requiresBurnInProtection) && settings.requiresBurnInProtection;
    }

}
