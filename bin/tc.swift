// tc — transient copy
// Reads from stdin and writes to NSPasteboard with the
// "org.nspasteboard.TransientType" marker, which well-behaved clipboard
// managers (Raycast, Maccy, Flycut, …) honor by skipping the entry.
//
// If stdin is empty, the pasteboard is cleared — this is how `pass` performs
// its timed auto-clear.

import AppKit

let data = FileHandle.standardInput.readDataToEndOfFile()
let content = String(data: data, encoding: .utf8) ?? ""
let pb = NSPasteboard.general

if content.isEmpty {
    pb.clearContents()
} else {
    // Apple-blessed way to mark pasteboard content as transient. Set as an
    // additional type alongside .string; clipboard managers look for this
    // type and exclude matching entries from history.
    let transient = NSPasteboard.PasteboardType("org.nspasteboard.TransientType")
    pb.declareTypes([.string, transient], owner: nil)
    pb.setString(content, forType: .string)
}
