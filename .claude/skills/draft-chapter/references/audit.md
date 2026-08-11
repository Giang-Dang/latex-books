# The independent audit

How to run step 5 so it tests the draft instead of confirming it.

## Contents

- Why a fresh agent
- Run the machine gate first
- What not to send
- The brief
- One auditor or a panel
- Triage
- Red flags

## Why a fresh agent

The agent that wrote the chapter has already accepted every claim in it once.
It knows what each sentence was meant to say, so it reads that meaning back in
where the words do not carry it, and it supplies from memory the context a
reader will not have. An unsourced number does not look unsourced to the agent
that wrote it; it looks like something it knows.

So the auditor has to be a subagent with no drafting context. Not a different
checklist, not a stricter mood, not a second pass later in the same session -
a clean context reading the files cold.

The cost of getting this wrong is on the record. One chapter shipped a latency,
a line count and an API attribute name asserted from memory, all three wrong.
Another printed a fabricated request timeline inside a listing, which is why
`check-chapter.ps1` now traces every printed decimal back to a research note. A
third called a listing the only one it had not trimmed, after reformatting the
strings inside that listing, and printed a response whose trailing zero a JSON
formatter had quietly dropped on the way to the page; that pair is why the
script also traces listings the prose calls captures. All three were caught by
an audit. None would have been caught by the draft reading itself. Each book's
own incidents are recorded in its SPEC decision log and open items.

## Run the machine gate first

Build, then run `pwsh scripts/check-chapter.ps1 books/<name>` from the repo
root, and fix everything it reports before briefing the auditor.

The script owns families of mechanical check: characters, citations, quoting,
index termination, contractions, spelling, dashes, measured-number provenance,
verbatim-capture claims and the log counts. Which of them actually ran for this
book, and how strictly, is the `==> policy:` line the script prints at the top
of the run, and that line rather than this list is what the brief passes on.

Attention the auditor spends re-deriving those findings is attention it is not
spending on the half no script can check: whether a sentence is true, whether
the voice is the book's, whether a listing says what the prose claims it says.

## What not to send

The brief is where bias gets reintroduced, usually while trying to be helpful.

- **No drafting rationale.** "Here is what I was going for" tells the auditor
  what to see.
- **No self-assessment.** Naming the sections you are unsure about pulls the
  whole report onto them, and away from the ones you are wrong to feel
  confident about. Those are the expensive ones.
- **No claim that something was already checked**, humanized or verified. It
  reads as permission to skip.
- **Nothing summarised out of the source files.** Send paths and let the
  auditor read them. Your summary is the draft's own reading of itself, which
  is the thing under test.

Send file paths, the sources the chapter must trace back to, and the report
format. Nothing else.

## The brief

A template. Fill every angle-bracket slot before sending it, because an
unfilled slot is how an auditor ends up reading the wrong chapter or judging
prose against a voice the book does not use. Keep the shape, and keep the order
of the report - a long brief gets skimmed from the bottom, so what matters most
is listed first.

- `<REPO ROOT>` - the absolute path to this repository, so that nothing in the
  brief resolves against the subagent's own working directory.
- `<BOOK>` - the book folder under `books/`.
- `<NN-slug>` - the chapter folder under audit.
- `<previous drafted chapter folder>` - the chapter the SPEC progress table
  marks drafted before this one. It is the voice specification, so it has to be
  a drafted chapter and not the stub next door.
- `<humanizer skill>` - the skill named on the SPEC's `Humanizer skill:` line.
- `<research file>` - the note under `research/` this chapter's facts trace to.
- `<companion repo and tag, or "none">` - the tag every listing must match.
  Write "none" for a chapter that ships no code rather than dropping the line:
  an auditor told there is no repo stops looking for one, and an auditor told
  nothing goes looking.
- `<policy line>` - the `==> policy:` line `check-chapter.ps1` printed on the
  run you just fixed everything from. Paste it exactly, do not summarise it.

