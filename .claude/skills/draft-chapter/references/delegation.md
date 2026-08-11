# Delegation

When to hand work to a subagent, which model runs it, and how the team stays
cheap. One file owns everything about the independent audit, including the one
case where it becomes a panel: `references/audit.md`, not this one.

## Contents

- The cost rule
- The budget
- What stays with the orchestrator
- The research pair
- The bibliography agent
- The figure agent
- Model and effort per task
- Briefing a subagent
- Continuing an agent
- Agent definitions
- Agent teams

## The cost rule

A subagent's cost is what it reads. Its context starts empty, so every file,
page and log it needs is paid for from zero. That gives one rule with two
sides:

- Delegate work whose inputs are bulky and disposable: web pages fetched to
  verify a claim, build output read once for a number, an experiment's logs.
  A short-lived subagent pays for that reading once and returns a distilled
  finding, where the same material held in the orchestrator's context is
  re-sent with every turn of a long session, through drafting, commit and PR.
- Keep work whose inputs the orchestrator must hold anyway: the SPEC, the
  prose, the triage of findings. A subagent doing that work re-reads what the
  orchestrator already carries, which is pure added cost.

Before any spawn, ask which side its inputs fall on.

## The budget

Ceilings per session, counting every spawn including the audit:

| Session | Subagents |
|---|---|
| Full chapter with companion code | 4-6 |
| Full chapter, no companion code | 3-4 |
| Revision, or a short chapter | 1 - the auditor only |

Staying under the ceiling is normal. The reason the small session gets one: a
brief that carries enough verified fact to keep an agent from inventing costs
real tokens to assemble, and under a few hundred lines of change the inline
work is cheaper than the briefing.

## What stays with the orchestrator

- Prose and the lab. Splitting sections across agents yields several voices
  to reconcile, which costs more than it saves.
- `SPEC.md`, the research file, commits, and the PR: shared state has one
  writer.
- Triage of audit findings, per `references/audit.md`.
- Compiling. Builds run centrally; see Concurrent builds in
  `references/environment.md`.

## The research pair

Step 1's two directions can run as two background agents while the
orchestrator finishes orienting:

- A web verifier, checking each load-bearing claim against primary sources at
  pinned versions.
- An empirical verifier, building and running the actual thing, because the
  compiler outranks the docs.

Cap it there: one agent per direction, not one per topic. Each returns
findings in one shape - claim, source and pinned version (or the commands
run), how to reproduce, confidence, and any disagreement found between source
and machine. The orchestrator merges what comes back into
`books/<name>/research/` itself; the research file has one writer like any
shared file.

## The bibliography agent

Spawn with the exact citation keys already written into the prose, pasted
into the brief. The agent fetches every URL, checks each byline against the
named-engineer rule (Citations and quoting in `references/house-style.md`),
and writes the chapter's block in `refs.bib`. Afterwards run
`pwsh scripts/check-chapter.ps1 books/<name>` to catch keys that drifted
anyway; see Citation keys in `references/environment.md`.

## The figure agent

The brief names one existing figure by path to read end to end - the idiom
specification, the same argument as the previous chapter for prose - plus the
Figures section of `references/house-style.md`, and the ownership boundary:
`figures/tikz/` only, no building. The orchestrator writes the call site
(`figure` environment, caption, label) in the section file and compiles
centrally.

## Model and effort per task

The tier follows the task difficulty, and each agent definition pins its own,
so a session chooses only for ad-hoc spawns:

- Judgment work inherits the session's model. The auditor exists to catch
  what a cheaper read misses.
- Tool-driven work runs on sonnet. The researcher's and figure agent's
  correctness comes from running things and reading sources, not from depth
  of reasoning.
- Mechanical fetch-and-format work runs on haiku: the bibliography agent.

## Briefing a subagent

Every brief needs all of these, or the agent invents something plausible:

- **Verified facts pasted in**, not referenced. An agent that has to go
  looking will find an old version.
- **An explicit "do not write this API from memory"** wherever the material is
  newer than the model, with the reason: the library shipped after the
  training cutoff.
- **The reference to copy, by path**: the implementation, the idiom figure,
  the file whose shape the output must match.
- **A file-ownership boundary**: exactly which directory it may write to, and
  which paths are off limits.
- **A build instruction**: either "you may build only your own project" or
  "do not build at all, the orchestrator compiles centrally". Two agents
  running a build against the same project will collide on intermediate
  output.
- **A demand to report uncertainty** rather than guessing silently. This is
  the line that surfaces the best findings; agents told to flag doubt have
  reported real API corrections, and one caught an error in the
  orchestrator's own code.

Treat what comes back as a lead, not a verdict. Verify any factual claim from
a subagent the same way you would verify your own.

## Continuing an agent

A follow-up question goes to the agent that did the work - in Claude Code,
SendMessage with that agent's id - so the answer comes from a context that
already holds the reading, instead of a fresh spawn paying for it again. The
one exception is the auditor: never continued, never reused, because a
context with no history is the thing being bought.

## Agent definitions

In Claude Code, spawn `chapter-auditor`, `book-researcher` and
`figure-drafter` by those agent types: their definitions under
`.claude/agents/` carry the standing brief, the tool limits and the model
tier, so a session brief adds only what changes per session - paths, keys,
verified facts. In a runtime without agent definitions, paste the body of the
agent's file into the brief and state its tool limits as instructions.

## Agent teams

Claude Code's experimental agent-teams feature (a shared task list, teammates
messaging each other directly) is a heavier mechanism: every teammate is a
full session. The one shape that might earn that cost is a many-domain
companion-code build whose waves genuinely need to hand work to each other
mid-flight. Until a session actually hits that, the spawn-and-continue
primitives above are the team.
