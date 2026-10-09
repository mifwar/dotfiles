/**
 * Default timeout for bash tool calls.
 *
 * pi's bash tool takes an optional `timeout` (seconds) with NO default, so a
 * command that never returns (a gpg/pinentry prompt with no tty, a hung HTTP
 * call, a deadlocked build) blocks the agent forever. Seen 2026-09-15: a
 * `pass show` call under a stripped env sat 8h28m until manually aborted.
 *
 * A wall-clock ceiling is the only guard that covers every hang class; the
 * model can still pass an explicit larger `timeout` for long test runs.
 */
import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEFAULT_SECONDS = Number(process.env.PI_BASH_TIMEOUT_SECONDS) || 30 * 60;

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", (event) => {
		if (isToolCallEventType("bash", event) && event.input.timeout === undefined) {
			event.input.timeout = DEFAULT_SECONDS;
		}
	});
}
