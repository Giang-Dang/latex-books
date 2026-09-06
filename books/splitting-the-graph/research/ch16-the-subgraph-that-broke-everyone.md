# Chapter 16 - The Subgraph That Broke Everyone

Research note for the seventh chapter of part III: what a schema change costs
the clients already asking, and what any of the checks in this book can see of
it.

Web sources accessed **2026-09-06**; everything else was measured on this
machine on the same date.

Five things are worth stating before any of it.

**This book shipped a breaking change two chapters ago and nothing said a
word.** Chapter 14 took the exclamation mark off five fields, for reasons that
chapter argues at length and that I still think are right. By the only
classification anybody publishes, every one of those five is a breaking change
to a client. Composition wrote a config at exit zero, the router served it, and
`verify.ps1` passed.

**The specification does not define a breaking change.** It never uses the
term as a category, in any edition. The list everything downstream uses is a
sixteen-member TypeScript enum in the reference implementation, and the two
commercial checkers each keep a list of their own on top of it.

**Composition catches the changes that break the composer, and those are a
different set from the changes that break a client.** Fourteen one-line edits
were composed against three unmodified documents. Twelve pass at exit zero
with nothing printed. The two that fail are both about the composer's own
ability to plan a route, and neither of them is a change a client would
notice first.

**Every failure a client sees arrives at HTTP 200.** A field the schema no
longer has, a required argument that was not there yesterday, and a field
that quietly stopped being non-null all come back 200. Two of them carry an
`errors` array and no `data` key at all; the third carries a correct answer
and no signal of any kind.

**The gate both vendors sell is the same gate, and it needs a control plane.**
`wgc subgraph check` and `rover subgraph check` both compare a candidate
schema against the published one and then against recorded client traffic,
both default to a seven-day window, and neither runs without an account.
Cosmo's self-hosted path is documented only as Docker Compose or Kubernetes,
which decision 23 does not have.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| `wgc` | 0.129.9, `@wundergraph/composition` 0.63.3 |
| Cosmo Router | 0.341.0, go1.26.6 |
| Baseline before this chapter | `verify.ps1` PASS on `main`, 493 assertions |
| After this chapter | PASS at 565, tag `ch16` |

**The tag is on a branch and `main` has not moved.** The work is on
`ch16-work` in a worktree, one commit ahead of `main` and a clean
fast-forward, and `ch16` points at it. Moving `main` means writing in that
repository's own checkout, which this session left alone on purpose, so the
fast-forward is the author's and is raised in the pull request. Nothing else
about the tag differs from `ch15`'s.

**One flaky failure worth recording, in chapter 15's block rather than this
one.** A run taken while a book build and a subagent were competing for the
machine returned exit `-1073740791` from `wgc` on the first row of chapter
15's shareable-`node` table, which is a Windows stack-buffer-overrun status
from the tool's own process rather than a composition result. A clean run
minutes later passed the same row. Not reproduced, not investigated, and
recorded here only so that the next person who sees it knows it has happened
once and knows to re-run before believing it.

**The databases must be deleted first**, the trap the chapter 11 open item
records. `verify.ps1` deletes all four before every run. Anything measured
outside it does the same.

**Force UTF-8 before reading `wgc` output from anything but an interactive
console**, decision 127's trap. Every capture below was taken with
`[Console]::OutputEncoding` set to UTF-8, and the box `wgc` draws around an
error is stripped by codepoint afterwards.

### Composing an arbitrary set of documents

Every composition in this chapter is generated into a temporary directory
rather than committed to `graph/`, which is decision 126's reasoning and what
chapter 15 already does: `graph/` holds what `wgc` reads and nothing
generated, and a committed copy of a service's exported schema goes stale the
first time that service changes. The shape is chapter 15's `Invoke-Ch15Compose`:
write N documents plus a `graph.yaml` naming them at ports 5001 to 5004, then

```
wgc router compose -i graph.yaml -o router.json
```

and keep the exit code and the stripped output.

**Normalise every document to LF on the way in.** The working tree is CRLF on
Windows and the replacement patterns are written LF, so a raw read makes every
`.Replace` a silent no-op and every variant composes exactly like the
original. Each variant below was diffed against its unmodified baseline before
being composed, to prove the edit landed.

## What was measured

### 1. Chapter 14's change, as a client sees it

