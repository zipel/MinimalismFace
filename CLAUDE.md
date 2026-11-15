# MinimalismFace

Shared rules for all the owner's Garmin apps are in `../AGENTS.md`. Read it before starting, in Claude Code too: on 2026-11-15 Claude Code didn't load it on its own. This file adds what is specific to this app, and wins where the two differ.

A minimal analog Garmin Connect IQ watch face, written in Monkey C. It runs on about 100 colour watches from 2019 onward (`manifest.xml`, minApiLevel 1.2.0).

## Where things are
- `source/MinimalismFaceView.mc`: draws the dial, hands, data fields and the dimmed always-on face. It's about 600 lines, so search it rather than reading all of it.
- `source/Settings.mc`: settings stored as app properties, including migration. `source/SettingsMenu.mc`: the on-watch settings menu (CIQ 3.2 and later only).
- `resources/`: the defaults. `resources-amoled/` adds the Smooth seconds setting (the screen sizes it applies to are listed in `monkey.jungle`). `resources-venu445mm/` and `resources-vivoactive5/` hold per-watch drawables. `personality/` holds launcher icon sizes for older watches.
- `README.md` (user docs) and `store/listing.md` (store text) describe every setting. Update both when a feature changes, and add a line to "What's new" in the listing for each release.

## Settings and design decisions
- Dial values: 0 outline and marks, 1 marks only, 2 none, 3 marks and numbers, 4 numbers only. The menu and phone list show them in the order 0, 1, 3, 4, 2. Stored values never change meaning: add new choices at the end and reorder only the lists.
- With marks and numbers, 12, 3, 6 and 9 replace their marks. Numbers only shows all twelve numbers and never the outline. Number positions are computed once and cached (`_hourNumbers`).
- Four data field places (top, right, bottom, left), each showing one of date, battery, steps or heart rate, or nothing. A field shows in one place at a time: picking one that's already shown elsewhere swaps the two places (`withoutDuplicates` in `Settings.mc`). Test it with several changes at once, not only single changes. All four sit at 47% of the radius.
- Steps read as the number up to 999, then whole thousands rounded down (1K, 6K, 12K). This keeps the field narrow enough for the small screens.
- The heart icon is one outline polygon, cached after the first draw so the face stays within the frame budget. Watch the frame budget when adding drawing work: Smooth seconds on the slowest AMOLED watches is the tight case.
- The tightest fit is the date next to the 3 or 9 on the vívoactive 3, at about 3 px. Check that watch first when anything gets wider.
- Data fields need no extra permissions, and new settings don't need a reinstall: `Settings.mc` migrates old values.

## Build and run
The developer key is `../developer_key`. The SDK comes from `$CONNECTIQ_SDK` or the SDK Manager.
- Simulator: `scripts/simulator.sh <product-id>`, for example `fenix847mm`. It builds `bin/simulator/MinimalismFace.prg` and keeps running until the face closes.
- Store package: `scripts/export.sh`, which writes `bin/MinimalismFace.iq`.
- To build for every watch at once, add `-e -r` (about 180 builds for 110 watches). It should finish with 0 warnings.
- Before committing, build with strict type checking: `"$SDK/bin/monkeyc" -d fenix847mm -f monkey.jungle -o bin/check.prg -y ../developer_key -l 3 -w`.

## Simulator quirks (SDK 9.3.0)
- Only the first monkeydo run after a simulator restart responds. Quit the simulator (`osascript -e 'quit app "ConnectIQ"'`) before each run.
- Always name test builds `MinimalismFace.prg`. The simulator remembers the first name an app was installed under, and the settings editor breaks if the name differs ("No settings file found for this app"). To fix it, quit the simulator and delete the wrong name's files from `$TMPDIR/com.garmin.connectiq/GARMIN/APPS/` (`MEDIA`, `SETTINGS` and `DATA`).
- To test with a given step count, try Simulation > Activity Monitoring > Set Activity Monitor Info (not yet confirmed by clicking it). Otherwise hard-code the value temporarily in `refreshReadings`, and revert it before exporting.
- `Properties.setValue` values are only saved reliably on a clean quit, not a kill.
- There is one settings store per app, shared by every device, so test values carry over into the owner's own runs. Say what a test leaves behind.
- The simulator reports steps as 0 and heart rate as 80. There's no screen capture permission, so the owner checks the rendering by eye.

## Releases and the store
- The owner's own watch is the fēnix 8 AMOLED 47mm (`fenix847mm`), so test there first.
- The app version lives only in the top line of "What's new" in `store/listing.md` and in the version the owner types when uploading to the Connect IQ developer dashboard. `manifest.xml` has no app version, the face shows none, and there are no git tags. For a release, add a "What's new" line; there's nothing else to bump. The current release is 1.5.0.
- `store/listing.md` holds the text the owner pastes into the dashboard by hand, so changes there don't reach the store until they do. The Description ends with a PayPal donation line, so the dashboard's monetization question needs a Yes. Garmin counts tips and donations, and a No can get the app delisted. A Yes puts a payment notice on the listing. The store has no donate button, only description text.
- The Forerunner 45 (Connect IQ 1.4.5) and Swim 2 are left out: the settings need `Application.Properties` (CIQ 2.4) and `Menu2` (CIQ 3.0). Supporting them would mean a separate code path, so they stay out unless users ask.
- Still open: store screenshots (steps in `store/listing.md` under Images). They need the simulator on the owner's Mac, since the agent can't capture the screen.
