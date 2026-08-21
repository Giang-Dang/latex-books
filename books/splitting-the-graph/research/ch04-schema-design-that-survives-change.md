# Chapter 4 - Schema Design That Survives Change

Research note for the chapter that puts every entity behind a global node id,
deprecates the field that id replaces, adds the book's first mutation, and
takes the first pass at nullability. Web sources accessed **2026-08-21**;
everything else was measured on this machine on the same date.

Unlike chapters 2 and 3, this one leans on published specifications as well as
on the compiler, because three of its four subjects have normative text behind
them: the Relay object identification specification, the GraphQL
specification's rule on deprecating a required argument, and the GraphQL
specification's rule on how a null propagates out of a non-null position. Each
of those is quoted below from the document itself rather than from a
description of it, and each was then checked against what the machine actually
does. They agreed everywhere the chapter relies on them, which is worth
recording because chapters 2 and 3 mostly recorded the opposite.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| Tags this chapter uses | `ch04` (branch `main`), `ch04-orphan`, `ch04-hc14` (branch `hc14`) |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| EF Core on `main` | 10.0.11 |
| EF Core on `hc14` | 9.0.19 |
| Gate | `pwsh verify.ps1`, run on each of the three branches. All printed PASS on 2026-08-21 |

| Tag | Branch | What it is | What its `verify.ps1` asserts |
|-----|--------|-----------|-------------------------------|
| `ch04` | `main` | the finished chapter | 96 assertions: the generated schema shapes, the two node id strings and what they decode to, the statement counts, the deprecation, and all three mutation outcomes |
| `ch04-orphan` | `ch04-orphan` | `speaker: Speaker!` with a session pointing at a speaker who does not exist | 16 assertions: the CS8603 the compiler emits, the emptied `nodes` list, the error path, and which sibling fields survive |
| `ch04-hc14` | `hc14` | the same source on 14.3.1 | the same 96 assertions, from the same script |

**No new package.** `HotChocolate.Types.Mutations` and
`HotChocolate.Types.Errors` both arrive transitively through
`HotChocolate.AspNetCore`, confirmed with
`dotnet list package --include-transitive`. `Sessions.csproj` is unchanged from
chapter 3, so the chapter prints no project file.

## Global object identification

### What the specification requires

Source: **GraphQL Global Object Identification Specification**,
<https://relay.dev/graphql/objectidentification.htm>, fetched 2026-08-21. The
document names no author or organisation. It is cited under SPEC decision 39 as
a specification's publisher defining that specification, which is the artifact
rather than a claim about the artifact.

> The server must provide an interface called `Node`. That interface must
> include exactly one field, called `id` that returns a non-null `ID`.

> The server must provide a root field called `node` that returns the `Node`
> interface. This root field must take exactly one argument, a non-null ID
> named `id`.

**Checked and found false: the specification does not require base64, and does
not use the word "opaque".** Both words were searched for in the fetched
document and neither appears anywhere in it. What it requires is global
uniqueness and refetchability. The base64 encoding and the opacity contract are
conventions that grew up around the specification rather than requirements in
it, and the chapter says so rather than attributing the convention to the
document. A separate, newer Relay documentation page does describe base64 as
"a useful convention in GraphQL to remind viewers that the string is an opaque
identifier"; that page is not the specification and is not cited.

The plural field is also not mandated by name. The specification generalises to
"plural identifying root fields" without naming one; `nodes` is Hot
Chocolate's choice.

### What Hot Chocolate 16.6.1 does

Three changes, and none of them touches an entity type:

- `Program.cs` gains `.AddGlobalObjectIdentification()` on the builder.
- `SessionType` gains a static method carrying `[NodeResolver]`.
- A new `SpeakerType` carries nothing but a `[NodeResolver]` method.

That is enough to rewrite `id: Int!` to `id: ID!` on both types, add
`implements Node` to both, define `interface Node { id: ID! }`, and add both
root fields:

