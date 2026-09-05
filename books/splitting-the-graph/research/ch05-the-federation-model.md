# Chapter 5 - The Federation Model

Research note for the chapter that draws the seam. It ships no C# at all: the
verification repo is unchanged from chapter 4, and every listing in the chapter
is either a request already asserted there, a schema-definition-language
document, or a normative directive definition quoted from the Apollo Federation
specification.

That makes this note's job different from chapters 2 to 4. Those had a compiler
to appeal to. This one has two authorities and they answer different questions:
the running Sessions service, which says what the join costs today, and the
Cosmo composer, which says whether a decomposition holds together. Both were
run on this machine on **2026-08-23**, and web sources were accessed the same
day.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| Tags this chapter uses | `ch05` (branch `main`), `ch05-hc14` (branch `hc14`) |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| EF Core on `main` | 10.0.11 |
| `wgc` (Cosmo CLI) | 0.129.7, installed globally through npm |
| Gate | `pwsh verify.ps1`. PASS on both branches, 104 assertions, 2026-08-23 |

**No new package and no new source file.** `Sessions.csproj` is unchanged from
chapter 3, and `git diff ch04..ch05` over `src/` is empty. The chapter prints
no C#, and `ch05` is the first tag in this repository on an unchanged tree.

### The eight assertions the chapter added

The chapter opens on a request that differs from chapter 3's by asking for no
identifiers at all, so nothing asserted it before. `verify.ps1` now asserts the
four sessions, the two-statement count, the four speaker names in schedule
order, that the raw response JSON contains none of `speakerId`, `sessionId` or
`id`, that the batched lookup reads the `Speakers` table, and the text of the
batched lookup itself.

Two things the run taught that the draft had wrong:

- **Placement.** Put after the chapter 4 mutation block, the speaker-name
  assertion failed: `Ada, Ada, Chidi, Bruno` rather than `Ada, Ada, Bruno,
  Chidi`. Chapter 4's successful reschedule moves session 3 to a later slot, so
  the schedule order the chapter prints is only true before that mutation runs.
  The block now sits before the chapter 4 section, and the script comment says
  why.
- **The statement text is EF Core's, not Hot Chocolate's.** The first version
  asserted `WHERE "s"."Id" IN (@ids1, @ids2, @ids3)` on both branches and
  failed on `hc14`. EF Core 9 emits

  ```sql
  WHERE "s"."Id" IN (
      SELECT "i"."value"
      FROM json_each(@__ids_0) AS "i"
  )
  ```

  so the three keys are inside one JSON array parameter and are not readable in
  the statement text at all. Both branches still issue one statement for the
  batch, which is what the count asserts. The expectation moved into the
  script's `$expected` table beside the other version-sensitive values.
  Chapter 3's callout already reports this difference, so chapter 5 needs no
  callout of its own and issues none.

## The join, measured

Every number below was measured against a freshly seeded database on
`http://localhost:5001/graphql`, counting the numbered markers `StatementLog`
writes to the console. That is the technique `verify.ps1` already uses in
`Invoke-GraphQLCounted`, so these runs and the gate count the same way.

### The seam query

```
{ sessions(first: 10) { nodes { title speaker { name } } } }
```

2 statements:

```sql
SELECT "s"."Title", "s"."SpeakerId" FROM "Sessions" AS "s" ORDER BY "s"."StartsAt" LIMIT @p
SELECT "s"."Id", "s"."Bio", "s"."Name" FROM "Speakers" AS "s" WHERE "s"."Id" IN (@ids1, @ids2, @ids3)
```

Response:

```json
{"data":{"sessions":{"nodes":[
  {"title":"Schemas That Outlive Their Authors","speaker":{"name":"Ada Fischer"}},
  {"title":"Reading a Query Plan","speaker":{"name":"Ada Fischer"}},
  {"title":"Paging Without Offsets","speaker":{"name":"Bruno Kaminski"}},
  {"title":"The Bank That Split Its Graph","speaker":{"name":"Chidi Okafor"}}]}}}
```

