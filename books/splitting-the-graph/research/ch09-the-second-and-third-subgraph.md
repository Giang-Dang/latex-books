# Chapter 9 - The Second and Third Subgraph

Research note for the chapter that splits the graph: the Speakers service, the
Ratings service, the three seam directives, and the first query answered across
more than one subgraph.

Web sources accessed **2026-08-24**; everything else was measured on this
machine on the same date.

Three things are worth stating before any of it.

**This chapter is where the book's central claim stops being a promise.** Every
chapter from 5 onward has said that a seam is a type two services both name and
only one owns. Until now there was one service, so there was no seam and
nothing to check. The two composition inputs chapter 7 hand-wrote to ask what
would happen are replaced here by services that actually export those
documents, and one of chapter 7's two guesses turns out to have been wrong in a
way worth recording.

**The hard part was not the extraction.** Moving the speaker rows into their own
service took an afternoon and produced no surprises. What cost the day was
getting a subgraph that contributes fields to a type it does not own to accept
a key it did not mint, which turns out to be blocked by an interaction between
global object identification and federation that nothing documents. Sections
"The serializer a subgraph cannot register" and "Three ways to fail to decode a
key" below are that.

**One finding contradicts Apollo's documentation and one contradicts chapter 8's
own numbers.** Both are recorded in full rather than smoothed over.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| `wgc` (Cosmo CLI) | 0.129.9, installed globally through npm |
| Cosmo Router | 0.341.0, the released Windows binary |
| Gate | `pwsh verify.ps1`, run on each tag below. All PASS 2026-08-24 |

| Tag | Branch | What it is | Assertions |
|-----|--------|-----------|------------|
| `ch09` | `main` | the finished chapter: three services, three databases, one graph | 328 |
| `ch09-hc14` | `hc14` | unchanged tree; the shared script branched so it still passes | 214 |
| `ch09-noserializer` | `ch09-noserializer` | the Ratings service with `AddDefaultNodeIdSerializer()` removed. Builds, starts, exports main's schema, answers its own root field, and fails only on the entity route (decision 51) | 20 |

**Ports**, per SPEC decision 44: Sessions 5001, Speakers 5002, Ratings 5003,
router 3002. Each service pins its own in `Properties/launchSettings.json`.

**Databases**, one per service and this is the point rather than an accident:
`conference.db`, `speakers.db`, `ratings.db`. All three are gitignored and
seeded at startup by `EnsureCreated()`.

**No project reference between the three**, per SPEC decision 43. Where two
services need the same shape, each declares its own copy. `ShareNodeFields` and
`StatementLog` are each written out twice; the `Session` record exists in two
services with different fields in each, which is the seam expressed in C#.

## What the three services own

| Type | Sessions (5001) | Speakers (5002) | Ratings (5003) |
|------|-----------------|-----------------|----------------|
| `Session` | owns: `id`, `title`, `abstract`, `startsAt`, `durationMinutes`, `speaker` | - | contributes: `averageScore`, `ratingCount`, `feedbackUrl`; declares `title` `@external` |
| `Speaker` | stub: `id` only, `resolvable: false` | owns: `id`, `name`, `bio` | - |
| `Query` | `sessions`, `sessionById`, `node`, `nodes` | `speakers`, `node`, `nodes` | `ratingCount` |

The two seams are deliberately different shapes, which is why the chapter needs
both services rather than one:

- **Speakers is the plain entity seam.** A type moves out whole. The service
  that gives it up keeps a stub so that its own field still has a type.
- **Ratings is the contribution seam.** No type moves. A service adds fields to
  a type another service owns, and never resolves that type's own data.

## The numbers this chapter prints

Every count below is asserted by `verify.ps1` at tag `ch09`. Four sessions,
three distinct speakers, six ratings across three of the four sessions.

| Request, through the router on 3002 | Sessions | Speakers | Ratings | Total |
|---|---|---|---|---|
| `sessions { nodes { title } }` | 1 | 0 | 0 | 1 |
| `sessions { nodes { title speaker { name } } }` | 1 | 1 | 0 | **2** |
| `+ averageScore ratingCount` | 1 | 1 | 1 | **3** |
| `sessions { nodes { title feedbackUrl } }` | 1 | 0 | 0 | 1 |
| `sessions { nodes { feedbackUrl } }` | 1 | 0 | 0 | 1 |
| any of the above with `X-WG-Skip-Loader` | 0 | 0 | 0 | 0 |

**The two in the second row is chapter 3's two.** Chapter 3 measured four
sessions and three distinct speakers at five statements naive and two batched,
inside one service. After the split it is still two, now one in each of two
processes. That is the single most useful number in the chapter and it is the
reason the Speakers reference resolver goes through a DataLoader from the first
line rather than being left naive for chapter 10 to fix.

The Speakers statement, in full, is the batched lookup:

```sql
SELECT "s"."Id", "s"."Bio", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" IN (@ids1, @ids2, @ids3)
```

Three parameters for four sessions, because two sessions share a speaker. Same
shape chapter 3 measured, in a different process.

The Ratings statement is the same idea over four keys:

```sql
SELECT "r"."Id", "r"."Score", "r"."SessionId"
FROM "Ratings" AS "r"
WHERE "r"."SessionId" IN (@sessionIds1, @sessionIds2, @sessionIds3, @sessionIds4)
```

### The seeded ratings, and the decimals the chapter prints

| Session | Scores | `averageScore` | `ratingCount` |
|---------|--------|----------------|---------------|
| 1, Schemas That Outlive Their Authors | 5, 4, 3 | **4** | 3 |
| 2, Reading a Query Plan | 4, 5 | **4.5** | 2 |
| 3, Paging Without Offsets | 3 | **3** | 1 |
| 4, The Bank That Split Its Graph | none | **null** | 0 |

The scores were chosen so that every average is exact in binary floating point
and prints without a tail. Session 4 is seeded with no ratings on purpose: an
average over no rows is null and the count beside it is zero, and a schema has
to say which of those two it means. This is the pair `verify.ps1` asserts.

**Ordering caveat for anyone reading the script.** The chapter 4 block runs the
`rescheduleSession` mutation before any chapter 9 assertion, and it moves
session 3 to 16:00. So in the script the page order is 1, 2, 4, 3 rather than
the seeded 1, 2, 3, 4. The chapter prints the seeded order, which is what runs
at its own tag. Every ordered chapter 9 assertion is written against the
post-mutation order and says so.

## The stub, and what `resolvable: false` actually does

SPEC open item, carried since chapter 6: Apollo recommends `resolvable: false`
on an entity stub and chapter 5's printed map does not carry it. Chapter 9
writes the first one, so this is where it is settled.

### What Apollo says

Source: `https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/entities/contribute-fields`,
section "Referencing an entity without contributing fields", accessed
2026-08-24.

> A stub definition includes only the `@key` fields of an entity. In this case,
> the `Product` type definition only includes the `id` field. It also includes
> `resolvable: false` in the `@key` directive to indicate that this subgraph
> doesn't define a reference resolver for the `Product` entity.

And on the `@key` reference page, `resolvable` defaults to `true`, and setting
it false means the subgraph does not define a reference resolver for the type.

**Precise answer to the question the open item asked.** Defining *some* stub
type is required: without it the subgraph names a type it never declares and
composition fails. Adding `resolvable: false` to that stub's key is **not**
composition-enforced by this composer - the argument has a default and nothing
rejects a stub that omits it - but it is what Apollo's own worked example does,
and its effect is real rather than cosmetic. See the next two sections.

### What it does to the exported schema

Written in C# as the second constructor argument, which is the only overload
that takes it:

```csharp
[ObjectType<Speaker>]
[Key("id", false)]
public static partial class SpeakerType;
```

`KeyAttribute` has exactly two constructors, `()` and
`(string fieldSet, bool resolvable = true)`, confirmed by reflecting on the
shipped `HotChocolate.ApolloFederation.dll`. Exported:

```graphql
type Speaker @key(fields: "id", resolvable: false) {
  "Stable identifier for this speaker."
  id: ID!
}
```

Two things left with it, and both are readouts rather than side effects:

- `implements Node` is gone, because the stub carries no `[NodeResolver]`.
- **`union _Entity = Session`.** Speaker dropped out of the entity union.
  Chapter 6 called that union a readout of which types are entities; here it is
  the readout of which types this service will answer an entity fetch for, and
  `resolvable: false` is what changed it. Sessions' `_Entity` had two members at
  `ch06` and has one at `ch09`.

### What it does to the router execution config

This is the part nothing documents and the part the chapter prints. Read out of
`graph/router.json` after `wgc router compose`:

```json
{ "typeName": "Session", "selectionSet": "id" }
{ "typeName": "Speaker", "selectionSet": "id", "disableEntityResolver": true }
```

Both in the Sessions datasource's `keys` array. The stub's key **is** in the
key table, because the router still needs the shape of it, and one boolean
beside it is the whole of what the argument bought. The same type in the
Speakers datasource carries no such property at all - the flag is written only
when it is false, so its absence is the positive case.

That flag is what stops the router routing an entity fetch for a Speaker to the
Sessions service. Chapter 7 called the key table "the seam in the form the
router actually consumes it"; this is the same idea one level down.

### And what happens if a caller ignores it

Measured. The composer respects the flag; nothing else does. Send Sessions a
representation for a Speaker on its own port:

```graphql
query E($r: [_Any!]!) { _entities(representations: $r) { __typename } }
```
with `[{ "__typename": "Speaker", "id": "U3BlYWtlcjox" }]`, and the answer is:

```json
{"errors":[{"message":"Unexpected Execution Error","path":["_entities"]}],"data":null}
```

Not a null in the list, which is what a key matching no row produces. An
unhandled error that takes the whole `data` key with it. The type is in the
schema, it advertises a `@key`, and nothing in the document tells a caller that
this one cannot be resolved - `resolvable: false` is in the subgraph SDL, but a
caller reading the schema through introspection never sees it, because
directives are not introspectable that way.

Recorded here and stated in the chapter. It is chapter 12's territory rather
than this chapter's, and chapter 12 should collect on it.