```
node("ID of the object." id: ID!): Node @cost(weight: "10")
nodes("The list of node IDs." ids: [ID!]!): [Node]! @cost(weight: "10")
```

**No `[ID]` attribute is needed on the entity's own id property.** The node
resolver is what makes the type a node, and being a node is what rewrites the
id field. `[ID<T>]` is needed only where a value that is not an entity's own id
field has to become one; the chapter uses it twice, on the mutation argument
and on the error types' id properties.

**A field moved.** `Session.id` is now the first field in the exported type,
ahead of `speaker`. In chapter 3's export it came after. Nothing in the source
changed its position, so this is the node machinery ordering the id field
first. Field order carries no meaning in GraphQL and no client can depend on
it, so no chapter claims anything about it; recorded so that a diff of the two
exports does not read as a defect.

### The id strings, measured

Read off a live response on 2026-08-21, and asserted by `verify.ps1` on both
`main` and `hc14`:

| Entity | `id` in the response | Base64-decodes to |
|--------|----------------------|-------------------|
| session 1 | `U2Vzc2lvbjox` | `Session:1` |
| speaker 1 | `U3BlYWtlcjox` | `Speaker:1` |

The bytes behind `U2Vzc2lvbjox` are `83 101 115 115 105 111 110 58 49`, which
is `Session:1` in ASCII with no framing of any kind. The format is the type
name, a colon, and the underlying key.

**The two versions agree byte for byte.** 14.3.1 and 16.6.1 produce the same
string for the same entity, measured on both branches. This is the chapter's
callout: a client holding cached ids across a 14-to-16 upgrade keeps them.
Bounded to those two versions, because Hot Chocolate 16 also ships
`AddLegacyNodeIdSerializer()` and a `NodeIdSerializerOptions.OutputNewIdFormat`
flag, which is evidence that some earlier version emitted something else. Which
version, and what it emitted, was **not** established, and no chapter claims
anything about it.

### Statement counts

| Request | Statements |
|---------|-----------|
| `node(id:)` for one session | 1 |
| `nodes(ids:)` for one session and one speaker | 2 |
| `sessions(first: 10) { nodes { id title speaker { id name } } }` | 2 |

The single `node` costs one statement and the projection still applies, because
`SessionType`'s node resolver takes a `QueryContext<Session>` exactly as
chapter 3's `sessionById` does. The statement it issues is
`SELECT "s"."Id", "s"."Title" FROM "Sessions" AS "s" WHERE "s"."Id" = @id LIMIT 1`
for a query asking only for `title`.

`nodes` is one statement per id and batches nothing across the two, which is
the number the chapter prints. The speaker half of that pair goes through
chapter 3's DataLoader and so arrives as a batch of one:
`WHERE "s"."Id" = @ids1`.

### What a bad id does, measured

Three cases, all measured on 2026-08-21 and all asserted:

1. **A string that is not a node id**, passed to `node(id:)`. HTTP **200**,
   `data.node` is `null`, and one error:

   ```
   {"errors":[{"message":"The node ID string has an invalid format.",
   "path":["node"],"extensions":{"originalValue":"not-an-id"}}],
   "data":{"node":null}}
   ```

2. **The same bad value inside an input object**, as `RescheduleSessionInput.sessionId`.
   HTTP **400**, and no `data` key at all. Same message, and it is raised at
   variable coercion rather than during execution:

   ```
   {"errors":[{"message":"The node ID string has an invalid format.",
   "extensions":{"originalValue":"2"}}]}
   ```

   The value sent was the string `"2"`, which is a legal `ID` as far as the
   scalar is concerned and not a legal node id. The 200-versus-400 split is the
   interesting half: the same malformed value is an execution error in one
   position and a request-level failure in the other.

