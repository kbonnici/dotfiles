import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Tools available in each mode.
// PLAN_MODE_TOOLS: read-only exploration -- no write or edit.
const PLAN_MODE_TOOLS = ["read", "bash", "grep"];

// Tools we manage -- everything outside this set is preserved from the original.
const MANAGED_TOOLS = new Set(["read", "write", "edit", "bash", "grep", "find", "ls"]);

// ---------------------------------------------------------------------------
// Bash allowlist for plan mode
// A command is allowed if it matches a safe pattern AND does not match a
// blocked pattern. This prevents accidental destructive operations while
// permitting read-only exploration.
// ---------------------------------------------------------------------------

const SAFE_PATTERNS: RegExp[] = [
  /^\s*cat\b/,
  /^\s*head\b/,
  /^\s*tail\b/,
  /^\s*less\b/,
  /^\s*more\b/,
  /^\s*grep\b/,
  /^\s*find\b/,
  /^\s*ls\b/,
  /^\s*pwd\b/,
  /^\s*echo\b/,
  /^\s*printf\b/,
  /^\s*wc\b/,
  /^\s*sort\b/,
  /^\s*uniq\b/,
  /^\s*diff\b/,
  /^\s*file\b/,
  /^\s*stat\b/,
  /^\s*du\b/,
  /^\s*df\b/,
  /^\s*tree\b/,
  /^\s*which\b/,
  /^\s*whereis\b/,
  /^\s*type\b/,
  /^\s*env\b/,
  /^\s*printenv\b/,
  /^\s*uname\b/,
  /^\s*whoami\b/,
  /^\s*id\b/,
  /^\s*date\b/,
  /^\s*cal\b/,
  /^\s*uptime\b/,
  /^\s*ps\b/,
  /^\s*top\b/,
  /^\s*htop\b/,
  /^\s*free\b/,
  /^\s*git\s+(status|log|diff|show|branch|remote|config\s+--get)\b/i,
  /^\s*git\s+ls-/i,
  /^\s*npm\s+(list|ls|view|info|search|outdated|audit)\b/i,
  /^\s*yarn\s+(list|info|why|audit)\b/i,
  /^\s*node\s+--version\b/i,
  /^\s*python\s+--version\b/i,
  /^\s*curl\s/i,
  /^\s*wget\s/i,
  /^\s*jq\b/,
  /^\s*sed\s+-n\b/i,
  /^\s*awk\b/,
  /^\s*rg\b/,
  /^\s*fd\b/,
  /^\s*bat\b/,
  /^\s*eza\b/,
];

const BLOCKED_PATTERNS: RegExp[] = [
  /\brm\b/i,
  /\brmdir\b/i,
  /\bmv\b/i,
  /\bcp\b/i,
  /\bmkdir\b/i,
  /\btouch\b/i,
  /\bchmod\b/i,
  /\bchown\b/i,
  /\bchgrp\b/i,
  /\bln\b/i,
  /\btee\b/i,
  /\btruncate\b/i,
  /\bdd\b/i,
  /\bshred\b/i,
  /(^|[^<])>(?!>)/,
  />>/,
  /\bnpm\s+(install|uninstall|update|ci|link|publish)\b/i,
  /\byarn\s+(add|remove|install|publish)\b/i,
  /\bpnpm\s+(add|remove|install|publish)\b/i,
  /\bpip\s+(install|uninstall)\b/i,
  /\bapt(-get)?\s+(install|remove|purge|update|upgrade)\b/i,
  /\bbrew\s+(install|uninstall|upgrade)\b/i,
  /\bgit\s+(add|commit|push|pull|merge|rebase|reset|checkout|branch\s+-[dD]|stash|cherry-pick|revert|tag|init|clone)\b/i,
  /\bsudo\b/i,
  /\bsu\b/i,
  /\bkill\b/i,
  /\bpkill\b/i,
  /\bkillall\b/i,
  /\breboot\b/i,
  /\bshutdown\b/i,
  /\bsystemctl\s+(start|stop|restart|enable|disable)\b/i,
  /\bservice\s+\S+\s+(start|stop|restart)\b/i,
  /\b(vim?|nano|emacs|code|subl)\b/i,
];

function isSafeCommand(command: string): boolean {
  const isDestructive = BLOCKED_PATTERNS.some((p) => p.test(command));
  const isSafe = SAFE_PATTERNS.some((p) => p.test(command));
  return !isDestructive && isSafe;
}

// Mode guidance injected fresh every turn (never persisted to history).
const PLAN_MODE_NOTE =
  "Current mode: PLAN. No file edits are available -- write and edit tools are " +
  "disabled. Bash is restricted to read-only commands (file inspection, search, " +
  "git read operations, etc.). Discuss the task and describe your implementation " +
  "approach in this conversation. When ready, present the plan as a numbered list " +
  "of concrete steps, each naming the files or areas it touches. Do not write " +
  "implementation-level diffs or attempt to use write/edit -- they are not " +
  "available in this mode.";