## The serializer a subgraph cannot register

The single most expensive thing in this chapter, and the reason the Ratings
service's `Program.cs` has a line in it that looks arbitrary.

### The problem

Ratings contributes fields to `Session`, a type it does not own. The keys it is
handed across the seam are the global node ids chapter 4 introduced -
`U2Vzc2lvbjox`, which is base64 of `Session:1`. To turn one into the integer its
own `Ratings` table is keyed by, it needs `INodeIdSerializer`, exactly as
chapters 6's reference resolvers do.

That serializer is registered by `AddGlobalObjectIdentification()`.

### Why the obvious fix does not work

Adding `AddGlobalObjectIdentification()` to Ratings does not start the service:

```
HotChocolate.SchemaException: For more details look at the `Errors` property.

1. There is no object type implementing interface `Node`. (HotChocolate.Types.Relay.NodeType)
   at HotChocolate.SchemaBuilder.Setup.CompleteSchema(...)
```

The call adds `node` and `nodes` to `Query` and the `Node` interface to the
schema, and then refuses to build because nothing implements it. Ratings owns no
node: its `Session` is a contribution, not an entity it can fetch by id from
nothing. So the feature that registers the serializer cannot be switched on in
the kind of subgraph that most needs to read a node id.

Making Ratings' `Session` a `Node` to satisfy it would be a lie - it would
declare that Ratings can answer `node(id:)` for a session, which it cannot.

### The fix

`AddDefaultNodeIdSerializer()`, which registers the serializer and nothing
else. Found by scanning `HotChocolate.Types.dll` for the type name rather than
in any documentation; the neighbouring names in the same assembly are
`AddLegacyNodeIdSerializer`, `INodeIdSerializerAccessor`,
`NodeIdSerializerOptions`, `NodeIdSerializerFormat`, `OptimizedNodeIdSerializer`
and `NodeIdSerializerTypeInterceptor`.

```csharp
builder
    .AddGraphQL()
    .AddRatingsTypes()
    .RegisterDbContextFactory<RatingContext>()
    .AddDefaultNodeIdSerializer()
    .AddApolloFederation()
    .ModifyCostOptions(options => options.ApplyCostDefaults = false);
```

**Without that line the failure is silent in the way this book keeps meeting.**
The reference resolver is injected a null `INodeIdSerializer`, throws a
`NullReferenceException` on the first `.Parse`, and the entity route answers:

```json
{"errors":[{"message":"Unexpected Execution Error","path":["_entities"]}],"data":{"_entities":[null]}}
```

No exception in any log, no stack trace, nothing at startup. The same shape
SPEC decision 69 recorded for `QueryContext<T>` in a reference resolver, and
the third time in this book that a missing registration produces
`Unexpected Execution Error` and no other evidence. Turning
`IncludeExceptionDetails` on is what produced the stack trace above; that switch
is a debugging aid and is not in the shipped file.

**Not established:** whether `AddDefaultNodeIdSerializer()` produces byte-identical
ids to the ones `AddGlobalObjectIdentification()` configures in the other two
services under every setting. It does for this book's types - the ids round-trip
across all three services and `verify.ps1` asserts the strings - but
`NodeIdSerializerOptions` and `NodeIdSerializerFormat` were not explored, and a
book that pinned a non-default format would have to check. Chapter 9 claims only
what round-trips here.

## Three ways to fail to decode a key

All measured against the Ratings reference resolver, all producing wrong or
absent answers rather than errors. Recorded together because the first two look
like they should work.

### 1. `[ID<Session>]` on the key property yields zero

```csharp
public sealed record Session([property: ID<Session>] int Id, string Title);
```

Exports `id: ID!`, which is what composition needs. The reference resolver
declared as `(int id, string title)` is then handed **`id = 0`**, every time,
for every key. Confirmed by printing the parameter from inside the resolver:

```
-- refresolver id=0 title=[]
```

Consequence: the service answers with `ratingCount: 0` and `averageScore: null`
for a session that has three ratings, at HTTP 200, with no error key. It reads
exactly like a session nobody rated.

This is SPEC decision 68's failure mode arriving through the property rather
than through the parameter. Decision 68 recorded that `[ID<T>]` **on the
parameter** does not decode and yields 0; this is the same result from the other
placement, which is worth a row because the decision as written does not cover
it.

### 2. Plain `[ID]` on a string property binds nothing

```csharp
public sealed record Session([property: ID] string Id, ...);
```

Exports `id: ID!`. The resolver parameter `string id` arrives **null**, and
`serializer.Parse(null, ...)` throws.

Except that it did not, and this is worth writing down because it cost an hour:
the `NullReferenceException` here was **not** the null `id`. It was the null
serializer from the previous section. Once `AddDefaultNodeIdSerializer()` was in
place, this shape worked. The two failures had the same symptom -
`Unexpected Execution Error`, `data._entities: [null]` - and were diagnosed as
one problem twice.

### 3. `[GraphQLType<IdType>]` exports the wrong nullability

```csharp
public sealed record Session([property: GraphQLType<IdType>] string Id, ...);
```

