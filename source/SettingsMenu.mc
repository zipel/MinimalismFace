import Toybox.Lang;
import Toybox.WatchUi;

// The face's settings menu on the watch: "Date" and "Battery", each showing its current choice
// underneath. Selecting one opens the list of places it can go.
class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => WatchUi.loadResource(Rez.Strings.SettingsTitle) as String});
        addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.DateTitle) as String, positionLabel(Settings.datePosition), :date, null));
        addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.BatteryTitle) as String, positionLabel(Settings.batteryPosition), :battery, null));
    }

    // Shows the current choices again (one choice can move the other)
    function refresh() as Void {
        showChoice(:date, Settings.datePosition);
        showChoice(:battery, Settings.batteryPosition);
    }

    private function showChoice(id as Symbol, position as Settings.Position) as Void {
        var index = findItemById(id);
        var item = getItem(index);
        if (item != null) {
            item.setSubLabel(positionLabel(position));
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

    // Opens the list of places for the selected setting, starting at its current choice
    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as Symbol;
        var current = (id == :date) ? Settings.datePosition : Settings.batteryPosition;

        var list = new WatchUi.Menu2({:title => item.getLabel()});
        var positions = [Settings.POSITION_TOP, Settings.POSITION_BOTTOM, Settings.POSITION_OFF];
        for (var i = 0; i < positions.size(); i += 1) {
            list.addItem(new WatchUi.MenuItem(positionLabel(positions[i]), null, positions[i], null));
            if (positions[i] == current) {
                list.setFocus(i);
            }
        }
        WatchUi.pushView(list, new PositionMenuDelegate(_menu, id), WatchUi.SLIDE_LEFT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// The list of places for one setting: choosing one saves it and goes back to the settings menu
class PositionMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as SettingsMenu;
    private var _setting as Symbol;

    function initialize(menu as SettingsMenu, setting as Symbol) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        _setting = setting;
    }

    function onSelect(item as MenuItem) as Void {
        var position = item.getId() as Settings.Position;
        if (_setting == :date) {
            Settings.setDatePosition(position);
        } else {
            Settings.setBatteryPosition(position);
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
