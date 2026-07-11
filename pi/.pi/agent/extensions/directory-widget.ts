/**
 * Directory Widget — shows current working directory relative to git repo root
 *
 * Inside a git repo:   repo-name/relative/path  branch
 * Outside a git repo:  dirname
 *
 * Also replaces Pi's default footer to remove cwd/branch (now shown in widget).
 * All other footer stats (tokens, cache, cost, context, model, statuses) are preserved.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execSync } from "node:child_process";
import path from "node:path";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

interface GitInfo {
  repoRoot: string;
  branch: string;
}

function getGitInfo(): GitInfo | null {
  try {
    const repoRoot = execSync("git rev-parse --show-toplevel 2>/dev/null", {
      encoding: "utf-8",
    }).trim();
    if (!repoRoot) return null;

    const branch = execSync("git rev-parse --abbrev-ref HEAD 2>/dev/null", {
      encoding: "utf-8",
    }).trim();

    return { repoRoot, branch };
  } catch {
    return null;
  }
}

function computeDisplayPath(cwd: string, gitInfo: GitInfo): string {
  const repoName = path.basename(gitInfo.repoRoot);
  const rel = path.relative(gitInfo.repoRoot, cwd);
  if (!rel || rel === ".") return repoName;
  return `${repoName}/${rel.replace(/\\/g, "/")}`;
}

function formatTokens(count: number): string {
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1000)}k`;
  if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
  return `${Math.round(count / 1_000_000)}M`;
}

function sanitizeStatusText(text: string): string {
  return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

export default function(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    // Shared git info cache: updated by footer's onBranchChange (event-driven),
    // read by the widget — no polling or per-frame shell execs needed.
    let sharedCwd = process.cwd();
    let sharedGitInfo = getGitInfo();

    // Widget: directory path + git branch (above editor, replacing footer cwd)
    ctx.ui.setWidget(
      "cwd-widget",
      (_tui, theme) => ({
        render: () => {
          const leftPad = " ";
          if (!sharedGitInfo) {
            return [leftPad + theme.fg("accent", path.basename(sharedCwd))];
          }
          return [
            leftPad +
            theme.fg("accent", computeDisplayPath(sharedCwd, sharedGitInfo)) +
            theme.fg("dim", "  ") +
            theme.fg("mdHeading", sharedGitInfo.branch),
          ];
        },
        invalidate: () => {
          sharedCwd = process.cwd();
          sharedGitInfo = getGitInfo();
        },
      }),
      { placement: "aboveEditor" },
    );

    // Custom footer: same as default but without cwd/git-branch line.
    // Pi's internal git watcher fires onBranchChange — we piggyback on it to
    // update the shared cache and trigger a full UI redraw (event-driven, zero polling).
    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsub = footerData.onBranchChange(() => {
        sharedCwd = process.cwd();
        sharedGitInfo = getGitInfo();
        tui.requestRender();
      });

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          const lines: string[] = [];

          // --- Line 1: session name only (no cwd, no branch) ---
          const sessionName = ctx.sessionManager.getSessionName();
          if (sessionName) {
            lines.push(truncateToWidth(theme.fg("dim", sessionName), width));
          }

          // --- Line 2: stats (same as default) ---
          let totalInput = 0;
          let totalOutput = 0;
          let totalCacheRead = 0;
          let totalCacheWrite = 0;
          let totalCost = 0;
          let latestCacheHitRate: number | undefined;

          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type === "message" && entry.message.role === "assistant") {
              totalInput += entry.message.usage.input;
              totalOutput += entry.message.usage.output;
              totalCacheRead += entry.message.usage.cacheRead;
              totalCacheWrite += entry.message.usage.cacheWrite;
              totalCost += entry.message.usage.cost.total;
              const latestPromptTokens =
                entry.message.usage.input + entry.message.usage.cacheRead + entry.message.usage.cacheWrite;
              latestCacheHitRate =
                latestPromptTokens > 0
                  ? (entry.message.usage.cacheRead / latestPromptTokens) * 100
                  : undefined;
            }
          }

          const statsParts: string[] = [];
          if (totalInput) statsParts.push(`↑${formatTokens(totalInput)}`);
          if (totalOutput) statsParts.push(`↓${formatTokens(totalOutput)}`);
          if (totalCacheRead) statsParts.push(`R${formatTokens(totalCacheRead)}`);
          if (totalCacheWrite) statsParts.push(`W${formatTokens(totalCacheWrite)}`);
          if ((totalCacheRead > 0 || totalCacheWrite > 0) && latestCacheHitRate !== undefined) {
            statsParts.push(`CH${latestCacheHitRate.toFixed(1)}%`);
          }
          if (totalCost) {
            statsParts.push(`$${totalCost.toFixed(3)}`);
          }
          // Context usage (same as default footer)
          const contextUsage = ctx.getContextUsage();
          const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const contextPercentValue = contextUsage?.percent ?? 0;
          const contextPercent = contextUsage?.percent !== null ? contextPercentValue.toFixed(1) : "?";
          let contextPercentStr: string;
          if (contextPercentValue > 90) {
            contextPercentStr = theme.fg("error", `${contextPercent}%/${formatTokens(contextWindow)}`);
          } else if (contextPercentValue > 70) {
            contextPercentStr = theme.fg("warning", `${contextPercent}%/${formatTokens(contextWindow)}`);
          } else {
            contextPercentStr = `${contextPercent}%/${formatTokens(contextWindow)}`;
          }
          statsParts.push(contextPercentStr);
          let statsLeft = statsParts.join(" ");
          let statsLeftWidth = visibleWidth(statsLeft);

          // Right side: model name + thinking level
          const modelId = ctx.model?.id || "no-model";
          let rightSide = modelId;
          if (ctx.model?.reasoning) {
            // Scan branch for last thinking_level_change entry
            let currentLevel = "off";
            for (const entry of ctx.sessionManager.getBranch()) {
              if (entry.type === "thinking_level_change") {
                currentLevel = (entry as any).thinkingLevel || "off";
              }
            }
            rightSide = currentLevel === "off"
              ? `${modelId} • thinking off`
              : `${modelId} • ${currentLevel}`;
          }
          if (footerData.getAvailableProviderCount() > 1 && ctx.model?.provider) {
            const withProvider = `(${ctx.model.provider}) ${rightSide}`;
            if (statsLeftWidth + 2 + visibleWidth(withProvider) <= width) {
              rightSide = withProvider;
            }
          }

          const rightSideWidth = visibleWidth(rightSide);
          const totalNeeded = statsLeftWidth + 2 + rightSideWidth;

          let statsLine: string;
          if (totalNeeded <= width) {
            const padding = " ".repeat(width - statsLeftWidth - rightSideWidth);
            statsLine = statsLeft + padding + rightSide;
          } else {
            const availableForRight = width - statsLeftWidth - 2;
            if (availableForRight > 0) {
              const truncatedRight = truncateToWidth(rightSide, availableForRight, "");
              const trw = visibleWidth(truncatedRight);
              statsLine = statsLeft + " ".repeat(Math.max(0, width - statsLeftWidth - trw)) + truncatedRight;
            } else {
              statsLine = statsLeft;
            }
          }

          const dimStatsLeft = theme.fg("dim", statsLeft);
          const remainder = statsLine.slice(statsLeft.length);
          const dimRemainder = theme.fg("dim", remainder);
          lines.push(dimStatsLeft + dimRemainder);

          // --- Line 3+: extension statuses (same as default) ---
          const extensionStatuses = footerData.getExtensionStatuses();
          if (extensionStatuses.size > 0) {
            const sorted = Array.from(extensionStatuses.entries())
              .sort(([a], [b]) => a.localeCompare(b))
              .map(([, text]) => sanitizeStatusText(text));
            lines.push(truncateToWidth(sorted.join(" "), width, theme.fg("dim", "...")));
          }

          return lines;
        },
      };
    });
  });
}