The four documents at tag `ch14-nonnull`, read with
`git show refs/tags/ch14-nonnull:src/<Name>/schema.graphql` (the plain tag
name is ambiguous in this repository, because a branch of the same name exists
beside the tag), against the four on `main` today. **Six lines differ across
the four documents and nothing else does:**

```
--- Sessions ---
<   nodes("The list of node IDs." ids: [ID!]!): [Node]! @shareable
>   nodes("The list of node IDs." ids: [ID!]!): [Node] @shareable
--- Speakers ---
<   nodes("The list of node IDs." ids: [ID!]!): [Node]! @shareable
>   nodes("The list of node IDs." ids: [ID!]!): [Node] @shareable
--- Ratings ---
<   ratingCount: Int!
>   ratingCount: Int
<   ratingCount: Int!
>   ratingCount: Int
<   feedbackUrl: String! @requires(fields: "title")
>   feedbackUrl: String @requires(fields: "title")
--- Search ---
<   session: Session!
>   session: Session
```

Six lines, five fields: `Query.nodes` is declared by two subgraphs and is one
field after composition.

Both sets compose. Exit **0** each, and the whole of what either printed:

```
Router execution config successfully written to ".../router.json".
```

The composed client-facing schema is `engineConfig.graphqlSchema` inside the
written config. Both are **247 lines**. The diff between them:

```
18c18
<   ): [Node]!
---
>   ): [Node]
48c48
<   ratingCount: Int!
---
>   ratingCount: Int
182c182
<   session: Session!
---
>   session: Session
210c210
<   ratingCount: Int!
---
>   ratingCount: Int
212c212
<   feedbackUrl: String!
---
>   feedbackUrl: String
```

Five hunks, five fields, nothing else. With the enclosing type read off the
surrounding lines of the composed document:

| Field | Was | Is |
|-------|-----|-----|
| `Query.nodes` | `[Node]!` | `[Node]` |
| `Query.ratingCount` | `Int!` | `Int` |
| `SessionSearchDocument.session` | `Session!` | `Session` |
| `Session.ratingCount` | `Int!` | `Int` |
| `Session.feedbackUrl` | `String!` | `String` |

**One field that looks like a sixth and is not.**
`SessionSearchDocument.ratingCount` is still `Int!` in the composed schema.
Search owns that column and answers it out of its own projection, so it is not
one of the five and the two fields named `ratingCount` in the supergraph are
not the same field.

**Neither composition said anything about the change, and there is no
mechanism by which it could have.** `wgc router compose` is handed one set of
documents and knows nothing about any other set, so it is not diffing
anything. It also printed no warning in either direction, widening or
narrowing, although `--suppress-warnings` in its own help shows warnings are a
thing it can emit.

**The check moved in the same commit as the change.** Verification repo commit
`56cd6b8`, `ch14: nothing across a seam promises to be there`, is one commit
touching nine source files and `verify.ps1`, and its own message says: *Four
assertions changed rather than loosened, and each is the schema text this
chapter deliberately moves.* That is the reason `verify.ps1` had nothing to
say about a breaking change: the corpus it asserts was edited to match the new
schema at the moment the new schema arrived.

### 2. The classification, and where it actually lives

The GraphQL specification does not define the term. Section 3 of the October
2021 edition, the September 2025 edition and the current working draft were
fetched and read: the word *breaking* appears in the custom-scalar
specification-url paragraph and in the field-deprecation prose, and in neither
place as a definition or a taxonomy.

What defines it is the reference implementation.
`graphql-js` v16.14.2, `src/utilities/findBreakingChanges.ts`, carries a
sixteen-member enum, read out of the raw file:

```
TYPE_REMOVED, TYPE_CHANGED_KIND, TYPE_REMOVED_FROM_UNION,
VALUE_REMOVED_FROM_ENUM, REQUIRED_INPUT_FIELD_ADDED,
IMPLEMENTED_INTERFACE_REMOVED, FIELD_REMOVED, FIELD_CHANGED_KIND,
REQUIRED_ARG_ADDED, ARG_REMOVED, ARG_CHANGED_KIND, DIRECTIVE_REMOVED,
DIRECTIVE_ARG_REMOVED, REQUIRED_DIRECTIVE_ARG_ADDED,
DIRECTIVE_REPEATABLE_REMOVED, DIRECTIVE_LOCATION_REMOVED
```