const BUILD_MODE_NOTE = "Current mode: BUILD. Full tool access is available.";

// Global flag shared with bordered-editor.ts so it can render the plan indicator
// in the editor's top border without conflicting editor component registrations.
const GLOBAL_PLAN_FLAG = "__planModeActive";
const GLOBAL_TUI = "__planModeTui";

function setPlanGlobal(active: boolean): void {
	(globalThis as any)[GLOBAL_PLAN_FLAG] = active;
}

function getPlanGlobal(): boolean {
	return !!(globalThis as any)[GLOBAL_PLAN_FLAG];
}

function requestEditorRender(): void {
	(globalThis as any)[GLOBAL_TUI]?.requestRender();
}
export default function(pi: ExtensionAPI) {
  let planMode = false;
  let savedTools: string[] | undefined;

  function getBuildModeTools(activeTools: string[]): string[] {
    // Start with the built-in build tools, then add any non-managed tools
    // that were active before we took over (extension tools, etc.).
    const build = ["read", "write", "edit", "bash", "grep"];
    for (const t of activeTools) {
      if (!MANAGED_TOOLS.has(t)) build.push(t);
    }
    return [...new Set(build)];
  }

  function getPlanModeTools(activeTools: string[]): string[] {
    // Plan mode: read, bash, grep + any non-managed tools that were active.
    const plan = ["read", "bash", "grep"];
    for (const t of activeTools) {
      if (!MANAGED_TOOLS.has(t)) plan.push(t);
    }
    return [...new Set(plan)];
  }

  function enterPlanMode(): void {
    const current = pi.getActiveTools();
    savedTools = [...current];
    pi.setActiveTools(getPlanModeTools(current));
  }

  function exitPlanMode(): void {
    const current = pi.getActiveTools();
    const tools = savedTools
      ? [...savedTools]
      : getBuildModeTools(current);
    savedTools = undefined;
    pi.setActiveTools(tools);
  }

  // ---------------------------------------------------------------------------
  // Keyboard shortcut: Ctrl+Alt+P
  // (Avoids conflict with Pi's built-in Ctrl+P for model cycling.)
  // ---------------------------------------------------------------------------
  pi.registerShortcut("ctrl+alt+p", {
    description:
      "Toggle plan mode (read-only planning vs. full build access). " +
      "Uses Ctrl+Alt+P instead of Ctrl+P to avoid conflicting with Pi's " +
      "built-in model-cycling shortcut.",
    handler: async (ctx) => {
      planMode = !planMode;

      if (planMode) {
        enterPlanMode();
      } else {
        exitPlanMode();
      }
      setPlanGlobal(planMode);
      requestEditorRender();
    },
  });

  // ---------------------------------------------------------------------------
  // Slash command: /plan
  // (Useful when the keybinding is unavailable or the user prefers typing.)
  // ---------------------------------------------------------------------------
  pi.registerCommand("plan", {
    description: "Toggle plan mode",
    handler: async (_args, ctx) => {
      planMode = !planMode;

      if (planMode) {
        enterPlanMode();
      } else {
        exitPlanMode();
      }
      setPlanGlobal(planMode);
      requestEditorRender();
    },
  });

  // ---------------------------------------------------------------------------
  // Bash allowlist enforcement (plan mode only)
  //
  // Blocks destructive bash commands in plan mode. Read-only commands (file
  // inspection, search, git read operations, etc.) are allowed.
  // ---------------------------------------------------------------------------
  pi.on("tool_call", async (event) => {
    if (!planMode || event.toolName !== "bash") return;

    const command = event.input.command as string;
    if (!isSafeCommand(command)) {
      return {
        block: true,
        reason:
          `Plan mode: bash command blocked (not in allowlist). ` +
          `Switch to build mode first with /plan or Ctrl+Alt+P.\n` +
          `Command: ${command}`,
      };
    }
  });

  // ---------------------------------------------------------------------------
  // Context hook: mode guidance
  //
  // Injected as a user-role message at the tail of every request so it behaves
  // like normal conversation content (ordinary caching, no accumulation).
  // Regenerated fresh every turn -- never written into session history, never
  // merged into the system prompt. This keeps prompt-cache hit rate unaffected.
  //
  // This is advisory only: setActiveTools() is what actually enforces the mode.
  // ---------------------------------------------------------------------------
  pi.on("context", async (event) => {
    const modeNote = planMode ? PLAN_MODE_NOTE : BUILD_MODE_NOTE;
    return {
      messages: [
        ...event.messages,
        { role: "user", content: `[${modeNote}]` },
      ],
    };
  });
}
