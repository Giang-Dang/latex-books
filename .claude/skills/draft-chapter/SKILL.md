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

That means: branch it, research it, plan it, build whatever code it needs, write
it, compile it, update the SPEC, commit, push, and open the pull request. Run
the whole thing without stopping to ask for permission between phases. The
phases below are the plan; do not write a separate plan document or wait for
approval of one.

Resolve the target from the argument. A bare number or "chapter N" means chapter
N of the only book under `books/`; if several books exist, take the book from
the request or ask. "appendix B", "the lab in chapter 3" and "the next
undrafted chapter" are all valid targets, the last resolving through the SPEC
progress table.

Ask the author a question only when proceeding either way would waste
substantial work or produce something unusable. Report decisions you made on
their behalf at the end instead of asking up front.

## Where the work happens

Never draft in the main checkout, and never on `main`. Each session runs in its
own worktree on a new branch cut from `origin/main`, so an abandoned session
leaves nothing to clean up, two chapters can be in flight at once, and the author
reviews the result as a diff instead of finding it already landed.

Name the branch after the target: `draft/<book>-chNN-<slug>` for chapter prose,
`feat/` or `fix/` for a session that only touches tooling. `<book>` is the folder
name under `books/`.

In Claude Code, `EnterWorktree` is this step - it makes the worktree under
`.claude/worktrees/`, cuts the branch from `origin/<default branch>`, and moves
the session into it. In any other runtime, from the repo root:

```
git fetch origin
git worktree add -b draft/<book>-chNN-<slug> .claude/worktrees/<slug> origin/main
```

Then check what you actually got, because a tool that names the branch for you
derives that name from the one you asked for rather than using it:

```
git status -sb
git merge-base --is-ancestor origin/main HEAD && echo based on origin/main
```

`git branch -m draft/<book>-chNN-<slug>` fixes a name that missed the convention.
From here every path in this skill is relative to the worktree root, including
`pwsh scripts/check-chapter.ps1 books/<name>`. The hook path is repository config
and `.githooks/` is tracked, so the pre-commit gate works in a worktree with
nothing re-run; `scripts/setup.ps1` is for a fresh clone, not a fresh worktree.

The base is `origin/main` even where a book's SPEC names a different one. A SPEC
that still declares its own base branch is a stale decision: raise it and let the
author settle it, rather than branching off it quietly. Same answer when the
target depends on work that has not reached `origin/main` yet - say so before
drafting, because a chapter written against a tree missing its predecessor will
contradict it.

## Orient first

Read these before writing anything. Each one changes what the chapter may say.

- `books/<name>/SPEC.md`, in full. The TOC line scopes the chapter, the decision
  log constrains it, the writing-rules section binds it, and open items may name
  work this chapter owes. Two of its writing-rules slots settle the shape of the
  session before anything else does: `Companion code:` says whether this book has
  a repo to build and tag before prose, and `Listings:` says what a listing in
  this book may be. A book answering "none" to the first is a book where step 2
  never runs, and the second is then the only answer to where a listing came
  from.
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
   The two directions can run as a pair of background subagents - see The
   research pair in `references/delegation.md`. Either way the orchestrator
   writes the findings to `books/<name>/research/` itself, following the shape
   of the existing files there.
2. **Companion code**, where the SPEC names a repo and this chapter ships code
   into it. Two conditions, and they are answered in different places: whether
   the mechanism exists at all is the book's, settled once on the SPEC's
   `Companion code:` line, and whether this chapter uses it is the chapter's.
   Read the line rather than inferring the book's answer from the chapter. Where
   it names a repo, that repo has to exist, pass its own verification, and be
   tagged **before** prose is written; see `references/companion-code.md`. Where
   it says "none", this step and the gate under it retire, and the `Listings:`
   line carries the weight instead.
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

   The drafting itself is never split across agents, but the chapter's figures
   and its bibliography block can be built alongside the prose by the figure
   and bibliography agents in `references/delegation.md`, within the session
   budget that file sets.
