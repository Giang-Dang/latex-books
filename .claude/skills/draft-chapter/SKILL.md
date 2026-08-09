---
name: draft-chapter
description: Drafts, outlines, continues, or revises a chapter, section, appendix, figure, or end-of-chapter lab for a book under books/ in this repo, following that book's SPEC.md. Use for any request to write or continue book content, however loosely phrased - "draft chapter 7", "continue the current book", "write the next section", "outline chapter 12", "add the lab to chapter 3", "this chapter needs a diagram". Also use when revising drafted prose for voice, or when updating a book's SPEC.md after a writing session.
---

# Draft a chapter

## Invocation

Typical use is a single line with no further instruction:

```
/draft-chapter chapter 3
```

That means: research it, plan it, build whatever code it needs, write it,
compile it, update the SPEC, and commit. Run the whole thing without stopping to
ask for permission between phases. The phases below are the plan; do not write a
separate plan document or wait for approval of one.

Resolve the target from the argument. A bare number or "chapter N" means chapter
N of the only book under `books/`; if several books exist, take the book from
the request or ask. "appendix B", "the lab in chapter 3" and "the next
undrafted chapter" are all valid targets, the last resolving through the SPEC
progress table.

Ask the author a question only when proceeding either way would waste
substantial work or produce something unusable. Report decisions you made on
their behalf at the end instead of asking up front.

## Orient first

Read these before writing anything. Each one changes what the chapter may say.

- `books/<name>/SPEC.md`, in full. The TOC line scopes the chapter, the decision
  log constrains it, the writing-rules section binds it, and open items may name
  work this chapter owes.
- `books/<name>/check-chapter.psd1`, if the book has one. It is the machine half
  of those writing rules, and which checks are live changes how you write: a
  book that leaves the spelling check off is a book whose variety nothing will
  correct for you, and one that bans every non-ASCII byte is a book where a
  pasted listing has to be cleaned before it lands.
- The chapter's stub at `chapters/NN-slug/ch.tex`. Its `\label{ch:...}` already
  exists and earlier chapters forward-reference it, so the label is fixed.
- **The previous drafted chapter's section files, end to end.** That is the voice
  specification. Paraphrasing a style guide produces a different voice; reading
  the actual prose does not.
- Any research file the SPEC points at for this chapter.

Then `grep -h '\\label{' chapters/*/ch.tex backmatter/*.tex` for the exact
cross-reference keys. Never guess a `\ref` target.

If the SPEC's TOC line has gone stale against current reality, say so before
drafting. A settled decision changes by being recorded as changed, never by
quietly diverging: update the TOC line and add a decision row in the same
session.

## Order of work

The sequence matters more than any individual step.

1. **Research**, in both directions. Web-verify against primary sources, and
   verify empirically by building and running. Where docs and the compiler
   disagree, the compiler wins and the research file records the disagreement.
   Write the findings to `books/<name>/research/` following the shape of the
   existing files there.
2. **Companion code**, if the chapter ships any. See
   `references/companion-code.md`. The repo has to exist, pass its own
   verification, and be tagged **before** prose is written.
3. **Report, then keep going.** Post the real schema, the measured numbers, and
   anything the build taught you that the docs did not. This is a progress
   report, not a request for approval: the author can interrupt if something
   looks wrong, and silence means continue.
4. **Draft.** Load the humanizer skill the book's SPEC names on its
   `Humanizer skill:` line and apply its checklist, along with the writing
   defaults in `AGENTS.md` and the SPEC's own writing rules. The humanizer runs
   embedded here: never ask which tone, pick the profile from what is being
   drafted and read only that one.

   | Target | Tone role |
   |---|---|
   | Chapter section prose | whatever the SPEC's `Voice:` line names: "first-person practitioner" (the AGENTS.md default) takes the chapter role; a SPEC declaring a textbook or a narrative voice takes the textbook or narrative role |
   | End-of-chapter lab, step-by-step walkthrough | lab |
   | Appendix, glossary, version matrix | appendix |
   | Files under `frontmatter/` | front matter |
   | Back-cover, catalogue or landing-page copy | blurb |

   A role is not a filename. Resolve it against the humanizer the SPEC named:
   that skill's own tone table maps each role to exactly one file under its
   `references/`, and the vendored humanizers name the same roles differently
   because they are written in different languages. Read the one file the role
   resolves to and leave the rest unread.

   One chapter can span roles: the lab section of an otherwise chapter-role
   chapter is judged as a lab.
   Scaffold to convention: `chapters/NN-slug/ch.tex` holds `\chapter`, `\label`
   and a short opener, then `\input`s one file per section, with every path
   written from the book root.
5. **Audit, from outside.** Build and run the check script first so the machine
   layer is already clean, then spawn one read-only subagent with **no drafting
   context** and brief it per `references/audit.md`. Reviewing your own draft in
   the context that wrote it is not this step: that reviewer accepted every
   claim once already and fills the gaps from memory. Verify each factual
   finding yourself before acting on it, and report the ones you reject along
   with why. The audit is a lead, not a verdict.
