# Chapter 14 - One Field Fails and the Response Is Empty

Research note for the fifth chapter of part III: what a non-null field costs
when the service behind it is not running.

Web sources accessed **2026-09-05**; everything else was measured on this
machine on the same date.

Five things are worth stating before any of it.

**Chapter 4's rule is necessary and not sufficient, and this chapter is the
amendment.** That rule says a field is non-null only where the value is
guaranteed from data the service owns, in the same process, with a constraint
behind it. `Ratings.Query.ratingCount` met it exactly: a `COUNT` over this
service's own table, which it can always produce. Behind a router it is also a
root field, and the nearest response position above a root field that is
allowed to hold a null is the `data` entry itself. Stop the service and the
whole response is empty, including the half another service answered
correctly.

**The blast radius is a property of the supergraph, not of the service.** The
same C# annotation is a harmless promise in one position and a response-wide
outage in another. What decides it is the distance from the field to the
nearest nullable position above it, and after composition that distance is
measured through types other teams wrote.

**One non-null position in this graph was not written by anybody.**
`AddGlobalObjectIdentification()` generates `Query.node` as `Node` and
`Query.nodes` as `[Node]!`. The nullable item type inside that list protects
nothing, because the router resolves the field as one batched step per owning
subgraph and fails the whole field when one of them is unreachable. Measured:
one dead subgraph named anywhere in the id list empties `data`, while the
singular `node(id:)`, hitting the identical failure, contains it to itself.

**The router's error-shaping configuration does not reach this at all.**
`subgraph_error_propagation` reshapes errors a *responding* subgraph returns
inside its own body. A subgraph that is not running never produces a body to
reshape, so `wrapped` and `pass-through` answer byte for byte the same.

**`@semanticNonNull` is not what the TOC line assumed, and it has moved
twice.** The directive is in no published edition of the specification. Its RFC
is open and stale; the working group that was pursuing it archived itself and
recorded that the work landed on a different proposal, `onError`. Hot Chocolate
16.6.1 has already shipped that unratified proposal's wire shape, and removed
the v15 runtime option that came closest to the directive. What survives under
the directive's name is an export-time rewrite of the printed schema that
changes nothing about execution.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| `wgc` | 0.129.9, `@wundergraph/composition` 0.63.3 |
| Cosmo Router | 0.341.0, go1.26.6 |
| Tags | `ch14` (main, 451), `ch14-nonnull` (449), `ch14-hc14` (216) |

Run `pwsh -NoProfile -File verify.ps1` on each. All three print PASS.

**The databases must be deleted first, and this cost real time.** `verify.ps1`
removes `conference.db`, `speakers.db`, `ratings.db` and `search.db` before it
starts, because `EnsureCreated` seeds an empty database and does nothing to an
existing one, and `rescheduleSession` moves a session's `StartsAt`. The first
measurement pass for this chapter ran against a database an earlier run had
mutated and returned the schedule as speakers `1, 1, 3, 2`, which is not the
`1, 1, 2, 3` decision 101 depends on. Every number below is from the re-run on
a clean seed. A standalone harness that forgets this produces plausible,
reproducible, wrong responses.

**One order caveat, and it is deliberate.** `verify.ps1` runs chapter 4's
mutation block before it reaches the router, so from that point the schedule
order is `Schemas, Reading, The Bank, Paging` and the rating counts are
`3, 2, 0, 1`. The chapter prints the seeded order, `Schemas, Reading, Paging,
The Bank` with counts `3, 2, 1, 0`, which is what a reader gets against a
database that has not had the mutation run against it. The chapter 14
assertions are written against the script's own order and none of the claims
depends on which of the two it is. Chapter 9 carries the same split for the
same reason.

## What was measured

All requests go to the router on 3002. The page is `sessions(first: 10)`, the
four-session page every chapter since 3 has printed.

### The failure, on `ch14-nonnull`, with Ratings stopped

Baseline first, everything running: four sessions, rating counts `3, 2, 1, 0`,
one statement in Sessions and one in Ratings. `{ ratingCount }` answers `6`.

