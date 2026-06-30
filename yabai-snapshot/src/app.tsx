import React, { useEffect, useState } from "react";
import { Box, Text, useApp, useInput } from "ink";
import {
  deleteProfile,
  listProfiles,
  loadProfile,
  saveProfile,
} from "./profile.js";
import {
  applyLayout,
  getFocusedSpace,
  queryWindowsForSpace,
} from "./yabai.js";
import type { SpaceProfile, YabaiWindow } from "./types.js";
import { execFileSync } from "node:child_process";

type View = "list" | "save" | "confirm-delete";

export default function App() {
  const { exit } = useApp();
  const [view, setView] = useState<View>("list");
  const [profiles, setProfiles] = useState<string[]>([]);
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [selectedProfile, setSelectedProfile] = useState<SpaceProfile | null>(
    null
  );
  const [saveName, setSaveName] = useState("");
  const [message, setMessage] = useState("");
  const [messageColor, setMessageColor] = useState("green");

  const refreshProfiles = async () => {
    const list = await listProfiles();
    setProfiles(list);
    if (selectedIndex >= list.length) {
      setSelectedIndex(Math.max(0, list.length - 1));
    }
  };

  useEffect(() => {
    refreshProfiles();
  }, []);

  useEffect(() => {
    const load = async () => {
      const name = profiles[selectedIndex];
      if (!name) {
        setSelectedProfile(null);
        return;
      }
      const p = await loadProfile(name);
      setSelectedProfile(p);
    };
    load();
  }, [profiles, selectedIndex]);

  const showMessage = (text: string, color = "green") => {
    setMessage(text);
    setMessageColor(color);
    setTimeout(() => setMessage(""), 3000);
  };

  const handleRestore = async () => {
    const profile = selectedProfile;
    if (!profile) return;

    const space = getFocusedSpace();
    if (!space) {
      showMessage("No focused space", "red");
      return;
    }

    applyLayout(profile.layout, space.index);

    const currentWindows = queryWindowsForSpace(space.id);
    const byApp = new Map<string, YabaiWindow[]>();
    for (const w of currentWindows) {
      const list = byApp.get(w.app) ?? [];
      list.push(w);
      byApp.set(w.app, list);
    }

    let restored = 0;
    for (const saved of profile.windows) {
      const candidates = byApp.get(saved.app);
      if (!candidates || candidates.length === 0) continue;
      const win = candidates.shift()!;

      if (saved.floating && !win.floating) {
        // yabai has no direct "set float"; toggle is best-effort.
        try {
          execFileSync("yabai", ["-m", "window", String(win.id), "--toggle", "float"]);
        } catch (err) {
          showMessage(`Failed to toggle float for ${saved.app}: ${String(err)}`, "yellow");
        }
      }

      if (saved.floating) {
        try {
          execFileSync("yabai", ["-m", "window", String(win.id), "--move", `abs:${saved.frame.x}:${saved.frame.y}`]);
          execFileSync("yabai", ["-m", "window", String(win.id), "--resize", `abs:${saved.frame.w}:${saved.frame.h}`]);
        } catch (err) {
          showMessage(`Failed to position ${saved.app}: ${String(err)}`, "yellow");
        }
      }
      restored++;
    }

    showMessage(
      `Restored ${restored}/${profile.windows.length} windows`,
      "green"
    );
  };

  const handleSave = async () => {
    const name = saveName.trim();
    if (!name) {
      setView("list");
      return;
    }
    const space = getFocusedSpace();
    if (!space) {
      showMessage("No focused space", "red");
      setView("list");
      return;
    }
    const windows = queryWindowsForSpace(space.id);
    await saveProfile(name, space.index, space.type, windows);
    await refreshProfiles();
    const idx = (await listProfiles()).indexOf(name);
    if (idx >= 0) setSelectedIndex(idx);
    setSaveName("");
    setView("list");
    showMessage(`Saved '${name}'`, "green");
  };

  const handleDelete = async () => {
    const name = profiles[selectedIndex];
    if (!name) return;
    await deleteProfile(name);
    await refreshProfiles();
    setView("list");
    showMessage(`Deleted '${name}'`, "yellow");
  };

  useInput((input, key) => {
    if (view === "save") {
      if (key.return) {
        handleSave();
        return;
      }
      if (key.escape) {
        setSaveName("");
        setView("list");
        return;
      }
      if (key.backspace || key.delete) {
        setSaveName((prev) => prev.slice(0, -1));
        return;
      }
      if (input && !key.ctrl && !key.meta) {
        setSaveName((prev) => prev + input);
        return;
      }
      return;
    }

    if (view === "confirm-delete") {
      if (input === "y" || input === "Y") {
        handleDelete();
      } else {
        setView("list");
      }
      return;
    }

    // list view
    if (input === "q" || key.escape) {
      exit();
      return;
    }
    if (input === "j" || key.downArrow) {
      setSelectedIndex((i) => Math.min(i + 1, profiles.length - 1));
      return;
    }
    if (input === "k" || key.upArrow) {
      setSelectedIndex((i) => Math.max(i - 1, 0));
      return;
    }
    if (key.return) {
      handleRestore();
      return;
    }
    if (input === "s") {
      setView("save");
      return;
    }
    if (input === "d") {
      if (profiles.length > 0) {
        setView("confirm-delete");
      }
      return;
    }
  });

  return (
    <Box flexDirection="column" height={24}>
      {/* Header */}
      <Box marginBottom={1}>
        <Text bold color="magenta">
          yabai-snapshot
        </Text>
        <Text dimColor> — save & restore window layouts</Text>
      </Box>

      {view === "save" && (
        <Box flexDirection="column" marginBottom={1}>
          <Text bold>Save current space layout</Text>
          <Text>
            Name: <Text color="cyan">{saveName}</Text>
            <Text dimColor>_</Text>
          </Text>
          <Text dimColor>Enter to confirm, Esc to cancel</Text>
        </Box>
      )}

      {view === "confirm-delete" && (
        <Box flexDirection="column" marginBottom={1}>
          <Text bold color="yellow">
            Delete profile '{profiles[selectedIndex]}'?
          </Text>
          <Text dimColor>y to confirm, any other key to cancel</Text>
        </Box>
      )}

      {view === "list" && (
        <>
          <Box flexDirection="row" flexGrow={1}>
            {/* Profile list */}
            <Box flexDirection="column" width={24} marginRight={2}>
              <Text underline bold>
                Profiles
              </Text>
              {profiles.length === 0 && (
                <Text dimColor>No profiles saved.</Text>
              )}
              {profiles.map((name, i) => (
                <Text
                  key={name}
                  color={i === selectedIndex ? "cyan" : undefined}
                  bold={i === selectedIndex}
                >
                  {i === selectedIndex ? "› " : "  "}
                  {name}
                </Text>
              ))}
            </Box>

            {/* Preview pane */}
            <Box flexDirection="column" flexGrow={1}>
              {selectedProfile ? (
                <>
                  <Text bold>{selectedProfile.name}</Text>
                  <Text dimColor>
                    Space {selectedProfile.spaceIndex} · {selectedProfile.layout}{" "}
                    · {selectedProfile.windows.length} windows
                  </Text>
                  <Text dimColor>
                    Saved {new Date(selectedProfile.createdAt).toLocaleString()}
                  </Text>
                  <Box marginTop={1} flexDirection="column">
                    {selectedProfile.windows.map((w) => (
                      <Text key={w.id} dimColor={w.floating ? false : true}>
                        {w.floating ? "◆ " : "  "}
                        {w.app}
                        <Text dimColor> — {w.title.slice(0, 40)}</Text>
                      </Text>
                    ))}
                  </Box>
                </>
              ) : (
                <Text dimColor>No profile selected.</Text>
              )}
            </Box>
          </Box>

          {/* Footer */}
          <Box marginTop={1}>
            <Text dimColor>
              ↑/k ↓/j navigate · Enter restore · s save · d delete · q quit
            </Text>
          </Box>
        </>
      )}

      {message && (
        <Box marginTop={1}>
          <Text color={messageColor}>{message}</Text>
        </Box>
      )}
    </Box>
  );
}
