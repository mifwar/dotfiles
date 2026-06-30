#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Save Clipboard Image to /tmp
# @raycast.mode silent
# @raycast.packageName Utilities
# @raycast.description Save the current clipboard image to /tmp

set -euo pipefail

# Use timestamp prefix to avoid collisions.
output_path="/tmp/$(date +%Y%m%d-%H%M%S)-clipboard.png"

if command -v pngpaste >/dev/null 2>&1; then
  if ! pngpaste "$output_path"; then
    echo "No image data found on the clipboard."
    exit 1
  fi
else
  if ! /usr/bin/osascript -l JavaScript <<EOF; then
ObjC.import("AppKit");

const pb = $.NSPasteboard.generalPasteboard;
let data = pb.dataForType($.NSPasteboardTypePNG);
if (!data) data = pb.dataForType($.NSPasteboardTypeTIFF);
if (!data) throw "No image data found on the clipboard.";

const image = $.NSImage.alloc.initWithData(data);
const rep = $.NSBitmapImageRep.alloc.initWithData(image.TIFFRepresentation);
const pngData = rep.representationUsingTypeProperties($.NSBitmapImageFileTypePNG, $.NSDictionary.alloc.init);
pngData.writeToFileAtomically("$output_path", true);
EOF
    echo "No image data found on the clipboard."
    exit 1
  fi
fi

printf "attached image: %s" "$output_path" | pbcopy
echo "Saved to $output_path (path copied to clipboard with label)"