**The finding the chapter opens on.** There is no value anywhere in that
response that ties a speaker to a session. Not a `speakerId`, not a `sessionId`,
not a key of any kind. The nesting is the entire record of the join. Chapter 3
put `[GraphQLIgnore]` on `Session.SpeakerId` and `verify.ps1` asserts its
absence from the `Session` type, so this is a property of the schema the book
designed rather than an accident of this query.

### The other counts

| Query | Statements |
|---|---|
| `{ sessions(first: 10) { nodes { title speaker { name } } } }` | 2 |
| `{ sessions(first: 10) { nodes { title speaker { id } } } }` | 2 |
| `{ sessions(first: 10) { nodes { id title } } }` | 1 |
| `{ node(id: "U3BlYWtlcjox") { __typename ... on Speaker { name } } }` | 1 |
| `{ nodes(ids: [3 speaker ids]) { ... on Speaker { name } } }` | 1 |
| `{ sessions(first: 10) { nodes { id title speaker { id name } } } }` | 2 |

The seeded schedule is four sessions and three distinct speakers, which is why
the `IN` list carries three parameters and not four:

| Speaker | Node id | Decodes to |
|---|---|---|
| Ada Fischer | `U3BlYWtlcjox` | `Speaker:1` |
| Bruno Kaminski | `U3BlYWtlcjoy` | `Speaker:2` |
| Chidi Okafor | `U3BlYWtlcjoz` | `Speaker:3` |

Ada Fischer gives two of the four sessions.

### One number that looks like a contradiction and is not

Three speaker ids through `nodes(ids:)` cost **one** statement, batched as
`IN (@ids1, @ids2, @ids3)`. Two *session* ids through the same field cost
**two**, and `verify.ps1` asserts that at line 428, under a comment calling it
"the stronger half of the claim: nothing about `nodes` batches."

The two are consistent and chapter 4 already says why, in the last paragraph of
section 4.3: `SpeakerType`'s node resolver goes through the DataLoader, and
`SessionType`'s issues its own `WHERE Id = @id`. The batching belongs to the
resolver, not to the field. Checked rather than assumed, because a measurement
that appears to contradict a standing assertion is exactly the kind of thing
that gets written into a chapter as a discovery.

Chapter 5 does not print any of these three numbers. They were measured to
decide whether the chapter could argue that a client can reconstruct the join
for itself, and the answer turned out to be simpler than the arithmetic: it
cannot, because no field exposes the key. Recorded so that the question is not
re-opened.

## The decomposition, composed

The chapter prints a three-subgraph decomposition of the conference example as
the map Part II implements. That map was checked by composing it, so the
chapter is not printing a design that turns out not to hold together.

Working directory (outside both repositories):
`.../scratchpad/compose/`. Three schema files and one `graph.yaml`, composed
with:

```
wgc router compose -i graph.yaml -o supergraph.json
```

`graph.yaml`:

```yaml
version: 1
subgraphs:
  - name: sessions
    routing_url: http://localhost:5001/graphql
    schema:
      file: ./sessions.graphql
  - name: speakers
    routing_url: http://localhost:5002/graphql
    schema:
      file: ./speakers.graphql
  - name: ratings
    routing_url: http://localhost:5003/graphql
    schema:
      file: ./ratings.graphql
```

Each schema file opens with

```graphql
extend schema
  @link(url: "https://specs.apollo.dev/federation/v2.7", import: ["@key"])
```

and then declares what its service owns. `sessions.graphql` carries `Session`
in full plus a `Speaker` stub of nothing but its key; `speakers.graphql`
carries `Speaker` in full; `ratings.graphql` carries `Rating` plus a `Session`
stub carrying the key and the two fields Ratings contributes.

**Result: composed.** The exact client-facing schema `wgc` wrote into
`engineConfig.graphqlSchema`, for the two types the chapter shows:

```graphql
type Session {
  id: ID!
  title: String!
  abstract: String
  startsAt: DateTime!
  durationMinutes: Int!
  speaker: Speaker
  ratings: [Rating!]!
  averageScore: Float
}

type Speaker {
  id: ID!
  name: String!
  bio: String
}
```

