import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MinimalismFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        Settings.load();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new MinimalismFaceView() ];
    }

    // The face's settings menu on the watch
    function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        var menu = new SettingsMenu();
        return [menu, new SettingsMenuDelegate(menu)];
    }

    // Settings were changed in the Connect IQ app on the phone while the face is running
    function onSettingsChanged() as Void {
        Settings.load();
        WatchUi.requestUpdate();
    }

}

function getApp() as MinimalismFaceApp {
    return Application.getApp() as MinimalismFaceApp;
}