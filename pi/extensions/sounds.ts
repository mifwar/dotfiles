import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { exec } from "node:child_process";
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { homedir } from "node:os";

const FLAG = `${homedir()}/.pi/agent/sound.txt`;

function soundsOn(): boolean {
  return !(existsSync(FLAG) && readFileSync(FLAG, "utf8").trim() === "0");
}

function play(sound: string) {
  if (!soundsOn()) return;
  // macOS: afplay. Linux: paplay (PulseAudio) / aplay (ALSA).
  if (process.platform === "darwin") {
    exec(`afplay /System/Library/Sounds/${sound}.aiff`);
  } else {
    exec(
      `paplay /usr/share/sounds/freedesktop/stereo/${sound}.oga || aplay /usr/share/sounds/alsa/Front_Center.wav`,
    );
  }
}

export default function (pi: ExtensionAPI) {
  // Fires when a run finishes with nothing left (no retries/compaction/follow-ups)
  pi.on("agent_settled", async () => play("Glass"));

  pi.registerCommand("sound", {
    description: "Toggle completion sounds, or: /sound on|off",
    handler: async (args, ctx) => {
      const wantOn =
        args?.trim() === "on" || (args?.trim() !== "off" && !soundsOn());
      writeFileSync(FLAG, wantOn ? "1" : "0");
      ctx.ui.notify(wantOn ? "Sounds on" : "Sounds off", "info");
    },
  });
}