**Amended 2026-09-05.** The chapter's map now shows the two Ratings fields
as `averageScore` and `ratingCount`, with no `Rating` type and no `ratings`
list, because that is what chapter 9 built and a reader carrying this map into
chapter 9 met a different graph (SPEC decision 132). The scratch composition
above was not re-run with the new names; what stands behind the map now is
the real composition `verify.ps1` performs on `main` at every run, whose
`engineConfig.graphqlSchema` carries exactly those two fields on `Session`
beside the six Sessions owns (chapter 9 note, "The plan grows a second step").
Field count unchanged at eight. `feedbackUrl`, the third Ratings field, is
left to chapter 9 because it needs `@requires`, and the chapter says so.

`Session` carries eight fields contributed by two services, and nothing in the
composed type says which service contributed which. That is the artifact the
chapter's last section is about.

## Two composition failures, reproduced

Both were produced in the same scratch directory, with the same `wgc` 0.129.7,
against two-subgraph inputs. Neither is quoted in the chapter: no tagged state
of the verification repo produces either, so SPEC decision 53 applies and they
are described in prose and recorded verbatim here.

### Two subgraphs both declaring `Query.node`

Chapter 4 turned on global object identification, so every subgraph this book
builds will export `node` and `nodes`. Two subgraphs that both do so, with no
further declaration, fail to compose:

```
The Object "Query" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "node" is defined in the following subgraphs: "sessions", "speakers".
 However, it is not declared "@shareable" in any of them.
```

Adding `@shareable` to `Query.node` in both subgraphs, and importing the
directive in both `@link` lists, composes without error. Re-run and confirmed.

This is a real bill that chapter 6 or chapter 9 has to pay, and it is recorded
here so that neither chapter meets it as a surprise.

### An entity referenced without a key

Sessions declaring `type Speaker { id: ID! }` with no `@key`, while Speakers
declares `type Speaker @key(fields: "id")`:

```
The Object "Speaker" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "id" is defined and declared "@shareable" in the following subgraph: "speakers".
 However, it is not declared "@shareable" in the following subgraph: "sessions".
```

Worth recording for two reasons. The error names shareability rather than the
missing key, so the message points away from the actual mistake. And it shows
the composer's own view of `@key`: the fields named in a key are treated as
shareable in the subgraph that declares the key, which is why only the subgraph
without one is reported.

## What the specification requires

All quotations below are from Apollo's *Apollo Federation Subgraph
Specification*, fetched 2026-08-23 at
`https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec`.
Chapter 1 already cites this document for its four-requirement count, on the
reasoning SPEC decision 39 records: it is the normative list of what a
specification requires of an implementation, and every line of it can be
checked against a running server, which is what a byline would otherwise stand
in for. That reasoning carries here unchanged.

### The subgraph contract

The additions a subgraph must make to its own schema:

```graphql
extend type Query {
  _entities(representations: [_Any!]!): [_Entity]!
  _service: _Service!
}

type _Service {
  sdl: String!
}
```

- `_service` "returns a `_Service` object, which in turn has a single field,
  `sdl`", and that string "must include all uses of all federation-specific
  directives, such as `@key`."
- `_entities`: "If a subgraph contributes fields to at least one entity, it
  must automatically define and correctly resolve the `Query._entities` field."
- `_Any` is "serialized as a generic JSON object, which enables the graph
  router to include representations of different entities in the same query,
  all of which can have a different shape."
- `_Entity` is generated, and "must include all entity types that are defined
  in the subgraph schema, except entities with a `@key` that sets
  `resolvable: false`."

### The ordering sentence

Under the heading *Understanding `Query._entities`*:

> The `Query._entities` field must return a list of entity objects that
> correspond to the provided representations, in the exact same order. Entries
> in the list can be null if no entity exists for a provided representation.

Restated operationally in the next section, *Resolving `Query._entities`*, as
step 2.3 of the resolver algorithm: "Make sure objects are listed in the same
order as their corresponding representations."

Chapter 11 owns this sentence. Recorded here at its exact heading so that
chapter does not have to find it again, and because chapter 5 states the
contract exists without arguing what breaks when it is violated.

### Entity and key

From *Entities: Introduction*, same site, same date:

