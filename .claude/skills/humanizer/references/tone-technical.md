# Tone: Technical

**Use for:** README, API docs, ADR, runbooks, pull request descriptions, long commit messages,
code comments.

**Person and personality level:** `none`. The subject is the system for what it does, and "you"
for what the reader does. No "we". No first person at all.

**Sentence rhythm:** short, roughly eight to twenty words, one idea per sentence. Write steps as
direct imperatives: "Run `npm ci` before building."

**Terminology:** reproduce command names, flags, environment variables, and file paths verbatim.
Never paraphrase an identifier the reader will have to type.

## Tells specific to this tone

- **§30 bites hardest here.** Documentation written as a diff narration: "This function was added
  to replace the previous approach." Docs must read coherently without knowing the last commit.
  Changelogs, release notes, and migration guides are the exceptions, since they are version-scoped
  by definition.
- **§13 subjectless fragments.** "No config file needed." "Handled automatically." Name the actor.
- **§4 in its docs dialect:** powerful, seamless, blazing-fast, robust, lightweight, battle-tested,
  production-ready. Docs say what the thing does; they do not sell it.
- **§16 bullets that restate their own header.** `**Performance:** Performance has been improved.`
- **Restating what the environment already says.** A flag list that duplicates `--help`, a scripts
  table copied out of `package.json`. Documentation earns its keep on what a reader cannot look up:
  why a choice was made, the convention nobody wrote down, the gotcha no config file confesses.

## Before and after

**Before:** This powerful, lightweight middleware was added to replace the previous approach of
parsing the body on every request, which was slow. Configuration is handled automatically. No
config file needed.

**After:** The middleware parses the request body once and caches it on the request object, so
downstream handlers do not parse it again. You do not need a config file.