3. **A well-formed id of the wrong type**: a speaker's id passed to `node(id:)`
   under a `... on Session` fragment. HTTP 200, **no error at all**, and the
   response is `{"data":{"node":{"__typename":"Speaker"}}}`. The fragment does
   not match, so it contributes nothing, and the client gets an object with
   none of the fields it asked for. This is the failure mode worth the prose:
   the two ids that were both `1` before this chapter are now distinguishable,
   and mixing them up is silent rather than loud.

On 14.3.1 case 1 carries an extra `"locations":[{"line":1,"column":21}]` key
that 16.6.1 does not. Chapter 2 already prints a 16 validation error that
*does* carry `locations`, so this is a difference in this one error rather than
a general one, and no callout is spent on it.

## Deprecation

### What the specification says

Source: **GraphQL specification, September 2025 edition**,
<https://spec.graphql.org/September2025/>, fetched and searched 2026-08-21.
This is the edition the running service already names: the `specifiedBy` URL in
chapter 2's validation error points at `September2025`.

Section 3.13.3 gives the directive's locations as `FIELD_DEFINITION`,
`ARGUMENT_DEFINITION`, `INPUT_FIELD_DEFINITION` and `ENUM_VALUE`, then the rule
this chapter rests on:

> The `@deprecated` directive must not appear on required (non-null without a
> default) arguments or input object field definitions.

> To deprecate a required argument or input field, it must first be made
> optional by either changing the type to nullable or adding a default value.

Section 3.6.2, on field deprecation:

> Fields in an object may be marked as deprecated as deemed necessary by the
> application. It is still legal to include these fields in a selection set (to
> ensure existing clients are not broken by the change), but the fields should
> be appropriately treated in documentation and tooling.

### What the machine does with it

`[GraphQLDeprecated("...")]` on a resolver method emits
`@deprecated(reason: "...")` on the field. Measured, and asserted.

**The required-argument rule is enforced at schema build, on both versions.**
Putting `[GraphQLDeprecated]` on `sessionById`'s `id` parameter, which is
`Int!` with no default, makes the service fail to start. Verbatim, and
identical on 16.6.1 and on 14.3.1:

```
Unhandled exception: HotChocolate.SchemaException: For more details look at
the `Errors` property.

1. Required argument Query.sessionById(id:) cannot be deprecated.
   (HotChocolate.Types.ObjectType)
```

Recorded here rather than quoted in the book, under SPEC decision 53: the
corrected code cannot produce this message, so no tagged state asserts it, and
the chapter states the fact in prose instead of printing the response.

**Deprecation is advisory, measured rather than assumed.** With the field
deprecated, `{ sessionById(id: 3) { title } }` still answers 200 with the
title. Introspecting `__type(name: "Query") { fields { name } }` does **not**
list `sessionById`; adding `fields(includeDeprecated: true)` does, with
`isDeprecated: true` and the reason string. So the only thing that changes for
a client is what its tooling offers it.

### The reason string this chapter uses

```
Ask for `node(id:)` instead. This field takes the database key, which is only
unique among sessions.
```

Chosen because a reason that names the replacement is actionable and a reason
that says "deprecated" is not. No source is claimed for that judgement; it is
mine.

## Mutations and error design

### The generated shapes

`[MutationType]` on a static class plus `.AddMutationConventions()` on the
builder. One method, `RescheduleSessionAsync`, with two `[Error<T>]`
attributes, produces all of this:

```
type Mutation {
  rescheduleSession(input: RescheduleSessionInput!): RescheduleSessionPayload!
}

input RescheduleSessionInput {
  sessionId: ID!
  startsAt: DateTime!
}

type RescheduleSessionPayload {
  session: Session
  errors: [RescheduleSessionError!]
}

union RescheduleSessionError = SessionNotFoundError | SpeakerDoubleBookedError

interface Error {
  message: String!
}

type SessionNotFoundError implements Error {
  message: String!
  sessionId: ID!
}

type SpeakerDoubleBookedError implements Error {
  message: String!
  speakerId: ID!
  clashingSessionId: ID!
}
```

