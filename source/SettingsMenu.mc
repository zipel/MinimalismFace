import Toybox.Lang;
import Toybox.WatchUi;

// The face's settings menu on the watch: an entry for each of the four data fields and "Dial", each
// showing its current choice underneath (selecting one opens the list of its choices), a
// "Seconds hand" switch and, on AMOLED watches, a "Smooth seconds" switch.
class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => WatchUi.loadResource(Rez.Strings.SettingsTitle) as String});
        // A data field's entry has its place (Settings.Location) as its id
        var titles = [Rez.Strings.TopFieldTitle, Rez.Strings.RightFieldTitle, Rez.Strings.BottomFieldTitle, Rez.Strings.LeftFieldTitle];
        for (var i = 0; i < titles.size(); i += 1) {
            addItem(new WatchUi.MenuItem(WatchUi.loadResource(titles[i]) as String, fieldLabel(Settings.fields[i]), i, null));
        }
        addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.DialTitle) as String, dialLabel(Settings.dial), :dial, null));
        addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.SecondsTitle) as String, null, :seconds, Settings.secondsHand, null));
        // The setting's resources are only in AMOLED watches' builds (resources-amoled)
        if (Rez.Strings has :SmoothSecondsTitle) {
            addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.SmoothSecondsTitle) as String, null, :smoothSeconds, Settings.smoothSeconds, null));
        }
    }

    // Shows the current choices again (one choice can move another)
    function refresh() as Void {
        for (var i = 0; i < Settings.fields.size(); i += 1) {
            showChoice(i, fieldLabel(Settings.fields[i]));
        }
        showChoice(:dial, dialLabel(Settings.dial));
    }

    private function showChoice(id as Symbol or Number, label as String) as Void {
        var index = findItemById(id);
        var item = getItem(index);
        if (item != null) {
            item.setSubLabel(label);
            updateItem(item, index);
        }
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as SettingsMenu;

    function initialize(menu as SettingsMenu) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    // Opens the list of choices for the selected setting, starting at its current choice
    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as Symbol or Number;
        if (id == :seconds) {
            // The switch has already flipped itself; save its new state
            Settings.setSecondsHand((item as WatchUi.ToggleMenuItem).isEnabled());
            return;
        }
        if (id == :smoothSeconds) {
            Settings.setSmoothSeconds((item as WatchUi.ToggleMenuItem).isEnabled());
            return;
        }

        var list = new WatchUi.Menu2({:title => item.getLabel()});

        if (id == :dial) {
            var dials = [Settings.DIAL_OUTLINE_AND_MARKS, Settings.DIAL_MARKS_ONLY, Settings.DIAL_NONE];
            for (var i = 0; i < dials.size(); i += 1) {
                list.addItem(new WatchUi.MenuItem(dialLabel(dials[i]), null, dials[i], null));
                if (dials[i] == Settings.dial) {
                    list.setFocus(i);
                }
            }
        } else {
            var current = Settings.fields[id as Number];
            var choices = [Settings.FIELD_DATE, Settings.FIELD_BATTERY, Settings.FIELD_STEPS, Settings.FIELD_HEART_RATE, Settings.FIELD_NONE];
            for (var i = 0; i < choices.size(); i += 1) {
                list.addItem(new WatchUi.MenuItem(fieldLabel(choices[i]), null, choices[i], null));
                if (choices[i] == current) {
                    list.setFocus(i);
                }
            }
        }
        WatchUi.pushView(list, new ChoiceMenuDelegate(_menu, id), WatchUi.SLIDE_LEFT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// The list of choices for one setting: choosing one saves it and goes back to the settings menu
class ChoiceMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as SettingsMenu;
    private var _setting as Symbol or Number;

    function initialize(menu as SettingsMenu, setting as Symbol or Number) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        _setting = setting;
    }

    function onSelect(item as MenuItem) as Void {
        if (_setting == :dial) {
            Settings.setDial(item.getId() as Settings.Dial);
        } else {
            Settings.setField(_setting as Settings.Location, item.getId() as Settings.Field);
        }
        _menu.refresh();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// What the menus show for a data field: "Date", "Battery", "Steps", "Heart rate" or "None"
function fieldLabel(field as Settings.Field) as String {
    if (field == Settings.FIELD_DATE) {
        return WatchUi.loadResource(Rez.Strings.FieldDate) as String;
    } else if (field == Settings.FIELD_BATTERY) {
        return WatchUi.loadResource(Rez.Strings.FieldBattery) as String;
    } else if (field == Settings.FIELD_STEPS) {
        return WatchUi.loadResource(Rez.Strings.FieldSteps) as String;
    } else if (field == Settings.FIELD_HEART_RATE) {
        return WatchUi.loadResource(Rez.Strings.FieldHeartRate) as String;
    }
    return WatchUi.loadResource(Rez.Strings.FieldNone) as String;
}

// What the menus show for a dial choice: "Outline and marks", "Marks only" or "None"
function dialLabel(dial as Settings.Dial) as String {
    if (dial == Settings.DIAL_MARKS_ONLY) {
        return WatchUi.loadResource(Rez.Strings.DialMarksOnly) as String;
    } else if (dial == Settings.DIAL_NONE) {
        return WatchUi.loadResource(Rez.Strings.DialNone) as String;
    }
    return WatchUi.loadResource(Rez.Strings.DialOutlineAndMarks) as String;
}