> Entities are objects that can be fetched with one or more unique key fields.
> Like a row in a database table, an entity contains fields of various types,
> and it can be uniquely identified by a key field or set of fields.

and

> An entity type is an object type that has been defined as an entity. Because
> an entity is keyed, an entity type's definition must have a `@key` directive.

`@key`, from the directives reference:

```graphql
directive @key(fields: FieldSet!, resolvable: Boolean = true)
  repeatable on OBJECT | INTERFACE
```

A key's `fields` argument is "a GraphQL selection set (provided as a string) of
fields and subfields that contribute to the entity's unique key". The reference
gives `"id"`, `"username region"` and `"name organization { id }"` as legal
values, so single, compound and nested keys are all in. Multiple `@key`
directives on one type are legal "if your subgraph library supports repeatable
directives". `resolvable: false` "indicates to the router that this subgraph
doesn't define a reference resolver for this entity", used "most commonly...
when referencing an entity without contributing fields".

`FieldSet` is a scalar: "Grammatically, a `FieldSet` is a selection set minus
the outermost curly braces." Note the name. Federation 1 spelled it
`_FieldSet`, and the underscore is gone in 2.

### The directive block, counted

The section headed *Subgraph schema additions* gives the definitions a subgraph
library must add for you. Counted from the page itself rather than from
anybody's summary: **sixteen**, in this order.

```graphql
directive @external on FIELD_DEFINITION | OBJECT
directive @requires(fields: FieldSet!) on FIELD_DEFINITION
directive @provides(fields: FieldSet!) on FIELD_DEFINITION
directive @key(fields: FieldSet!, resolvable: Boolean = true) repeatable on OBJECT | INTERFACE
directive @link(url: String!, as: String, for: link__Purpose, import: [link__Import]) repeatable on SCHEMA
directive @shareable repeatable on OBJECT | FIELD_DEFINITION
directive @inaccessible on FIELD_DEFINITION | OBJECT | INTERFACE | UNION | ARGUMENT_DEFINITION | SCALAR | ENUM | ENUM_VALUE | INPUT_OBJECT | INPUT_FIELD_DEFINITION
directive @tag(name: String!) repeatable on FIELD_DEFINITION | INTERFACE | OBJECT | UNION | ARGUMENT_DEFINITION | SCALAR | ENUM | ENUM_VALUE | INPUT_OBJECT | INPUT_FIELD_DEFINITION
directive @override(from: String!) on FIELD_DEFINITION
directive @composeDirective(name: String!) repeatable on SCHEMA
directive @interfaceObject on OBJECT
directive @authenticated on FIELD_DEFINITION | OBJECT | INTERFACE | SCALAR | ENUM
directive @requiresScopes(scopes: [[federation__Scope!]!]!) on FIELD_DEFINITION | OBJECT | INTERFACE | SCALAR | ENUM
directive @policy(policies: [[federation__Policy!]!]!) on FIELD_DEFINITION | OBJECT | INTERFACE | SCALAR | ENUM
directive @context(name: String!) repeatable on INTERFACE | OBJECT | UNION
directive @fromContext(field: federation__ContextFieldValue) on ARGUMENT_DEFINITION
```

`@extends` sits below that block under a comment saying it is "required only
for libraries that don't support GraphQL's built-in `extend` keyword", which is
why the chapter calls it the seventeenth rather than counting it among the
sixteen. The count was re-checked against the page directly after a cold audit
flagged it as untraced, and it holds.

**Two of the sixteen are documented inconsistently by Apollo itself.** The
directives reference page gives `@tag` an extra `SCHEMA` location that the
subgraph specification page does not, and gives `@context` as
`on OBJECT | INTERFACE | UNION` without `repeatable` where the specification
page has it `repeatable on INTERFACE | OBJECT | UNION`. The chapter rests on
neither, and the SPEC's open items carry it forward to appendix C, which will
have to choose.

`@cost` and `@listSize` are **not** in that block. The directives reference
documents them under demand control rather than among the federation
directives, which is why the chapter says Apollo "documents both alongside the
sixteen" rather than calling them federation directives.

### What each of the rest actually does

