/**
 * Command Code (cmd) bridge.
 *
 * Delegates work to the `cmd` CLI so pi keeps its harness while cmd does the
 * thinking with your subscribed plan (models, taste, /plan, /goal, its MCP
 * servers). Runs `cmd -p` headless in your project dir; no API key needed —
 * the CLI uses ~/.commandcode/auth.json. Works on any plan; the Provider API
 * endpoint (api.commandcode.ai/provider/v1) requires a GOAT+ plan instead.
 *
 * Install: symlink into ~/.pi/agent/extensions/cmd-bridge.ts, then /reload.
 */
import { spawn } from "node:child_process";
import { createInterface } from "node:readline";
import { Type } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const CMD_TIMEOUT_MS = 15 * 60 * 1000;
const CMD = process.env.CMD_BRIDGE_BIN ?? "cmd";

const cmdBridgeTool = defineTool({
	name: "cmd",
	label: "Command Code",
	description:
		"Delegate a task to the Command Code CLI (cmd) — its own coding agent with your subscribed plan: " +
		"its models (claude-sonnet-5, gpt-5.6-sol, deepseek/deepseek-v4-flash, ...), taste system, /plan, " +
		"/goal, skills, and MCP servers. Runs `cmd -p` headless in your project dir. " +
		"cmd has no memory of previous calls — make the task self-contained.",
	parameters: Type.Object({
		task: Type.String({
			description:
				"The task for Command Code, self-contained (no memory of earlier calls). " +
				"Point it at specific files/paths if it should work on code.",
		}),
		model: Type.Optional(
			Type.String({
				description:
					'Model id, e.g. "claude-sonnet-5", "claude-fable-5", "deepseek/deepseek-v4-flash", ' +
					'"moonshotai/kimi-k3". Default: cmd\'s plan default. Run `cmd --list-models` for all.',
			}),
		),
		yolo: Type.Optional(
			Type.Boolean({
				description:
					"Allow cmd to edit files and run shell commands. Default false: read-only analysis " +
					"(file reads, grep, glob allowed; writes/shell denied). Use true only for trusted work.",
				default: false,
			}),
		),
		maxTurns: Type.Optional(
			Type.Integer({
				description: "Max agent turns before cmd gives up and returns partial work. Default 25.",
				default: 25,
			}),
		),
	}),

	async execute(_toolCallId, params, signal, onUpdate, ctx) {
		const args = [
			"-p",
			params.task,
			"--output-format",
			"json",
			"--skip-onboarding",
			"--no-auto-update",
			"--max-turns",
			String(params.maxTurns ?? 25),
		];
		if (params.model) args.push("--model", params.model);
		if (params.yolo) args.push("--yolo");

		const cwd = (ctx as { cwd?: string }).cwd ?? process.cwd();
		const child = spawn(CMD, args, { cwd, stdio: ["ignore", "pipe", "pipe"] });

		let resultLine = "";
		let errText = "";
		let progressCount = 0;

		// Stream NDJSON frames: forward tool activity as live progress, keep the final result line.
		createInterface({ input: child.stdout }).on("line", (line) => {
			let frame: { type?: string; event?: { type?: string; toolName?: string; description?: string } };
			try {
				frame = JSON.parse(line);
			} catch {
				return;
			}
			if (frame.type === "result") {
				resultLine = line;
			} else if (frame.type === "event" && frame.event?.type === "tool_running" && onUpdate) {
				if (progressCount++ < 60) {
					onUpdate({
						content: [
							{
								type: "text",
								text: `[cmd] ${frame.event.toolName}${frame.event.description ? " — " + frame.event.description : ""}`,
							},
						],
					});
				}
			}
		});
		child.stderr.on("data", (d) => {
			errText = (errText + d.toString()).slice(-4000);
		});

		const { code, killed, timedOut } = await new Promise<{ code: number | null; killed: boolean; timedOut: boolean }>(
			(resolve, reject) => {
				let timedOut = false;
				const timer = setTimeout(() => {
					timedOut = true;
					child.kill("SIGTERM");
				}, CMD_TIMEOUT_MS);
				const onAbort = () => child.kill("SIGTERM");
				signal?.addEventListener("abort", onAbort, { once: true });
				child.on("error", (e) => {
					clearTimeout(timer);
					signal?.removeEventListener("abort", onAbort);
					reject(e);
				});
				child.on("close", (code) => {
					clearTimeout(timer);
					signal?.removeEventListener("abort", onAbort);
					resolve({ code, killed: child.killed, timedOut });
				});
			},
		);

		if (timedOut) {
			throw new Error(
				`cmd did not finish within ${CMD_TIMEOUT_MS / 60000} minutes. ` +
					`Raise maxTurns or split the task. Last stderr: ${errText.slice(-300)}`,
			);
		}

		let result: {
			subtype?: string;
			finalText?: string;
			error?: string;
			stopReason?: string;
			usage?: { inputTokens?: number; outputTokens?: number };
			sessionId?: string;
		} = {};
		if (resultLine) {
			try {
				result = JSON.parse(resultLine);
			} catch {
				/* fall through to error path */
			}
		}

		if (result.subtype === "success") {
			return {
				content: [{ type: "text", text: result.finalText ?? "" }],
				details: {
					stopReason: result.stopReason,
					sessionId: result.sessionId,
					usage: result.usage,
				},
			};
		}

		if (result.subtype === "max_turns") {
			return {
				content: [
					{
						type: "text",
						text: `cmd hit the max-turns cap (${params.maxTurns ?? 25}) — partial result:\n\n${result.finalText ?? ""}`,
					},
				],
				details: { stopReason: "max_turns", sessionId: result.sessionId },
			};
		}

		const why =
			result.error ||
			(errText.trim() ? errText.trim().split("\n").slice(-3).join("\n") : `exit code ${code ?? "?"}`);
		throw new Error(`cmd failed (${result.subtype ?? "unknown"}): ${why}`);
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(cmdBridgeTool);
}