| Request | `data` | errors | Sessions |
|---|---|---|---|
| `sessions(first: 10) { nodes { title averageScore } }` | four titles, `averageScore` null on each | 1 | 1 |
| `sessions(first: 10) { nodes { title ratingCount } }` | `sessions.nodes` is **null** | 2 | 1 |
| `sessions(first: 10) { nodes { title feedbackUrl } }` | `sessions.nodes` is **null** | 2 | 1 |
| `sessions(first: 10) { nodes { title ratingCount } pageInfo { hasNextPage endCursor } }` | `nodes` null, `pageInfo` intact: `hasNextPage` false, `endCursor` `Mw==` | 2 | 1 |
| `sessions(first: 10) { edges { node { title ratingCount } } }` | `sessions.edges` is **null** | 2 | 1 |
| `{ ratingCount }` | **`null`** | 1 | 0 |
| `{ ratingCount sessions(first: 10) { nodes { title } } }` | **`null`** | 2 | **1** |
| `sessions(first: 10) { nodes { title } }` | four titles | 0 | 1 |

The first error is always the fetch failure and carries no `path`:

```
Failed to fetch from Subgraph 'ratings' at Path 'sessions.nodes'.
```

The second is the propagation, and it does carry one:

```
Cannot return null for non-nullable field 'Query.sessions.nodes.ratingCount'.
  path: ["sessions", "nodes", 0, "ratingCount"]
```

At the root field the fetch error drops the path clause entirely,
`Failed to fetch from Subgraph 'ratings'.`, and the propagation names
`'Query.ratingCount'` at path `["ratingCount"]`.

**The last row is the chapter.** `data` is null for the whole response, and
the Sessions service still spent one statement: the four titles were read out
of SQLite, and then discarded because a field belonging to a different service
could not be null. No HTTP status anywhere in this table is anything but 200.

**`edges` bubbles one position higher than `nodes`**, because `SessionsEdge.node`
is `Session!` and absorbs nothing.

**`pageInfo` survives.** It is a sibling of `nodes` under `sessions` and the
climb never reaches their common parent, which is the same shape chapter 4's
figure draws inside one service. The `data` half of that response, which is
what the chapter prints and says it is printing:

```json
{"data":{"sessions":{"nodes":null,"pageInfo":{"hasNextPage":false,"endCursor":"Mw=="}}}}
```

The whole response carries the same two errors as the request without
`pageInfo` on it.

### The generated plural field, on `ch14-nonnull`, with Speakers stopped

`Query.nodes` is `[Node]!`, a non-null list of nullable items.

| Request | `data` |
|---|---|
| `nodes(ids: [<session>, <speaker>])` | **`null`**, one error, no path, no per-item null |
| `nodes(ids: [<session>])` | answers normally |
| `node(id: <speaker>)` | `{"node": null}`, one error, contained |

The item type is nullable and it makes no difference. The router fails the
field, not the entry, and the field's own non-null wrapper carries that to
`data`. The singular field, which is nullable, absorbs the identical failure.

For contrast, in the same state, `sessions(first: 10) { nodes { title speaker
{ name } } }` returns four titles with `speaker` null on each, because
`Session.speaker` is nullable. That request produces **five** errors: the fetch
failure plus one `Cannot return null for non-nullable field
'Query.sessions.nodes.speaker.name'` per row, at paths 0, 1, 2 and 3.

**Chapter 9 prints that response with one error, and that listing is wrong.**
The cold audit caught the contradiction and it resolves against chapter 9.
Measured at tag `ch09` itself, in a throwaway worktree built and composed from
that tag's own three services: five errors, the same five, with a byte
identical `data` half. So it is not a behaviour a later chapter changed; the
listing was trimmed to its first error when it was written. Nothing in either
gate reads an errors array for length, and `check-listings.ps1` compares
whole-file **source** listings rather than printed responses, which is how it
survived. Chapter 14 states the corrected count in section 1 rather than
repeating the claim, `verify.ps1` now asserts the count and the four paths, and
whether to amend chapter 9's own page is recorded as an open item on the same
reasoning decision 96 used for chapter 6.

**An error-count asymmetry worth knowing.** A climb that is contained reports
one propagation error per affected row. A climb that wipes the containing list
reports exactly one, at index 0, however many rows were lost. So the response
that lost four sessions carries fewer errors than the response that lost none.

### The other direction, on `ch14-nonnull`, with Sessions stopped

