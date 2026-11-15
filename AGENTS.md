# MinimalismFace

A minimal analog Garmin Connect IQ watch face, written in Monkey C. It runs on about 100 colour watches from 2019 onward (`manifest.xml`, minApiLevel 1.2.0). The owner is new to Connect IQ, so explain CIQ concepts (sleep and always-on modes, AMOLED burn-in rules, monkeyc and monkeydo) when they come up.

## Where things are
- `source/MinimalismFaceView.mc`: draws the dial, hands, data fields and the dimmed always-on face. It's about 600 lines, so search it rather than reading all of it.
- `source/Settings.mc`: settings stored as app properties, including migration. `source/SettingsMenu.mc`: the on-watch settings menu (CIQ 3.2 and later only).
- `resources/`: the defaults. `resources-amoled/` adds the Smooth seconds setting (the screen sizes it applies to are listed in `monkey.jungle`). `resources-venu445mm/` and `resources-vivoactive5/` hold per-watch drawables. `personality/` holds launcher icon sizes for older watches.
- `README.md` (user docs) and `store/listing.md` (store text) describe every setting. Update both when a feature changes.

## Build and run
The developer key is `../developer_key`. The SDK comes from `$CONNECTIQ_SDK` or the SDK Manager.
- Simulator: `scripts/simulator.sh <product-id>`, for example `fenix847mm`. It builds `bin/simulator/MinimalismFace.prg` and keeps running until the face closes.
- Store package: `scripts/export.sh`, which writes `bin/MinimalismFace.iq`.
- Before committing, build with strict type checking: `"$SDK/bin/monkeyc" -d fenix847mm -f monkey.jungle -o bin/check.prg -y ../developer_key -l 3 -w`.
- The project path contains a space, and monkeydo splits arguments at spaces. Run tools from the project folder with relative paths.

## Simulator quirks (SDK 9.3.0)
- Only the first monkeydo run after a simulator restart responds. Quit the simulator (`osascript -e 'quit app "ConnectIQ"'`) before each run.
- Always name test builds `MinimalismFace.prg`. The simulator remembers the first name an app was installed under, and the settings editor breaks if the name differs.
- `Properties.setValue` values are only saved reliably on a clean quit, not a kill.
- There is one settings store per app, shared by every device, so test values carry over into the owner's own runs. Say what a test leaves behind.
- The simulator reports steps as 0 and heart rate as 80. There's no screen capture permission, so the owner checks the rendering by eye.

## Releases and the store
- The owner's own watch is the fēnix 8 AMOLED 47mm (`fenix847mm`), so test there first.
- The app version lives only in the top line of "What's new" in `store/listing.md` and in the version the owner types when uploading to the Connect IQ developer dashboard. `manifest.xml` has no app version, the face shows none, and there are no git tags. For a release, add a "What's new" line; there's nothing else to bump. The current release is 1.5.0.
- `store/listing.md` holds the text the owner pastes into the dashboard by hand, so changes there don't reach the store until they do. The Description ends with a PayPal donation line; because of it the dashboard's monetization question may need a Yes.
- Still open: store screenshots (steps in `store/listing.md` under Images). They need the simulator on the owner's Mac, since the agent can't capture the screen.

## Working rules
- Make one commit per change and push straight to `main`. Don't create feature branches. Leave the owner's uncommitted edits out of commits.
- Keep reviews tightly scoped: name the files and questions, and limit the number of tool calls. Ask before starting any multi-agent review. An open-ended one once used about 1M tokens and found nothing.
- Don't read `bin/`, screenshots or SDK binaries.