Exports `id: ID`, nullable, and composition then fails on the `Node` interface
contract:

```
The implementation of Interface "Node" by "Session" is invalid because:
 The field "id" is invalid because:
  The implemented response type "ID" is not a valid subtype (equally or more
  restrictive) of the response type "ID!" ... "Node.id".
```

`[GraphQLType<T>]` replaces the whole type reference including its nullability,
so it needs `NonNullType<IdType>` to be equivalent. Not used; `[ID]` is shorter
and correct.

### What the book ships

```csharp
public sealed record Session(
    [property: ID] string Id,
    [property: GraphQLIgnore] int Key,
    string Title);
```

Three fields where the owning service has one. `Id` is the node id as a string,
because that is what arrives and what has to go back. `Key` is the integer
inside it, hidden from the schema because no client has a use for it. `Title` is
never stored. The reference resolver decodes once and fills both:

```csharp
var nodeId = serializer.Parse(id, typeof(int));
if (nodeId.TypeName != nameof(Session)) { return null; }
return new Session(id, (int)nodeId.InternalId!, title ?? string.Empty);
```

The type-name guard is decision 68's, unchanged, in a third service.

## `@external` and `@requires`

### The attribute surface, from the assembly

Reflected out of `HotChocolate.ApolloFederation.dll` 16.6.1 rather than read in
documentation, because ChilliCream's own federation API pages return HTTP 404
at every version tried on 2026-08-24 (`/docs/hotchocolate/v16/api-reference/apollo-federation/`
and the v13 equivalent both 404, and the site's sitemap lists no
`/docs/hotchocolate/` pages at all).

| Attribute | Base | Valid on | Ctor |
|-----------|------|----------|------|
| `ExternalAttribute` | `DescriptorAttribute` | Class, Struct, Method, Property | `()` |
| `RequiresAttribute` | `ObjectFieldDescriptorAttribute` | **Method, Property only** | `(string fieldSet)` |
| `ProvidesAttribute` | `ObjectFieldDescriptorAttribute` | **Method, Property only** | `(string fieldSet)` |
| `KeyAttribute` | `DescriptorAttribute` | Class, Property, Interface | `()`, `(string fieldSet, bool resolvable = true)` |
| `ReferenceResolverAttribute` | `DescriptorAttribute` | Class, Struct, Method, Interface | `()`, with `EntityResolver` and `EntityResolverType` as settable properties |

`RequiresAttribute` and `ProvidesAttribute` declare no `[AttributeUsage]` of
their own; they inherit `ObjectFieldDescriptorAttribute`'s, which is
`Method | Property`. **Proved by the compiler** rather than only by metadata:
putting `[Requires("...")]` on the type class gives

```
error CS0592: Attribute 'Requires' is not valid on this declaration type.
It is only valid on 'method, property, indexer' declarations.
```

So in this book's idiom - a `[ObjectType<T>]` static partial class carrying
`[Key]` and `[ReferenceResolver]` on the class - `[Requires]` and `[Provides]`
go on the static resolver method inside the class, never on the class. `[External]`
can legally go on either, and goes on the method here.

Cross-checked against the shipped source at ChilliCream/graphql-platform tag
`16.6.1`, commit `5121c37e16f2ab6bf8dfb8bdbd2ec96e2d86737a`,
`src/HotChocolate/ApolloFederation/src/ApolloFederation/Types/Directives/`.

### The FieldSet string is parsed but never checked

Measured. `[Requires("!!! not valid")]` throws at schema build:

```
Expected a `Name`-token, but found a `Bang`-token.
  at HotChocolate.ApolloFederation.Types.FieldSetType.ParseSelectionSet(String s)
  at HotChocolate.ApolloFederation.Types.RequiresDirective..ctor(String fields)
```

But `[Requires("doesNotExist")]`, naming a field that does not exist on the
type, **builds and exports cleanly**:

```graphql
shippingCost: Decimal! @requires(fields: "doesNotExist")
```

Validation is syntactic only. A typo in a `@requires` or `@provides` field set
reaches the exported schema, and whether anything catches it afterwards is the
composer's business rather than Hot Chocolate's. Worth a sentence in the chapter
because it is the kind of thing a reader assumes is checked.

### What the spec says `@requires` does

Source: `https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/directives`,
accessed 2026-08-24. That is the url `refs.bib` carries and the one re-fetched to
confirm the two `@provides` preconditions and the sentence after them word for
word. A parallel path, `/docs/graphos/reference/federation/directives`, serves the
same page; the book cites one of them and this note records that they are the same
document rather than two sources. The declarations, from the subgraph specification's own
schema additions block at
`https://www.apollographql.com/docs/federation/subgraph-spec` (the redirect
target of `https://specs.apollo.dev/federation/v2.6/`):

```
directive @external on FIELD_DEFINITION | OBJECT
directive @requires(fields: FieldSet!) on FIELD_DEFINITION
directive @provides(fields: FieldSet!) on FIELD_DEFINITION
```

None is `repeatable`, in contrast to `@key`, `@link`, `@shareable` and `@tag`.

