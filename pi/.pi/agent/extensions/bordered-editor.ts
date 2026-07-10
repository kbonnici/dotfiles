/**
 * Bordered Editor - adds rounded left/right borders to the text input
 *
 * The border color follows the thinking level (same as the bottom border).
 * Install by adding to extensions in settings.json or using --extension.
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { visibleWidth } from "@earendil-works/pi-tui";

const TL = "╭";
const TR = "╮";
const BL = "╰";
const BR = "╯";
const H = "─";
const V = "│";

// Shared state with plan-mode extension (set via globalThis)
const GLOBAL_PLAN_FLAG = "__planModeActive";
const GLOBAL_TUI = "__planModeTui";

class BorderedEditor extends CustomEditor {
  constructor(tui: any, theme: any, kb: any) {
    super(tui, theme, kb);
    (globalThis as any)[GLOBAL_TUI] = tui;
  }
  render(width: number): string[] {
    // Need at least room for 2 border chars + minimal content
    if (width < 6) return super.render(width);

    const innerWidth = width - 2;

    // Let the base editor render into the reduced width
    const lines = super.render(innerWidth);

    // The Editor always renders:
    //   [0]          = top border (horizontal ─ line)
    //   [1..n-2]     = content lines
    //   [n-1]        = bottom border (horizontal ─ line)
    //   [n..]        = optional autocomplete lines (not handled here)
    //
    // We replace the Editor's own top/bottom borders with rounded
    // variants and wrap content with vertical side bars.

    if (lines.length < 3) {
      // Too few lines, render empty box
      return [
        this.borderColor(TL) + this.borderColor(H).repeat(innerWidth) + this.borderColor(TR),
        this.borderColor(V) + " ".repeat(innerWidth) + this.borderColor(V),
        this.borderColor(BL) + this.borderColor(H).repeat(innerWidth) + this.borderColor(BR),
      ];
    }

    // Separate the Editor's parts
    const _editorTopBorder = lines[0]!;             // discard, we draw our own
    const contentLines = lines.slice(1, lines.length - 1);
    const editorBottomBorder = lines[lines.length - 1]!;

    const result: string[] = [];

    // Top border: rounded corners, with plan mode indicator on the left if active
    const planActive = !!(globalThis as any)[GLOBAL_PLAN_FLAG];
    if (planActive) {
      const indicator = " \x1b[38;2;60;160;100m\u{1F5D2}\u{FE0F} PLAN\x1b[39m ";
      const indicatorWidth = visibleWidth(indicator);
      const gap = innerWidth - indicatorWidth - 2;
      if (gap >= 0) {
        result.push(
          this.borderColor(TL) +
          this.borderColor(H).repeat(2) +
          indicator +
          this.borderColor(H).repeat(gap) +
          this.borderColor(TR),
        );
      } else if (innerWidth >= indicatorWidth) {
        result.push(
          this.borderColor(TL) +
          indicator +
          this.borderColor(H).repeat(innerWidth - indicatorWidth) +
          this.borderColor(TR),
        );
      } else {
        result.push(this.borderColor(TL) + this.borderColor(H).repeat(innerWidth) + this.borderColor(TR));
      }
    } else {
      result.push(this.borderColor(TL) + this.borderColor(H).repeat(innerWidth) + this.borderColor(TR));
    }

    // Content lines with vertical side borders
    for (const line of contentLines) {
      const lineLen = visibleWidth(line);
      const pad = Math.max(0, innerWidth - lineLen);
      result.push(this.borderColor(V) + line + " ".repeat(pad) + this.borderColor(V));
    }

    // Bottom border: rounded corners wrapping the editor's thinking-level-colored fill
    result.push(this.borderColor(BL) + editorBottomBorder + this.borderColor(BR));

    return result;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.setEditorComponent((tui, theme, kb) => new BorderedEditor(tui, theme, kb));
  });
}
