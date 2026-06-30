import { mkdir, readdir, readFile, unlink, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { SpaceProfile, YabaiWindow } from "./types.js";

const PROFILE_DIR = join(homedir(), ".config", "ysnap", "profiles");

async function ensureDir() {
  await mkdir(PROFILE_DIR, { recursive: true });
}

function windowToState(w: YabaiWindow) {
  return {
    id: w.id,
    app: w.app,
    title: w.title,
    frame: { ...w.frame },
    floating: w.floating === 1,
    layer: w.layer,
  };
}

export async function saveProfile(
  name: string,
  spaceIndex: number,
  layout: string,
  windows: YabaiWindow[]
): Promise<void> {
  await ensureDir();
  const profile: SpaceProfile = {
    name,
    createdAt: new Date().toISOString(),
    spaceIndex,
    layout,
    windows: windows.map(windowToState),
  };
  const path = join(PROFILE_DIR, `${name}.json`);
  await writeFile(path, JSON.stringify(profile, null, 2), "utf-8");
}

export async function listProfiles(): Promise<string[]> {
  try {
    const files = await readdir(PROFILE_DIR);
    return files
      .filter((f) => f.endsWith(".json"))
      .map((f) => f.replace(/\.json$/, ""))
      .sort();
  } catch {
    return [];
  }
}

export async function loadProfile(name: string): Promise<SpaceProfile | null> {
  try {
    const path = join(PROFILE_DIR, `${name}.json`);
    const raw = await readFile(path, "utf-8");
    return JSON.parse(raw) as SpaceProfile;
  } catch {
    return null;
  }
}

export async function deleteProfile(name: string): Promise<boolean> {
  try {
    const path = join(PROFILE_DIR, `${name}.json`);
    await unlink(path);
    return true;
  } catch {
    return false;
  }
}
