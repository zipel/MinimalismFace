#!/bin/bash
# Builds bin/MinimalismFace.iq, the package to upload to the Connect IQ Store.
#
# Usage: scripts/export.sh [developer-key]
#   developer-key  path to your developer key; by default developer_key in the
#                  folder that contains this project
#
# The SDK is the one in $CONNECTIQ_SDK, or else the one selected in the SDK Manager.

KEY="$1"

# A key path you give is relative to the folder you ran this from
case "$KEY" in
    "" | /*) ;;
    *) KEY="$PWD/$KEY" ;;
esac

cd "$(dirname "$0")/.." || exit 1
if [ -z "$KEY" ]; then
    KEY="../developer_key"
fi
if [ ! -f "$KEY" ]; then
    echo "Can't find the developer key $KEY. Pass its path as an argument." >&2
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

"$SDK/bin/monkeyc" -e -r -f monkey.jungle -o bin/MinimalismFace.iq -y "$KEY" -w
