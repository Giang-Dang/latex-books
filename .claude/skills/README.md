# Skills in this repo

## Owned here

- **draft-chapter** - the writing workflow for books under `books/`. Research,
  companion code, prose, build, SPEC update, commit. Start here.

## Vendored copies

`humanizer` and `skill-conventions` are copies of skills that also exist in a
personal `~/.claude/skills/`. They are checked in so the repo carries its own
dependencies: `CLAUDE.md` requires the humanizer before any book prose is
drafted, and a clone without it silently loses that step.

They are copies, so they can drift from upstream. Refresh with:

```
cp -r ~/.claude/skills/humanizer .claude/skills/humanizer
cp -r ~/.claude/skills/skill-conventions .claude/skills/skill-conventions
```

Review the diff before committing a refresh rather than taking it blind; these
shape how the books read.

If the same skill name exists both here and personally, the project copy is the
one that travels with the repo and is what a fresh clone gets. Prefer editing
the personal copy and refreshing, rather than letting the two diverge in
different directions.

**humanizer** is derived from Wikipedia's "Signs of AI writing", maintained by
WikiProject AI Cleanup; the attribution is in its own file.

## Why these two

- `humanizer` is a hard dependency: `CLAUDE.md` and `draft-chapter` both require
  it before prose is written or reviewed.
- `skill-conventions` is how `draft-chapter` itself gets maintained, so it is
  here for whoever edits that skill next.

Nothing else is vendored. A skill that only helps the person at the keyboard,
rather than the book, belongs in a personal skills directory.