Quoted from the directives reference so that the tour in section 5.6 is not
written from memory:

- `@override`: the field stays where it was. "The composed supergraph schema
  indicates that `Product.inStock` is resolved by the Inventory subgraph but
  not the Products subgraph, even though the Products subgraph also defines the
  field."
- `@inaccessible`: "An `@inaccessible` field or type is not omitted from the
  supergraph schema, so the router still knows it exists (but clients can't
  include it in operations)."
- `@interfaceObject`: "Indicates that an object definition serves as an
  abstraction of another subgraph's entity interface. This abstraction enables
  a subgraph to automatically contribute fields to all entities that implement
  a particular entity interface."
- `@composeDirective`: needed because "by default, composition omits most
  directives from the supergraph schema".
- `@tag`: "Applies arbitrary string metadata to a schema location. Custom
  tooling can use this metadata during any step of the schema delivery flow."

### What the specification does not define

**"Supergraph" is not a word the subgraph specification defines.** It appears
in passing in that document and has no entry in its glossary of schema
additions, which covers the `Query` fields, `_Service`, `_Entity`, `_Any`,
`FieldSet`, `Scope`, `Policy` and the directives. The term is introduced
instead on Apollo's conceptual page *Federated schemas*, under a heading that
announces it as terminology:

> When combining multiple GraphQL APIs, the single, federated graph is called a
> supergraph. [...] In a supergraph, the constituent APIs are called subgraphs.

So the specification regulates one side of the arrangement, the subgraph, and
"supergraph" is Apollo's name for the composed result rather than a term with
normative force. Chapter 5 says this out loud, because chapter 1 already used
both words and a reader is entitled to know which one is load-bearing.

## What Hot Chocolate 16.6.1 actually does

Measured on this machine on 2026-08-23, from the shipped package rather than
from the source tree or the documentation. A scratch console project outside
both repositories, `net10.0`, one `PackageReference` to
`HotChocolate.ApolloFederation` 16.6.1, reflecting over the loaded assembly and
then building a one-entity schema:

```csharp
var schema = await new ServiceCollection()
    .AddGraphQL()
    .AddApolloFederation()
    .AddQueryType<Query>()
    .BuildSchemaAsync();
Console.WriteLine(schema.ToString());
```

with `Speaker` carrying `[Key("id")]` and a static `[ReferenceResolver]`
method.

### The version cap, and the default

`HotChocolate.ApolloFederation.FederationVersion`, read out of the loaded
16.6.1 assembly with `Enum.GetNames`:

```
Unknown = 0
Federation10 = 10   Federation24 = 24
Federation20 = 20   Federation25 = 25
Federation21 = 21   Federation26 = 26
Federation22 = 22   Default      = 26
Federation23 = 23   Federation27 = 27
                    Latest       = 27
```

**The package models Federation up to v2.7 and defaults to v2.6.** It has no
concept of v2.8 or later at all, so `@context` and `@fromContext` (v2.8) are
not a thing a subgraph written with this package can declare.

### The `@link` line it emits

With nothing pinned, the exported schema opens:

```graphql
schema
  @link(
    url: "https://specs.apollo.dev/federation/v2.6"
    import: ["@key", "@tag", "FieldSet"]
  ) {
  query: Query
}
```

Pinning `FederationVersion.Federation27` changes only the version in that
string. The import list holds what the schema actually uses, plus `@tag` and
`FieldSet`, which appear whether or not anything applies them.

**This is why the chapter's printed map says `v2.6`.** It is what the reader's
own subgraph will emit in chapter 6 if they do not go looking for a setting,
and a map that disagreed with it would be a map of a different graph.

### The federation additions, as this package writes them

```graphql
type Query {
  speakerById(id: Int!): Speaker
  _service: _Service!
  _entities(representations: [_Any!]!): [_Entity]!
}

type _Service { sdl: String! }
union _Entity = Speaker
scalar _Any
scalar FieldSet

directive @key(fields: FieldSet!, resolvable: Boolean = true) repeatable on
  | OBJECT
  | INTERFACE
```

