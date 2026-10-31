import Toybox.Lang;
import Toybox.WatchUi;

// The face's settings menu on the watch: "Date", "Battery" and "Dial", each showing its current
// choice underneath. Selecting one opens the list of its choices.
class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => WatchUi.loadResource(Rez.Strings.SettingsTitle) as String});
        addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.DateTitle) as String, positionLabel(Settings.datePosition), :date, null));
        addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.BatteryTitle) as String, positionLabel(Settings.batteryPosition), :battery, null));
        addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.DialTitle) as String, dialLabel(Settings.dial), :dial, null));
    }

    // Shows the current choices again (one choice can move the other)
    function refresh() as Void {
        showChoice(:date, positionLabel(Settings.datePosition));
        showChoice(:battery, positionLabel(Settings.batteryPosition));
        showChoice(:dial, dialLabel(Settings.dial));
    }

    private function showChoice(id as Symbol, label as String) as Void {
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
        var id = item.getId() as Symbol;
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
            var current = (id == :date) ? Settings.datePosition : Settings.batteryPosition;
            var positions = [Settings.POSITION_TOP, Settings.POSITION_BOTTOM, Settings.POSITION_OFF];
            for (var i = 0; i < positions.size(); i += 1) {
                list.addItem(new WatchUi.MenuItem(positionLabel(positions[i]), null, positions[i], null));
                if (positions[i] == current) {
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
    private var _setting as Symbol;

    function initialize(menu as SettingsMenu, setting as Symbol) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        _setting = setting;
    }

    function onSelect(item as MenuItem) as Void {
        if (_setting == :dial) {
            Settings.setDial(item.getId() as Settings.Dial);
        } else if (_setting == :date) {
            Settings.setDatePosition(item.getId() as Settings.Position);
        } else {
            Settings.setBatteryPosition(item.getId() as Settings.Position);
        }
        _menu.refresh();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// What the menus show for a place on the screen: "Top", "Bottom" or "Off"
function positionLabel(position as Settings.Position) as String {
    if (position == Settings.POSITION_TOP) {
        return WatchUi.loadResource(Rez.Strings.PositionTop) as String;
    } else if (position == Settings.POSITION_BOTTOM) {
        return WatchUi.loadResource(Rez.Strings.PositionBottom) as String;
    }
    return WatchUi.loadResource(Rez.Strings.PositionOff) as String;
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