Every part of that is generated. Worth naming individually:

- The method's parameters that are not services become fields of a generated
  input type named after the mutation, and the argument itself is named
  `input`.
- The return type becomes a **nullable** field of a generated payload type,
  even though the C# method returns `Task<Session>`, which is non-null. The
  convention knows the call can answer with errors instead. This is the
  chapter's best single example of the schema and the C# annotation
  deliberately disagreeing, and `verify.ps1` asserts the schema does not
  contain `session: Session!`.
- Each `[Error<TException>]` type contributes one object type to a generated
  union. The naming rule strips `Exception` and appends `Error`:
  `SessionNotFoundException` becomes `SessionNotFoundError`.
- `Exception.Message` becomes `message: String!`. Every other public property
  of the exception becomes a field, which is how `sessionId` and
  `clashingSessionId` reach the schema.
- An `Error` interface is defined and every member of the union implements it,
  which is what lets a client write `... on Error { message }` and get
  something from an error type it has never heard of.

**No `clientMutationId`.** Nothing in the generated input or payload carries
one. Checked against the current Relay documentation as well: the live
mutations guide and the `useMutation` reference mention it nowhere. It was
never a `must` even in the archived 2019 mutation specification, which used
`may`. No chapter claims Relay requires it.

### The source that argues for this shape

**Marc-Andre Giroux, "A Guide to GraphQL Errors"**, 2020-08-01,
<https://productionreadygraphql.com/2020-08-01-guide-to-graphql-errors/>,
fetched 2026-08-21. Byline confirmed on the page itself, which reads
"A Guide to GraphQL Errors / Marc-Andre Giroux / August 01, 2020". His own
site, not a vendor's, so the named-engineer test does not even arise.

His "Stage 6a: Error Union List + Interface" is the shape Hot Chocolate
generates:

> What if we could combine the extensibility of the interface with the
> expressivity of the union? Well, we can! [...] Make sure all of your union
> members implement a common interface for this solution to work.

and on the union itself, at stage 5:

> Error unions are great because they are a really expressive way of
> structuring our schema. It lets clients see right away what could happen when
> querying or mutating a resource.

**Not cited, and why.** Giroux credits Sasha Solomon's "200 OK! Error Handling
in GraphQL" as the post explaining the philosophy behind the union approach.
That post is on Medium, which reset the connection on every attempt, and no
Wayback Machine snapshot of the URL exists. Nothing from it is quoted or
paraphrased, and the chapter cites Giroux, who was readable.

### The three outcomes, measured

The seeded schedule: Ada Fischer gives session 1 at 09:00 and session 2 at
10:00, both 45 minutes.

| Request | Status | Statements | Payload |
|---------|--------|-----------|---------|
| move a session id that matches nothing | 200 | 1 | `session: null`, one `SessionNotFoundError` |
| move session 2 to 09:30, clashing with session 1 | 200 | 2 | `session: null`, one `SpeakerDoubleBookedError` naming speaker 1 and session 1 |
| move session 3 to 16:00 | 200 | 3 | the moved session, `errors: null` |

Raw, for the two failures:

```
{"data":{"rescheduleSession":{"session":null,"errors":[
{"__typename":"SessionNotFoundError","message":"No session has id 99.",
"sessionId":"U2Vzc2lvbjo5OQ=="}]}}}

{"data":{"rescheduleSession":{"session":null,"errors":[
{"__typename":"SpeakerDoubleBookedError",
"message":"Speaker 1 already gives session 1 in that slot.",
"speakerId":"U3BlYWtlcjox","clashingSessionId":"U2Vzc2lvbjox"}]}}}
```

The three counts are the three code paths: the lookup alone, the lookup plus
the speaker's other sessions, and both plus the `UPDATE`. The clash costs two
statements **and writes nothing**, which is the property that makes a declared
error different from an exception escaping into the `errors` array.

### Two things the mutation had to do differently, and why