`SessionSearchDocument.session` is `Session!` and Sessions is what hydrates it.

- `searchSessions(first: 2, order: RATING_DESCENDING) { nodes { session { title } averageScore } }`
  answers `searchSessions.nodes: null`, two errors, and Search still spent its
  one statement computing the ranking that was then thrown away.
- `searchSessions(first: 2, order: RATING_DESCENDING) { nodes { startsAt ratingCount } }`
  answers completely with no error, because nothing in it crosses to Sessions.

### The fix, on `main`

Five fields, and the reasoning differs by position.

| Field | Was | Is | Why |
|---|---|---|---|
| `Ratings.Query.ratingCount` | `Int!` | `Int` | a root field; the position above it is `data` |
| `Ratings.Session.ratingCount` | `Int!` | `Int` | contributed to a type this service does not own |
| `Ratings.Session.feedbackUrl` | `String!` | `String` | the same, and behind `@requires`, so two ways to fail |
| `Search.SessionSearchDocument.session` | `Session!` | `Session` | the router fills this from another service |
| `Query.nodes` (Sessions and Speakers) | `[Node]!` | `[Node]` | generated, and a root field |

Everything else stays non-null and that is the point: `Session.title`,
`Speaker.name`, `SessionSearchDocument.ratingCount` and `startsAt` are all
owned by the service that answers them, with a constraint behind them, and none
of them moved.

The same requests, re-measured with Ratings stopped:

| Request | `data` | errors | Sessions |
|---|---|---|---|
| `sessions(first: 10) { nodes { title ratingCount } }` | four titles, `ratingCount` null on each | 1 | 1 |
| `sessions(first: 10) { nodes { title feedbackUrl } }` | four titles, `feedbackUrl` null on each | 1 | 1 |
| `sessions(first: 10) { edges { node { title ratingCount } } }` | four edges intact | 1 | 1 |
| `{ ratingCount }` | `{"ratingCount": null}` | 1 | 0 |
| `{ ratingCount sessions(first: 10) { nodes { title } } }` | `ratingCount` null **and four titles** | 1 | 1 |

With Speakers stopped, `nodes(ids: [<session>, <speaker>])` now answers
`{"nodes": null}` rather than emptying `data`. With Sessions stopped, the
search page returns two rows carrying `session: null` and their scores,
`4.5` and `4`, rather than an empty list.

Two errors become one in every case. The second error was always the
propagation, and there is no longer anything to propagate.

### `Query.nodes` is generated, so the fix is a type interceptor

`node` and `nodes` are declared in no class, so there is no signature to put a
question mark on. `ObjectFieldConfiguration.Type` is settable on the
configuration a `TypeInterceptor` is handed, and
`TypeReference.Parse("[Node]", TypeContext.Output)` builds the replacement.
`NullableNodesField` is about twenty lines and reaches exactly the one field,
in the same hook `ShareNodeFields` uses to reach the same two fields for
chapter 7's directive. Both subgraphs that export the field carry a copy,
because the composed field would otherwise have two types.

Verified by export: `nodes("The list of node IDs." ids: [ID!]!): [Node] @shareable`
in both `src/Sessions/schema.graphql` and `src/Speakers/schema.graphql`, and
the graph composes unchanged.

**Not established:** whether `AddGlobalObjectIdentification()` has an option
that does this without an interceptor. None was found, and the search was not
exhaustive.

**The half-softened graph composes, and the chapter first said it would not.**
This started as a prediction in the draft, was caught by the cold audit as
unmeasured, and turned out to be wrong. Copy the four current schemas to a
scratch directory, revert only the Speakers one to `[Node]!`, compose at `wgc`
0.129.9: exit zero, nothing printed. And the client schema in the produced
config takes the **nullable** one:

```
  nodes(
    """The list of node IDs."""
    ids: [ID!]!
  ): [Node]
```

So handed two types for one shareable field this composer takes the more
permissive rather than refusing the pair. That is the same shape as decision 73
and decision 88 and it is why the prediction was never safe by analogy. The
book softens both services anyway, because a graph that is correct only because
a composer was lenient breaks on the release where it stops being, and because
the half-softened Speakers subgraph would tell anyone reading its own schema a
different story from the supergraph. `verify.ps1` generates both inputs and
asserts both halves, rather than committing a copy of another service's
exported schema into `graph/` where it would go stale.

