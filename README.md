MinimalismFace — Simple Watch Face

Overview
- A minimal analog Connect IQ watch face for Garmin's AMOLED watches from the Venu 2/2S onward: hour, minute and seconds hands plus the weekday and date, with a dimmed always-on mode.
- Settings, on the watch or in the Connect IQ app on the phone, put the date and an optional battery level above or below the centre, or turn either off.

Prerequisites
- Install the Connect IQ SDK: https://developer.garmin.com/connect-iq/sdk/
- Install Visual Studio Code and the Connect IQ/Monkey C extension (recommended).

Build & Run in the Simulator (command line)
- Run these from this folder. Both scripts find the SDK through `CONNECTIQ_SDK` or the SDK Manager, and sign with `../developer_key` unless you pass your key's path as the last argument.

Build the .iq package for the Connect IQ Store:

```bash
scripts/export.sh
```

Run the simulator for Fēnix 8 AMOLED 47mm (any product id from `manifest.xml` works):

```bash
scripts/simulator.sh fenix847mm
```

The script builds the face for that watch, opens the simulator and sends the face to it with the SDK's `monkeydo` tool; the simulator only shows a watch once an app is sent to it. It keeps running, showing the face's output, until the face is closed.

Run in VS Code (recommended)
- Open this folder in VS Code.
- Configure the Connect IQ SDK path in the extension settings.
- Use the Connect IQ extension Run/Debug commands (Command Palette) to launch the simulator targeting `fenix847mm` (Fēnix 8 47mm / 51mm).

VS Code Tasks
- Both tasks run the scripts above and sign with the developer key set in the Monkey C extension (`monkeyC.developerKeyPath`), or with `../developer_key` when that setting is empty.
- `Tasks: Run Task` → `Build & Run Simulator`: pick the watch from the list (type part of its id, e.g. `fenix847`), and the face opens in the simulator on that watch. The list comes from the Monkey C extension. The task keeps running while the face is open; running it again stops that run, asks for the watch again and shows your latest code.
- `Tasks: Run Task` → `Export for Connect IQ Store`: builds `bin/MinimalismFace.iq`, the file to upload.

Files added to help:
- `.vscode/tasks.json` — the two tasks above.
- `scripts/simulator.sh` — builds the face for one watch and shows it in the simulator.
- `scripts/export.sh` — builds the package for the Connect IQ Store.

Install on a Fēnix 8 AMOLED 47mm device
- The usual method for users is to publish the app through the Connect IQ Store and install it from Garmin Connect Mobile.
- For local testing on your paired device, follow Garmin's developer documentation for side-loading and device deployment:
  https://developer.garmin.com/connect-iq/dev-guides/overview/

Files of interest
- `source/MinimalismFaceView.mc` — watch face view; draws the dial, hands, date and battery fields, plus the dimmed always-on face.
- `source/Settings.mc` — the two settings (where the date and the battery level go), stored as app properties.
- `source/SettingsMenu.mc` — the settings menu on the watch.
- `resources/settings/` — the same settings for the Connect IQ app on the phone.
- `manifest.xml` — app manifest (targets every AMOLED watch from the Venu 2/2S onward).