5. **Audit, from outside.** Build and run the check script first so the machine
   layer is already clean, then spawn one read-only subagent with **no drafting
   context** and brief it per `references/audit.md` - one auditor is the
   default, and that file names the one case where the audit becomes a small
   panel. Reviewing your own draft in
   the context that wrote it is not this step: that reviewer accepted every
   claim once already and fills the gaps from memory. Verify each factual
   finding yourself before acting on it, and report the ones you reject along
   with why. The audit is a lead, not a verdict.
6. **Close out.** Rebuild after the audit fixes, run the check script again,
   update SPEC, then commit and push. One commit per logical change, subject in
   the repo's style: `draft: chapter NN, <chapter title>` for the prose,
   `feat:`, `fix:` or `refactor:` for anything else the session touched. The
   pre-commit hook rebuilds every book in the staged paths, so it is slow on
   purpose; read what it prints rather than working around it. Then
   `git push -u origin HEAD`.
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
8. **Open the PR.** Last, so that it can carry the retro:

   ```
   gh pr create --base main --title 'draft: chapter NN, <chapter title>' \
     --body-file <a scratch file outside the repo>
   ```

   The body covers what the chapter does, which gates passed and how each audit
   finding was resolved, the companion tag its listings depend on where the book
   has one, the SPEC rows that moved, and step 7's proposals as a list the author
   can act on. Write it to a scratch path rather than the working tree, so
   drafting the PR does not leave a file behind in the commit that follows.
   Target `main`, never another book's branch.

   Stop at the open PR. Merging it and clearing the worktree are the author's,
   and a worktree removed before review takes the branch's working state with it.

Writing prose before the code exists produces listings that then have to be made
true, which is backwards and tends to leave inventions in the text. A book with
no repo meets the same failure in a smaller form: a listing written to illustrate
a sentence is not evidence for it, so the prose has to say what that listing
actually is.

## Gates

Do not pass one of these without the previous one holding.

| Gate | Condition |
|---|---|
| Branch | Work is in a worktree on a new branch cut from `origin/main`; the main checkout is untouched |
| Research | Every load-bearing fact has a primary source at a pinned version, or was measured |
| Companion code | Where the SPEC names a repo: its verification script passes and the chapter's tag is pushed |
| Report | What the research settled posted before prose starts: the real schema, the measured numbers, whatever the sources and the machine disagreed about |
| Prose | Every listing has the provenance the SPEC's `Listings:` line names, and nothing invented is presented as real code |
| Build | `latexmk` exits 0; `pwsh scripts/check-chapter.ps1 books/<name>` exits 0 |
| Audit | A subagent with no drafting context reported; every finding is fixed, or rejected on the record |
| SPEC | Progress row, decisions, TOC and open items all reflect reality |
| Commit | `.githooks/pre-commit` passes unaided; never `--no-verify` |
| PR | Branch pushed with its upstream set; PR open against `main`, body carrying the gate results and the retro proposals |

The build gate: from the book directory `latexmk -C && latexmk` (through the
Bash tool), then from the repo root:

```
pwsh scripts/check-chapter.ps1 books/<name>
```

Add `-Chapter NN` to lint one chapter while iterating. The script owns the
mechanical checks, and it owns them as families: characters, citations, quoting,
index termination, contractions, spelling, dashes, measured-number provenance,
verbatim-capture claims, listing width, and the build log's overfull and
undefined counts.

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
  wave pattern that keeps parallel code work from colliding. Nothing in it
  applies to a book whose SPEC says "none" for companion code, so that book
  never opens it.
- `references/delegation.md` - when to hand work to a subagent, the session
  budget, model tiers, and the briefs. Read before spawning anything beyond
  the audit.
- `references/audit.md` - the independent audit: why a fresh agent, what to
  withhold from the brief, the brief itself, and how to triage what comes back.
- `references/environment.md` - build and tooling traps specific to this
  machine and repo. Read it before the first `latexmk` run of a session.

## Done when

The full book compiles clean with `\includeonly` commented out, every listing has
the provenance its SPEC names for it, `SPEC.md` reflects the new state, the
pre-commit hook passes on its own, and the branch is pushed with a PR open
against `main`. Leave the worktree where it is: whether that PR merges is the
author's call, not the session's.