and a six-member `DangerousChangeType` beside it (`VALUE_ADDED_TO_ENUM`,
`TYPE_ADDED_TO_UNION`, `OPTIONAL_INPUT_FIELD_ADDED`, `OPTIONAL_ARG_ADDED`,
`IMPLEMENTED_INTERFACE_ADDED`, `ARG_DEFAULT_VALUE_CHANGE`).

Chapter 14's change is `FIELD_CHANGED_KIND`. The deciding function, read line
by line rather than summarised:

```ts
if (isNonNullType(oldType)) {
  // if they're both non-null, make sure the underlying types are compatible
  return (
    isNonNullType(newType) &&
    isChangeSafeForObjectOrInterfaceField(oldType.ofType, newType.ofType)
  );
}
```

Old is `NonNull(String)`, new is not non-null, so the conjunction fails, the
change is not safe, and `findFieldChanges` pushes `FIELD_CHANGED_KIND`. The
comment further down says the reverse plainly: *moving from nullable to
non-null of the same underlying type is safe.*

**The rule is the other way round for an argument**, in the same file, in
`isChangeSafeForInputObjectFieldOrFieldArg`: *moving from non-null to nullable
of the same underlying type is safe.* An output field that stops promising is
breaking; an argument that stops demanding is not.

**Checked and found false.** A summarising fetch of the same file reported
that converting non-null to nullable is safe for object and interface fields.
That is the exact opposite of what the source does. It was caught only by
reading the raw file, and it is recorded here so that nobody re-derives the
wrong version from a summary.

**Version drift worth knowing.** At `graphql-js` v17.0.2 the file is gone and
the logic is folded into `src/utilities/findSchemaChanges.ts` under one
function, with a third category, `SafeChangeType`, that did not exist in v16
(safe changes were simply not reported). The breaking members this chapter
names are identical in both.

### 3. Fourteen edits, and which two the composer refuses

Each row is one change to one document, with the other three unmodified,
composed as a four-subgraph graph. Every diff was checked before composing.

| # | Change | Composition |
|---|--------|-------------|
| a | remove `Query.sessionById` and its `@deprecated` block, Sessions | exit 0 |
| b | remove `Session.abstract`, Sessions | exit 0 |
| c | rename `Session.title` to `Session.name`, Sessions | **exit 1** |
| d | `Session.title` `String!` to `String`, Sessions | exit 0 |
| e | `Session.durationMinutes` `Int!` to `Int`, Sessions | exit 0 |
| f | `Query.sessions` gains a required `track: String!` | exit 0 |
| g | `sessionById(id: Int!)` to `sessionById(id: ID!)` | exit 0 |
| h | remove `Session.startsAt`, Sessions | exit 0 |
| i | `@key(fields: "id")` to `@key(fields: "id title")`, Sessions | **exit 1** |
| j | remove `Speaker.bio`, Speakers | exit 0 |
| k | `Speaker.name` `String!` to `String`, Speakers | exit 0 |
| l | `Session.averageScore` `Float` to `Int`, Ratings | exit 0 |
| m | remove `Session.ratingCount`, Ratings | exit 0 |
| n | remove `Query.searchSessions`, Search | exit 0 |

Twelve of fourteen compose, and each of the twelve printed the one success
line and nothing else. **All twelve are on the `graphql-js` breaking list**:
a, b, h, j, m and n are `FIELD_REMOVED`; d, e, k and l are
`FIELD_CHANGED_KIND`, l because the named type changed and the other three for
the same reason chapter 14's five are; f is `REQUIRED_ARG_ADDED`; and g is
`ARG_CHANGED_KIND`.

**Row g was classified wrongly at first and the correction is worth keeping.**
A first pass called it "arguably safe, and only for a client sending a
literal", which is two errors in one clause. The classification is not a
judgment call: `findArgChanges` runs
`isChangeSafeForInputObjectFieldOrFieldArg(Int!, ID!)`, both sides are
non-null so it recurses to `Int` against `ID`, the two named types differ, and
nothing in that function makes a change between different named types safe. It
reports `ARG_CHANGED_KIND`. And the runtime intuition behind the clause runs
the other way from how it was written: the specification's `ID` accepts an
integer input, so a client sending the literal `sessionById(id: 1)` is the one
that survives, while a client that declared `$id: Int!` fails variable-usage
validation against a location typed `ID!`. **Neither runtime half was measured
here**, and no chapter claims either: the chapter names the category, says a
reader will want to argue that it is harmless, and points at Apollo's own
concession that a check reports it as breaking because validation cannot
establish that it is not. Whoever picks this up should serve the row-g graph
and send both forms before the book says anything about run time.