The `@key` definition matches the specification exactly, including
`resolvable`'s default and both locations. Chapter 6 owns showing this from
the real service; it is recorded here because chapter 5's directive tour has
to be true of the package the book uses and not only of the specification.

A representation, as the chapter prints one:

```json
{"__typename": "Speaker", "id": "U3BlYWtlcjox"}
```

The type name and the key fields, and the specification says each item is
"serialized as a generic JSON object". The id string is the one chapter 4
measured; the shape is the specification's, whose own example is
`{"__typename": "Product", "upc": "abc123"}`.

### The directives the package ships

Type names ending in `Directive` in the 16.6.1 assembly:

```
Authenticated  ExtendServiceType  InterfaceObject  Policy         RequiresScopes
Compose        External           Key              Provides       Shareable
Contact        Inaccessible       Link             Requires
```

Absent, and worth recording because the specification defines them: no
`@context`, no `@fromContext` (v2.8), no `@cacheTag` (v2.12). `@tag` is absent
too, but for a different reason: it lives in Hot Chocolate's core rather than
in this package, which is why the `@link` import list above carries it anyway.
`@cost` and `@listSize` are likewise core, and chapter 3's exported schema
already prints both.

### One divergence from the specification, measured

The specification defines

```graphql
directive @link(url: String!, as: String, for: link__Purpose,
                import: [link__Import]) repeatable on SCHEMA
```

and the package emits

```graphql
directive @link(url: String!, import: [String!]) repeatable on SCHEMA
```

No `as`, no `for`, and `import` typed as `[String!]` rather than as the
specification's `link__Import`. Nothing in this book needs `as` or `for`, so no
chapter claims anything about them, but a reader who reaches for namespacing
through `@link(as:)` will not find it here. Recorded rather than printed.

## Why Apollo Federation v2 and not the draft

Chapter 1 tells the reader in print that this book builds on Apollo Federation
v2 "rather than on that draft" and forward-references chapter 5 for the reason.
SPEC decisions 6 and 7 recorded the reasoning as settled in the requirements
interview, and `2026-08-hard-cases.md` recorded the facts underneath it as
**not yet verified**. They were verified on 2026-08-23. Two needed narrowing
and both narrowings are now in the decision rows.

### The specification's own status

`https://graphql.github.io/composite-schemas-spec/` lists exactly one edition,
labeled **Working Draft**, dated Fri, Aug 7, 2026, and marks the project
**Prerelease**. There is no numbered release. Fetched twice, once for the index
page's status labels and once for the draft's own title, because the chapter
rests on both.

The repository's own process documents disagree with the rendered spec and with
each other: `README.md` carries a "Stage 0: Preliminary" banner, `ROADMAP.md`
says "We are currently in the _Proposal Stage_", and the rendered document says
Working Draft. The chapter says only what the published document says about
itself, and does not pick a stage.

### It is not a renaming of Apollo Federation

Read out of the draft directly:

```graphql
directive @lookup on FIELD_DEFINITION
directive @key(fields: FieldSelectionSet!) repeatable on OBJECT | INTERFACE
directive @require(field: FieldSelectionMap!) on ARGUMENT_DEFINITION
directive @is(field: FieldSelectionMap!) on ARGUMENT_DEFINITION
directive @external on FIELD_DEFINITION
```

Three differences the chapter uses, all confirmed by fetching the draft rather
than by reading about it: the key scalar is `FieldSelectionSet`, not Apollo's
`FieldSet`; there is **no `_entities` root field anywhere in the document**,
with `@lookup` on an ordinary field in its place; and `@require` applies to an
argument where Apollo's `@requires` applies to a field. The chapter prints the
first two and mentions neither `@is` nor `@require`, because two differences
carry the point and six would be a directive tour of a specification the book
does not use.

### The rename

`https://github.com/graphql/composite-schemas-wg/blob/main/notes/2026/summary-2026-08-06.md`
records "Michael announced that the final specification name will be 'GraphQL
Federation Specification'" and that "the new specification would extend Apollo
Federation rather than replace it". The file opens with its own disclaimer:
"NOTICE: This summary was auto-generated by Zoom's \"AI\". AI-generated content
may be inaccurate or misleading. Always check for accuracy."