> Indicates that the resolver for a particular entity field depends on the
> values of other entity fields that are resolved by other subgraphs. This tells
> the router that it needs to fetch the values of those externally defined
> fields first, **even if the original client query didn't request them**.

> If a subgraph requires an entity field, the subgraph must define that field
> and mark it as external ... Otherwise, a composition error occurs.

Both halves are confirmed by measurement below. The second is why
`Session.title` is declared `@external` in Ratings at all: nothing in the
service resolves it and nobody ever asks for it there.

Version caveat: Apollo's reference page is unversioned and now includes
directives that postdate v2.6 (`@context`, `@fromContext`, `@policy`). The three
this chapter uses carry a "Federation v1.0" minimum-version badge in the page
data, so their semantics are unchanged through v2.6.

### What `@requires` does, measured

The field, and the reason it exists in the example: a feedback URL is built from
the session's title, and the title belongs to another service.

```csharp
[Requires("title")]
public static string GetFeedbackUrl([Parent] Session session)
    => "https://feedback.example/2026/" + Slug(session.Title);
```

The strong form of the claim is the second request below, where the client never
mentions `title`:

```graphql
{ sessions { nodes { feedbackUrl } } }
```

```json
{"data":{"sessions":{"nodes":[
  {"feedbackUrl":"https://feedback.example/2026/schemas-that-outlive-their-authors"},
  {"feedbackUrl":"https://feedback.example/2026/reading-a-query-plan"}]}}}
```

No `title` anywhere in the response, and the Sessions service was still asked
for it: **1 statement**, and the plan's first fetch reads
`{ sessions { nodes { title __typename id } } }`.

In the plan, the representation grows a second entry beside the key:

```json
"representations": [
  { "kind": "@requires", "typeName": "Session", "fieldName": "feedbackUrl",
    "fragment": "fragment Requires_for_feedbackUrl on Session {\n    title\n}" },
  { "kind": "@key", "typeName": "Session",
    "fragment": "fragment Key on Session {\n    __typename\n    id\n}" }
]
```

And in the execution config, `@requires` is the only one of the three seam
directives that compiles into a rule about a single field rather than about a
type. The Ratings datasource, and only that one, carries a `requires` array:

```json
{ "typeName": "Session", "fieldName": "feedbackUrl", "selectionSet": "title" }
```

`@external` compiles into a list on the same datasource's root node, separate
from the fields the subgraph actually resolves:

```json
{ "typeName": "Session",
  "fieldNames": ["averageScore", "ratingCount", "feedbackUrl", "id"],
  "externalFieldNames": ["title"] }
```

Ratings issues **no statement at all** for `feedbackUrl`: it answers entirely
out of the representation.

## `@provides`, and a disagreement with Apollo's documentation

### What Apollo says

Same source and access date.

> Specifies a set of entity fields that a subgraph can resolve, but only at a
> particular schema path (at other paths, the subgraph can't resolve those
> fields).

> If a subgraph can always resolve a particular entity field, do not apply this
> directive.

> Using this directive is always an optional optimization.

And the two preconditions:

> If a subgraph provides an entity field: The subgraph must define that field
> and mark it as external ... The entity field must be marked as either
> shareable or external in every subgraph that defines it. The entity field must
> be marked as shareable in at least one other subgraph ... **Otherwise, a
> composition error occurs.**

### What this composer does

Measured 2026-08-24 with `wgc` 0.129.9. `graph/provides-unshared.graphql` meets
the first precondition and not the second: it provides `Speaker.name`, marks it
`@external` locally, and is composed against `src/Speakers/schema.graphql`,
where `name` is declared with no `@shareable` on it.

```
$ wgc router compose -i graph-with-provides.yaml -o /tmp/prov.json
Router execution config successfully written to "...".
$ echo $?
0
```

**It composes.** Exit zero, a config written, nothing said, and nothing
anywhere in the output mentioning shareable. Apollo's documentation says this is
a composition error; this composer accepts it.

Same class of thing as SPEC decision 73, where Hot Chocolate emits
`@cost(weight: "10")` and Cosmo's composer holds a definition typing `weight` as
`Int!`. The book prints what the tool prints, per decision 77, and says the
specification's own documentation says otherwise.

`verify.ps1` asserts that it composes, so a `wgc` that starts enforcing the rule
fails a run and the chapter is corrected rather than ageing quietly. That is the
protection decision 78 described for a version string.

**Not established:** what the router does at runtime with such a graph. There is
no service behind `provides-unshared.graphql` - it is an input file, per
decision 76 - so whether the router would honour, ignore or mis-route the
`@provides` was not measured, and the chapter claims nothing about it.

### Why the book's graph ships no `@provides`

Not a gap. The preconditions require the providing subgraph to hold a copy of a
field it does not own, and to have the owning subgraph declare that field
`@shareable`. After chapter 9 the Sessions service does not store speaker names
at all, so there is nothing for it to provide; making it provide one would mean
putting the speaker rows back and declaring `Speaker.name` shareable in both
services, which is the duplication chapter 17 is about and precisely what
chapter 7 closes by teaching the reader not to do.

The chapter states the directive, its preconditions, the measurement above, and
that trade. It does not ship one.

