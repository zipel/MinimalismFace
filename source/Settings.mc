import Toybox.Application;
import Toybox.Lang;

// The face's settings: where the date goes and where the battery level goes (each picks one of the
// two fields, above or below the centre, or Off), how much of the dial is drawn, and whether the
// seconds hand shows. They are stored as properties, so the settings menu on the watch and the
// Connect IQ app on the phone (resources/settings) change the same values.
module Settings {

    // Stored numbers; settings.xml uses the same values for the phone's lists
    enum Position {
        POSITION_OFF = 0,
        POSITION_TOP = 1,
        POSITION_BOTTOM = 2
    }

    enum Dial {
        DIAL_OUTLINE_AND_MARKS = 0,
        DIAL_MARKS_ONLY = 1,
        DIAL_NONE = 2
    }

    // Current choices, kept here so the face doesn't read storage every second
    var datePosition as Position = POSITION_BOTTOM;
    var batteryPosition as Position = POSITION_OFF;
    var dial as Dial = DIAL_OUTLINE_AND_MARKS;
    var secondsHand as Boolean = true;

    // Reads the settings from storage. The phone app can put the date and the battery in the same
    // field; then the one that was just changed keeps it, and the other moves to the remaining field.
    function load() as Void {
        var date = readChoice("DatePosition", POSITION_BOTTOM) as Position;
        var battery = readChoice("BatteryPosition", POSITION_OFF) as Position;

        if (date != POSITION_OFF && date == battery) {
            if (date == lastDatePosition()) {
                // The date stayed where it was, so the battery was moved onto it
                date = otherField(battery);
                writeChoice("DatePosition", date);
            } else {
                battery = otherField(date);
                writeChoice("BatteryPosition", battery);
            }
        }

        datePosition = date;
        batteryPosition = battery;
        rememberDatePosition();
        dial = readChoice("Dial", DIAL_OUTLINE_AND_MARKS) as Dial;
        secondsHand = readSwitch("SecondsHand", true);
    }

    // Choices made in the settings menu on the watch. Moving one field into the place the other
    // uses swaps them.
    function setDatePosition(position as Position) as Void {
        if (position != POSITION_OFF && position == batteryPosition) {
            batteryPosition = otherField(position);
            writeChoice("BatteryPosition", batteryPosition);
        }
        datePosition = position;
        writeChoice("DatePosition", position);
        rememberDatePosition();
    }

    function setBatteryPosition(position as Position) as Void {
        if (position != POSITION_OFF && position == datePosition) {
            datePosition = otherField(position);
            writeChoice("DatePosition", datePosition);
            rememberDatePosition();
        }
        batteryPosition = position;
        writeChoice("BatteryPosition", position);
    }

    function setDial(choice as Dial) as Void {
        dial = choice;
        writeChoice("Dial", choice);
    }

    function setSecondsHand(on as Boolean) as Void {
        secondsHand = on;
        writeChoice("SecondsHand", on);
    }

    // The top field for the bottom one and the other way round
    function otherField(position as Position) as Position {
        return position == POSITION_TOP ? POSITION_BOTTOM : POSITION_TOP;
    }

    // A stored choice (0, 1 or 2 for every setting), or the default if it is missing or out of range.
    // Some phone apps have stored numbers as text, so anything that converts to a number is accepted.
    function readChoice(key as String, defaultValue as Number) as Number {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e instanceof Lang.Exception) {
            return defaultValue;
        }
        if (value instanceof Lang.Long || value instanceof Lang.Float || value instanceof Lang.Double || value instanceof Lang.String) {
            value = value.toNumber();
        }
        if (value instanceof Number && value >= 0 && value <= 2) {
            return value;
        }
        return defaultValue;
    }

    // An on/off setting, or the default if it is missing. Text and numbers from older phone apps
    // are accepted too.
    function readSwitch(key as String, defaultValue as Boolean) as Boolean {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e instanceof Lang.Exception) {
            return defaultValue;
        }
        if (value instanceof Boolean) {
            return value;
        } else if (value instanceof Number) {
            return value != 0;
        } else if (value instanceof Lang.String) {
            return value.equals("true");
        }
        return defaultValue;
    }

    function writeChoice(key as String, value as Number or Boolean) as Void {
        try {
            Application.Properties.setValue(key, value);
        } catch (e instanceof Lang.Exception) {
            // Keep showing the choice even if it couldn't be saved
        }
    }

    // Where the face last showed the date. It is kept in storage because the face is restarted,
    // for example when its settings menu on the watch closes, and load() needs it after that.
    function lastDatePosition() as Position {
        var value = Application.Storage.getValue("ShownDatePosition");
        if (value instanceof Number) {
            return value as Position;
        }
        return datePosition;
    }

    function rememberDatePosition() as Void {
        var stored = Application.Storage.getValue("ShownDatePosition");
        if (!(stored instanceof Number) || stored != datePosition) {
            Application.Storage.setValue("ShownDatePosition", datePosition);
        }
    }
}
