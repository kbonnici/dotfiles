/**
 * Permission Gate Extension
 *
 * Blocks or prompts for confirmation when running potentially harmful commands.
 * Dangerous commands require user confirmation before execution.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

interface DangerousPattern {
  pattern: RegExp;
  message: string;
  // If true, blocks without prompting (too dangerous)
  blockWithoutPrompt?: boolean;
}

const DANGEROUS_PATTERNS: DangerousPattern[] = [
  // Recursive delete (most dangerous)
  {
    pattern: /\brm\s+-rf?\s+/i,
    message: "Recursive delete (rm -rf)",
  },
  {
    pattern: /\brm\s+-r\s+[\/~]/i,
    message: "Recursive delete from root/home",
    blockWithoutPrompt: true,
  },

  // Git dangerous commands
  {
    pattern: /\bgit\s+push/i,
    message: "git push",
  },
  {
    pattern: /\bgit\s+force\s+push/i,
    message: "git force push (--force, -f)",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bgit\s+reset\s+--hard/i,
    message: "git reset --hard",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bgit\s+rm\s+--cached/i,
    message: "git rm --cached",
  },
  {
    pattern: /\bgit\s+rm\s+-r/i,
    message: "git rm -r (recursive)",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bgit\s+branch\s+-D/i,
    message: "git branch -D (delete branch)",
  },
  {
    pattern: /\bgit\s+branch\s+-d\s+-f/i,
    message: "git branch -d -f (force delete branch)",
  },

  // Sudo commands
  {
    pattern: /\bsudo\s+rm/i,
    message: "sudo rm",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bsudo\s+mkfs/i,
    message: "sudo mkfs (format disk)",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bsudo\s+dd\b/i,
    message: "sudo dd (disk operations)",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bsudo\s+chmod\s+-R\s+777/i,
    message: "sudo chmod -R 777",
  },

  // Disk operations
  {
    pattern: /\bdd\s+(if=|of=)/i,
    message: "dd command (disk operations)",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bmkfs\b/i,
    message: "mkfs (format)",
    blockWithoutPrompt: true,
  },

  // Remote script execution
  {
    pattern: /\bcurl\s+.*\|\s*(ba)?sh/i,
    message: "curl | sh (execute remote script)",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bwget\s+.*\|\s*(ba)?sh/i,
    message: "wget | sh (execute remote script)",
    blockWithoutPrompt: true,
  },
  {
    pattern: /\bcurl\s+.*>.*\/(ba)?sh/i,
    message: "curl to shell script",
    blockWithoutPrompt: true,
  },

  // System modification
  {
    pattern: /\bchown\s+-R\s+/i,
    message: "chown -R (recursive ownership change)",
  },
  {
    pattern: /\bchmod\s+-R\s+777/i,
    message: "chmod -R 777 (world writable)",
  },

  // Kill all processes
  {
    pattern: /\bkillall\s+-9/i,
    message: "killall -9",
  },
  {
    pattern: /\bpkill\s+-9/i,
    message: "pkill -9",
  },
];

// Commands that are always allowed (read-only, safe)
const SAFE_PATTERNS = [
  /^\s*git\s+status/i,
  /^\s*git\s+log/i,
  /^\s*git\s+show/i,
  /^\s*git\s+diff/i,
  /^\s*git\s+branch(\s+-v)?$/i,
  /^\s*git\s+branch\s+-a/i,
  /^\s*git\s+status\s+/i,
  /^\s*git\s+diff\s+--cached/i,
  /^\s*git\s+rev-parse/i,
  /^\s*git\s+ls-files/i,
  /^\s*git\s+ls-tree/i,
  /^\s*git\s+show-branch/i,
  /^\s*git\s+remote\s+-v/i,
  /^\s*git\s+fetch/i,
  /^\s*git\s+clone/i,
  /^\s*ls\s/,
  /^\s*cat\s/,
  /^\s*head\s/,
  /^\s*tail\s/,
  /^\s*grep\s/,
  /^\s*find\s/,
  /^\s*echo\s/,
  /^\s*pwd\b/,
  /^\s*which\s/,
  /^\s*type\s/,
  /^\s*file\s/,
  /^\s*stat\s/,
];

function checkForDangerousCommand(command: string): DangerousPattern | null {
  for (const pattern of DANGEROUS_PATTERNS) {
    if (pattern.pattern.test(command)) {
      return pattern;
    }
  }
  return null;
}

function isSafeCommand(command: string): boolean {
  // Check if command matches any safe pattern
  for (const pattern of SAFE_PATTERNS) {
    if (pattern.test(command)) {
      return true;
    }
  }
  return false;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    // Only check bash commands
    if (!isToolCallEventType("bash", event)) {
      return;
    }

    const command = event.input.command;

    // Skip empty commands
    if (!command || command.trim() === "") {
      return;
    }

    // Check if command is in the allowed list
    if (isSafeCommand(command)) {
      return;
    }

    // Check for dangerous patterns
    const dangerous = checkForDangerousCommand(command);

    if (dangerous) {
      // For extremely dangerous commands, block without prompting
      if (dangerous.blockWithoutPrompt) {
        return {
          block: true,
          reason: `Blocked: ${dangerous.message} is too dangerous to execute automatically.`,
        };
      }

      // For other dangerous commands, ask for confirmation
      const confirmed = await ctx.ui.confirm(
        "Potentially Harmful Command",
        `This command may be dangerous:\n\n${dangerous.message}\n\nCommand: ${command}\n\nDo you want to proceed?`,
      );

      if (!confirmed) {
        return {
          block: true,
          reason: `Denied by user: ${dangerous.message}`,
        };
      }
    }
  });
}
