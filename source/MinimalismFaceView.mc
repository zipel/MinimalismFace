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

    // True when the watch's own mechanical hands point at the time (Instinct Crossover
    // AMOLED). The face then leaves the hour and minute hands to them.
    private var _physicalHandsShowTime as Boolean = false;

    // True on rectangular screens (Venu Sq, Venu Sq 2, Venu X1), where the dial follows the screen's shape
    private var _rectangular as Boolean = false;

    function initialize() {
        WatchFace.initialize();
        _rectangular = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // No static layout required; we draw directly in onUpdate.
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _physicalHandsShowTime = usePhysicalHands();
        // Pick up changes made in the face's settings menu on the watch
        Settings.load();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Smooth edges where the watch supports it (older ones like the Approach S62 don't)
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
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

        // Always-on mode on AMOLED screens (and the Venu Sq's LCD) has burn-in rules, so draw the
        // reduced face instead (with mechanical hands telling the time, the screen can stay dark).
        // MIP screens have no such rules and keep the full face, without the seconds hand.
        if (!_isAwake && needsBurnInProtection()) {
            if (!_physicalHandsShowTime) {
                drawAlwaysOn(dc, cx, cy, radius, hourAngleDeg, minuteAngleDeg, clockTime.min);
            }
            return;
        }

        drawDial(dc, cx, cy, radius);
        drawFields(dc, cx, cy, radius);

        // Hour and minute hands, unless the watch's mechanical hands already show them
        if (!_physicalHandsShowTime) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

            // Hour hand
            dc.setPenWidth(4);
            drawRadialLine(dc, cx, cy, hourAngleDeg, 0, radius * 0.5);

            // Minute hand
            dc.setPenWidth(3);
            drawRadialLine(dc, cx, cy, minuteAngleDeg, 0, radius * 0.75);
        }

        // Seconds hand only while awake (asleep it would sit frozen between once-a-minute updates)
        // and when the Seconds hand setting is on. Red, with a short tail behind the centre like
        // on a classic watch.
        var showSeconds = _isAwake && Settings.secondsHand;
        if (showSeconds) {
            var secondAngleDeg = 90 - clockTime.sec * 6;
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            drawRadialLine(dc, cx, cy, secondAngleDeg, 0, radius * 0.88);
            drawRadialLine(dc, cx, cy, secondAngleDeg + 180, 0, radius * 0.15);
        }

        // center cap, with a red dot on top while the seconds hand is showing
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 6);
        if (showSeconds) {
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

    // Outer ring and a mark for every hour, or only the marks, or nothing, as the Dial setting says.
    // On rectangular screens the ring follows the screen's own rounded-rectangle shape, 6 px in
    // from the edge, and the marks run along it.
    private function drawDial(dc as Dc, cx as Number, cy as Number, radius as Number) as Void {
        if (Settings.dial == Settings.DIAL_NONE) {
            return;
        }
        var outline = (Settings.dial == Settings.DIAL_OUTLINE_AND_MARKS);
        dc.setPenWidth(2);

        if (_rectangular) {
            var w = dc.getWidth();
            var h = dc.getHeight();
            var corner = screenCornerRadius(w, h) - 6;
            if (outline) {
                dc.drawRoundedRectangle(6, 6, w - 12, h - 12, corner);
            }

            // Each mark ends just inside the outline, where its hour's direction meets it
            var gap = radius * 0.03;
            dc.setPenWidth(3);
            for (var i = 0; i < 12; i += 1) {
                var edge = distanceToRoundedRect(i * 30, cx - 6 - gap, cy - 6 - gap, corner - gap);
                drawRadialLine(dc, cx, cy, i * 30, edge - radius * 0.07, edge);
            }
            return;
        }

        if (outline) {
            dc.drawCircle(cx, cy, radius);
        }

        // Hour marks just inside the ring
        dc.setPenWidth(3);
        for (var i = 0; i < 12; i += 1) {
            drawRadialLine(dc, cx, cy, i * 30, radius * 0.90, radius * 0.97);
        }
    }

    // The two fields above and below the centre, showing the date and the battery level
    // wherever the settings put them
    private function drawFields(dc as Dc, cx as Number, cy as Number, radius as Number) as Void {
        if (Settings.datePosition != Settings.POSITION_OFF) {
            drawDate(dc, cx, fieldY(Settings.datePosition, cy, radius));
        }
        if (Settings.batteryPosition != Settings.POSITION_OFF) {
            drawBattery(dc, cx, fieldY(Settings.batteryPosition, cy, radius));
        }
    }

    // Vertical centre of the top or bottom field
    private function fieldY(position as Settings.Position, cy as Number, radius as Number) as Float {
        return position == Settings.POSITION_TOP ? cy - radius * 0.4 : cy + radius * 0.4;
    }

    // Weekday and day of the month, e.g. "Thu 23"
    private function drawDate(dc as Dc, x as Number, y as Float) as Void {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day]);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Battery level: a horizontal battery outline with the charge inside it, e.g. "22", centred
    // on (x, y). The battery is sized to fit "100" in the small font.
    private function drawBattery(dc as Dc, x as Number, y as Float) as Void {
        var font = Graphics.FONT_XTINY;
        var level = System.getSystemStats().battery;
        var text = (level + 0.5).toNumber().toString();

        // Body just taller than the digits and at least twice as wide, with a terminal on the right
        var line = 2;
        var pad = 1;
        var digitHeight = dc.getFontHeight(font) * 0.6;
        var h = (digitHeight + 2 * (line + pad) + 2.5).toNumber();
        var w = dc.getTextWidthInPixels("100", font) + 2 * (line + pad) + 4;
        if (w < 2 * h) {
            w = 2 * h;
        }
        var nubWidth = (h / 6 > 2) ? h / 6 : 2;
        var nubHeight = h / 2;

        var left = (x - (w + nubWidth) / 2.0 + 0.5).toNumber();
        var top = (y - h / 2.0 + 0.5).toNumber();

        // Outline drawn as a filled body with its inside cleared, so it is the same on every watch
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(left, top, w, h, line + 1);
        dc.fillRectangle(left + w, top + (h - nubHeight) / 2, nubWidth, nubHeight);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left + line, top + line, w - 2 * line, h - 2 * line);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + w / 2, top + h / 2, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Always-on face for AMOLED screens and the Venu Sq. Garmin requires it to stay under
    // 10% of the screen's brightness and recommends avoiding pixels that stay lit, so this
    // draws only thin grey hour and minute hands that start away from the pivot, and moves
    // them to a different spot (within 2 px) every minute.
    private function drawAlwaysOn(dc as Dc, cx as Number, cy as Number, radius as Number, hourAngleDeg as Numeric, minuteAngleDeg as Numeric, minute as Number) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

        // The first always-on watches (Venu, D2 Air, Venu Sq) are stricter. They are the ones
        // without System.getDisplayMode, which came with the Venu 2's brightness rule.
        if (!(System has :getDisplayMode)) {
            drawStrictAlwaysOn(dc, cx, cy, radius, hourAngleDeg, minuteAngleDeg, minute);
            return;
        }

        var shift = minute % 9;
        var x = cx + (shift % 3 - 1) * 2;
        var y = cy + (shift / 3 - 1) * 2;

        dc.setPenWidth(3);
        drawRadialLine(dc, x, y, hourAngleDeg, 10, radius * 0.5);
        dc.setPenWidth(2);
        drawRadialLine(dc, x, y, minuteAngleDeg, 10, radius * 0.75);
    }

    // Always-on hands for the first always-on watches, which turn the screen off if any pixel
    // stays lit for more than 3 minutes. Every minute both hands move 3 px to the other side of
    // their line, so their pixels go dark the next minute. They start 24 px out, because nearer
    // the pivot they move too little. And the minute hand leaves out the part that runs within
    // 12 px of the hour hand, so it can't relight the hour hand's pixels in the minute between.
    // Simulated minute by minute over 12 hours, no pixel stays lit for more than 3 minutes.
    private function drawStrictAlwaysOn(dc as Dc, cx as Number, cy as Number, radius as Number, hourAngleDeg as Numeric, minuteAngleDeg as Numeric, minute as Number) as Void {
        var side = (minute % 2 == 0) ? -3 : 3;

        // Where the minute hand starts: 24 px out, or further while it lies close to the hour hand
        // (12 px from the hour hand's line, or just past its tip when the hands are nearly in line)
        var minuteInner = 24.0;
        var between = (hourAngleDeg - minuteAngleDeg) * Math.PI / 180.0;
        var spread = Math.sin(between).abs();
        if (Math.cos(between) > 0 && spread * minuteInner < 12) {
            var pastHourHand = radius * 0.5 + 4;
            minuteInner = (spread * pastHourHand > 12) ? 12 / spread : pastHourHand;
        }

        dc.setPenWidth(3);
        drawRadialLineToSide(dc, cx, cy, hourAngleDeg, side, 24, radius * 0.5);
        dc.setPenWidth(2);
        drawRadialLineToSide(dc, cx, cy, minuteAngleDeg, side, minuteInner, radius * 0.75);
    }

    // Draws a line along angleDeg (hands, hour marks), from `inner` to `outer` pixels out from the centre
    private function drawRadialLine(dc as Dc, cx as Numeric, cy as Numeric, angleDeg as Numeric, inner as Numeric, outer as Numeric) as Void {
        var rad = angleDeg * Math.PI / 180.0;
        var cos = Math.cos(rad);
        var sin = Math.sin(rad);
        dc.drawLine(cx + cos * inner, cy - sin * inner, cx + cos * outer, cy - sin * outer);
    }

    // drawRadialLine moved `side` px sideways: to the right of the line's direction, or to the left when negative
    private function drawRadialLineToSide(dc as Dc, cx as Numeric, cy as Numeric, angleDeg as Numeric, side as Numeric, inner as Numeric, outer as Numeric) as Void {
        var rad = angleDeg * Math.PI / 180.0;
        drawRadialLine(dc, cx + side * Math.sin(rad), cy + side * Math.cos(rad), angleDeg, inner, outer);
    }

    // Corner radius of the rectangular screens, measured from Garmin's device images:
    // Venu X1 (448x486) about 68 px; Venu Sq 2 and Sq 2 Music (320x360), and Venu Sq and Sq Music
    // (240x240), about 10 px
    private function screenCornerRadius(w as Number, h as Number) as Number {
        return (w == 448 && h == 486) ? 68 : 10;
    }

    // Distance from the centre to the edge of a centred rounded rectangle (half-width hw,
    // half-height hh, corner radius r) along angleDeg (90 is 12 o'clock, decreasing clockwise)
    private function distanceToRoundedRect(angleDeg as Numeric, hw as Numeric, hh as Numeric, r as Numeric) as Numeric {
        var rad = angleDeg * Math.PI / 180.0;
        var ux = Math.cos(rad).abs();
        var uy = Math.sin(rad).abs();

        // Where the direction meets the straight edges: whichever edge it reaches first
        var t = (ux * hh > uy * hw) ? hw / ux : hh / uy;

        // If that point lies on a rounded corner, meet the corner's circle instead
        if (r > 0 && ux * t > hw - r && uy * t > hh - r) {
            var ccx = hw - r;
            var ccy = hh - r;
            var b = ux * ccx + uy * ccy;
            t = b + Math.sqrt(b * b - (ccx * ccx + ccy * ccy - r * r));
        }
        return t;
    }

    // On a watch with mechanical hands over the screen, asks the system to point them at the
    // current time (left alone they are reported to rest flat at 9 and 3 o'clock under a
    // Connect IQ face). Returns true only if that worked; otherwise the face draws its own hands.
    private function usePhysicalHands() as Boolean {
        // Both checks are needed: the compiler rejects the clock state on watches whose software
        // predates it (Approach S62, vívoactive 3 models) unless the code checks for it first
        if ((WatchUi.View has :setClockHandPosition) && (WatchUi has :ANALOG_CLOCK_STATE_SYSTEM_TIME)) {
            try {
                return setClockHandPosition({:clockState => WatchUi.ANALOG_CLOCK_STATE_SYSTEM_TIME});
            } catch (e instanceof Lang.Exception) {
                // Some watch software has refused this request; draw our own hands instead
            }
        }
        return false;
    }

    // True on screens that need the always-on burn-in rules (AMOLED, and the Venu Sq's LCD)
    private function needsBurnInProtection() as Boolean {
        var settings = System.getDeviceSettings();
        return (settings has :requiresBurnInProtection) && settings.requiresBurnInProtection;
    }

}
