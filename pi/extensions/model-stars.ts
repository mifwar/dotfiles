// /stars - scrollable model browser like native /model, with starring.
//
// Keys: up/down/j/k navigate · tab toggle all/starred
//       / search (type to filter, enter switch, esc cancel) · s star/unstar
//       enter switch · esc/q cancel
// Stars stored in ~/.pi/agent/model-stars.json

import type { ExtensionAPI, ExtensionCommandContext, Theme } from "@earendil-works/pi-coding-agent";
import type { Model } from "@earendil-works/pi-ai";
import type { TUI } from "@earendil-works/pi-tui";
import { matchesKey, truncateToWidth } from "@earendil-works/pi-tui";
import { readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const STORE = join(homedir(), ".pi", "agent", "model-stars.json");
const MAX_VISIBLE = 10;

type Item = {
	key: string;
	model: Model<any>;
	starred: boolean;
	current: boolean;
	toggle?: "star" | "filter"; // set when the action should reopen instead of switch
};

function loadStars(): string[] {
	try {
		return JSON.parse(readFileSync(STORE, "utf8"));
	} catch {
		return [];
	}
}

function saveStars(keys: string[]) {
	writeFileSync(STORE, JSON.stringify(keys.sort(), null, 2));
}

function buildItems(all: Model<any>[], starredOnly: boolean, currentKey: string): Item[] {
	const stars = new Set(loadStars());
	return all
		.map((m) => {
			const key = `${m.provider}/${m.id}`;
			return { key, model: m, starred: stars.has(key), current: key === currentKey };
		})
		.filter((i) => !starredOnly || i.starred)
		.sort((a, b) => Number(b.starred) - Number(a.starred) || a.key.localeCompare(b.key));
}

class StarPicker {
	private baseItems: Item[];
	items: Item[];
	index: number;
	private query = "";
	private searching = false;

	constructor(
		private tui: TUI,
		private theme: Theme,
		private done: (result: Item | undefined) => void,
		all: Model<any>[],
		private starredOnly: boolean,
		focusKey?: string,
	) {
		this.baseItems = buildItems(all, starredOnly, focusKey ?? "");
		this.items = this.baseItems;
		this.index = Math.max(0, this.baseItems.findIndex((i) => i.key === focusKey));
	}

	private applyQuery(): void {
		const q = this.query.trim().toLowerCase();
		this.items = q
			? this.baseItems.filter((i) => i.key.toLowerCase().includes(q))
			: this.baseItems;
		if (this.index >= this.items.length) this.index = Math.max(0, this.items.length - 1);
	}

	handleInput(data: string): void {
		// typing a printable char while searching edits the query
		if (this.searching) {
			if (matchesKey(data, "escape")) {
				this.searching = false;
				this.query = "";
				this.applyQuery();
			} else if (matchesKey(data, "backspace")) {
				this.query = this.query.slice(0, -1);
				this.applyQuery();
			} else if (matchesKey(data, "return")) {
				const item = this.items[this.index];
				if (item) return this.done(item);
				return;
			} else if (matchesKey(data, "up") || data === "k") {
				this.index = Math.max(0, this.index - 1);
			} else if (matchesKey(data, "down") || data === "j") {
				this.index = Math.min(this.items.length - 1, this.index + 1);
			} else if (data.length === 1 && data.charCodeAt(0) >= 32) {
				this.query += data;
				this.applyQuery();
			} else {
				return;
			}
			return this.tui.requestRender();
		}

		if (matchesKey(data, "escape") || data === "q") return this.done(undefined);
		if (data === "/") {
			this.searching = true;
			return this.tui.requestRender();
		}
		if (matchesKey(data, "return")) return this.done(this.items[this.index]);
		if (matchesKey(data, "tab")) {
			if (!this.items.length && !this.starredOnly) return; // nothing starred yet
			return this.done({ ...this.items[this.index], toggle: "filter", key: this.items[this.index]?.key ?? "" });
		}
		if (data === "s" || data === " ") {
			const item = this.items[this.index];
			if (item) return this.done({ ...item, toggle: "star" });
			return;
		}
		if (matchesKey(data, "up") || data === "k")
			this.index = Math.max(0, this.index - 1);
		else if (matchesKey(data, "down") || data === "j")
			this.index = Math.min(this.items.length - 1, this.index + 1);
		else return;
		this.tui.requestRender();
	}

	render(width: number): string[] {
		const th = this.theme;
		const title = this.searching
			? `/ ${this.query}▌`
			: `${this.starredOnly ? "★ Starred models" : "All models"}`;
		const lines = [
			` ${th.fg("accent", title)} ${th.fg("dim", `· ${this.items.length}`)}`,
			"",
		];
		if (!this.items.length)
			lines.push(` ${th.fg("dim", this.searching ? "(no match)" : "(none — tab for all models)")}`);
		const start = Math.max(0, Math.min(this.index - Math.floor(MAX_VISIBLE / 2), this.items.length - MAX_VISIBLE));
		const end = Math.min(start + MAX_VISIBLE, this.items.length);
		for (let i = start; i < end; i++) {
			const item = this.items[i];
			const sel = i === this.index;
			const mark = item!.starred ? th.fg("warning", "★") : " ";
			let line = `${sel ? th.fg("accent", "→ ") : "  "}${mark} ${sel ? th.fg("accent", item!.key) : item!.key}`;
			if (item!.current) line += th.fg("success", " ✓");
			lines.push(truncateToWidth(line, width));
		}
		if (start > 0 || end < this.items.length)
			lines.push(` ${th.fg("dim", `(${this.index + 1}/${this.items.length})`)}`);
		lines.push("", ` ${th.fg("dim", "enter switch · / search · s star · tab filter · esc close")}`);
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	async function openPicker(ctx: ExtensionCommandContext, starredOnly: boolean) {
		const all = ctx.modelRegistry.getAvailable();
		if (!all.length) return ctx.ui.notify("No available models", "warning");

		let filter = starredOnly;
		let focusKey = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;
		while (true) {
			const currentKey = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "";
			const result = await ctx.ui.custom<Item | undefined>(
				(tui, theme, _kb, done) => new StarPicker(tui, theme, done, all, filter, focusKey),
				{ overlay: true, overlayOptions: { anchor: "center", width: 60, maxHeight: MAX_VISIBLE + 6 } },
			);

			if (!result) return;

			if (result.toggle === "star") {
				focusKey = result.key;
				const stars = loadStars();
				saveStars(stars.includes(result.key) ? stars.filter((s) => s !== result.key) : [...stars, result.key]);
				continue;
			}
			if (result.toggle === "filter") {
				filter = !filter;
				continue;
			}

			if (!(await pi.setModel(result.model)))
				ctx.ui.notify(`No API key for ${result.key}`, "error");
			return;
		}
	}

	pi.registerCommand("stars", {
		description: "Browse models like /model, with starring (/stars or /stars starred)",
		handler: async (args, ctx) => {
			await openPicker(ctx, args.trim() === "starred");
		},
	});
}
