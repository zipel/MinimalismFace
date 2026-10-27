#!/bin/bash
# Builds the face for one watch and shows it in the Connect IQ simulator.
#
# Usage: scripts/simulator.sh <device> [developer-key]
#   device         the watch to simulate, e.g. fenix847mm (fēnix 8 AMOLED 47mm);
#                  the product ids in manifest.xml are the choices
#   developer-key  path to your developer key; by default developer_key in the
#                  folder that contains this project
#
# The SDK is the one in $CONNECTIQ_SDK, or else the one selected in the SDK Manager.

DEVICE="$1"
KEY="$2"

# The VS Code task passes ERR_NO_DEVICE when the watch picker is closed without a choice
if [ "$DEVICE" = "ERR_NO_DEVICE" ]; then
    echo "No watch was picked, so nothing was built." >&2
    exit 1
fi
if [ -z "$DEVICE" ]; then
    echo "Usage: $0 <device> [developer-key], for example: $0 fenix847mm" >&2
    exit 1
fi

# A key path you give is relative to the folder you ran this from
case "$KEY" in
    "" | /*) ;;
    *) KEY="$PWD/$KEY" ;;
esac

# Work from the project folder. The paths below stay relative to it because monkeydo
# splits its file arguments at spaces, and this project's full path contains one.
cd "$(dirname "$0")/.." || exit 1
if [ -z "$KEY" ]; then
    KEY="../developer_key"
fi
if [ ! -f "$KEY" ]; then
    echo "Can't find the developer key $KEY. Pass its path as the second argument." >&2
    exit 1
fi

SDK="$CONNECTIQ_SDK"
if [ -z "$SDK" ]; then
    SDK="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg" 2>/dev/null)"
fi
SDK="${SDK%/}"
if [ ! -x "$SDK/bin/monkeyc" ]; then
    echo "Can't find the Connect IQ SDK. Install one with the SDK Manager, or set CONNECTIQ_SDK to its folder." >&2
    exit 1
fi

OUT=bin/simulator
"$SDK/bin/monkeyc" -d "$DEVICE" -f monkey.jungle -o "$OUT/MinimalismFace.prg" -y "$KEY" -w || exit 1

# Open the simulator, or bring it to the front, and wait until it can receive apps
open -a "$SDK/bin/ConnectIQ.app"
attempt=0
until nc -z 127.0.0.1 1234 >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 60 ]; then
        echo "The simulator didn't start. Open it from the SDK Manager and run this again." >&2
        exit 1
    fi
    sleep 1
done

# Send the face, plus its settings file so File > Edit Persistent Storage can change its settings.
# monkeydo keeps running and shows the face's output until the face is closed.
"$SDK/bin/monkeydo" "$OUT/MinimalismFace.prg" "$DEVICE" \
    -a "$OUT/MinimalismFace-settings.json:GARMIN/Settings/MinimalismFace-settings.json"