### The router's error configuration, at 0.341.0

`router/config.yaml` sets no `subgraph_error_propagation` block, so everything
below is the default. The block name and its keys were confirmed against the
running binary by the refusal-as-probe method chapter 8 established: a config
carrying `subgraph_error_propagation: {bogus_key_xyz: true}` is refused with

```
router config validation error for config.yaml: jsonschema validation failed
- at '/subgraph_error_propagation': additional properties 'bogus_key_xyz' not allowed
```

Keys, from `router/pkg/config/config.schema.json`: `enabled` (deprecated),
`mode` (`wrapped` default, or `pass-through`), `rewrite_paths`,
`attach_service_name`, `default_extension_code`, `allowed_extension_fields`,
`allow_all_extension_fields`, `omit_locations`, `omit_extensions`,
`allowed_fields`, `propagate_status_codes`.

**Measured, and this is the finding: the block does not reach a stopped
subgraph.** With Ratings down, `wrapped` and `pass-through` produce byte
identical responses for both the list request and the root field. The block
only reshapes errors a live subgraph returns in its own body, which was proved
against a request that is refused by chapter 12's guard while the Speakers
service is running:

- wrapped: one outer `Failed to fetch from Subgraph 'speakers'.` carrying
  `extensions.errors` with the originals inside it, plus `serviceName` and
  `statusCode`.
- pass-through: the subgraph's own two errors surface directly, each with its
  `path` and `extensions.code` of `AUTH_NOT_AUTHENTICATED`.

So the `Failed to fetch from Subgraph '<name>'` message is fixed router
behavior and is not configurable through this block.

**Two internal contradictions in the router's own artifacts, recorded and not
printed.** The config schema declares `omit_locations` default `true` while the
router's own documentation page at the same tag says the default is `false`;
and `enabled`'s description reads "(default: false)" above a declared default
of `true`. Neither was isolated behaviorally here, no query in this session
produced a `locations` field to observe, and no chapter states a default for
either. A separate observation that was **not** resolved: `extensions.statusCode`
appeared under a minimal `pass-through` config that never set
`propagate_status_codes`, whose declared default is `false`. Whether the
default is wrong in the schema or the field is populated by another mechanism
was not established, and no chapter claims anything about it.

**Also not established:** the config schema was fetched from the repository's
`main` branch rather than from a file inside the 0.341.0 archive. The key set
is corroborated by the binary refusing an unknown key, so the *keys* are
reliable at this version; the stated *defaults* are not version-pinned.

### `@semanticNonNull` in Hot Chocolate 16.6.1

The flag exists and is export-only. `dotnet run -- schema export --help` on the
Sessions project prints:

```
  --semantic-non-null          Rewrite the exported schema to strip non-null
                               wrappers from output fields and apply the
                               @semanticNonNull directive instead.
```

Running it rewrites every output field on Query-reachable object and interface
types: the `!` comes off and a directive goes on, bare for a singular field and
`@semanticNonNull(levels: [1])` where only the item level of a list was
non-null. The rewritten document appends its own definition,

```
directive @semanticNonNull(levels: [Int!] = [0]) on FIELD_DEFINITION
```

**Two things it does not touch**, both measured rather than inferred from the
flag's name: `Mutation.rescheduleSession: RescheduleSessionPayload!` keeps its
`!`, and argument types such as `ids: [ID!]!` are untouched. It is an output
rewrite of the query side, not a blanket transform.

**It composes.** The four schemas were copied to a scratch directory, the
Sessions one replaced with the rewritten form, and `wgc router compose` run on
them at 0.129.9. Exit zero, nothing said. The directive survives into
`engineConfig.graphqlSchema`, which is what the router serves. **The composer
substitutes its own definition of it**: the merged schema declares
`levels: [Int!]!`, a non-null list, where the subgraph's own document, still
present verbatim in `serviceSdl` beside it, declares `levels: [Int!]`. So
`@wundergraph/composition` 0.63.3 has first-class knowledge of this directive
rather than tolerating it as an unknown one. Cosmo documents the directive with
the stricter signature and gives minimum versions of composition 0.45.0 and
`wgc` 0.93.1, both below what this book pins.

