MinimalismFace — Simple Watch Face

Overview
- A minimal analog Connect IQ watch face for Garmin's AMOLED watches from the Venu 2/2S onward: hour, minute and seconds hands plus the weekday and date, with a dimmed always-on mode.
- Settings, on the watch or in the Connect IQ app on the phone, put the date and an optional battery level above or below the centre, or turn either off.

Prerequisites
- Install the Connect IQ SDK: https://developer.garmin.com/connect-iq/sdk/
- Install Visual Studio Code and the Connect IQ/Monkey C extension (recommended).

Build & Run in the Simulator (command line)
- Replace `<SDK_PATH>` below with your Connect IQ SDK install folder.

Build the .iq package:

```bash
<SDK_PATH>/bin/monkeyc -f manifest.xml -o bin/MinimalismFace.iq -y
```

Run the simulator for Fēnix 8 AMOLED 47mm:

```bash
<SDK_PATH>/bin/simulator -f bin/MinimalismFace.iq -d fenix847mm
```

Run in VS Code (recommended)
- Open this folder in VS Code.
- Configure the Connect IQ SDK path in the extension settings.
- Use the Connect IQ extension Run/Debug commands (Command Palette) to launch the simulator targeting `fenix847mm` (Fēnix 8 47mm / 51mm).

VS Code Tasks (one-click build + run)
- Set an environment variable `CONNECTIQ_SDK` pointing to your Connect IQ SDK folder (or edit the commands in `.vscode/tasks.json`).
- In VS Code run the task: `Tasks: Run Task` → `Build & Run Simulator` (this will build the `.iq` and launch the simulator for `fenix847mm`).

Files added to help:
- `.vscode/tasks.json` — tasks to build and run the simulator using `${env:CONNECTIQ_SDK}`.

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