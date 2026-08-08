---
name: skill-conventions
description: Conventions and best practices for authoring Agent Skills (Claude Code, Codex, and the open agentskills.io format). Covers frontmatter rules, description writing, naming, progressive disclosure, file organization, scripts, and a pre-deploy checklist. Trigger on the ACTION, not the wording — apply this before any Edit or Write to a file whose path ends in SKILL.md, and before creating a new skill, regardless of who initiated it or why. This fires even when the user never says "skill" and editing a SKILL.md is incidental to a larger task (e.g. "add a convention", "document this rule", "where should this go", "add a testing rule") — that self-initiated, incidental edit is the most-missed case, so default to loading this skill the moment a SKILL.md becomes the edit target. Also fires on explicit "make a skill", "turn this into a skill", "update this skill".
---

# Skill Conventions

A standing reference for writing skills that other agents can reliably **find** and
**follow**. Apply it on every skill create or update, then run the pre-deploy
[checklist](references/checklist.md) before finishing.

The format is a cross-vendor open standard (agentskills.io), adopted by Claude Code,
OpenAI Codex, and others. These conventions hold across all of them; vendor-specific
plumbing is called out where it matters.

## Core principle

The context window is shared RAM, not free storage. At startup only each skill's
`name` + `description` are loaded; the body loads only when the skill triggers; bundled
files load only when read. So **add only what the model doesn't already know** — challenge
every paragraph ("does Claude need this, or does it know it?"). Too little context and the
agent flounders; too much or irrelevant and quality drops and cost rises.

**Match degrees of freedom to the task.** Open-ended judgment task → give direction and
trust the model (high freedom). Fragile/exact sequence (migrations, builds) → give a
specific script and say "run exactly this" (low freedom). Explain the *why* behind rules
rather than stacking all-caps MUSTs; modern models follow reasoning better than commands.

## Frontmatter (normative)

Required fields, per the open spec:

- **`name`** — 1–64 chars; lowercase letters, numbers, hyphens only; no leading/trailing or
  consecutive hyphens; **must match the parent directory name**; avoid reserved words
  `claude` / `anthropic`.
- **`description`** — 1–1024 chars, non-empty, third person. See next section — this is the
  highest-leverage field in the whole skill.

Optional (use only when needed): `license`, `compatibility` (≤500 chars; environment needs
like "Requires git, jq, network access"), `metadata` (arbitrary string map, e.g. author/version),
`allowed-tools` (experimental, space-separated pre-approved tools).

Validate frontmatter and naming with the reference linter when available:
`skills-ref validate ./skill-name`.

## Writing the description

This single field decides whether the skill is ever used — the agent reads only the
description to choose among potentially 100+ skills, and skill lists get truncated when
long (Codex caps the list near 8000 chars), so **front-load the key use case and trigger
words**.

Three rules:

1. **What + when + keywords.** State what it does, the concrete situations/triggers that
   should fire it, and search terms a user would actually type (file types, errors, tools).
2. **Be a little pushy.** Agents tend to *under*-trigger skills. Add explicit "use this even
   when the user just says X" cues rather than hoping a vague phrase matches.
3. **Never summarize the step-by-step workflow.** If the description spells out the process,
   the agent follows the *description* and skips reading the body — so a two-step workflow
   silently becomes one step. Describe *when to reach for it*, not *how it works inside*.

```yaml
# Bad — vague, no triggers
description: Helps with PDFs.

# Bad — leaks the workflow, so the body gets skipped
description: Use when filling PDFs — analyze the form, build a field map, validate it, then fill.

# Good — what + when + keywords, no workflow
description: Extracts text and tables from PDFs, fills forms, and merges files. Use when working
  with PDF files or when the user mentions PDFs, forms, or document extraction.
```

## Naming