### The gateway audit's two `@provides` failures

SPEC open item, carried from chapter 8: what do the three suites Cosmo Router
fails in `graphql-hive/federation-gateway-audit` have in common, and do they
touch anything this book does. Chapter 9 was the chapter that had to know before
teaching the directive. Answered by reading the suites' own source at
`https://github.com/graphql-hive/federation-gateway-audit/tree/main/src/test-suites`,
accessed 2026-08-24.

- **`provides-on-interface`**: `@provides` on a field whose return type is an
  `interface` (`Media.animals: [Animal]`, with `Dog` and `Cat` implementing it).
- **`provides-on-union`**: the identical pattern over `union Media = Book | Movie`.
- **`complex-entity-call`**: four subgraphs chained through compound, multi-field,
  nested `@key` field sets, with several `@key` declarations on one type. **No
  `@provides` or `@requires` anywhere in it.**

**So the open item's answer is that the two `provides-*` failures are about
`@provides` on abstract types, and the third is not about `@provides` at all.**
A `@provides` on a plain object-typed field, which is the only kind a chapter
like this would write, is not in the territory either failing suite covers.
Nothing in this book's example is affected, and the chapter says nothing about
the audit.

Two further things turned up and neither changes chapter 8:

- The audit's committed `results.txt` for Cosmo Router was last regenerated at
  commit `c460d4a1` on 2025-09-30, against router **0.247.0**, and shows six
  failing suites. The `install.sh` pin was later bumped to 0.321.2 without
  regenerating the results. That is the same self-disagreement decision 84
  already recorded as one of its four reasons for printing no score, seen from
  another angle. Decision 84's own numbers came from **running** the audit
  against 0.341.0 on this machine, which remains the measurement of record.
- Two merged upstream PRs suggest the abstract-type handling was fixed before
  0.341.0: `wundergraph/cosmo` #3043, "fix: handling of provides on abstract
  types", merged 2026-07-02 and shipped in router 0.326.3; and #3026,
  "feat(composition): support @provides on fields returning a Union type",
  shipped in `@wundergraph/composition` 0.63.0, below the 0.63.3 this book
  pins. **This is in tension with decision 84's local run, which still recorded
  those two suites failing at 0.341.0**, and the tension is not resolved here:
  re-running the audit was out of scope for this chapter. Recorded so that
  whoever revisits decision 84 starts from it. No chapter prints any of it.

## What the router does with the seam

### The plan grows a second step

Chapter 8's whole plan vocabulary was `Sequence` and `Single`, over a graph with
one subgraph. The seam adds `BatchEntity`, and a third subgraph adds `Parallel`.

For `{ sessions { nodes { title speaker { name } } } }`:

```json
{ "kind": "Sequence", "children": [
  { "kind": "Single", "fetch": { "kind": "Single", "subgraphName": "sessions",
      "subgraphId": "0", "fetchId": 0,
      "query": "{ sessions { nodes { title speaker { __typename id } } } }" } },
  { "kind": "Single", "fetch": {
      "kind": "BatchEntity",
      "path": "sessions.nodes.@.speaker",
      "subgraphName": "speakers", "subgraphId": "1", "fetchId": 1,
      "dependsOnFetchIds": [0],
      "representations": [ { "kind": "@key", "typeName": "Speaker",
        "fragment": "fragment Key on Speaker { __typename id }" } ],
      "query": "query($representations: [_Any!]!){ _entities(representations: $representations){ ... on Speaker { __typename name } } }" } } ] }
```

Four things in that second fetch are the chapter's material: the `path` naming
the seam, `dependsOnFetchIds` naming what it waits for, the `representations`
fragment showing what will be sent, and the `query` being the `_entities` call
chapter 6 wrote the resolver for.

Note also what the **first** fetch asks for. The client asked for
`speaker { name }`; Sessions is asked for `speaker { __typename id }`. The
router rewrote the selection to fetch the key it will need.

Add the third subgraph and the two independent entity fetches become a
`Parallel` node holding both, each with `dependsOnFetchIds: [0]`. The sequence
still has two steps.

### The subgraph ids are positional

`sessions` 0, `speakers` 1, `ratings` 2, assigned in `graph.yaml` order. A
subgraph inserted in the middle of that file renumbers the ones after it, which
matters because chapter 8 taught reading `subgraphId` out of a plan. Asserted.

### One subgraph down is not the graph down

Chapter 8 could not stage this with one service. Stop Speakers and ask for
titles and names:

```json
{"errors":[{"message":"Failed to fetch from Subgraph 'speakers' at Path 'sessions.nodes.@.speaker'."}],
 "data":{"sessions":{"nodes":[{"title":"...","speaker":null}, ...]}}}
```

HTTP 200. Every title present, every `speaker` null, one error naming the
subgraph and the path. A query that does not cross the broken seam
(`title ratingCount`) is completely unaffected and carries no error key at all.

This is the concrete form of SPEC decision 59's reasoning: `speaker` stayed
nullable because Sessions cannot guarantee a value from data it does not own,
and after chapter 9 that is literally true rather than a judgement about
constraints. Chapter 14 collects on it.