**Two composed results read back out of the config**, because the chapter
prints them. Row f writes `sessions(track: String!, first: Int, after: String,
last: Int, before: String): SessionsConnection` into the composed schema, the
new argument first because that is where the edit inserted it. Row h removes
`startsAt` from the merged `Session` entirely, leaving only the two unrelated
fields of that name, on `RescheduleSessionInput` and on
`SessionSearchDocument`.

**Row h was pre-checked**, because removing a field another subgraph depends
on would fail for a different reason. `startsAt` appears three times across
the four documents: `Session.startsAt` in Sessions, `RescheduleSessionInput
.startsAt` in the same document, and `SessionSearchDocument.startsAt`, which
Search declares and owns. No `@key` and no `@requires` anywhere names it. The
composition confirms it: the merged `Session` in the composed schema simply
has no `startsAt` on it.

**Row c**, the rename, fails for the far end rather than the near one:

```
The Object "Session" is invalid because the following field definition is declared "@external" on all instances of
that field:
 "title" in subgraph "ratings"
At least one instance of a field definition must always be resolvable (and therefore not declared "@external").
```

Ratings declares `title: String! @external` so that `feedbackUrl` can
`@requires` it. Rename the Sessions copy and the `@external` declaration is
suddenly the only declaration of a field of that name, which the composer
refuses categorically. The message is not about the `@requires` selection set
and not about the rename.

**Row i**, widening the key, fails somewhere else again. Ratings still
declares `@key(fields: "id")` on its own `Session`, so it can no longer
satisfy the stricter key, and the route Search had into Sessions-owned fields
through Ratings is severed. Four errors, one per orphaned field, `speaker`,
`abstract`, `startsAt` and `durationMinutes`, each in the shape chapter 15
prints, naming `search` as the root and `ratings` as the entity ancestor:

```
 - The entity ancestor "Session" in subgraph "ratings" does not satisfy the key field set "id title" to access subgra
```

**That line is truncated by `wgc` itself.** The box is a fixed 120 columns and
elides mid-word rather than wrapping, exactly as decision 134 recorded for a
different sentence in the same family, and setting `COLUMNS=300` does not
widen it. `wgc router compose` has no `--json` and no machine-readable output,
so there is no lossless way to recover the sentence. It reads as *to access
subgraph "sessions"*, and that reading is by sense rather than verified byte
for byte. **No chapter quotes this line.**

**Neither refusal is about a client.** Both are the composer failing to build
a servable graph, which is the only question it asks. And a reader predicting
from first principles which two of the fourteen would fail, and why, would
likely get both explanations wrong.

**A bare scalar change gets the same silence as a nullability change.** Row l
changes `averageScore` from `Float` to `Int`, which is a different type and
not a widening, and the composer treats it exactly like row d.

### 4. What a client gets

The four services unmodified and running, the router started against a
generated config. **No service changed for any of this**, which is the point
worth recording: for rows a and f the router refuses the request against its
own copy of the composed schema and never asks anybody, so the entire failure
lives in the document the composer read.

Row a, the deprecated field removed, and a client still sending it:

```
{ sessionById(id: 1) { title } }
```

```
HTTP/1.1 200 OK
{"errors":[{"message":"Cannot query field \"sessionById\" on type \"Query\".","path":["query"]}]}
```

Row f, the new required argument, and the query this book has printed since
chapter 3:

```
{ sessions(first: 10) { nodes { title } } }
```

```
HTTP/1.1 200 OK
{"errors":[{"message":"argument: track is required on field: sessions but missing","path":["query"]}]}
```

Row d, `title` gone nullable, and the same query:

```
HTTP/1.1 200 OK
{"data":{"sessions":{"nodes":[{"title":"Schemas That Outlive Their Authors"},{"title":"Reading a Query Plan"},{"title":"Paging Without Offsets"},{"title":"The Bank That Split Its Graph"}]}}}
```

Byte for byte the answer the unchanged graph gives, because every row in this
seed has a title.

