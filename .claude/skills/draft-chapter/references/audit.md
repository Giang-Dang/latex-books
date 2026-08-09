# The independent audit

How to run step 5 so it tests the draft instead of confirming it.

## Contents

- Why a fresh agent
- Run the machine gate first
- What not to send
- The brief
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

The cost of getting this wrong is on the record. Chapter 02 shipped a latency,
a line count and an API attribute name asserted from memory, all three wrong.
Chapter 04 printed a fabricated `11.3ms/11.4ms` request timeline inside a
minted block, which is why `check-chapter.ps1` now traces every decimal back to
a research note. Both were caught by an audit. Neither would have been caught
by the draft reading itself.

## Run the machine gate first

Build, then run `pwsh scripts/check-chapter.ps1 books/<name>` from the repo
root, and fix everything it reports before briefing the auditor.

The script owns bytes, citation ties and keys, quoting, index termination,
contractions, spellings, dashes, measured-number provenance and the log counts.
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

Filled in for chapter 05 of the federation book. Adapt the paths; keep the
shape, and keep the order of the report - a long brief gets skimmed from the
bottom, so what matters most is listed first.

```
Read-only audit of a book chapter. Do not edit any file. Repo root is
F:/repo/latex-books.

Chapter under audit - read every file end to end:
  books/federated-graphql-on-dotnet/chapters/05-schema-design-that-survives-change/ch.tex
  ...and 01-what-a-client-can-survive.tex through 07-your-turn.tex in that folder

Read before judging anything:
  books/federated-graphql-on-dotnet/chapters/04-data-without-the-n-plus-1/*.tex
      - the voice specification. Take the voice from this prose, not from any
        description of it.
  CLAUDE.md - repo-wide writing defaults
  books/federated-graphql-on-dotnet/SPEC.md - writing rules, decision log, and
        the TOC line for this chapter
  .claude/skills/draft-chapter/references/house-style.md
  .claude/skills/humanizer/SKILL.md - apply its checklist

Sources this chapter must trace back to:
  books/federated-graphql-on-dotnet/research/2026-08-ch05-schema-design.md
  companion repo F:/repo/mosaic-graph at tag ch05

Report in this order. Earlier items matter more; if you run short, cut from the
bottom.
  1. Any number, version, API name, identifier or listing in the chapter that
     does not trace to the research note, to the companion repo at that tag, or
     to a cited primary source. The research note is a claim too: a number
     recorded there with no way to reproduce it was not measured.
  2. Violations of CLAUDE.md, the SPEC writing rules or house-style. Include
     \ref targets that do not resolve, and a SPEC TOC line that no longer
     describes what the chapter actually does.
  3. Voice drift from chapter 04, and anything on the humanizer checklist.

Format: one line per finding - file:line, the quoted span, what is wrong, the
rule or source it fails, and confidence (certain / likely / unsure). Flag
uncertainty instead of guessing; an "unsure" that turns out to be real beats a
confident miss.

The mechanical checks already pass, so do not re-report bytes, citation ties,
citation keys, literal quote characters, unterminated \index lines,
contractions, American spellings or dash characters.

No praise, no summary, no restating what the chapter does well. If a category
turns up nothing, say so in one line. Do not manufacture findings to fill it.
```

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