The chapter repeats that caveat in the prose rather than hiding it in the bib
entry, and states separately that the rename has not reached the specification,
which was checked independently by fetching the document and reading its title.
The notes name people by first name only, so no individual is attributed a
position.

### The Fusion line

- `HotChocolate.Fusion` 15.1.17, published 2026-06-16, confirmed from NuGet
  registration metadata. The package has **no 16.x release at all**: the
  flat-container index tops out at 15.1.17. The SPEC's version and date are
  exact.
- Michael Staib's *What's new in Fusion 16*, on ChilliCream's blog and bylined,
  supplies the word the SPEC uses: "When we set out to rewrite Fusion, we had
  three main goals: remove the constraints imposed by Hot Chocolate, achieve
  top-tier performance with .NET, and make the gateway feel like a natural
  extension of your ASP.NET Core app, rather than a black box configured with
  YAML." The same post says Fusion 16 implements the current version of the
  Composite Schema Specification.
- **The SPEC's "composed with Nitro CLI" is too narrow.** The same post says
  Fusion 16 "no longer depends on command-line tools for composition" and
  describes an Aspire-driven path where the composer fetches schemas at
  startup. The Nitro CLI is one option. Decision 6 corrected; the chapter never
  claimed it.
- `HotChocolate.ApolloFederation` publishes stable releases across 14.x, 15.x
  and 16.x with no gap. **The SPEC's "the only subgraph contract reaching
  both" overreaches**, because the base library reaches both trivially. The
  claim that survives, and the one the chapter prints, is about federation
  tooling specifically.

Both package lines were read directly rather than taken on report:

```
curl -s https://api.nuget.org/v3-flatcontainer/hotchocolate.fusion/index.json
curl -s https://api.nuget.org/v3-flatcontainer/hotchocolate.apollofederation/index.json
```

`HotChocolate.Fusion`: 569 versions, last three `15.1.15`, `15.1.16`,
`15.1.17`, and **no `16.` version of any kind**. `HotChocolate.ApolloFederation`
stable releases: five on 14.x ending at `14.3.1`, twenty-two on 15.x, and
twenty-eight on 16.x ending at `16.6.1`. That last number is worth noting
against the version baseline: `16.6.1` is the newest stable the index carries,
so the book's pin is current and not one patch behind.

### The license

Apollo Router's own `LICENSE` carries the Elastic License 2.0 clause decision 7
leans on: "You may not provide the software to third parties as a hosted or
managed service, where the service provides users with access to any
substantial set of the features or functionality of the software." That holds.

What does not hold is the family-wide form in `2026-08-hard-cases.md`. Apollo's
`subgraph-js`, the JavaScript counterpart of the package this book uses, is
**MIT**, with its own `LICENSE` file. Elastic covers the router, gateway and
composition tier. Decision 7 and the hard-cases note are both corrected. No
chapter prints either version, so nothing in the manuscript had to change.

### Recorded and not used

Michael Staib's post on Fusion 16.5 reports a federation-gateway-audit table
scoring Fusion and Hive Router at 100 percent, Apollo Router lower, and Cosmo
Router lower still. **Nothing from it is printed.** It is a signed vendor post
making a claim about competitors, and the Sources rule admits a vendor for
their own product and not for anyone else's. It is in the SPEC's open items
because decision 7 chose Cosmo on license and version coverage rather than on
an audit score, and the score is worth checking here before part III leans on
the router.

Hive Router, re-checked because decision 7 names it as the strongest rejected
alternative: published by The Guild at `github.com/graphql-hive/router`, MIT,
written in Rust, and its own documentation says it "supports Federation v2
only" and that "Federation v1 supergraphs are not supported".

## Claims checked and found false

- **That `nodes(ids:)` never batches.** It batches whenever the node resolver
  behind the type goes through a DataLoader. See the measured section above;
  chapter 4 already stated the mechanism correctly, and the number that looked
  like a counterexample is not one.