**The API surface, read out of the shipped assemblies by reflection** rather
than from documentation:

- `HotChocolate.Serialization.SchemaFormatterOptions.RewriteToSemanticNonNull`
  is a `bool` **property**, not a method. In `HotChocolate.Types.Abstractions`.
- `HotChocolate.Serialization.SemanticNonNullSchemaRewriter` is a static class
  exposing `public static DocumentNode Rewrite(DocumentNode schema)`. There is
  no method named `RewriteToSemanticNonNull` anywhere in 16.6.1.
- `MapGraphQLSemanticNonNullSchema(...)` exists in
  `HotChocolate.AspNetCore.Pipeline`, defaulting to the route
  `/graphql/semantic-non-null-schema.graphql`.
- `HotChocolate.Language.ErrorHandlingMode`, in `HotChocolate.Language.Web`, is
  an enum with exactly two members: `Propagate = 0` and `Null = 1`. It is read
  off an `onError` property of the request body taking `"PROPAGATE"` or
  `"NULL"`, with a server default at
  `RequestExecutorOptions.DefaultErrorHandlingMode` and an
  `AllowErrorHandlingModeOverride` flag beside it.

That last one matters more than the directive: **Hot Chocolate 16.6.1 has
implemented the wire shape of a specification change that is not merged.**

### On the `hc14` branch

`schema export --help` on 14.3.1 lists `--output` and `--schema-name` and
nothing else. Passing the flag anyway:

```
Unrecognized command or argument '--semantic-non-null'.
```

That is the whole of chapter 14's callout, and `verify.ps1` asserts both
halves: the flag is in the help text on 16 and absent on 14, and the refusal
names it.

**A trap for whoever runs this next:** `dotnet run -- --help` does not print
help at all on either version. It falls through and starts Kestrel. Only
`schema --help` and `schema export --help` work.

## Sources

### The specification

URL: https://spec.graphql.org/September2025/ , fetched 2026-09-05. The current
Latest Release, dated 2025-09-03. Category: the artifact itself, decision 39.

Section **6.4.4, Handling Execution Errors**, carries both sentences the
chapter rests on. The first is already quoted in chapter 4. The second is this
chapter's, and it is the last sentence of the section:

> If every response position from the root of the request to the source of the
> execution error has a Non-Null type, then the "data" entry in the execution
> result should be null.

Verified by extracting the text of the section from the fetched document rather
than by reading a summary of it.

### The RFC, and where the work actually went

All fetched 2026-09-05 with `gh`, so the states are the repository's own
records rather than a page about them. Category: artifact.

- `graphql/graphql-spec` PR **1065**, "RFC: SemanticNonNull type (null only on
  error)", author Benjie Gillam, opened 2023-11-24. State **open**, never
  merged, never closed. Last updated 2026-03-19, and that update is a label
  event: `martinbonnin` applied `stale`. The last substantive comment was
  2025-04-06. The GraphQL project's own RFC tracker at
  https://rfcs.graphql.org/rfcs/wg1410/ puts it at stage **RFC 0, Strawman**
  and records the same stale date.
- `graphql/graphql-spec` PR **1163**, "Error behaviors (including
  `onError: \"NULL\"`)", same author, opened 2025-04-30, updated 2026-09-03.
  Stage **RFC 1, Proposal**.
- `graphql/graphql-spec` PR **1165**, "Add Transitional Non-Null appendix
  (`@noPropagate` directive)", same author, also Strawman, also stalled
  2026-03-19.
- `graphql/nullability-wg`, README fetched raw:
  > As of February, 5th, 2026, this working group is archived.
  and, naming where the work went:
  > Many thanks to everyone who contributed the many discussions and that made
  > it possible to land on the current **service capabilities** + `onError`
  > proposal.

So PR 1065 is simultaneously open and superseded, and the chapter says both
halves rather than only the first. Neither `onError` nor `noPropagate` nor
`semanticNonNull` appears in the September 2025 edition or in the current
working draft; both were searched.

### Michael Staib on Hot Chocolate 16

URL: https://chillicream.com/blog/2026/05/11/hot-chocolate-16/ , fetched
2026-09-05. **Bylined Michael Staib**, dated 2026-05-11, so it clears the
named-engineer bar and the chapter names him. Byline confirmed by fetching the
page directly rather than taking it from a search result.

