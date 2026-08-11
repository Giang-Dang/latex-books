# Companion code, and delegating the work

How to grow a book's companion repository for a chapter, and how to parallelise
it without the agents colliding.

Read this only if the book ships companion code. Whether it does, which
repository that is, and the one command that proves the repository is good are
all in the book's SPEC; a conceptual book has none of the three and none of this
applies to it.

## Contents

- Why code comes first
- Growing the repo
- The verification gate
- Tagging
- Delegation waves
- Briefing a subagent

## Why code comes first

The rule that every listing is real code is only enforceable in one direction.
Write the prose first and the listings become claims that then have to be made
true, which is how invented API names and unmeasured numbers survive into a
draft. Build the thing, run it, read what it actually printed, then describe it.

The compiler is also the best available research tool for anything newer than
the model's training data. A documented API that does not exist fails at build
time; the same API asserted in prose fails in print.

## Growing the repo

Read the companion repo's `README.md` before adding anything: it carries the
chapter-to-tag table and the layout conventions.

A repo that later chapters take apart also has one layout rule that every later
extraction depends on, and the book's SPEC states it. Hold it even where a
shortcut is tempting - the shortcut costs the chapter taking it nothing, and
costs the chapter doing the extraction a rewrite.

When a chapter deliberately leaves something naive so a later chapter can fix
it, say so in a code comment as well as in the prose. A future reader of the
repo has no chapter text in front of them.

## The verification gate

Every companion repo has one command that proves it is good, named in the book's
SPEC, and it has to pass before a tag is created.

If a chapter legitimately changes one of the numbers that command asserts,
update it and say so in the commit message. Never loosen an assertion to make a
run pass.

## Tagging

`chNN` marks the end-of-chapter state; `chNN-<step>` if a chapter needs an
intermediate one. Tag only after the verification gate passes, then push the
branch and the tag. Chapter prose references tags by name, and the labs tell
readers to check them out, so an unpushed tag is a broken instruction.

## Delegation waves

Subagents are worth it for bounded, mechanical work. Prose is neither: splitting
sections across agents yields several voices to reconcile, which costs more than
it saves. Keep the writing.

A pattern that worked for a multi-domain service:

- **Shared files stay with the orchestrator**: the entry point, dependency
  manifests, the solution or workspace file, any committed generated artifact,
  `SPEC.md`, all prose.
- **Wave A** - one agent per domain folder, each owning exactly one folder.
  Sequence any domain that others depend on into an earlier wave, or hand the
  dependents its exact contract so they can be written against it.
- **Wave B** - samples, container files, verification scripts, in parallel.
- **Wave C** - bibliography block and figures, in parallel; their briefs are in
  `references/delegation.md`. The research file stays with the orchestrator.
- **Final** - one read-only audit by an agent with no drafting context; see
  `references/audit.md`.

## Briefing a subagent

The briefing checklist lives in `references/delegation.md`, with the rest of
the delegation guidance. It applies to every spawn, the code waves included.