Prefer **gerund form** (verb + -ing) — it names the activity: `processing-pdfs`,
`analyzing-spreadsheets`, `writing-documentation`. Action-oriented (`process-pdfs`) or noun
phrases (`pdf-processing`) are acceptable. Avoid vague names (`helper`, `utils`, `tools`,
`data`). Keep naming consistent across a skill collection. Remember the name must equal the
directory name.

## Progressive disclosure

Structure the skill so detail loads only when a task calls for it:

1. **Metadata** (~100 tokens) — `name` + `description`, always loaded.
2. **`SKILL.md` body** — loaded on trigger. Keep it **under 500 lines**; this is an overview
   that points to detail, like a table of contents.
3. **Bundled files** — loaded only when read; effectively unlimited, no context cost until used.

```
skill-name/
├── SKILL.md          # required: overview + the common path
├── scripts/          # executable code (run, not read)
├── references/       # docs loaded on demand
└── assets/           # templates, schemas, images used in output
```

Keep references **one level deep** from SKILL.md — agents partially-read deeply nested chains
(`head -100`) and miss content. For multi-domain skills, split by domain
(`references/finance.md`, `references/sales.md`) so only the relevant file loads. Give any
reference file over ~100 lines a table of contents at the top, so a partial read still reveals
its full scope.

## Writing patterns

- **One responsibility per skill.** Start from 2–3 concrete use cases, not exhaustive edge
  cases. If a skill sprawls across unrelated tasks, split it.
- **Consistent terminology.** Pick one word ("field", "extract", "endpoint") and keep it.
- **No time-sensitive text.** Don't write "before August 2025…"; put deprecated material in a
  `<details>` "old patterns" block instead.
- **One excellent example beats five mediocre ones.** Make it concrete and runnable, not a
  fill-in-the-blank template, and don't reimplement it in five languages.
- **Default + escape hatch, not a menu.** "Use pdfplumber. For scanned PDFs, use pdf2image"
  beats listing five libraries.
- **Forward slashes only** in paths (`scripts/run.py`), even on Windows.
- **Fully-qualify MCP tools** as `Server:tool` (e.g. `GitHub:create_issue`) or the agent may
  not find them.
- **Prefer a CLI over a heavy MCP** when it's more token-efficient (e.g. `gh` over a GitHub
  MCP) — it lowers the bar for cheaper/faster models to chain calls reliably.

## Scripts

- **Say whether to execute or read.** "Run `analyze.py` to extract fields" (execute, the common
  case — reliable, no tokens) vs "see `analyze.py` for the algorithm" (read as reference).
- **Solve, don't punt.** Handle errors in the script instead of failing and leaving the agent to
  guess. No voodoo constants — justify every magic number in a comment.
- **List dependencies.** State required packages; don't assume they're installed (the API
  execution environment has no network/install).
- **Bundle repeated work.** If every invocation would otherwise rewrite the same helper, write
  it once into `scripts/` and point at it.

## Discipline skills (optional)

Only for skills that enforce a *rule* under pressure (e.g. "always write the test first"). For
these, add a short **red-flags list** ("you're about to skip the test because…") and a
**rationalization table** (excuse → reality) capturing the workarounds agents actually invent.
Skip this ceremony for ordinary technique/reference skills — it's overhead there.

## Verify before deploy (lightweight)

You don't need the full benchmark pipeline for most skills. Do a quick sanity check:

1. Run 2–3 realistic prompts a user would actually type, **with** the skill — does the agent
   find it and follow it? Optionally compare against a **without-skill** baseline to confirm the
   skill is pulling its weight.
2. Confirm it triggers on the intended phrasing (and doesn't on near-misses).
3. **Clean up eval artifacts** (scratch eval files, output folders) unless asked to keep them.
4. Walk the [pre-deploy checklist](references/checklist.md).

For rigorous eval loops (parallel runs, grading, benchmark viewer, description optimization),
use the `skill-creator` or `global-skill-creator` skills — this skill stays deliberately lean
and defers to them rather than force-loading them.