> With `onError: "NULL"`, Hot Chocolate stops null propagation, returns `null`
> at the field that failed, and still reports the error.

And, pairing the two mechanisms:

> For those clients, you can enable the new error mode on the server and expose
> a `@semanticNonNull` schema. That way the runtime behavior matches the
> semantics the compatibility schema advertises.

### The migration note

URL: https://chillicream.com/docs/hotchocolate/v16/migrating/migrate-from-15-to-16/

Unsigned, and used only for what the software does rather than as an argument,
which decision 39 permits. It records that v15's runtime `EnableSemanticNonNull`
option was **removed** in v16 "in favor of the onError proposal", and that
`DefaultErrorHandlingMode` is what replaces it. This corrects the chapter 4
note, which had the export flag and `ErrorHandlingMode` as two independent
features; they are the replacement for a third that no longer exists.

### Sashko Stubailo on nullability

URL: https://www.apollographql.com/blog/using-nullability-in-graphql ,
**bylined Sashko Stubailo**, 2018-06-05. Clears the bar, and the chapter names
him and the date, because the date is the point: the advice predates federation
and the chapter is about what changes when a router is in the middle.

> I'd suggest making any fields that have resolvers that fetch asynchronous
> data nullable, so that it's easier to deal with errors that result from a
> service or database being unreachable.

### Barred, and why

Apollo's own nullability guide at
https://www.apollographql.com/docs/graphos/schema-design/guides/nullability is
**unsigned** and argues a position, so under decision 39 it cannot be cited as
authority. Recorded here because its position is worth knowing and is not the
chapter's: it declines to give a rule, calling the question case by case and
tied to internal SLAs. The chapter's rule is therefore stated as my judgment
under decision 38, citing nobody, and the fact that Apollo publishes no rule is
part of why.

Benjie Gillam's https://benjie.dev/graphql/nullability is signed and would
clear the bar. Nothing from it is used: it argues for error-handling clients as
the way to keep strict non-null, which is a client-side answer and this chapter
is about the schema. Recorded so a later chapter can pick it up.

## Checked and found false

- **That the nullable item type in `[Node]!` limits the damage.** It does not.
  One unreachable subgraph empties the whole field and, through its non-null
  wrapper, the whole response.
- **That `subgraph_error_propagation` changes what a dead subgraph produces.**
  It does not; `wrapped` and `pass-through` are byte identical there.
- **That the number of errors tracks the number of rows lost.** It is the
  opposite way round in the case that matters: four lost sessions produce one
  propagation error, four surviving ones produce four.
- **That `@semanticNonNull` is a runtime feature in 16.6.1.** It changes the
  printed schema only. The runtime lever with similar intent is
  `ErrorHandlingMode`, and it is a different mechanism reached a different way.
- **That `RewriteToSemanticNonNull` is a method.** It is a `bool` property; the
  rewriter is `SemanticNonNullSchemaRewriter.Rewrite`.
- **That `--semantic-non-null` softens the whole schema.** Mutation root field
  return types and every argument type are untouched.
- **That `dotnet run -- --help` lists the schema commands.** It starts the web
  server instead, on both 16.6.1 and 14.3.1.

## Not established

- Whether `AddGlobalObjectIdentification()` offers an option that makes `nodes`
  nullable without a type interceptor.
- Whether the `omit_locations` and `propagate_status_codes` defaults in the
  router's published config schema match the 0.341.0 binary. The keys are
  confirmed against the binary; the defaults are not, and the schema was read
  from the repository's `main` branch. No chapter states either default.
- Which of Hot Chocolate and Cosmo is right about `@semanticNonNull(levels:)`,
  `[Int!]` against `[Int!]!`. This is the third vendor disagreement in the book
  after decision 73's `@cost` and decision 88's `@provides`, and it is reported
  as a disagreement. Whether the mismatch can be provoked into a failure was
  not tested, because nothing in this book ships the directive.
- What the router does with a semantic-non-null supergraph at run time. The
  composition was measured; no service was ever served from it.
- Whether `ErrorHandlingMode.Null` behaves as Staib describes. It was read out
  of the assembly and not exercised, because the book ships no request that
  sets `onError` and the mechanism is per-request rather than schema-level.
