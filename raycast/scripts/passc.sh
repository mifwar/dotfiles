#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy Pass Entry
# @raycast.mode silent
# @raycast.packageName Password
# @raycast.description Copy a pass entry to the clipboard without recording it in Raycast's history
# @raycast.argument1 { "type": "text", "placeholder": "entry (e.g. email/gmail)" }

set -euo pipefail

passc "$1"
echo "Copied '$1' (auto-clears in ~45s, not stored in clipboard history)"