**A trap that cost a failing assertion, and it is the chapter 11 open item
from the inside.** That capture is in seeded order, taken on a fresh graph
with no mutation sent, which is the state a reader typing the book out is in
and the order chapters 3 and 14 print. Inside `verify.ps1` it is not:
chapter 4's `rescheduleSession` block runs long before chapter 16's and moves
a session, so the schedule there reads `1, 1, 3, 2`. A literal list of the
four titles asserted the seed and failed against the graph. The open item's
rule is that anything measuring **outside** `verify.ps1` deletes the databases
first; the other half, now recorded, is that anything asserting inside it
after the chapter 4 block is looking at a moved schedule. The assertion was
changed to the thing the chapter actually claims: the softened field answers
what the subgraph answers in the same breath, which is true in either state
and is the claim rather than a restatement of chapter 3.

Introspecting the field confirms the schema moved:
`title` comes back `{"kind":"SCALAR","ofType":null,"name":"String"}`, where
`id`, `startsAt` and `durationMinutes` in the same response still come back
`NON_NULL` with the named type under `ofType`. **Nothing at any point
announces it.** Not the composition, not the router at startup, not the
request, not the router's log. A client that generated its types from the old
schema and never introspects again keeps trusting a guarantee the graph
stopped making, and nothing fails until a row actually has a null title.

**Both refusals are validation, before planning.** Against the healthy graph,
an unknown field:

```
{ sessions(first: 10) { nodes { nonexistentField } } }
```

```
HTTP/1.1 200 OK
{"errors":[{"message":"Cannot query field \"nonexistentField\" on type \"Session\".","path":["query","sessions","nodes"]}]}
```

and a required argument omitted, `{ node { id } }`:

```
HTTP/1.1 200 OK
{"errors":[{"message":"argument: id is required on field: node but missing","path":["query"]}]}
```

Both 200, both with an `errors` array and no `data` key at all, not even
`"data": null`.

**And the status code moved when the router arrived.** Found while writing the
assertions rather than in the measurement pass, and it sharpens the section.
Chapter 2 sends `{ sessions { titel } }` straight to the Sessions service, and
`verify.ps1` has asserted since that chapter that Hot Chocolate answers **400**
for a validation error, with the specification url in its `extensions`. The
same class of mistake sent to the same service on port 5001 today still
answers 400. Through the router it is a 200 carrying a `path` and nothing
else. Same graph, same mistake, two status codes, decided by which process the
request reached. Both halves are now asserted together in the chapter 16 block
rather than left one chapter apart.

**Not established at code level:** that validation precedes
planning was inferred from the router's own request log, where the invalid
requests are three orders of magnitude faster than a healthy `sessions` page
and no subgraph logs anything during them, rather than from reading
`graphql-go-tools`. The chapter says the two things that were measured, that
the request is refused and that no subgraph is asked, and does not describe
the router's internal order. **This book prints no timings** under decision
19, so the latency evidence stays in this note.

### 5. The gate, and what it needs

`wgc subgraph check` with no `wgc auth login` performed:

```
Organization slug is not set. Please run `wgc auth login` to set the organization slug.
```

Exit **1**. The same message and the same exit code from `wgc subgraph fix`,
from `wgc federated-graph check` and from `wgc proposal create`. Its own help
text says what it is: *Checks for breaking changes and composition errors
across all connected federated graphs*, and knowing what is connected is what
a control plane is for. The two options that matter here, verbatim from that
help:

```
  --skip-traffic-check                This will skip checking for client
                                      traffic and any breaking change will fail
                                      the run.
```

Cosmo's own documentation for the feature says what the traffic is and where
it comes from: *This is done by sending schema usage traffic to Cosmo Cloud
from your routers. If you propose a breaking change and no active clients use
the affected schema changes the check will pass*, and *By default operation
checks look at the client traffic of the last 7 days to validate if a breaking
change can be safely published, however, this can be configured using the
namespace Policies*, which is where the chapter's clause about the window
being a namespace setting comes from. And a limit worth
knowing given how much of this book's graph is directives: *Currently, we do
not track the usage of directives. This means that changing or deleting
directives will always be detected as a non-breaking change, even if clients
are using them.*

**`wgc router compose` is the only command in the CLI that runs with no
control plane**, and its own help says so: *This makes it easy to test your
router without a control-plane connection.* It has no concept of a previous
version, so it cannot diff. Every other check-shaped subcommand was tried
directly and refused for want of an organization slug.

