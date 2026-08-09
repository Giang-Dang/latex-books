# Skills in this repo

This folder is the only tracked copy. `.agents/skills`, for runtimes that look
there instead, is a link to it created by `pwsh scripts/setup.ps1` (a junction
on Windows, a symlink on macOS and Linux) and is gitignored. Edit skills here;
nothing needs mirroring afterwards.

## Owned here

- **draft-chapter** - the writing workflow for books under `books/`. Research,
  companion code, prose, build, SPEC update, commit. Start here.

## Vendored copies

`humanizer`, `humanizer-vi` and `skill-conventions` are copies of skills that
also exist in a personal `~/.claude/skills/`. They are checked in so the repo
carries its own dependencies: `AGENTS.md` requires the humanizer before any book
prose is drafted, and a clone without it silently loses that step. That holds
once per language the library writes in. The English `humanizer` covers English
books and `humanizer-vi` covers Vietnamese ones; a clone that cannot load the
right one for the book in front of it loses the step in exactly the way the
English copy is here to prevent.

They are copies, so they can drift from upstream. Refresh with:

```
cp -r ~/.claude/skills/humanizer .claude/skills/humanizer
cp -r ~/.claude/skills/humanizer-vi .claude/skills/humanizer-vi
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

## Why these are here

- `humanizer` is a hard dependency: `AGENTS.md` and `draft-chapter` both require
  it before prose is written or reviewed.
- `humanizer-vi` is that same dependency for Vietnamese. A book written in
  Vietnamese loads it instead of the English one, not alongside it.
- `skill-conventions` is how `draft-chapter` itself gets maintained, so it is
  here for whoever edits that skill next.

Nothing else is vendored. A skill that only helps the person at the keyboard,
rather than the book, belongs in a personal skills directory.
