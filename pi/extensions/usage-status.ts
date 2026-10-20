/**
 * Subscription usage in the footer, for the active model's provider.
 *
 *   ⚡ 5h 75% → 2h24m · wk 33% → Mon 02:42 · mo 66% → 14 Nov 07:22
 *
 * Percentages are remaining; reset times use ai-usage's own compact vocabulary and
 *
 * Numbers come from `ai-usage status --json` (github.com/mifwar/ai-usage): one quota
 * implementation, the same one its dashboard renders. Refreshes after each settled run,
 * on a model switch, and every 5 minutes. A settled run forces a live fetch on top of
 * ai-usage's own 2-minute cache, at most once a minute, so a burst of turns cannot turn
 * into a burst of upstream requests.
 *
 * Install: symlink into ~/.pi/agent/extensions/usage-status.ts, then /reload.
 * Set AI_USAGE_BIN to override the binary.
 */
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const KEY = "usage";
const REFRESH_MS = 5 * 60_000;
const LIVE_MIN_MS = 60_000;
const TIMEOUT_MS = 20_000;

// pi provider id -> ai-usage provider name, where they differ
const ALIAS: Record<string, string> = { anthropic: "claude", "openai-codex": "codex" };
// window id -> footer label
const SHORT: Record<string, string> = { five_hour: "5h", weekly: "wk", monthly: "mo" };

// `go install` lands outside the PATH of a GUI-launched pi.
const BIN =
  [
    process.env.AI_USAGE_BIN,
    join(homedir(), "go/bin/ai-usage"),
    join(homedir(), ".local/bin/ai-usage"),
  ].find((p): p is string => !!p && existsSync(p)) ?? "ai-usage";

type Window = { id: string; label: string; percent?: number; resets_at?: string };
type Account = { status: string; windows: Window[] };

const DAY = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTH = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const pad = (n: number) => String(n).padStart(2, "0");
const hm = (t: Date) => `${pad(t.getHours())}:${pad(t.getMinutes())}`;
const sameDay = (a: Date, b: Date) => a.toDateString() === b.toDateString();

// Port of ai-usage's resetCompact(): "2h24m", "tmrw 07:00", "Mon 14:00", "14 Nov 07:22", local time.
export function resetIn(iso: string, now = new Date()): string | undefined {
  const t = new Date(iso);
  if (Number.isNaN(+t)) return undefined;
  const ms = t.getTime() - now.getTime();
  if (ms <= 0) return "now";
  if (ms < 60_000) return "<1m";
  if (ms < 3_600_000) return `${Math.floor(ms / 60_000)}m`;
  if (ms < 86_400_000 && sameDay(t, now)) {
    const h = Math.floor(ms / 3_600_000);
    const m = Math.floor(ms / 60_000) % 60;
    return m ? `${h}h${pad(m)}m` : `${h}h`;
  }
  const tomorrow = new Date(now);
  tomorrow.setDate(now.getDate() + 1);
  if (sameDay(t, tomorrow)) return `tmrw ${hm(t)}`;
  if (ms < 7 * 86_400_000) return `${DAY[t.getDay()]} ${hm(t)}`;
  return `${t.getDate()} ${MONTH[t.getMonth()]} ${hm(t)}`;
}

function line(account: Account | undefined): string | undefined {
  if (account?.status !== "ok") return undefined;
  const parts = account.windows.map((w) => {
    const name = SHORT[w.id] ?? w.label;
    const pct = w.percent === undefined ? name : `${name} ${Math.round(100 - w.percent)}%`;
    const reset = w.resets_at ? resetIn(w.resets_at) : undefined;
    return reset ? `${pct} → ${reset}` : pct;
  });
  return parts.length ? `⚡ ${parts.join(" · ")}` : undefined;
}

export default function (pi: ExtensionAPI) {
  let provider: string | undefined;
  let timer: ReturnType<typeof setInterval> | undefined;
  let lastLive = 0;
  let busy = false;

  async function refresh(ctx: ExtensionContext) {
    const name = provider ? (ALIAS[provider] ?? provider) : undefined;
    if (!name) return ctx.ui.setStatus(KEY, undefined);
    if (busy) return;
    busy = true;
    try {
      const live = Date.now() - lastLive > LIVE_MIN_MS;
      const args = ["status", "--json", "--provider", name, ...(live ? ["--refresh"] : [])];
      const { stdout, code } = await pi.exec(BIN, args, { timeout: TIMEOUT_MS });
      if (live) lastLive = Date.now();
      let account: Account | undefined;
      try {
        if (code === 0) account = (JSON.parse(stdout) as { accounts?: Account[] }).accounts?.[0];
      } catch {
        // ai-usage printed a parse_error row; show nothing rather than a wrong number
      }
      ctx.ui.setStatus(KEY, line(account));
    } finally {
      busy = false;
    }
  }

  pi.on("session_start", (_event, ctx) => {
    provider = ctx.model?.provider;
    void refresh(ctx);
    timer ??= setInterval(() => void refresh(ctx), REFRESH_MS);
  });
  pi.on("model_select", (event, ctx) => {
    provider = event.model.provider;
    void refresh(ctx);
  });
  pi.on("agent_settled", (_event, ctx) => void refresh(ctx));
  pi.on("session_shutdown", (_event, ctx) => {
    if (timer) clearInterval(timer);
    timer = undefined;
    ctx.ui.setStatus(KEY, undefined);
  });
}
