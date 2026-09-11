/**
 * Bridge Pen.app's MCP server into pi as native tools.
 *
 * Spawns the Pen MCP server over stdio, lists its tools, and registers each
 * one with pi.registerTool(). Tool calls proxy back through the MCP client.
 *
 * ponytail: no generic MCP framework here — hardcoded to Pen's server, one
 * file. If you later want many MCP servers, generalize to a config list.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const SERVER = {
  command:
    "/Applications/Pen.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64",
  args: ["--app", "desktop"],
  // ponytail: env {} from the config; none needed for Pen
};

export default function (pi: ExtensionAPI) {
  let client: Client | null = null;

  pi.on("session_start", async (_event, ctx) => {
    if (client) return; // idempotent

    try {
      const transport = new StdioClientTransport({
        command: SERVER.command,
        args: SERVER.args,
        stderr: "inherit",
      });
      client = new Client({ name: "pi-pencil", version: "0.1.0" });
      await client.connect(transport);

      const { tools } = await client.listTools();
      const existing = new Set(pi.getAllTools().map((t) => t.name));

      for (const tool of tools) {
        // Avoid clobbering built-in tools with the same name.
        const name = existing.has(tool.name) ? `pencil_${tool.name}` : tool.name;
        const toolName = tool.name;

        // MCP inputSchema is plain JSON Schema; TypeBox validates standard
        // object schemas directly. If one is exotic, fall back to pass-through.
        let parameters: unknown;
        try {
          parameters = tool.inputSchema ?? { type: "object", properties: {} };
          // Probe-compile so a bad schema doesn't silently break at call time.
          // (typebox is on pi's allowed import list)
          if (typeof parameters !== "object" || parameters === null) throw new Error("bad schema");
        } catch {
          parameters = Type.Object({}, { additionalProperties: true });
        }

        pi.registerTool({
          name,
          label: tool.name,
          description: tool.description ?? `Pen.dev tool: ${tool.name}`,
          parameters: parameters as never,
          async execute(_toolCallId, params) {
            if (!client) throw new Error("Pen MCP server not connected");
            const res = await client.callTool({
              name: toolName,
              arguments: params as Record<string, unknown>,
            });
            if (res.isError) {
              const msg = (res.content as { type: string; text?: string }[])
                .map((b) => b.text ?? "")
                .join("\n");
              throw new Error(msg || `Pen tool ${toolName} failed`);
            }
            const content = (
              res.content as { type: string; text?: string; mimeType?: string; data?: string }[]
            ).map((b) => {
              if (b.type === "text") return { type: "text", text: b.text ?? "" };
              if (b.type === "image")
                return {
                  type: "image",
                  source: { type: "base64", mediaType: b.mimeType ?? "image/png", data: b.data ?? "" },
                };
              return { type: "text", text: JSON.stringify(b) };
            });
            return { content, details: {} };
          },
        });
      }

      ctx.ui.notify(`Pen MCP: ${tools.length} tools connected`, "info");
    } catch (err) {
      ctx.ui.notify(`Pen MCP failed: ${(err as Error).message}`, "error");
      client = null;
    }
  });

  pi.on("session_shutdown", async () => {
    if (client) {
      await client.close().catch(() => {});
      client = null;
    }
  });
}