```
Read-only audit of a book chapter. Do not edit any file. Repo root is
<REPO ROOT>.

Chapter under audit - read every file end to end:
  books/<BOOK>/chapters/<NN-slug>/ch.tex
  ...and every section file in that folder

Read before judging anything:
  books/<BOOK>/chapters/<previous drafted chapter folder>/*.tex
      - the voice specification. Take the voice from this prose, not from any
        description of it.
  AGENTS.md - repo-wide writing defaults (CLAUDE.md only imports it)
  books/<BOOK>/SPEC.md - writing rules, decision log, and the TOC line for
        this chapter
  books/<BOOK>/check-chapter.psd1 - the machine half of those writing rules
  .claude/skills/draft-chapter/references/house-style.md
  .claude/skills/<humanizer skill>/SKILL.md - apply its checklist. Judge each
      file under its tone role: chapter prose as chapter prose, the
      end-of-chapter lab as a lab. That skill's own tone table says which
      file under its references/ each role resolves to; read only those.

Sources this chapter must trace back to:
  books/<BOOK>/research/<research file>
  companion repo <companion repo and tag, or "none">

Report in this order. Earlier items matter more; if you run short, cut from the
bottom.
  1. Any number, version, API name, identifier or listing in the chapter that
     does not trace to the research note, to the companion repo at that tag, or
     to a cited primary source. The research note is a claim too: a number
     recorded there with no way to reproduce it was not measured.
  2. Violations of AGENTS.md, the SPEC writing rules or house-style. Include
     \ref targets that do not resolve, and a SPEC TOC line that no longer
     describes what the chapter actually does.
  3. Voice drift from the previous chapter, and anything on the humanizer
     checklist, each file judged under the tone role named above for it.

Format: one line per finding - file:line, the quoted span, what is wrong, the
rule or source it fails, and confidence (certain / likely / unsure). Flag
uncertainty instead of guessing; an "unsure" that turns out to be real beats a
confident miss.

The mechanical checks already pass. This is the policy the script resolved for
this book on that run:
  <policy line>
A family shown there as on has already been checked, so do not re-report it. A
family shown as off did not run at all, so nothing in it was checked and it is
yours to judge like any other prose question.

No praise, no summary, no restating what the chapter does well. If a category
turns up nothing, say so in one line. Do not manufacture findings to fill it.
```

In Claude Code, spawn the auditor as the `chapter-auditor` agent type: its
definition under `.claude/agents/` enforces read-only tools and carries the
standing rules, so the brief above is all it needs.

## One auditor or a panel

One auditor is the default, and the record above is a single-agent record:
every catch it lists came from one fresh context reading everything. Stay with
one.

The exception is a chapter too big for one careful pass - many sections, many
listings, many measured numbers - where the three report items start competing
for the same attention. There the audit splits by lens into three fresh
read-only subagents under the same brief discipline:

- **A fact tracer**: the chapter plus the research note and the companion repo
  at the tag. Report item 1 only.
- **A rules auditor**: the chapter plus AGENTS.md, the SPEC,
  check-chapter.psd1 and house-style. Report item 2 only.
- **A voice auditor**: the chapter plus the previous drafted chapter and the
  humanizer file its roles resolve to. Report item 3 only.

Each lens gets the template above minus the other lenses' reading list and
report items, so the chapter under audit is the only reading all three share
and the panel's total is close to one auditor's - the extra cost is two more
reads of the chapter itself, which is what the length that triggered the
split pays for. Panel members are never continued and never told of each
other's findings; triage below is unchanged and works the union of the three
reports.

## Triage

Verify each factual finding yourself before acting on it. The audit is a lead,
not a verdict, and an auditor reading cold will sometimes call a deliberate
decision a mistake - the decision log is the answer to that, not the draft's
memory of why it did something.

**A finding you reject goes into the session report with the evidence that
rejects it.** One line each. Silent dismissal is exactly how a biased reviewer
launders its own draft past an independent one, and writing it down is what
makes that visible to the author instead of invisible.

## Red flags

You are about to skip the subagent because:

| Excuse | Reality |
|---|---|
| "check-chapter is clean" | It checks bytes and keys. It cannot read. |
| "I applied the humanizer while drafting" | Same context, same blind spot. |
| "The chapter is short, or it is only a revision" | Length was never the argument for independence. |
| "I know what the auditor would say" | That belief is the defect being corrected. |
| "I will fold it into the final read-through" | The final read-through is done by the agent that wrote it. |