**The overlap test runs in memory.** Written as an EF Core predicate,
`s.StartsAt.AddMinutes(s.DurationMinutes)` cannot be translated, because
`StartsAt` goes through the value converter chapter 3 introduced. The first
version of this mutation did exactly that and produced
`Unexpected Execution Error` at HTTP 200 with `data: null`, which is neither of
the two declared errors. The shipped version loads the speaker's other sessions
and tests the overlap in C#. That is the second statement in the counts above.

**The error types carry node ids, not integers.** The first version exposed
`speakerId: Int!` and `clashingSessionId: Int!`, and `verify.ps1` failed on
chapter 3's assertion that the schema hides the `speakerId` foreign key. The
assertion was right and the schema was wrong: chapter 3 makes a point of
`[GraphQLIgnore]`ing that key on `Session`, and an error type about a session
handing it straight back undoes that. Both properties carry `[ID<T>]` now, so
what comes back is a node id a client can feed to `node(id:)`. The chapter 3
assertion was narrowed at the same time, from a whole-file search for
`speakerId` to a search inside the `Session` type, plus a new one that no field
anywhere in the schema is typed `speakerId: Int`. That is a sharpening rather
than a loosening: the old form could not tell two different fields apart.

## Nullability, the first pass

### How C# maps to the schema

`<Nullable>enable</Nullable>` has been in `Sessions.csproj` since chapter 2, so
this has been true all along and only now gets named:

| C# | GraphQL |
|----|---------|
| `string Title` | `title: String!` |
| `string? Abstract` | `abstract: String` |
| `Task<Speaker?>` | `speaker: Speaker` |
| `Task<Speaker>` | `speaker: Speaker!` |

The last row is measured on the `ch04-orphan` branch, where dropping one `?`
from the resolver's return type is the whole of the schema change.

### What the specification says happens next

Source: **GraphQL specification, September 2025 edition**, section 6.4.4,
"Handling Execution Errors", fetched and quoted 2026-08-21:

> If the result of resolving a response position is `null` [...] and that
> position is of a Non-Null type, then an execution error is raised at that
> position.

> Since Non-Null response positions cannot be null, execution errors are
> propagated to be handled by the parent response position. If the parent
> response position may be null then it resolves to null, otherwise if it is a
> Non-Null type, the execution error is further propagated to its parent
> response position.

> If a List type wraps a Non-Null type, and one of the response position
> elements of that list resolves to null, then the entire list response
> position must resolve to null.

> only one error should be added to the errors list per response position

**Note on wording.** The spec never says "the nearest nullable ancestor",
which is the usual community paraphrase. Its mechanism is recursive: propagate
to the parent, stop where the parent may be null, otherwise keep going. The
chapter follows the spec's wording rather than the paraphrase.

### What the machine does, measured on `ch04-orphan`

The branch makes two changes: `GetSpeakerAsync` returns `Task<Speaker>`, and
session 4 points at speaker 99, who does not exist. The DataLoader answers a
missing key with null, exactly as chapter 3 said it would.

**The compiler predicts it before any request is sent.** Building the branch
emits, on the resolver's expression body:

```
warning CS8603: Possible null reference return.
```

`verify.ps1` on that branch asserts the warning appears, and runs
`dotnet build --no-incremental` so that an up-to-date project cannot let the
assertion pass by compiling nothing.

Five requests, all HTTP 200. The last row is the one that matters most: the
schema is equally broken there and nothing in the response says so.

| Request | `data` | Error path |
|---------|--------|-----------|
| `sessions { nodes { title speaker { name } } }` | `sessions.nodes` is `null`, all four sessions gone | `["sessions","nodes",3,"speaker"]` |
| the same plus `pageInfo { hasNextPage }` | `nodes` null, **`pageInfo` intact** | same |
| `sessions { edges { node { title speaker { name } } } }` | `sessions.edges` is `null` | `["sessions","edges",3,"node","speaker"]` |
| `sessionById(id: 4) { title speaker { name } }` | `sessionById` is `null` | `["sessionById","speaker"]` |
| `sessions { nodes { title } }` | all four titles, **no `errors` key** | none |

