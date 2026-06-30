import { execFileSync } from "node:child_process";
import type { YabaiSpace, YabaiWindow } from "./types.js";

/** Run a yabai command, returning stdout as a string. Throws on failure. */
function yabai(args: string[]): string {
  return execFileSync("yabai", args, { encoding: "utf-8" });
}

export function querySpaces(): YabaiSpace[] {
  const out = yabai(["-m", "query", "--spaces"]);
  return JSON.parse(out) as YabaiSpace[];
}

export function queryWindows(): YabaiWindow[] {
  const out = yabai(["-m", "query", "--windows"]);
  return JSON.parse(out) as YabaiWindow[];
}

export function queryWindowsForSpace(spaceId: number): YabaiWindow[] {
  const out = yabai(["-m", "query", "--windows", "--space", String(spaceId)]);
  return JSON.parse(out) as YabaiWindow[];
}

export function getFocusedSpace(): YabaiSpace | undefined {
  return querySpaces().find((s) => s["has-focus"]);
}

export function applyLayout(layout: string, spaceIndex: number) {
  yabai(["-m", "space", String(spaceIndex), "--layout", layout]);
}

export function setWindowFloat(windowId: number) {
  yabai(["-m", "window", String(windowId), "--toggle", "float"]);
}

export function moveWindowAbsolute(windowId: number, x: number, y: number) {
  yabai(["-m", "window", String(windowId), "--move", `abs:${x}:${y}`]);
}

export function resizeWindowAbsolute(windowId: number, w: number, h: number) {
  yabai(["-m", "window", String(windowId), "--resize", `abs:${w}:${h}`]);
}