**Self-hosting the control plane is documented as containers only.**
WunderGraph's self-hosted page offers Docker Compose for a local machine and
Kubernetes with a Helm chart for production, and the component list is a
Node.js control plane, PostgreSQL, Redis, ClickHouse, an S3-compatible store,
Keycloak with its own PostgreSQL, a CDN server, an OTEL collector and a
metrics collector. The page's own front matter promises *Docker, Kubernetes,
VMs, or Bare Metal* and the body gives instructions for the first two only.
**Not established:** whether a bare-metal path works. Nothing documents one,
which is a different statement from it being impossible.

**Apollo's is the same shape.** `rover subgraph check` needs a graph ref, a
published schema and an API key; its lifecycle documentation says GraphOS
diffs the local schema against the published one and then checks the diff
against operations executed *within a customizable time window (by default,
this is the last seven days)*. Two facts from its reference page are worth
more than the mechanics. Its categories are keyed to usage rather than to
shape, so `FIELD_REMOVED` is defined as *A field used by at least one
operation was removed*. And it concedes its own imprecision: *In some cases,
in-place updates are compatible with affected clients at runtime (such as a
type rename or a conversion from an object to an interface that uses the same
fields). However, schema checks still marks these as breaking changes, because
validation does not have enough information to ensure that they are safe.*
There is also a ceiling: *Operations checks run against a maximum of 10,000
distinct operations.*

### 6. The gate this book can build, run twice

Two compositions and a diff, which is section 1 of this note performed as a
procedure rather than as an experiment: compose the four published documents,
compose the four candidate documents, pull `engineConfig.graphqlSchema` out of
each config, and diff. Both compositions exit 0 and the diff is the report.
That is the whole of what a graph with no control plane gets for free, and it
answers the shape question and not the usage question.

The usage half is `verify.ps1` itself, and its limit is the one section 1
records: it is a corpus of operations maintained by the same people who change
the schema, in the same commit.

### 7. Root fields, for the last section

Read out of `engineConfig.graphqlSchema` in the current healthy config.
`type Query` carries **seven** fields and `type Mutation` carries **one**:

| Root field | Declared by |
|------------|-------------|
| `node` | `sessions` and `speakers` |
| `nodes` | `sessions` and `speakers` |
| `sessions` | `sessions` |
| `sessionById` | `sessions` |
| `speakers` | `speakers` |
| `ratingCount` | `ratings` |
| `searchSessions` | `search` |
| `rescheduleSession` (Mutation) | `sessions` |

Confirmed against the `rootNodes` entries in each datasource configuration:

```
sessions: {"typeName":"Query","fieldNames":["node","nodes","sessions","sessionById"]}, {"typeName":"Mutation","fieldNames":["rescheduleSession"]}
speakers: {"typeName":"Query","fieldNames":["node","nodes","speakers"]}
ratings:  {"typeName":"Query","fieldNames":["ratingCount"]}
search:   {"typeName":"Query","fieldNames":["searchSessions"]}
```

Four teams, one `Query` type, and one of the seven is already retired in name
only.

## Sources

**`graphql-js`, `src/utilities/findBreakingChanges.ts`, v16.14.2.**
`https://raw.githubusercontent.com/graphql/graphql-js/v16.14.2/src/utilities/findBreakingChanges.ts`,
2026-09-06. Cited under decision 39 as the artifact: it is where the list is
defined, and the specification defines none. Read raw; see the corrected
summary above.

**GraphQL specification, Section 3, three editions.**
`https://raw.githubusercontent.com/graphql/graphql-spec/{October2021,September2025,main}/spec/Section%203%20--%20Type%20System.md`,
2026-09-06. Fetched to establish an absence: no definition of a breaking
change in any of them. Also confirms a real edition difference the book does
not currently need: October 2021 allows `@deprecated` on `FIELD_DEFINITION`
and `ENUM_VALUE` only, and September 2025 widens it to arguments and input
fields and makes `reason` non-null with a default. Chapter 4 already cites
this edition for the advisory clause and does not need amending.

**Cosmo, Schema Checks.**
`https://cosmo-docs.wundergraph.com/studio/schema-checks`, 2026-09-06.
Unsigned, admitted under decision 39 as a vendor documenting what its own tool
does. Cited for the traffic source, the seven-day default and the untracked
directives.