Verbatim, the first one:

```
{"errors":[{"message":"Cannot return null for non-nullable field.",
"path":["sessions","nodes",3,"speaker"],"extensions":{"code":"HC0018"}}],
"data":{"sessions":{"nodes":null}}}
```

Exactly one error for four lost sessions, which is the spec's "only one error
per response position" showing on the page. The blast radius is the distance
from the failing field to the first position that may be null: `speaker` cannot
be null, the `Session` inside `[Session!]` cannot be null, and `nodes` can, so
`nodes` absorbs it and stops there. `pageInfo` is a sibling of `nodes` and is
untouched. The last row is the one that makes it uncomfortable: whether a
client ever sees this depends on whether that client selected the field.

**This is why `speaker` stays nullable on `main`.** The chapter argues from a
measurement rather than from taste, and chapter 10 puts a network in the place
of the missing row.

## Checked, and recorded so nobody re-derives it

- **`IIdSerializer` does not exist in 16.6.1.** The Hot Chocolate documentation
  names `IIdSerializer` as the service for serialising a global id in custom
  code. Searching every XML documentation file shipped in the 16.6.1 packages
  finds `HotChocolate.Types.Relay.INodeIdSerializer` and no `IIdSerializer` at
  all. The machine outranks the page, as in chapters 2 and 3. **No chapter
  names either type**, because nothing in chapter 4 needs to serialise an id by
  hand; recorded so that a later chapter that does starts from the right name.
- **`@semanticNonNull` is not in any published GraphQL specification edition.**
  Searching the September 2025 edition finds no definition of it. It is an
  open, unmerged RFC on the specification repository, PR 1065, opened
  2023-11-24 by Benjie Gillam and still open. In 16.6.1 the directive exists
  only as an **export-time rewrite**: `schema export --semantic-non-null` on
  the CLI, `SchemaFormatterOptions.RewriteToSemanticNonNull`, and a
  `MapGraphQLSemanticNonNullSchema()` endpoint. There is also a
  `HotChocolate.Language.ErrorHandlingMode` carried on every request object.
  **Chapter 4 mentions none of this**; it is chapter 14's, and the SPEC's open
  items now say so, because chapter 14's approved scope line names
  `@semanticNonNull` as though it were the mechanism.
- **A required argument cannot be deprecated on either version.** Recorded
  above with the verbatim message. Not a version difference, so not a callout.
- **Hot Chocolate 16 is said to require that deprecating a field also deprecate
  the interface field it implements.** The 15-to-16 migration guide states this
  and attributes it to "the draft specification"; that normative sentence could
  not be found in the draft edition. **Nothing in this chapter depends on it**
  and no chapter states it. Worth re-checking before chapter 14, which is the
  next chapter to put an interface under a deprecation.
- **Almost the whole chapter compiles unchanged on 14.3.1.** Global object
  identification, the deprecation, the mutation conventions, `[Error<T>]`,
  `[ID<T>]` on an exception property and `[MutationType]` all exist and behave
  identically. **One line does not.** The node resolver takes a
  `QueryContext<Session>`, and 14 has no `IQueryable` overload of `With`, which
  is the gap chapter 3's callout already described. The `hc14` branch's
  `SessionType.cs` is therefore written as
  `.Where(s => s.Id == id).FirstOrDefaultAsync(ct)` rather than as a resolver
  starting fresh there would be, so that the callout's instruction - drop the
  parameter and the `.With(query)` line - is literally what compiles. The
  statement count stays at one; only the column list grows. The same
  `verify.ps1` runs on both branches and all 96 assertions pass on each.
