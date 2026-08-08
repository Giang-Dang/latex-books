# Skill Pre-Deploy Checklist

Run through this before considering a skill done. Grouped by concern; skip groups that
don't apply (e.g. Scripts, if the skill is markdown-only).

## Contents
- Core quality
- Frontmatter & description
- Progressive disclosure & files
- Scripts (if any)
- Testing & cleanup

## Core quality
- [ ] Skill has a single, clear responsibility (not a grab-bag of unrelated tasks)
- [ ] Body adds only what the model doesn't already know — no filler explanations
- [ ] Consistent terminology throughout (one word per concept)
- [ ] At least one concrete, runnable example (not a fill-in-the-blank template)
- [ ] No time-sensitive statements (deprecated material in an "old patterns" `<details>` block)
- [ ] Explains the *why* behind rules instead of stacking all-caps MUSTs

## Frontmatter & description
- [ ] `name`: 1–64 chars, lowercase/numbers/hyphens, no leading/trailing/consecutive hyphens
- [ ] `name` matches the parent directory name; avoids reserved words `claude` / `anthropic`
- [ ] `description`: ≤1024 chars, non-empty, third person
- [ ] Description states **what + when + trigger keywords**, front-loaded
- [ ] Description does **not** summarize the step-by-step workflow (would cause body-skipping)
- [ ] Description is a little "pushy" about when to trigger (fights under-triggering)
- [ ] Optional fields (`license`, `compatibility`, `metadata`, `allowed-tools`) used only if needed
- [ ] Validated with `skills-ref validate ./skill-name` if the linter is available

## Progressive disclosure & files
- [ ] `SKILL.md` body is under 500 lines
- [ ] Detail that isn't always needed is moved to `references/` / `scripts/` / `assets/`
- [ ] All file references are one level deep from SKILL.md (no nested reference chains)
- [ ] Reference files over ~100 lines have a table of contents at the top
- [ ] Forward slashes in every path (`scripts/run.py`), even on Windows
- [ ] MCP tools fully qualified as `Server:tool`
- [ ] No `@file` force-loading of other skills (name them instead)

## Scripts (if any)
- [ ] Each script clearly marked as "execute" or "read as reference"
- [ ] Scripts handle errors themselves rather than punting to the agent
- [ ] No voodoo constants — every magic number justified in a comment
- [ ] Required packages listed; no assumption they're pre-installed
- [ ] Helpers every invocation would otherwise rewrite are bundled once in `scripts/`

## Testing & cleanup
- [ ] Tried 2–3 realistic prompts WITH the skill — agent finds and follows it
- [ ] (Optional) Compared against a WITHOUT-skill baseline to confirm added value
- [ ] Triggers on intended phrasing; doesn't fire on near-misses
- [ ] For discipline skills only: red-flags list + rationalization table present
- [ ] Eval artifacts and scratch output folders removed (unless asked to keep them)
- [ ] Skill appears in the available-skills list on next session load
