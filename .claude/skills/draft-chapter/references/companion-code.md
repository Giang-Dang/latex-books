# Companion code, and delegating the work

How to grow a book's companion repository for a chapter, and how to parallelise
it without the agents colliding.

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

Read the companion repo's `README.md` for its chapter-to-tag table and its
layout conventions before adding anything.

For the federation book's `mosaic-graph`, the layout rule that everything else
depends on is: **one folder per domain, and every field lives in the folder of
the domain that owns it, even when it hangs off a type another domain
declared.** `Product` is a Catalog record, but `Product.price` is a resolver in
`Pricing/Types/`. That is what makes a later extraction a move rather than a
rewrite, and it is worth preserving even when a shortcut is tempting.

Keep dependencies between domains acyclic and one-directional. The domain that
references nobody is the one that can be extracted first.

When a chapter deliberately leaves something naive so a later chapter can fix
it, say so in a code comment as well as in the prose. A future reader of the
repo has no chapter text in front of them.

## The verification gate

Every companion repo should have one command that proves it is good. For
`mosaic-graph` that is `scripts/verify.ps1`, and it must print `PASS` before a
tag is created. It builds in Release with warnings as errors, regenerates the
schema and fails on drift from the committed copy, checks the sample projects
still agree, starts the service, asserts the seeded counts and the lookup
count, and runs the Postman collection through newman.

If a chapter legitimately changes one of those expected numbers, update the
script and say so in the commit message. Never loosen an assertion to make a
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

A pattern that worked for a six-domain service:

- **Shared files stay with the orchestrator**: the entry point, central package
  management, the solution file, the committed schema, `SPEC.md`, all prose.
- **Wave A** - one agent per domain folder, each owning exactly one folder.
  Sequence any domain that others depend on into an earlier wave, or hand the
  dependents its exact contract so they can be written against it.
- **Wave B** - samples, container files, verification scripts, in parallel.
- **Wave C** - research file, bibliography block, figures, in parallel.
- **Final** - one read-only voice-and-rules audit.

## Briefing a subagent

Every brief needs all of these, or the agent invents something plausible:

- **Verified API facts pasted in**, not referenced. An agent that has to go
  looking will find an old version.
- **An explicit "do not write this API from memory"**, with the reason: the
  library shipped after the training cutoff.
- **The reference implementation to copy**, by path, plus the build settings it
  must satisfy.
- **A file-ownership boundary**: exactly which directory it may write to, and
  which paths are off limits.
- **A build instruction**: either "you may build only your own project" or "do
  not build at all, the orchestrator compiles centrally". Two agents running a
  build against the same project will collide on intermediate output.
- **A demand to report uncertainty** rather than guessing silently. This is the
  line that surfaces the best findings; agents that were told to flag doubt
  reported real API corrections, and one caught an error in the orchestrator's
  own code.

Treat what comes back as a lead, not a verdict. Verify any factual claim from a
subagent the same way you would verify your own.
