import Toybox.Application;
import Toybox.Lang;

// The face's settings: which data field each of the four places around the centre shows, what the
// dial shows, whether the seconds hand shows, and, on AMOLED watches, whether it sweeps
// instead of ticking. They are stored as properties, so the settings menu on the watch and the
// Connect IQ app on the phone (resources/settings and resources-amoled) change the same values.
module Settings {

    // Stored numbers; settings.xml uses the same values for the phone's lists
    enum Field {
        FIELD_NONE = 0,
        FIELD_DATE = 1,
        FIELD_BATTERY = 2,
        FIELD_STEPS = 3,
        FIELD_HEART_RATE = 4
    }

    enum Dial {
        DIAL_OUTLINE_AND_MARKS = 0,
        DIAL_MARKS_ONLY = 1,
        DIAL_NONE = 2,
        DIAL_MARKS_AND_NUMBERS = 3,
        DIAL_NUMBERS_ONLY = 4
    }

    // The places around the centre, in the order of fields and FIELD_KEYS
    enum Location {
        LOCATION_TOP = 0,
        LOCATION_RIGHT = 1,
        LOCATION_BOTTOM = 2,
        LOCATION_LEFT = 3
    }

    const FIELD_KEYS = ["TopField", "RightField", "BottomField", "LeftField"];

    // Current choices, kept here so the face doesn't read storage every second
    var fields as Array<Field> = [FIELD_NONE, FIELD_NONE, FIELD_DATE, FIELD_NONE] as Array<Field>;
    var dial as Dial = DIAL_OUTLINE_AND_MARKS;
    var secondsHand as Boolean = true;
    var smoothSeconds as Boolean = false;

    // Reads the settings from storage
    function load() as Void {
        moveOldPositions();

        var chosen = fields.slice(null, null);
        for (var i = 0; i < chosen.size(); i += 1) {
            chosen[i] = readChoice(FIELD_KEYS[i], fields[i], FIELD_HEART_RATE) as Field;
        }
        useFields(chosen, chosen, lastFields());

        dial = readChoice("Dial", DIAL_OUTLINE_AND_MARKS, DIAL_NUMBERS_ONLY) as Dial;
        secondsHand = readSwitch("SecondsHand", true);
        // Stays off on the other watches, whose builds don't have this property
        smoothSeconds = readSwitch("SmoothSeconds", false);
    }

    // Before version 1.4.0 the date and the battery each had a position: 0 = off, 1 = top, 2 = bottom.
    // The first time a newer version runs, this moves those choices to the top and bottom data
    // fields, and putting the old values back to their defaults marks that as done. Those defaults
    // need no move, as the new settings' defaults show the same thing.
    function moveOldPositions() as Void {
        var date = readChoice("DatePosition", 2, 2);
        var battery = readChoice("BatteryPosition", 0, 2);
        if (date == 2 && battery == 0) {
            return;
        }
        writeChoice(FIELD_KEYS[LOCATION_TOP], (date == 1) ? FIELD_DATE : ((battery == 1) ? FIELD_BATTERY : FIELD_NONE));
        writeChoice(FIELD_KEYS[LOCATION_BOTTOM], (date == 2) ? FIELD_DATE : ((battery == 2) ? FIELD_BATTERY : FIELD_NONE));
        writeChoice("DatePosition", 2);
        writeChoice("BatteryPosition", 0);
    }

    // Choices made in the settings menu on the watch
    function setField(location as Location, field as Field) as Void {
        var chosen = fields.slice(null, null);
        chosen[location] = field;
        useFields(chosen, fields, fields);
    }

    function setDial(choice as Dial) as Void {
        dial = choice;
        writeChoice("Dial", choice);
    }

    function setSecondsHand(on as Boolean) as Void {
        secondsHand = on;
        writeChoice("SecondsHand", on);
    }

    function setSmoothSeconds(on as Boolean) as Void {
        smoothSeconds = on;
        writeChoice("SmoothSeconds", on);
    }

    // Starts using the chosen data fields, without duplicates. Saves any that differ from the stored
    // ones, and what the face now shows if it differs from what it last showed.
    function useFields(chosen as Array<Field>, stored as Array<Field>, last as Array<Field>) as Void {
        var result = withoutDuplicates(chosen, last);
        var changed = false;
        for (var i = 0; i < result.size(); i += 1) {
            if (result[i] != stored[i]) {
                writeChoice(FIELD_KEYS[i], result[i]);
            }
            if (result[i] != last[i]) {
                changed = true;
            }
        }
        fields = result;
        if (changed) {
            Application.Storage.setValue("ShownFields", result as Array<Application.Storage.ValueType>);
        }
    }

    // Each data field can show in only one place, but the phone's lists let it be chosen in several.
    // Then a place that was just changed keeps it, and a place that wasn't takes what the changed
    // place showed before, so the two swap. A choice in the watch's menu works the same way.
    function withoutDuplicates(chosen as Array<Field>, last as Array<Field>) as Array<Field> {
        var result = chosen.slice(null, null);
        for (var i = 0; i < chosen.size(); i += 1) {
            for (var j = 0; j < chosen.size(); j += 1) {
                // Changed places go first, then the order of the places
                var changedI = chosen[i] != last[i];
                var changedJ = chosen[j] != last[j];
                if (chosen[i] != FIELD_NONE && chosen[j] == chosen[i] && j != i
                        && ((changedJ && !changedI) || (changedJ == changedI && j < i))) {
                    result[i] = FIELD_NONE;
                }
            }
        }
        for (var i = 0; i < chosen.size(); i += 1) {
            if (result[i] != chosen[i] && chosen[i] == last[i]) {
                for (var j = 0; j < chosen.size(); j += 1) {
                    if (chosen[j] == chosen[i] && chosen[j] != last[j] && last[j] != FIELD_NONE && result.indexOf(last[j]) == -1) {
                        result[i] = last[j];
                        break;
                    }
                }
            }
        }
        return result;
    }

    // A stored choice from 0 to maxValue, or the default if it is missing or out of range.
    // Some phone apps have stored numbers as text, so anything that converts to a number is accepted.
    function readChoice(key as String, defaultValue as Number, maxValue as Number) as Number {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e instanceof Lang.Exception) {
            return defaultValue;
        }
        if (value instanceof Lang.Long || value instanceof Lang.Float || value instanceof Lang.Double || value instanceof Lang.String) {
            value = value.toNumber();
        }
        if (value instanceof Number && value >= 0 && value <= maxValue) {
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

    // What the face last showed. It is kept in storage because the face is restarted, for example
    // when its settings menu on the watch closes, and load() needs it after that.
    function lastFields() as Array<Field> {
        var stored = Application.Storage.getValue("ShownFields");
        if (stored instanceof Array && stored.size() == fields.size()) {
            return stored as Array<Field>;
        }
        return fields;
    }
}