- **Two things do come back differently on 14**, and the chapter says so rather
  than claiming the answers are identical. The malformed-node-id error carries
  an extra `"locations":[{"line":1,"column":21}]` entry that 16.6.1 does not.
  And the exported schema differs in the `DateTime` specification URL and in
  the byte order mark at its head, both of which chapter 2's callout already
  owns and neither of which is chapter 4's doing.

## What the audit changed, and the two findings it did not

The chapter went to a three-lens panel of read-only agents with no drafting
context: one tracing facts to this note and to the tags, one checking the SPEC
and house style, one reading voice against chapter 3. What follows is only the
part worth keeping; the rest was applied and is now in the prose.

Six findings changed something outside the prose:

- **`Session.id` is not the first field in chapter 3's export.** The chapter
  opened by asking a reader to read "the first field" of each type, and in
  chapter 3's schema `Session` begins with `speaker`. Checked at the `ch03` tag
  and corrected; the section now prints the order that tag actually exports.
  This note already recorded that the field moved, and the chapter contradicted
  its own source.
- **`verify.ps1` proved less than the chapter printed, in three places.** The
  four-row body with eight node ids was asserted on its first pair only; the
  claim that `nodes` batches nothing "even when both are sessions" had only
  ever been measured on a session-plus-speaker pair; and the coercion error's
  `originalValue` was printed as `2` while the script sent `3`. All three are
  now asserted, and the count went from 91 to 96.
- **The chapter 4 callout claimed more than the branch built.** It said the
  chapter compiles unchanged on 14, exports the same schema and answers the
  same way. All three are false in the ways recorded above. The callout now
  states the one line that differs, and the `hc14` branch was rewritten to the
  shape the callout tells a reader to write.
- **The callout also stated two patch versions in a sentence**, which decision
  35 puts in appendix A and nowhere else, and claimed provenance for its own
  listings, which decision 18 says the book does not do. Both are gone.
- **`[GraphQLDeprecated]` on the `id` argument** was reported as unhighlighted
  changes in two listings: `SessionType.cs` gained two `using` directives that
  the `highlightlines` range did not cover, and `Program.cs` lost a semicolon
  on the line above the two new ones. Both corrected.
- **Displayed quotations had no decision behind them.** Chapter 4 is the first
  to quote normative text at paragraph length, and decision 37 names only
  `\enquote{}`. Recorded as decision 61 rather than left as a habit.

Two findings were rejected, and the reasons are here because a rejection that
is not written down is indistinguishable from an oversight:

- **"Section 2 is theory before code, against decision 14."** Raised as unsure.
  Rejected: decision 14 requires that the reader has seen the behaviour before
  the mechanism is explained, and section 1 shows the collision in the exported
  schema before section 2 explains what fixes it. The specification quotations
  in section 2 explain a failure the reader has already been shown.
- **"The chapter runs beats 2 to 4 three times rather than once, and no
  decision records the pattern."** Raised as unsure. Rejected as a defect:
  decision 13 fixes the order of the five beats, not how many subjects a
  chapter may take through them, and chapter 3's fifth section already did the
  same thing. Recorded as decision 62 so that the next audit does not have to
  raise it again.

## Where the chapter's counts come from

Every count printed in the chapter, and the request that produces it. Check out
the tag named and run `pwsh verify.ps1` to reproduce any row.

| Count | Request | Tag |
|-------|---------|-----|
| 1 statement | `node(id: "U2Vzc2lvbjox") { ... on Session { title } }` | `ch04` |
| 2 statements | `nodes(ids: ["U2Vzc2lvbjox", "U3BlYWtlcjox"])` | `ch04` |
| 1 statement | `rescheduleSession` with an id matching nothing | `ch04` |
| 2 statements | `rescheduleSession` producing a clash | `ch04` |
| 3 statements | `rescheduleSession` that succeeds | `ch04` |
| 4 sessions, 1 error | the orphaned page | `ch04-orphan` |
| 96 assertions | the whole script | `ch04` and `ch04-hc14` |
