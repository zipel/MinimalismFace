import Toybox.Application;
import Toybox.Lang;

// The face's two settings: where the date goes and where the battery level goes. Both pick one of
// the two fields, above or below the centre, or Off. They are stored as properties, so the settings
// menu on the watch and the Connect IQ app on the phone (resources/settings) change the same values.
module Settings {

    // Stored numbers; settings.xml uses the same values for the phone's lists
    enum Position {
        POSITION_OFF = 0,
        POSITION_TOP = 1,
        POSITION_BOTTOM = 2
    }

    // Current choices, kept here so the face doesn't read storage every second
    var datePosition as Position = POSITION_BOTTOM;
    var batteryPosition as Position = POSITION_OFF;

    // Reads both settings from storage. The phone app can put the date and the battery in the same
    // field; then the one that was just changed keeps it, and the other moves to the remaining field.
    function load() as Void {
        var date = readPosition("DatePosition", POSITION_BOTTOM);
        var battery = readPosition("BatteryPosition", POSITION_OFF);

        if (date != POSITION_OFF && date == battery) {
            if (date == lastDatePosition()) {
                // The date stayed where it was, so the battery was moved onto it
                date = otherField(battery);
                writePosition("DatePosition", date);
            } else {
                battery = otherField(date);
                writePosition("BatteryPosition", battery);
            }
        }

        datePosition = date;
        batteryPosition = battery;
        rememberDatePosition();
    }

    // Choices made in the settings menu on the watch. Moving one into the field the other
    // uses swaps them.
    function setDatePosition(position as Position) as Void {
        if (position != POSITION_OFF && position == batteryPosition) {
            batteryPosition = otherField(position);
            writePosition("BatteryPosition", batteryPosition);
        }
        datePosition = position;
        writePosition("DatePosition", position);
        rememberDatePosition();
    }

    function setBatteryPosition(position as Position) as Void {
        if (position != POSITION_OFF && position == datePosition) {
            datePosition = otherField(position);
            writePosition("DatePosition", datePosition);
            rememberDatePosition();
        }
        batteryPosition = position;
        writePosition("BatteryPosition", position);
    }

    // The top field for the bottom one and the other way round
    function otherField(position as Position) as Position {
        return position == POSITION_TOP ? POSITION_BOTTOM : POSITION_TOP;
    }

    // A stored position, or the default if it is missing or not one of the three values.
    // Some phone apps have stored numbers as text, so anything that converts to a number is accepted.
    function readPosition(key as String, defaultValue as Position) as Position {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e instanceof Lang.Exception) {
            return defaultValue;
        }
        if (value instanceof Lang.Long || value instanceof Lang.Float || value instanceof Lang.Double || value instanceof Lang.String) {
            value = value.toNumber();
        }
        if (value instanceof Number && value >= POSITION_OFF && value <= POSITION_BOTTOM) {
            return value as Position;
        }
        return defaultValue;
    }

    function writePosition(key as String, position as Position) as Void {
        try {
            Application.Properties.setValue(key, position);
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