## The finding that changes what chapter 7 bought

**`@shareable` on `Query.node` is a promise neither subgraph can keep, and the
router takes it at face value.**

Chapter 7 shipped `ShareNodeFields`, a type interceptor putting `@shareable` on
`node` and `nodes` and nothing else, and argued the trade: thirty lines to avoid
promising four fields in order to keep a promise about two. Chapter 9 is where
the bill for those two arrives.

`@shareable` says any subgraph declaring the field can resolve it. That is false
of both: Sessions can resolve `node(id:)` for a `Session` and Speakers for a
`Speaker`, and neither can do the other's. Measured, three requests that
disagree with each other:

**1. It works when the query names the type.**

```graphql
{ node(id: "U3BlYWtlcjox") { __typename ... on Speaker { name } } }
```
```json
{"data":{"node":{"__typename":"Speaker","name":"Ada Fischer"}}}
```

The fragment is what lets the planner route to `speakers`.

**2. The same id, the same field, a fragment for the other type, and it fails.**

```graphql
{ node(id: "U3BlYWtlcjox") { __typename ... on Session { title } } }
```
```json
{"errors":[{"message":"Failed to fetch from Subgraph 'sessions'.",
  "extensions":{"errors":[{"message":"There is no node resolver registered for type `Speaker`.",
  "path":["node"],"extensions":{"code":"DOWNSTREAM_SERVICE_ERROR"}}],
  "serviceName":"sessions","statusCode":200}}],"data":{"node":null}}
```

Chapter 4 established that a well-formed node id of the wrong type is **not** an
error: the fragment does not match and the client gets an object with no fields
it asked for. Across a seam it is an error, because the planner had nothing to
route on and sent it to the subgraph that does not own the type.

**3. `nodes` with one id of each type, which no single subgraph can answer.**

```graphql
{ nodes(ids: ["U2Vzc2lvbjox", "U3BlYWtlcjox"]) { __typename } }
```
```json
{"data":{"nodes":[{"__typename":"Session"},null]},
 "errors":[{"message":"Failed to fetch from Subgraph 'sessions'."}]}
```

Half the list, at HTTP 200.

The composed `Node` interface names both types - the router advertises
`possibleTypes` as `Session` and `Speaker` - and each service answers its own
ids correctly on its own port. So this is a routing problem rather than a
resolver one: the router cannot tell, from an opaque id and no fragment, which
subgraph to ask.

**No fix was found that keeps global object identification.** The options
considered and rejected:

- Give every subgraph a node resolver for every type. Impossible; they do not
  have the rows.
- Make `node` non-shareable and declare it in one subgraph only. Composition
  passes and the same failure remains, because that one subgraph still cannot
  resolve the others' types.
- Have the node resolver return null for a type it does not own instead of
  throwing. Turns a loud failure into a silent wrong answer, which is the class
  of defect chapters 11 and 12 exist to warn about.
- `@inaccessible` on `node` and `nodes` in every subgraph, removing the field
  from the client schema. Honest, and costs the reader the whole of chapter 4's
  global refetch story.

The book ships the graph as measured and states the sharp edge. This is a real
consequence of SPEC decision 67 - federating on the global node id was my
judgement rather than Apollo's guidance, and Apollo publishes none - and it
belongs in the decision log rather than in a footnote. Chapter 15, on where
satisfiability actually fails, is the chapter that should collect on it.

## Chapter 7's collision is gone, and that is the deliverable

`graph/graph-with-speakers.yaml` composed chapter 7's hand-written
`speakers.graphql` against the live Sessions schema, and **failed**, with the
error chapter 7 prints:

```
The Object "Speaker" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "name" is defined in the following subgraphs: "sessions", "speakers".
 However, it is not declared "@shareable" in any of them.
 The field "bio" is defined in the following subgraphs: "sessions", "speakers".
 However, it is not declared "@shareable" in any of them.
```

The same input, unchanged, now composes: exit 0, no output. Sessions stopped
claiming `name` and `bio`, so nothing collides.

This is SPEC decision 52's case and not a loosened assertion. `verify.ps1`
asserts the current state, and the current state is that the seam was cut;
chapter 7's printed error stays reproducible at tag `ch07`, where the whole tree
is right. On `hc14`, where the extraction never happened, the same assertion
still expects chapter 7's error text word for word, which is what the shared
script's new `SpeakerExtracted` expectation selects between.

A composition that starts failing again would mean the extraction had come
undone, and that is worth a red run.

### What chapter 7 guessed, and what the service actually exports

Worth printing side by side in the chapter. Chapter 7's hand-written
`speakers.graphql` was twenty-four lines: `@link`, `Query` with `node` and
`nodes`, the `Node` interface, `Speaker` with three fields, `scalar FieldSet`.

The Speakers service exports all of that and, in addition: `speakers` as a
paged connection with `SpeakersConnection` and `SpeakersEdge`, the `PageInfo`
type with `@shareable` on all four of its fields, `_service`, `_entities`,
`_Service`, `_Any`, `union _Entity = Speaker`, `@tag` in the `@link` import list,
and the printed definitions of `@key`, `@link` and `@shareable`.

