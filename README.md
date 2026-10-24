MinimalismFace — Simple Watch Face

Overview
- A minimal analog Connect IQ watch face for Venu 3 and Venu 3S: hour, minute and seconds hands plus the date, with a dimmed always-on mode.

Prerequisites
- Install the Connect IQ SDK: https://developer.garmin.com/connect-iq/sdk/
- Install Visual Studio Code and the Connect IQ/Monkey C extension (recommended).

Build & Run in the Simulator (command line)
- Replace `<SDK_PATH>` below with your Connect IQ SDK install folder.

Build the .iq package:

```bash
<SDK_PATH>/bin/monkeyc -f manifest.xml -o bin/MinimalismFace.iq -y
```

Run the simulator for Venu 3:

```bash
<SDK_PATH>/bin/simulator -f bin/MinimalismFace.iq -d venu3
```

Run in VS Code (recommended)
- Open this folder in VS Code.
- Configure the Connect IQ SDK path in the extension settings.
- Use the Connect IQ extension Run/Debug commands (Command Palette) to launch the simulator targeting `venu3`.

VS Code Tasks (one-click build + run)
- Set an environment variable `CONNECTIQ_SDK` pointing to your Connect IQ SDK folder (or edit the commands in `.vscode/tasks.json`).
- In VS Code run the task: `Tasks: Run Task` → `Build & Run Simulator` (this will build the `.iq` and launch the simulator for `venu3`).

Files added to help:
- `.vscode/tasks.json` — tasks to build and run the simulator using `${env:CONNECTIQ_SDK}`.

Install on a Venu 3 device
- The usual method for users is to publish the app through the Connect IQ Store and install it from Garmin Connect Mobile.
- For local testing on your paired device, follow Garmin's developer documentation for side-loading and device deployment:
  https://developer.garmin.com/connect-iq/dev-guides/overview/

Files of interest
- `source/MinimalismFaceView.mc` — watch face view; draws the dial, hands and date, plus the dimmed always-on face.
- `manifest.xml` — app manifest (targets `venu3` and `venu3s`).