- **That the ChilliCream documentation covers `HotChocolate.ApolloFederation`
  on v16.** It does not, as of 2026-08-23:
  `https://chillicream.com/docs/hotchocolate/v16/api-reference/apollo-federation/`
  redirects to an unversioned path that returns 404, and the site's own sitemap
  carries no Apollo Federation subgraph-authoring page, only Fusion pages. So
  every claim this chapter makes about the package is measured from the package
  rather than read anywhere, and no chapter may cite that URL.
- **That `HotChocolate.ApolloFederation` is the package Apollo publishes.** It
  is not, and there is a second, deprecated one.
  `ApolloGraphQL.HotChocolate.Federation`, from the archived
  `apollographql/federation-hotchocolate` repository, states in its own README
  that it "is now officially deprecated in favor of the HotChocolate built-in
  Federation module". Recorded so that a later session does not "correct" the
  book's package name to the dead one.
- **That the Federation 2.x libraries are Elastic License v2 as a family.**
  `subgraph-js` is MIT. See the license section above; the hard-cases note and
  SPEC decision 7 are both corrected.
- **That Fusion 16 is composed with the Nitro CLI.** It can be, and it no
  longer depends on a command-line tool for composition. SPEC decision 6
  corrected.
- **That `@inaccessible` keeps a field out of the supergraph.** The first draft
  of section 5.6 said exactly that and it is wrong in the way that matters: the
  field *is* in the supergraph schema, the router knows about it, other
  subgraphs may reference it, and what is withheld is the client's ability to
  select it. Caught by the cold audit, corrected against Apollo's own wording,
  and recorded here because the wrong version is the intuitive one and a later
  chapter will be tempted by it.

### The Fusion package family, as evidence for "replaced"

Chapter 5 says the 14-era Fusion "stopped receiving releases and was replaced
by differently named packages". Read out of NuGet's search API rather than
inferred:

```
curl -s "https://azuresearch-usnc.nuget.org/query?q=HotChocolate.Fusion&prerelease=false&take=20"
```

`HotChocolate.Fusion`, `.Abstractions`, `.CommandLine` and `.SourceSchema` all
sit frozen at `15.1.17`. A differently named family runs at 16.x beside them:
`.Composition`, `.Execution`, `.Packaging`, `.Aspire`, `.AspNetCore`,
`.Diagnostics`, `.SourceSchema.Packaging`, `.Caching`, and a
`.Connectors.ApolloFederation` at `16.4.0`, which incidentally corroborates
from a second direction the claim that Fusion 16.5 speaks Apollo Federation.

## Sources, with access date

All fetched 2026-08-23.

| Source | Category | Used for |
|---|---|---|
| Apollo, *Apollo Federation Subgraph Specification* | normative specification | the subgraph contract, the ordering sentence, `FieldSet`, the directive count |
| Apollo, *Introduction to Entities* | vendor documentation of its own product | the definition of an entity and the `@key` requirement |
| Apollo, *Apollo Federation Directives* | normative specification reference | the three key examples, `resolvable` |
| Apollo, *Introduction to Apollo Federation* | vendor documentation | the two terms, and only as terminology |
| GraphQL Composite Schemas Spec, draft and index | normative specification draft | its own status, `@lookup`, `FieldSelectionSet`, the absence of `_entities` |
| Composite Schemas Working Group, 2026-08-06 summary | standards body's record of its own group | the rename; carries an auto-generation disclaimer, repeated in the prose |
| Staib, *What's new in Fusion 16*, ChilliCream blog | signed engineering post | the word "rewrite", which specification Fusion 16 implements |
| NuGet flat-container and registration APIs | package metadata | the Fusion and ApolloFederation release lines |
| Apollo Router `LICENSE`, Apollo `subgraph-js/LICENSE` | the artifacts themselves | the Elastic clause, and the MIT correction |

**Deliberately not cited, and why.**
`https://chillicream.com/docs/hotchocolate/v16/api-reference/apollo-federation/`
does not resolve, as recorded above. Staib's Fusion 16.5 post is cited nowhere:
its useful content for this chapter is a comparison against other vendors'
gateways, which the Sources rule bars. And the ChilliCream documentation is
absent from `refs.bib`'s chapter 5 block entirely rather than cited with a
caveat, because a citation to a 404 is worse than none.
