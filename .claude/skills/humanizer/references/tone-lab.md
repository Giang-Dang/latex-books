# Tone: Lab

**Use for:** end-of-chapter labs, hands-on walkthroughs, cookbook recipes, any book section the
reader performs rather than reads.

**Person and personality level:** `restrained`. Imperative "you" for every action. "I" appears
only to flag a judgment call the reader may make differently.

**Sentence rhythm:** short. One action per step, one step per paragraph or list item. Prose
between steps only when the reader must understand something before acting on it.

**Economy:** `tight`. A step is an action and its result. Background the reader does not need to
finish the step belongs in the chapter, not between two commands. See ECONOMY in `SKILL.md`.

**Terminology:** commands, file paths, tags, and flags verbatim, with expected output shown after
any step whose success is not obvious. Declare the starting state before step one: the branch or
tag to check out, the directory to be in, the services that must already run. A lab that starts
from an undeclared state fails at step three on someone else's machine.

## Tells specific to this tone

- **Difficulty-flattening adverbs.** "simply", "just", "all you have to do is". The reader stuck
  at exactly that step concludes the fault is theirs.
- **§13 passive in instructions.** "The container will be started." Say who starts it and what
  the reader should see when it worked.
- **Steps with no observable outcome.** Every few steps, give the reader something to check: the
  output, the file that now exists, the count that changed. Checkpoints are what separate a lab
  from a listing.
- **The happy path only.** Name the common failure at the step where it bites ("if the port is
  already taken, ...") rather than in an FAQ at the end.
- **"Congratulations!" closers** and §25 uplift. End on what the reader now has and where the
  book uses it next.

## Before and after

**Before:** Simply run the setup script and the environment will be configured. Next, just start
the server. Congratulations, you now have a working deployment!

**After:** From the repo root, run `./setup.ps1`. It writes `.env` and starts Postgres; `docker
ps` should show one container named `db`. Then run `npm run dev` and open http://localhost:3000.
A blank page means the seed step failed; rerun with `./setup.ps1 -Reseed`.