6. **Close out.** Rebuild after the audit fixes, run the check script again,
   update SPEC, commit.
7. **Retro, proposals only.** List what cost time this session, then sort each
   item into exactly one of these:

   - A machine-checkable mistake **any book would want caught** becomes a
     proposed new check in `scripts/check-chapter.ps1`.
   - A machine-checkable mistake **only this book cares about** becomes a
     proposed setting in `books/<name>/check-chapter.psd1`, plus the rule it
     enforces in the SPEC's writing-rules section. The two go together: a
     setting with no rule is a rule nobody agreed to, and a rule with no
     setting is a rule nothing enforces.
   - A book-specific lesson no script can check goes into that book's SPEC
     open items or decision log (do that now - it is in scope).
   - A cross-book process lesson becomes a proposed edit to this skill's
     references, but only once the same lesson has bitten in two different
     chapters - a one-off is noise, name it and drop it.

   **The line between the first two arms is the one that keeps this skill
   usable by a second book.** Nothing that names a particular book - its
   subject, its libraries, its repository, its measured numbers, its running
   example - belongs in this skill or in `scripts/check-chapter.ps1`. Both are
   read by every book, and both have had to be cleaned of exactly that once
   already. If a proposal cannot be written without naming a book, it is a SPEC
   or a psd1 proposal, not a skill or script one.

   Present proposals to the author as diffs and stop there: never edit this
   skill, its references, or the check script in a drafting session.

Writing prose before the code exists produces listings that then have to be made
true, which is backwards and tends to leave inventions in the text.

## Gates

Do not pass one of these without the previous one holding.

| Gate | Condition |
|---|---|
| Research | Every load-bearing fact has a primary source at a pinned version, or was measured |
| Companion code | That repo's verification script passes; the chapter's tag is pushed |
| Report | Real schema and numbers posted before prose starts |
| Prose | Every listing traceable to a file in the companion repo at the chapter's tag |
| Build | `latexmk` exits 0; `pwsh scripts/check-chapter.ps1 books/<name>` exits 0 |
| Audit | A subagent with no drafting context reported; every finding is fixed, or rejected on the record |
| SPEC | Progress row, decisions, TOC and open items all reflect reality |
| Commit | `.githooks/pre-commit` passes unaided; never `--no-verify` |

The build gate: from the book directory `latexmk -C && latexmk` (through the
Bash tool), then from the repo root:

```
pwsh scripts/check-chapter.ps1 books/<name>
```

Add `-Chapter NN` to lint one chapter while iterating. The script owns the
mechanical checks, and it owns them as families: characters, citations, quoting,
index termination, contractions, spelling, dashes, measured-number provenance,
verbatim-capture claims, and the build log's overfull and undefined counts.

Which of those families are live for this book, and how strictly, is not fixed.
The script holds the checks and a set of defaults; the book's
`check-chapter.psd1` holds where it differs. The resolved policy is printed as a
`==> policy:` line at the top of every run, so read that line rather than
assuming: a family it reports as `off` produced no findings because it never
looked. Fix findings rather than arguing with them.

Two families trace a claim back to `research/`. The `number` check wants every
printed decimal recorded there. The `verbatim` check fires when prose calls a
listing a capture ("verbatim", "in full", "exactly as", "not trimmed") and a
line of that listing appears in no research note; which environments count as
capture-bearing is part of the printed policy. Both have the same fix: record
what you actually captured, or stop claiming you captured it.

Then read `build/main.pdf` and look at the chapter: figure placement, listings
inside the measure, index entries, citations resolving. A clean log is not the
same as a chapter that reads well on the page.

## Numbers and sources

If the text states a measurement, measure it, and record how to reproduce it in
the research file. One drafted chapter asserted a latency, a line count and an
API attribute name from memory; all three were wrong, and only the audit caught
them. Treat any number you did not personally run as unverified. The incidents
behind one book's own rules are recorded in its SPEC decision log and open
items, not here.

Vendor sources are usable only when a named engineer is named in the prose, so
check the byline rather than the domain.

## Reference material

Load these when the task reaches them, not before.

- `references/house-style.md` - LaTeX and prose conventions shared by books in
  this repo: citations, quoting, index entries, listings, figures, labels.
- `references/companion-code.md` - the code-before-prose workflow, and the
  subagent delegation pattern that keeps parallel work from colliding.
- `references/audit.md` - the independent audit: why a fresh agent, what to
  withhold from the brief, the brief itself, and how to triage what comes back.
- `references/environment.md` - build and tooling traps specific to this
  machine and repo. Read it before the first `latexmk` run of a session.

## Done when

The full book compiles clean with `\includeonly` commented out, every listing is
traceable to a companion-repo tag, `SPEC.md` reflects the new state, and the
pre-commit hook passes on its own.