The guess was right about everything it covered and covered about a third of the
document. That is a fair summary of what hand-writing a subgraph schema to
reason about composition is worth: enough to answer the question chapter 7
asked, and not a substitute for the export.

`PageInfo` is the interesting addition, because it is now declared by two
services and composes without anyone thinking about it. SPEC decision 72
recorded that `AddApolloFederation()` writes `@shareable` onto all four
`PageInfo` fields unasked, and this is the case that vindicates it: two paged
subgraphs would otherwise collide on a generated type neither author wrote.

## Counts the chapter prints about the schema

| Thing | Value |
|-------|-------|
| Named types the router serves (excluding `__*`) | **23** |
| Named types the Sessions subgraph serves | **24** |
| `Query` fields at the router, with deprecated | **5, 6** |
| `Query` fields on Sessions, with deprecated | **5, 6** |
| Fields on `Session` at the router | **9** |
| Of those, from a service that does not own the type | **3** |
| Fields on `Speaker` at the router | **3** |
| Fields on `Speaker` in the Sessions subgraph | **1** |

Chapter 8 printed 21 and 24. The router's count went to 23 because the Speakers
service contributes `SpeakersConnection` and `SpeakersEdge`; the Sessions
subgraph's 24 did not move, because a stub is still a type. The router's `Query`
went from 3 and 4 to 5 and 6, gaining `speakers` and `ratingCount`.

The router's `Session` has nine fields and three of them - `averageScore`,
`ratingCount`, `feedbackUrl` - come from a service that does not own `Session`.
A client cannot tell which three, and that is the point of the whole exercise.

## Things checked and found false, or not established

- **False:** that `@provides` without a `@shareable` elsewhere is a composition
  error. Apollo's documentation says so; `wgc` 0.129.9 composes it. Recorded
  above.
- **False:** that `[ID<T>]` on the key property makes the entity route decode a
  node id. It yields 0 silently.
- **False:** that a subgraph contributing fields to a type it does not own can
  switch on global object identification. The schema does not build.
- **Not established:** what the router does at runtime with a `@provides` whose
  preconditions are unmet.
- **Not established:** whether `AddDefaultNodeIdSerializer()` and
  `AddGlobalObjectIdentification()` produce identical ids under non-default
  `NodeIdSerializerOptions`.
- **Not established:** whether the two `provides-*` audit suites still fail at
  router 0.341.0. Upstream PRs suggest they were fixed before it; decision 84's
  local run says they failed. Not re-run here.
- **Not established:** whether any arrangement of `@inaccessible`, `@override`
  or a custom `Node` split would make `node(id:)` route correctly across
  subgraphs. Four options were considered and rejected on reasoning rather than
  measurement, and only the first is certain.
- **Not investigated:** `@interfaceObject`, which is the directive Apollo offers
  for a subgraph contributing fields to an interface. The book's example has no
  federated interface. Appendix C's territory.

## Corrections made to the draft before the audit

Two claims in the first draft were checked against the repository and were
wrong. Recorded because both are the class of error this book's own history
says an audit catches and a draft does not.

- The Speakers service's `Speaker.cs` was described as chapter 2's record
  "unchanged, minus a namespace". It is not: the doc summary gained a sentence
  naming which service owns the rows. The prose now says what actually
  changed.
- `ShareNodeFields` was described as chapter 7's file "character for
  character", and the duplication was costed at "thirty-three lines twice".
  Neither holds. The Sessions copy is 33 lines and the Speakers copy is 38,
  because the second one carries a longer comment explaining why there are two
  of it; the class body from the declaration down is what is identical, and it
  is 23 lines. The prose now claims only the class body, and drops the count.

## Sources

| What | URL | Accessed |
|------|-----|----------|
| Apollo Federation subgraph specification | `https://www.apollographql.com/docs/federation/subgraph-spec` | 2026-08-24 |
| Apollo federation directives reference | `https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/directives` | 2026-08-24 |
| Apollo, contributing fields to an entity | `https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/entities/contribute-fields` | 2026-08-24 |
| `HotChocolate.ApolloFederation` 16.6.1 source at tag | `https://github.com/ChilliCream/graphql-platform/tree/5121c37e16f2ab6bf8dfb8bdbd2ec96e2d86737a/src/HotChocolate/ApolloFederation` | 2026-08-24 |
| Federation gateway audit test suites | `https://github.com/graphql-hive/federation-gateway-audit/tree/main/src/test-suites` | 2026-08-24 |
| Cosmo PR 3043, provides on abstract types | `https://github.com/wundergraph/cosmo/pull/3043` | 2026-08-24 |
| Cosmo PR 3026, provides on union-returning fields | `https://github.com/wundergraph/cosmo/pull/3026` | 2026-08-24 |

ChilliCream's own federation documentation pages were **not** usable: every
version of `/docs/hotchocolate/*/api-reference/apollo-federation/` returned 404
on 2026-08-24 and the site's sitemap listed no `/docs/hotchocolate/` pages at
all. Everything about the C# surface in this note comes from the shipped
assembly, the compiler, or the tagged source, which is a better authority
anyway.