**Cosmo, self-hosted.** `https://cosmo-docs.wundergraph.com/self-hosted`,
2026-09-06. Same footing. Cited for nothing in the chapter directly; it is
what the claim about containers rests on.

**Apollo, Schema Checks Reference.**
`https://www.apollographql.com/docs/graphos/platform/schema-management/checks/reference`,
2026-09-06. Unsigned, same footing. Cited for the sentence conceding that some
safe in-place updates are reported as breaking anyway.

**Apollo, running schema checks.**
`https://www.apollographql.com/docs/graphos/platform/schema-management/checks/run`,
2026-09-06. Same footing. The prerequisites and the seven-day window.

**Nikhil Patel, Whatnot, *Eliminating GraphQL Schema Bloat with AI (So You
Don't Have To)*, 2025-11-18.** Bylined by a named engineer at the company
being described, which is what the Sources rule asks. Medium refused both a
direct fetch and a raw request from this machine, so the text is the Wayback
snapshot of 2026-07-14 and the byline was read inside that snapshot rather
than off the publication's meta tag, which credits only the publication.
Quoted for two things: *over 2,600 unused fields, including nearly 200 root
queries and mutations*, and *older versions of our mobile apps may still call
queries that have long been removed from the main branch, and admin tooling
dashboards often execute queries entirely outside our primary repositories.
That means static analysis can't tell the whole story.*

**Stefan Avram, WunderGraph, *A Comprehensive Overview of GraphQL Federation
in Open Source*.** `https://wundergraph.com/blog/a-brief-overview-of-open-source-graphql-federation`,
2026-09-06. Byline read out of the page's JSON-LD: co-founder of WunderGraph.
Passes the vendor rule, and the chapter says who he is and what he sells,
because the sentence quoted argues for the product he sells: *The scariest
failure mode is the breaking change - a field removed, a type renamed, an
argument made required - that slips into production and takes a client app
down with it.*

### Checked, and not used

**No published account of a federated-graph outage caused by a breaking
change.** Searched for bylined engineering write-ups from Netflix, Expedia,
Airbnb, Shopify and GitHub under several phrasings and found none. So the
chapter's claim that this is the largest availability risk in a federated
graph is stated as my judgment under decision 38, with Avram named as an
interested party who says the same thing, rather than presented as consensus.

**Christian Ernst, Booking.com, *Improving GraphQL Federation Resiliency:
Investigating Failed Schema Updates*, 2022-10-24.** Bylined and real, and
about the wrong thing: it is Apollo's managed-federation Uplink failing to
hand a current schema to gateway processes, which is a schema *distribution*
availability problem rather than a breaking-change one. The word *breaking*
does not appear in it. Recorded because the two are easy to conflate and the
next session looking for this material will find this article first.

**Apollo, *Demand Oriented Schema Design*.** Argues the chapter's thesis about
schema shape and is unsigned vendor prose arguing an outcome, which decision
39 bars. Not cited. The same applies to the Principled GraphQL *Agility* page
it rests on, which was not separately checked for a byline.

**Marc-Andre Giroux on schema shape.** His 2018 Apollo guest post, bylined and
usable, warns against autogenerating a schema from a REST API but does not
make the claim this chapter needs about a schema nobody can retire. His 2019
post *Careful about the GraphQL Burger* is adjacent and also not it. A talk
deck of his appears to be closer, and its text could not be verified
slide by slide, so nothing from it is used.

## What this chapter did not establish

- **Whether the router validates before planning at code level.** Inferred
  from latency and from subgraph silence, not read out of
  `graphql-go-tools`. The chapter claims only what was measured.
- **The elided characters in `wgc`'s truncated resolvability line for row i.**
  The box is fixed width, there is no machine-readable output, and no chapter
  quotes the line.
- **Whether Cosmo's control plane can be self-hosted without containers.**
  Nothing documents a path. Absence of documentation is not a measurement.
- **What Cosmo's schema check actually reports for chapter 14's five fields.**
  It was never run against a control plane, because this book has none. The
  claim the chapter makes is about what the command needs, which is measured,
  not about what it would say.
- **Whether any Hot Chocolate mechanism exports a schema diff.** Not looked
  for. It would be a subgraph-local answer to a supergraph-wide question, and
  the chapter's gate is built at the composed schema instead.
