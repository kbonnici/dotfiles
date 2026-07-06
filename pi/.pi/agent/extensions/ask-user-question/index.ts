/**
 * ask_user_question - Simple structured question dialog
 *
 * Features:
 * - Single or multiple questions with tab navigation
 * - Single and multi-select support
 * - "Other" free-text fallback
 * - Submit review tab
 * - Escape to cancel
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Editor, type EditorTheme, Key, matchesKey, Text, truncateToWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";

// Types
interface QuestionOption {
	label: string;
	description?: string;
}

interface Question {
	header: string;
	question: string;
	options: QuestionOption[];
	multiSelect?: boolean;
}

interface Answer {
	questionIndex: number;
	question: string;
	kind: "option" | "custom" | "chat" | "multi";
	answer: string | null;
	selected?: string[];
	notes?: string;
}

interface Result {
	questions: Question[];
	answers: Answer[];
	cancelled: boolean;
}

// Schema
const OptionSchema = Type.Object({
	label: Type.String({ description: "Display label (1-5 words, max 60 chars)" }),
	description: Type.Optional(Type.String({ description: "Explains the choice" })),
});

const QuestionSchema = Type.Object({
	question: Type.String({ description: "Full question text, ends with ?" }),
	header: Type.String({ description: "Chip label, max 16 chars" }),
	options: Type.Array(OptionSchema, { description: "2-4 options per question" }),
	multiSelect: Type.Optional(Type.Boolean({ description: "Allow multiple selections" })),
});

const ParamsSchema = Type.Object({
	questions: Type.Array(QuestionSchema, { description: "1-4 questions" }),
});

const RESERVED_LABELS = ["Other", "Type something.", "Chat about this", "Next →"];

// Validation
function validate(questions: Question[]): string | null {
	if (!questions?.length) return "no_questions";
	if (questions.length > 4) return "too_many_questions";

	const seenQuestions = new Set<string>();

	for (const q of questions) {
		if (seenQuestions.has(q.question)) return "duplicate_question";
		seenQuestions.add(q.question);

		if (!q.options?.length || q.options.length < 2) return "empty_options";
		if (q.options.length > 4) return "too_many_options";

		const seenLabels = new Set<string>();
		for (const o of q.options) {
			if (RESERVED_LABELS.includes(o.label)) return "reserved_label";
			if (seenLabels.has(o.label)) return "duplicate_option_label";
			seenLabels.add(o.label);
		}
	}

	return null;
}

// Error response factory
function errorResult(message: string, questions: Question[] = []): {
	content: { type: "text"; text: string }[];
	details: { answers: Answer[]; cancelled: boolean; error: string };
} {
	return {
		content: [{ type: "text", text: message }],
		details: { answers: [], cancelled: true, error: message },
	};
}

export default function ask_user_question(pi: ExtensionAPI) {
	pi.registerTool({
		name: "ask_user_question",
		label: "Ask Questions",
		description:
			"Ask the user structured clarifying questions. Use when you need user input to proceed. Supports single questions, multiple questions with tab navigation, single-select, multi-select, and 'Other' free-text fallback.",
		parameters: ParamsSchema,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (!ctx.hasUI) {
				return errorResult("Error: UI not available (non-interactive mode)", params.questions);
			}

			const validationError = validate(params.questions);
			if (validationError) {
				const messages: Record<string, string> = {
					no_questions: "Error: No questions provided",
					too_many_questions: "Error: Too many questions (max 4)",
					empty_options: "Error: Each question needs 2-4 options",
					too_many_options: "Error: Too many options (max 4)",
					duplicate_question: "Error: Duplicate question",
					duplicate_option_label: "Error: Duplicate option label",
					reserved_label: "Error: Reserved label used",
				};
				return errorResult(messages[validationError] || validationError, params.questions);
			}

			const questions = params.questions as Question[];
			const isMulti = questions.length > 1;
			const totalTabs = questions.length + 1; // questions + Submit

			const result = await ctx.ui.custom<Result>((tui, theme, _kb, done) => {
				// State
				let currentTab = 0;
				let optionIndex = 0;
				let inputMode = false;
				let cachedLines: string[] | undefined;

				const selections: (number | null)[] = questions.map(() => null);
				const multiSelections: (Set<number>)[] = questions.map(() => new Set());
				const notes: (string | null)[] = questions.map(() => null);

				// Editor for "Type something"
				const editorTheme: EditorTheme = {
					borderColor: (s) => theme.fg("accent", s),
					selectList: {
						selectedPrefix: (t) => theme.fg("accent", t),
						selectedText: (t) => theme.fg("accent", t),
						description: (t) => theme.fg("muted", t),
						scrollInfo: (t) => theme.fg("dim", t),
						noMatch: (t) => theme.fg("warning", t),
					},
				};
				const editor = new Editor(tui, editorTheme);

				// Helpers
				function refresh() {
					cachedLines = undefined;
					tui.requestRender();
				}

				function submit(cancelled: boolean) {
					const answers: Answer[] = questions.map((q, idx) => {
					if (q.multiSelect) {
						const selected = Array.from(multiSelections[idx])
							.filter((i) => i < q.options.length)
							.map((i) => q.options[i].label);
						// If "Type something" was selected (index >= options.length), use that text
						const hadCustomOption = Array.from(multiSelections[idx]).some(
							(i) => i >= q.options.length
						);
						if (selected.length > 0 || notes[idx] || hadCustomOption) {
							return {
								questionIndex: idx,
								question: q.question,
								kind: "multi" as const,
								answer: notes[idx] ?? null,
								selected,
								notes: notes[idx] ?? undefined,
							};
						}
					}
						const sel = selections[idx];
						if (sel !== null) {
							const opts = [...q.options, { label: "Type something.", isOther: true }];
							const opt = opts[sel];
							if (opt?.isOther && notes[idx]) {
								return {
									questionIndex: idx,
									question: q.question,
									kind: "custom" as const,
									answer: notes[idx]!,
								};
							} else {
								return {
									questionIndex: idx,
									question: q.question,
									kind: "option" as const,
									answer: q.options[sel].label,
									notes: notes[idx] ?? undefined,
								};
							}
						}
						return {
							questionIndex: idx,
							question: q.question,
							kind: "chat" as const,
							answer: null,
						};
					});
					done({ answers, cancelled });
				}

				function currentOptions(): (QuestionOption & { isOther?: boolean })[] {
					const q = questions[currentTab];
					if (!q) return [];
					const opts: (QuestionOption & { isOther?: boolean })[] = [...q.options];
					opts.push({ label: "Type something.", isOther: true });
					return opts;
				}

				function allAnswered(): boolean {
					return questions.every((q, idx) => {
						if (q.multiSelect) {
							const hasSelections = multiSelections[idx].size > 0;
							const hadCustomOption = Array.from(multiSelections[idx]).some(
								(i) => i >= q.options.length
							);
							return hasSelections || notes[idx] || hadCustomOption;
						}
						return selections[idx] !== null;
					});
				}

				function advanceAfterAnswer() {
					if (!isMulti) {
						submit(false); // Single question: submit immediately
						return;
					}
					if (currentTab < questions.length - 1) {
						currentTab++;
					} else {
						currentTab = questions.length; // Submit tab
					}
					optionIndex = 0;
					refresh();
				}

				// Editor submit callback
				editor.onSubmit = (value) => {
					const trimmed = value.trim();
					if (trimmed) {
						notes[currentTab] = trimmed;
					}
					inputMode = false;
					editor.setText("");
					advanceAfterAnswer();
				};

				function handleInput(data: string) {
					const q = questions[currentTab];

					// Input mode: route to editor
					if (inputMode) {
						if (matchesKey(data, Key.escape)) {
							inputMode = false;
							editor.setText("");
							refresh();
							return;
						}
						if (matchesKey(data, Key.enter)) {
							inputMode = false;
							const value = editor.getText();
							const trimmed = value.trim();
							if (trimmed) {
								notes[currentTab] = trimmed;
								// For multi-select, delete from multiSelections since we store custom text in notes
								if (q?.multiSelect) {
									multiSelections[currentTab].delete(optionIndex);
								} else {
									selections[currentTab] = optionIndex;
								}
							} else {
								selections[currentTab] = optionIndex;
							}
							editor.setText("");
							advanceAfterAnswer();
							return;
						}
						editor.handleInput(data);
						refresh();
						return;
					}

					const opts = currentOptions();

					// Tab navigation (multi-question only)
					if (isMulti) {
						if (matchesKey(data, Key.tab) || matchesKey(data, Key.right)) {
							currentTab = (currentTab + 1) % totalTabs;
							optionIndex = 0;
							refresh();
							return;
						}
						if (matchesKey(data, Key.shift("tab")) || matchesKey(data, Key.left)) {
							currentTab = (currentTab - 1 + totalTabs) % totalTabs;
							optionIndex = 0;
							refresh();
							return;
						}
					}

					// Submit tab
					if (currentTab === questions.length) {
						if (matchesKey(data, Key.enter) && allAnswered()) {
							submit(false);
						} else if (matchesKey(data, Key.escape)) {
							submit(true);
						}
						return;
					}

					// Option navigation
					if (matchesKey(data, Key.up)) {
						optionIndex = Math.max(0, optionIndex - 1);
						refresh();
						return;
					}
					if (matchesKey(data, Key.down)) {
						optionIndex = Math.min(opts.length - 1, optionIndex + 1);
						refresh();
						return;
					}

					// Space: toggle multi-select
					if (matchesKey(data, Key.space) && q?.multiSelect) {
						if (multiSelections[currentTab].has(optionIndex)) {
							multiSelections[currentTab].delete(optionIndex);
						} else {
							multiSelections[currentTab].add(optionIndex);
						}
						refresh();
						return;
					}

					// Enter: select option
					if (matchesKey(data, Key.enter) && q) {
						const opt = opts[optionIndex];
						if (opt.isOther) {
							inputMode = true;
							editor.setText("");
							refresh();
							return;
						}

						if (q.multiSelect) {
							// Just advance to next tab (don't toggle)
							optionIndex = 0;
							advanceAfterAnswer();
						} else {
							selections[currentTab] = optionIndex;
							advanceAfterAnswer();
						}
						refresh();
						return;
					}

					// Cancel
					if (matchesKey(data, Key.escape)) {
						submit(true);
					}
				}

				function render(width: number): string[] {
					if (cachedLines) return cachedLines;

					const lines: string[] = [];
					const add = (s: string) => lines.push(truncateToWidth(s, width));

					const q = questions[currentTab];

					add(theme.fg("accent", "─".repeat(width)));

					// Tab bar (multi-question only)
					if (isMulti) {
						const tabs: string[] = [];
						for (let i = 0; i < questions.length; i++) {
							const isActive = i === currentTab;
							const isAnswered = questions[i].multiSelect
								? multiSelections[i].size > 0
								: selections[i] !== null;
							const box = isAnswered ? "■" : "□";
							const color = isAnswered ? "success" : "muted";
							const text = ` ${box} ${questions[i].header} `;
							const styled = isActive
								? theme.bg("selectedBg", theme.fg("text", text))
								: theme.fg(color, text);
							tabs.push(styled);
						}
						const canSubmit = allAnswered();
						const isSubmitTab = currentTab === questions.length;
						const submitText = " ✓ Submit ";
						const submitStyled = isSubmitTab
							? theme.bg("selectedBg", theme.fg("text", submitText))
							: theme.fg(canSubmit ? "success" : "dim", submitText);
						tabs.push(submitStyled);
						add(` ${tabs.join(" ")} `);
						lines.push("");
					}

					const opts = currentOptions();

					// Render options
					function renderOptions() {
						for (let i = 0; i < opts.length; i++) {
							const opt = opts[i];
							const selected = i === optionIndex;
							const isOther = opt.isOther === true;
							const check = q?.multiSelect
								? multiSelections[currentTab].has(i)
									? theme.fg("success", "█")
									: " "
								: " ";
							const prefix = selected ? theme.fg("accent", "> ") : "  ";
							const color = selected ? "accent" : "text";

							if (isOther && inputMode) {
								add(prefix + theme.fg("accent", `${check} ${opt.label} ✎`));
							} else {
								add(prefix + theme.fg(color, `${check} ${opt.label}`));
							}

							if (opt.description) {
								add(`     ${theme.fg("muted", opt.description)}`);
							}
						}
					}

					// Content
					if (inputMode && q) {
						add(theme.fg("text", ` ${q.question}`));
						lines.push("");
						renderOptions();
						lines.push("");
						add(theme.fg("muted", " Your answer:"));
						for (const line of editor.render(width - 2)) {
							add(` ${line}`);
						}
						lines.push("");
						add(theme.fg("dim", " Enter to submit • Esc to cancel"));
					} else if (currentTab === questions.length) {
						// Submit review tab
						add(theme.fg("accent", theme.bold(" Ready to submit")));
						lines.push("");
						for (let i = 0; i < questions.length; i++) {
							const q = questions[i];
							const prefix = `${theme.fg("muted", q.header + ": ")}`;

							if (q.multiSelect && multiSelections[i].size > 0) {
								const selected = Array.from(multiSelections[i])
									.map((idx) => q.options[idx].label)
									.join(", ");
								add(prefix + theme.fg("text", selected));
							} else if (selections[i] !== null) {
								add(prefix + theme.fg("text", q.options[selections[i]!].label));
							} else {
								add(prefix + theme.fg("warning", "(not answered)"));
							}
						}
						lines.push("");
						if (allAnswered()) {
							add(theme.fg("success", " Press Enter to submit"));
						} else {
							const missing = questions
								.filter((q, idx) => {
									if (q.multiSelect) return multiSelections[idx].size === 0;
									return selections[idx] === null;
								})
								.map((q) => q.header)
								.join(", ");
							add(theme.fg("warning", ` Unanswered: ${missing}`));
						}
					} else if (q) {
						add(theme.fg("text", ` ${q.question}`));
						lines.push("");
						renderOptions();
					}

					lines.push("");
					if (!inputMode) {
						const help = isMulti
							? " Tab/←→ navigate • ↑↓ select • Enter confirm • Esc cancel"
							: " ↑↓ navigate • Enter select • Esc cancel";
						if (questions[currentTab]?.multiSelect) {
							add(theme.fg("dim", help + " • Space toggle"));
						} else {
							add(theme.fg("dim", help));
						}
					}
					add(theme.fg("accent", "─".repeat(width)));

					cachedLines = lines;
					return lines;
				}

				return {
					render,
					invalidate: () => {
						cachedLines = undefined;
					},
					handleInput,
				};
			});

			if (result.cancelled) {
				return {
					content: [{ type: "text", text: "User cancelled" }],
					details: { answers: result.answers, cancelled: true, questions },
				};
			}

			const answerLines = result.answers.map((a) => {
				if (a.kind === "multi" && a.selected) {
					return `${questions[a.questionIndex].header}: ${a.selected.join(", ")}`;
				}
				if (a.kind === "option" && a.answer) {
					return `${questions[a.questionIndex].header}: ${a.answer}`;
				}
				if (a.kind === "custom" && a.answer) {
					return `${questions[a.questionIndex].header}: ${a.answer}`;
				}
				return `${questions[a.questionIndex].header}: (no answer)`;
			});

			return {
				content: [{ type: "text", text: answerLines.join("\n") }],
				details: { answers: result.answers, cancelled: false, questions },
			};
		},

		renderCall(args, theme, _context) {
			const qs = (args.questions as Question[]) || [];
			const count = qs.length;
			const headers = qs.map((q) => q.header).join(", ");
			let text = theme.fg("toolTitle", theme.bold("ask_user_question "));
			text += theme.fg("muted", `${count} question${count !== 1 ? "s" : ""}`);
			if (headers) {
				text += theme.fg("dim", ` (${truncateToWidth(headers, 40)})`);
			}
			return new Text(text, 0, 0);
		},

		renderResult(result, _options, theme, _context) {
			const details = result.details as { answers: Answer[]; cancelled: boolean; questions?: Question[] } | undefined;
			if (!details) {
				const text = result.content[0];
				return new Text(text?.type === "text" ? text.text : "", 0, 0);
			}
			if (details.cancelled) {
				return new Text(theme.fg("warning", "Cancelled"), 0, 0);
			}
			const qs = details.questions || [];
			const lines = details.answers.map((a) => {
				const q = qs[a.questionIndex];
				const header = q?.header || `Q${a.questionIndex + 1}`;
				if (a.kind === "multi" && a.selected) {
					return `${theme.fg("success", "✓ ")}${theme.fg("accent", header)}: ${a.selected.join(", ")}`;
				}
				if (a.kind === "option" && a.answer) {
					return `${theme.fg("success", "✓ ")}${theme.fg("accent", header)}: ${a.answer}`;
				}
				if (a.kind === "custom" && a.answer) {
					return `${theme.fg("success", "✓ ")}${theme.fg("accent", header)}: ${a.answer}`;
				}
				return `${theme.fg("warning", "? ")}${theme.fg("accent", header)}: (no answer)`;
			});
			return new Text(lines.join("\n"), 0, 0);
		},
	});
}
