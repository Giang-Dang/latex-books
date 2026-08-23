# Chapter 6 - Your First Subgraph

Research note for the chapter that turns the Sessions service into a subgraph:
the package, `@key`, the reference resolver, and the two root fields the
contract adds. It is the first chapter in the book to write federation C#, so
unlike chapter 5 it has a compiler to appeal to again, and the compiler is the
authority wherever it and a document disagree.

Web sources accessed **2026-08-23**; everything else was measured on this
machine on the same date.

One thing is worth stating before any of it. ChilliCream publishes no
documentation page for `HotChocolate.ApolloFederation` on any version of Hot
Chocolate, re-checked on this date and recorded below. So every claim this
chapter makes about the package was measured from the package, and no chapter
may cite a ChilliCream federation page, because there is not one to cite.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| EF Core on `main` | 10.0.11 |
| EF Core on `hc14` | 9.0.19 |
| `HotChocolate.ApolloFederation` | 16.6.1 on `main`, 14.3.1 on `hc14` |
| Gate | `pwsh verify.ps1`, run on each of the four tags below. All PASS 2026-08-23 |

| Tag | Branch | What it is | Assertions |
|-----|--------|-----------|------------|
| `ch06` | `main` | the finished chapter: both types keyed, one reference resolver each, both guarded | 148 |
| `ch06-unguarded` | `ch06-unguarded` | the same two resolvers spending the decoded key without reading the type name in it | 9 |
| `ch06-hc14-ignored` | `hc14` | the attribute idiom on 14.3.1, compiling and doing nothing | 125 |
| `ch06-hc14` | `hc14` | `Speaker` federated the code-first way, which is the only way that works on 14 | 128 |

**One new package**, `HotChocolate.ApolloFederation`, on both branches. It is
the first package this book has added since chapter 3.

## What the compiler settled

Nothing in this section could be looked up. The section below on ChilliCream
records that no documentation page exists for this package on any version, so
every line here came from building and running a probe project, then from the
verification repo itself.

### Where the attributes go

`[Key("id")]` and `[ReferenceResolver(EntityResolver = nameof(...))]` both go on
the `[ObjectType<T>]` static partial class. Three placements were tried and two
of them fail quietly:

| Placement | Result |
|---|---|
| `[Key("id")]` on the `[ObjectType<T>]` class | `@key(fields: "id")` in the schema |
| `[property: Key]` on the record's `Id` parameter | also works; field name inferred |
| `[Key("id")]` on the record type itself | **compiles, no `@key` anywhere** |
| `[ReferenceResolver]` on the resolver *method* | **compiles, does nothing, and publishes the method as a schema field** |

The last two are the dangerous ones because neither is an error. The attribute
is read off the class the source generator is building the type from, and a
positional record is not that class.

`EntityResolverType` is **not** required when the named method lives in the same
class as the attribute. The first working version carried it; it was removed and
the schema and every request were unchanged. The chapter prints the shorter form.

`KeyAttribute`'s constructor is `KeyAttribute(string fieldSet, bool resolvable =
true)`, and `[Key("id", false)]` exports
`@key(fields: "id", resolvable: false)` and removes the type from the `_Entity`
union. No chapter uses it; chapter 9 will.

### What the reference resolver is handed

**The undecoded global node id string.** Measured by printing the parameter:
the value that arrives is `U3BlYWtlcjox`, not `1`.

**Checked and found false: `[ID<T>]` decodes it.** It does not.
`[ID<Speaker>] int id` compiles, leaves the schema unchanged, and the parameter
arrives as `0`, so the entity resolves to `null` with no error at HTTP 200. This
was measured twice, once with `[ID]` and once with `[ID<Speaker>]`, because a
silently wrong value is exactly the kind of thing that gets written into a
chapter as working code.

The decode is `INodeIdSerializer.Parse(id, typeof(int))`. Three ways of getting
the serializer were tried and the differences matter:

| How | Result |
|---|---|
| `INodeIdSerializer serializer` as a plain parameter | **works** |
| `[Service] INodeIdSerializer serializer` | works |
| `INodeIdSerializerAccessor` by either route | throws: it lives in schema services, not request services, and reaching it needs `context.Schema.Services` |

The book uses the first, because it matches the idiom every other resolver in
this book already uses. An earlier draft used the accessor through
`IResolverContext`, which works and is three lines longer for no gain.

The second argument to `Parse` is **the CLR type of the key**, not the entity
type. `typeof(Session)` throws `NodeIdInvalidFormatException: The node ID string
has an invalid format.`, which is the same message chapter 4 printed for a
genuinely malformed id, so the message points away from the mistake.

`Parse` returns a `NodeId` with `InternalId` (the integer) and `TypeName` (the
string `Speaker` or `Session`, read out of the same base64).

### `QueryContext<T>` cannot be injected into a reference resolver

Measured, and the failure mode is the reason it is in the chapter.
`QueryContext<Session>` in the parameter list compiles, builds a schema, starts
the service, and then answers the first `_entities` request with

```json
{"errors":[{"message":"Unexpected Execution Error","path":["_entities"]}],
 "data":{"_entities":[null]}}
```

No exception reaches stdout or stderr, in Development or otherwise. It was
isolated by removing one parameter at a time. Zero statements are issued, so the
failure is before the resolver body.

The consequence the chapter prints: the entity route runs without the projection
chapter 3 built.

### The two statements, side by side

Same session, same single field selected, both against a freshly seeded
database:

```sql
-- node(id: "U2Vzc2lvbjox") { ... on Session { title } }
SELECT "s"."Title"
FROM "Sessions" AS "s"
WHERE "s"."Id" = @id
LIMIT 1

-- _entities, one Session representation, same selection
SELECT "s"."Id", "s"."Abstract", "s"."DurationMinutes", "s"."SpeakerId", "s"."StartsAt", "s"."Title"
FROM "Sessions" AS "s"
WHERE "s"."Id" = @key
LIMIT 1
```

One column against six. Both are asserted in `verify.ps1` by matching the
statement text rather than the count, because the count is the same and the
count is not what the section is about.

### The counts

| Request | Statements |
|---|---|
| 1 `Session` representation | 1 |
| 3 `Session` representations | 3 |
| 3 `Speaker` representations | 1 |
| 2 `Speaker` and 1 `Session`, mixed | 2 |
| `_service { sdl }` | 0 |

`SessionType`'s reference resolver queries directly and `SpeakerType`'s goes
through the DataLoader chapter 3 built, which is the whole difference between
3 and 1. This is the same mechanism chapter 4 recorded for `nodes`, and it is
chapter 10's subject; chapter 6 prints the counts and does not argue about them.

### Everything the entity route does with a bad representation

All at HTTP 200 unless noted. Each row is asserted at `ch06`.

| Representation | Answer |
|---|---|
| a key matching no row | `[null]`, no `errors` key |
| a `Speaker` key under `__typename: "Session"`, **guarded** | `[null]`, no statement issued |
| a `Speaker` key under `__typename: "Session"`, **unguarded** | the session with that number, no error. `ch06-unguarded` |
| `id: "not-an-id"` | field error `The node ID string has an invalid format.` with `extensions.originalValue`, and `[null]` in that position only |
| `__typename` of a type with no `@key` | `Unexpected Execution Error`, and the whole `_entities` field is null rather than one entry |
| a representation with no `id` at all | `Unexpected Execution Error`; the underlying exception is `ArgumentNullException` on a parameter named `formattedId` |

The last two are recorded and **not printed**. The specification does not
address either case, as recorded in the web half above, so whatever this package
does with them is an implementation choice rather than a required behaviour and
the chapter would be teaching a local accident.

### `_service`

Returns the exported schema. Compared programmatically rather than by eye: the
string `_service { sdl }` returns and the bytes of `schema.graphql` are equal
after normalising CRLF to LF, and `verify.ps1` asserts that equality on every
run rather than asserting a length or a substring.

It carries descriptions, the `@cost` directives, and the federation additions
themselves. **Which contradicts the package's own description of `_Service`**,
generated into the schema, which says the returned document "does not include
the additions of the federation spec". It does. The chapter says so and trusts
the string.

Costs 0 statements. Reachable from an ordinary introspection query: asking for
the fields of `Query` lists `node`, `nodes`, `sessions`, `_service` and
`_entities`. `sessionById` is absent from the same list because chapter 4
deprecated it, which is the contrast the chapter draws.

### `@shareable` arrives without being asked for

`AddApolloFederation()` puts `@shareable` on all four fields of the generated
`PageInfo` type. Nothing in this book applies it. It also adds `@shareable` to
the `@link` import list, which is how the import list gives the change away.

It does **not** put `@shareable` on `Query.node` or `Query.nodes`, which is the
collision chapter 5 recorded against this book and which chapter 7 has to pay.
Both halves are asserted, because the chapter's paragraph rests on the contrast
rather than on either fact alone.

## HotChocolate 14.3.1

The largest version difference this book has met, and the first one that is not
a difference in output but in whether the code works at all.

### The attributes compile and are never read

At `ch06-hc14-ignored`: `HotChocolate.ApolloFederation` 14.3.1 restores,
`AddApolloFederation()` runs, and the same `[Key("id")]` and
`[ReferenceResolver]` that work on 16 produce a schema with

- no `@key` on any type
- no `_entities` on `Query`
- no `union _Entity`
- `@key` absent from the `@link` import list

while `_service`, `_Service`, `scalar _Any`, `scalar FieldSet`, the `@link` line
and `@shareable` on `PageInfo` all arrive exactly as on 16. So the failure is
precisely the entity half, and it is silent: a composer reading `_service` finds
a subgraph it cannot route into rather than an error.

**And it is not inert.** The method named by `[ReferenceResolver]` is published
as a field despite `[GraphQLIgnore]`, and it lands on `Speaker` rather than on
`Query`:

```graphql
type Speaker implements Node {
  id: ID!
  """
  The same reference resolver main carries, to find out what 14
  does with it.
  """
  resolveSpeakerReference(id: String!): Speaker @cost(weight: "10")
}
```

A type with a field taking an id and returning a different instance of itself,
with the doc comment as its description. Asserted at that tag by querying it
through `node(id:)` and getting a different speaker back.

### What works instead

A code-first `ObjectType<Speaker>` calling `.Key("id")` and
`.ResolveReferenceWith(...)`. Both directives apply, because the descriptor
calls are made rather than discovered. At `ch06-hc14` the exported schema
carries `@key(fields: "id")` on `Speaker`, `_entities` on `Query`,
`union _Entity = Speaker`, and no leaked field, and a live `_entities` request
answers correctly with the same batching and the same type-name guard.

The `Configure` body the callout prints, from
`src/Sessions/SpeakerType.cs` at that tag:

```csharp
protected override void Configure(
    IObjectTypeDescriptor<Speaker> descriptor)
{
    descriptor
        .ImplementsNode()
        .ResolveNodeWith(
            typeof(SpeakerType).GetMethod(
                nameof(ResolveByKeyAsync))!);

    descriptor
        .Key("id")
        .ResolveReferenceWith(
            _ => ResolveReferenceAsync(default!, default!));
}
```

`ResolveByKeyAsync(IResolverContext, int)` and
`ResolveReferenceAsync(string, IResolverContext)` are the two methods it points
at, both public because the descriptor reaches them by reflection. The second
does the same `Parse` and the same `TypeName` comparison the 16 resolvers do; it
reaches the serializer through `context.Schema.Services` rather than by
injection, because a code-first resolver's parameter list is bound differently.

The cost is the class. `[ObjectType<Speaker>]` and `ObjectType<Speaker>` are two
declarations of one type and collide, so the type leaves the source generator
entirely. That is what the chapter's callout is about.

Two details found the hard way. `.ResolveNodeWith` takes a `MethodInfo` on 14
where `.ResolveReferenceWith` two lines below it takes an expression lambda;
passing a lambda to the first is `CS1660`. And because `_Entity` is
`= Speaker` on this branch, a fragment spread on `Session` inside an `_entities`
query is a validation error rather than an empty match, which is the union doing
its job and which broke the first version of the branch's assertions.

Session is left unkeyed on `hc14` under decision 47: the callout quotes one
entity, so the branch carries one.

### Four printer differences, none of them federation's

Recorded because they are in the expectations table and could otherwise look
like federation behaving differently. 14 escapes the slashes in the `@link`
url, puts spaces inside the import brackets, orders the import list
`["@key", "@tag", "@shareable", "FieldSet"]` where 16 writes
`["@key", "@shareable", "@tag", "FieldSet"]`, and writes the `@key` arguments
with no comma between them.

## Two assertions narrowed, and why that is not loosening

Chapter 4 asserted `type Session implements Node {` and
`type Speaker implements Node {` as whole lines. Chapter 6 appended
`@key(fields: "id")` to both headers, so the brace moved and both assertions
failed. They now read `type Session implements Node` without the brace, which
asserts what chapter 4 meant by them, and chapter 6's own block asserts the key
separately.

Two absence checks written while drafting were **wrong in a way that would have
passed**. `$schema.Contains('_entities')` is true on a subgraph with no entity
route at all, because the generated description of `scalar _Any` contains the
words "root `_entities` field". `$schema.Contains('scalar FieldSet')` is true on
both versions whether or not any key uses it. Both were rewritten to match the
field and the union declarations precisely. A check that passes for the wrong
reason is worse than no check, and these two would have reported that 14
federates.

## What the specification requires of a subgraph

All quotations in this section are from Apollo's *Apollo Federation Subgraph
Specification*, fetched 2026-08-23 at
`https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec`
(final URL after redirects; the fetched URL and the final URL are the same).

Chapters 1 and 5 already cite this document, on the reasoning SPEC decision 39
records: it is the normative list of what a specification requires of an
implementation, every line of it can be checked against a running server, and
that check is what a byline would otherwise be standing in for. The reasoning
carries here unchanged, and this chapter is the one that actually performs the
check, because it has a running subgraph to perform it against.

**Re-verified, unchanged.** Every quotation chapter 5's note recorded from this
page was re-extracted byte for byte on 2026-08-23 and still matches, including
the `@key` definition and the ordering sentence. Nothing in the chapter 5 note
needs correcting.

### `_service`, in full

The section is headed *Enhanced introspection with `Query._service`*, and the
heading is the answer to what the field is for.

> Some federated graph routers can compose their supergraph schema dynamically
> at runtime. To do so, a graph router first executes the following enhanced
> introspection query on each of its subgraphs to obtain all subgraph schemas:

The passage ends on a colon and runs straight into a code block holding
`query { _service { sdl } }`. The chapter quotes it with that colon, which is
the source's own punctuation; an earlier draft closed the quotation with a
period the source does not have.

The page then argues against the use case it has just described, in a caution
callout:

> Apollo strongly recommends against dynamic composition in the graph router.
> Dynamic composition can cause unexpected downtime if composition fails on
> router startup. Nevertheless, supporting this use case is still a requirement
> for subgraph libraries.

And, in a note callout:

> The `_service` field is not included in the composed supergraph schema. For
> security reasons, it's intended solely for use by the graph router.

That second callout is worth the chapter's attention, because the field is not
hidden from anybody: it is on `Query`, it introspects, and any client that can
reach the subgraph can ask for it. What the sentence describes is an intention,
not a control. Chapter 12 is the chapter about the difference, and this is the
same shape of mistake in a smaller form.

The requirements on the returned string:

> `Query._service` returns a `_Service` object, which in turn has a single
> field, `sdl` (short for schema definition language). The `sdl` field returns a
> string representation of the subgraph's schema.

> The returned `sdl` string has the following requirements:
> - It must include all uses of all federation-specific directives, such as
>   `@key`.
> - If supporting Federation 1, `sdl` must omit all automatically added
>   definitions from Subgraph schema additions, such as `Query._service` and
>   `_Service.sdl!` If your library is only supporting Federation 2, `sdl` can
>   include these definitions.

> The value returned for the `sdl` field should include all of this
> information, including directives (excess whitespace can be removed).

Restated in the page's own glossary of schema additions:

> **type _Service** - This object type must have an `sdl: String!` field, which
> returns the SDL of the subgraph schema as a string. The returned schema string
> must include all uses of federation-specific directives (`@key`, `@requires`,
> etc.). If supporting Federation 1, the schema must not include any definitions
> from Subgraph schema additions.

**Three questions asked of this text, and what it actually answers.**

- *Must `sdl` be the schema as the author wrote it, or the schema after the
  library's own additions?* The specification does not put it in those terms.
  It requires that every **use** of a federation directive appear, and it makes
  whether the automatically added **definitions** may appear conditional on
  Federation 1 support: a library supporting Federation 1 must omit them, and a
  Federation-2-only library may include them. So the answer for any given
  library is a property of that library, not of the specification, and the
  chapter has to read it off the running service rather than state it.
- *Is anything said about descriptions, or about a normalized printing?* One
  clause, and only one: excess whitespace can be removed. Descriptions are not
  mentioned at all, in either direction.
- *Who calls it, and when?* The router, at startup, and only where the router
  composes dynamically. No CLI is named. Which makes the field's practical
  audience narrower than its visibility, and that gap is the paragraph above.

### `_entities`, and the algorithm

The section is headed *Resolving `Query._entities`*, and the numbering below is
the page's own, confirmed from its HTML list markup rather than from the
rendered text:

> Every subgraph must also automatically define the resolver for this field. The
> logic for this resolver is as follows:
>
> 1. Create an empty array that will contain the entity objects to return.
> 2. For each entity representation included in the `representations` list:
>    1. Obtain the entity's `__typename` from the representation.
>    2. Pass the full representation object to whatever mechanism the library
>       provides the subgraph developer for fetching entities of the
>       corresponding `__typename`.
>    3. Add the fetched entity object to the array of entity objects. Make sure
>       objects are listed in the same order as their corresponding
>       representations.
> 3. Return the array of entity objects.

The page then splits the work between the library and the developer, naming its
own step:

> Notice in step 2.2 above that the subgraph developer is responsible for
> defining logic that fetches a particular entity based on its representation.
> The subgraph library is responsible for providing the mechanism that
> developers use to specify this logic, and for automatically hooking into this
> mechanism in the resolver for `Query._entities`.

That division is the whole of what a reference resolver is: step 2.2 is yours
and every other step is the package's. It is also why the specification does not
prescribe an attribute or a method name, and says so:

> Your subgraph library does not need to use this reference resolver pattern. It
> just needs to provide and document some pattern for defining entity-fetching
> logic.

The order and null rule is restated in this section as a reminder, in the same
words chapter 5 quoted:

> The `Query._entities` field must return a list of entity objects that
> correspond to the provided representations, in the exact same order. Entries
> in the list can be null if no entity exists for a provided representation.

**A gap in the specification, recorded because the chapter meets it.** The text
above does not distinguish a representation that names an entity which does not
exist from a representation whose `__typename` names a type this subgraph does
not define. Only the first is addressed, as "no entity exists for a provided
representation". The second is not addressed anywhere in the section. Whatever
this package does with it is therefore an implementation choice rather than a
required behaviour, and the chapter must say so if it prints it.

### Entity stubs, and `resolvable: false`

Not addressed on the subgraph specification page, which contains the word
"stub" nowhere, and not addressed on *Introduction to Entities* either, which
contains neither "stub" nor "resolvable". It is on a third page,
*Contribute and Reference Entity Fields*, fetched 2026-08-23 at
`https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/entities/contribute-fields`,
under the heading *Referencing an entity without contributing fields*:

> To fix this, add a stub of the `Product` entity to the Reviews schema, like
> so:

```graphql
type Review {
  product: Product!
  score: Int!
}

type Product @key(fields: "id", resolvable: false) {
  id: ID!
}
```

> A stub definition includes only the `@key` fields of an entity. In this case,
> the `Product` type definition only includes the `id` field. It also includes
> `resolvable: false` in the `@key` directive to indicate that this subgraph
> doesn't define a reference resolver for the `Product` entity.

**This matters for chapter 9 and not for chapter 6**, because chapter 6 ships
one service which owns both of its types and declares no stub at all. It is
recorded here rather than left for chapter 9 to find, because chapter 5 already
printed the Sessions subgraph's `Speaker` stub as

```graphql
type Speaker @key(fields: "id") {
  id: ID!
}
```

with no `resolvable: false`, and that map composed - the chapter 5 note records
the successful `wgc router compose` run. So the two are not in conflict about
what composes; Apollo's guidance is about what a stub should say, and the map
chapter 5 printed does not say it. Which of the three stub-shaped declarations
in that map actually wants the argument is a question with a real answer, and
it is chapter 9's: Sessions' `Speaker` never resolves a Speaker and wants
`resolvable: false`; Ratings' `Session` contributes two fields of its own and
must stay resolvable. Carried into the SPEC's open items.

### A one-subgraph graph

Fetched 2026-08-23. The request went to
`https://www.apollographql.com/docs/graphos/get-started/concepts/graphs`, which
redirects; the final URL is
`https://www.apollographql.com/docs/graphos/resources/concepts/graphs`.

> Because the [GraphOS Router] provides advantages beyond support for multiple
> subgraphs, you may choose to start a supergraph with just one subgraph and a
> router.

> Though this graph has only one subgraph, it's still considered a supergraph
> rather than a monograph because of the presence of the router.

and the same page's glossary entry:

> A graph that operates on a standalone GraphQL server which receives queries
> directly from client applications, without a router.

**Recorded, and not used in chapter 6.** The distinction turns on the presence
of a router, and chapter 6 has no router: it ships one subgraph and composes
nothing. So the quotation does not support the sentence a chapter 6 draft would
want it for. It belongs to chapter 8, which is where a router first appears,
and it is recorded here so that chapter does not have to find it again. The
same page's next sentence lists product features of Apollo's own router, which
is a vendor arguing for its own product and is barred either way.

## What is not documented anywhere

### ChilliCream, re-checked

`https://chillicream.com/docs/hotchocolate/v16/` answers 301 and the final URL
is `https://chillicream.com/docs/hotchocolate`. The versioned path segment is
gone from the site rather than broken: the redirect drops `/v16/` and lands on
the unversioned current documentation.

The sitemap at `https://chillicream.com/sitemap.xml` carries 254 URLs, 68 of
them under `/docs/hotchocolate/`. **None mentions Apollo Federation or
subgraphs.** The only federation pages on the site belong to a different
product, Fusion, and both are about Fusion consuming or migrating from Apollo
Federation rather than about authoring a subgraph:
`https://chillicream.com/docs/fusion/connectors/apollofederation` and
`https://chillicream.com/docs/fusion/migration/coming-from-apollo-federation`.

Chapter 5's note recorded this as of 2026-08-23 and it holds on re-check the
same day, with one detail sharpened: the v16 path does not 404, it redirects,
and the page it redirects to has no federation content either.

### No guidance anywhere on a global object identification id as a key

Searched Apollo's documentation for it directly, including the entity key
design guidance under *Thinking in Entities*, which is the page that would
carry it. Zero matches for "opaque", for "relay", and for a global id used as a
`@key`. This is a real absence rather than a failed fetch: the most likely page
was fetched and read and is silent.

Chapter 4 put every entity in this book behind a global node id, and chapter 5
argued from it that the book already has its keys. That argument is therefore
**mine and not Apollo's**, and SPEC decision 38 says what to do about it: state
it as my judgment, in first person, and cite nobody. The chapter does that
rather than citing a page that does not say it.

### The package's own documentation is XML doc comments

`HotChocolate.ApolloFederation` 16.6.1's `.nuspec`, fetched 2026-08-23 at
`https://api.nuget.org/v3-flatcontainer/hotchocolate.apollofederation/16.6.1/hotchocolate.apollofederation.nuspec`,
gives `projectUrl` as `https://chillicream.com/` and pins the repository to
`https://github.com/ChilliCream/graphql-platform.git` at commit
`5121c37e16f2ab6bf8dfb8bdbd2ec96e2d86737a`. There is no README under the
ApolloFederation subproject at that commit, checked through the GitHub trees
API. The prose that exists is XML doc comments on the attribute classes:

`src/HotChocolate/ApolloFederation/src/ApolloFederation/Types/Directives/KeyAttribute.cs`
at that commit gives the constructor as
`public KeyAttribute(string fieldSet, bool resolvable = true)` and says of the
non-resolvable form that it "indicates to router that given entity should never
be resolved within given subgraph", which "allows your subgraph to still
reference target entity without contributing any fields to it". That is
ChilliCream restating Apollo's stub pattern independently, in near-identical
words.

`src/HotChocolate/ApolloFederation/src/ApolloFederation/Resolvers/ReferenceResolverAttribute.cs`
says the reference resolver "enables your gateway's query planner to resolve a
particular entity by whatever unique identifier your other subgraphs use to
reference it", and declares the attribute on `Class | Interface | Struct |
Method` with `AllowMultiple = true`, plus `EntityResolver` and
`EntityResolverType` properties for pointing at a resolver defined elsewhere.

**Recorded and not cited.** The book's Sources rule says that an identifier in
a source tree is evidence that somebody once meant something by it and nothing
more, and a doc comment is only a longer version of the same thing: it is what
the author intended, not what the assembly does. Everything above was useful for
knowing what to try, and every behavioural claim the chapter makes is measured
from the running service instead. The two agreed wherever the chapter relies on
them, which is recorded rather than assumed.

### The version, re-confirmed

`https://api.nuget.org/v3-flatcontainer/hotchocolate.apollofederation/index.json`,
fetched 2026-08-23: **16.6.1 is still the newest stable**. A prerelease train
`16.6.2-p.1` through `16.6.2-p.6` exists above it with no stable `16.6.2`, so a
16.6.2 could land before the book ships. Decision 35 keeps versions out of
sentences and appendix A is re-verified before release, which is the mechanism
that handles this; recorded so that the appendix A pass knows a bump is likely
rather than hypothetical.

## Claims checked and found false

Measured, in the order the chapter would have got them wrong.

- **That `[ID<T>]` decodes a node id in a reference resolver.** It does not. It
  yields 0 and the entity answers null, silently, with no error anywhere.
  Measured twice, once with `[ID]` and once with `[ID<Speaker>]`.
- **That `QueryContext<T>` can be injected into a reference resolver.** It
  cannot. It compiles, builds a schema, starts the service, and fails at request
  time with `Unexpected Execution Error` and no logged exception.
- **That `EntityResolverType` is required on `[ReferenceResolver]`.** It is not,
  when the named method is in the same class. Removed from both resolvers, and
  the schema and every assertion were unchanged.
- **That `INodeIdSerializerAccessor` is the way to reach the serializer.** It
  works and is three lines longer than necessary. `INodeIdSerializer` injects
  directly into a reference resolver, with or without `[Service]`.
- **That `Parse`'s second argument is the entity type.** It is the CLR type of
  the key. Passing the entity type throws the same message a genuinely malformed
  id produces, so the message points away from the mistake.
- **That the package's own `_Service` description is accurate.** The generated
  description says the returned document "does not include the additions of the
  federation spec". The document includes them.
- **That `[Key]` on the domain record works.** It compiles and produces no key.
  The attribute is read off the class the generator builds the type from.
- **That the 14.3.1 attributes fail loudly, or fail completely.** They compile
  with no warning, produce no entity half at all, and publish the resolver
  method as a public field despite `[GraphQLIgnore]`.
- **That Apollo documents a global object identification id as a `@key`.** It
  does not, anywhere that could be found. The claim is the author's under
  decision 38.
- **That the specification says what to do with a representation naming a type
  the subgraph does not define.** It does not. It addresses only the case where
  no entity exists for a representation, so what this package does with the
  other case is an implementation choice and no chapter prints it.

Two of these were caught by writing the assertion before the prose, which is
the point of the order this book works in. The `[ID<T>]` one would have shipped
as a working listing.

## Where the chapter's counts come from

Every number printed in chapter 6, and the request that produces it. Check out
the tag named and run `pwsh verify.ps1` to reproduce any row.

| Count | Request | Tag |
|-------|---------|-----|
| 1 statement | `_entities` with one `Session` representation | `ch06` |
| 3 statements | `_entities` with three `Session` representations | `ch06` |
| 1 statement | `_entities` with three `Speaker` representations | `ch06` |
| 1 column | `node(id:)` selecting `title`, statement text asserted | `ch06` |
| 6 columns | `_entities` selecting `title`, statement text asserted | `ch06` |
| 0 statements | `_service { sdl }` | `ch06` |
| 0 statements | a guarded representation whose key names another type | `ch06` |
| 4 directives | `@shareable` on `PageInfo`, counted in the exported schema | `ch06` |
| 148 assertions | the whole script | `ch06` |
| 9 assertions | the whole script | `ch06-unguarded` |
| 125 assertions | the whole script | `ch06-hc14-ignored` |
| 128 assertions | the whole script | `ch06-hc14` |

## A judgment recorded rather than left implicit

Decision 16 says a change to an already-shown file is typeset as the full file
again with `highlightlines`, or as the complete enclosing member where the file
is too long to reprint. Chapter 6 shows the reference resolvers twice, once
without the type name guard and once with it.

`SessionType.cs` is reprinted in full both times, which is the first form.
`SpeakerType.cs` is printed in full once, and the second change to it is
described in prose rather than reprinted, because the two files take the same
nine-line insertion in the same place and printing it twice would be the same
paragraph twice. Appendix E carries both in their final state under decision 17.

The alternative considered and rejected: printing the guard alone as a four-line
listing. That is a fragment under decision 15 whatever its provenance, and this
book does not print fragments.

## The cold audit, and what it changed

One read-only agent with no drafting context, briefed per the draft-chapter
skill's audit reference. It ran after both gates were already clean, so
everything below is the half no script checks. Accepted findings, in the order
they mattered:

- **A response quoted that the service never returned.** The chapter shortened
  the `QueryContext` failure to `{"errors":[{"message":"Unexpected Execution
  Error"}]}`, dropping the `path` and the `data` keys. No tagged state produces
  that response at all, so decision 53 applies: the chapter now describes the
  failure in prose and says why it is not printed.
- **A file printed that exists at no tag.** Section 1 printed an intermediate
  `SpeakerType.cs` carrying the two attributes but not the method they name,
  described as not compiling. Nothing builds that state, so under decision 48 it
  was unprovable. Section 1 now names the two attributes in prose and section 3
  prints both type classes for the first time.
- **`highlightlines` marked the wrong line.** In `Program.cs` it marked
  `.AddMutationConventions()`, which lost a semicolon, rather than
  `.AddApolloFederation()`, which is the new call. Chapter 4's equivalent
  listing marks the new calls, and this now matches it.
- **`highlightlines` marked an unchanged line.** The section 1 listing marked
  `[ObjectType<Speaker>]`, which chapter 4 already printed.
- **Two elisions were undeclared.** The exported schema excerpt drops
  descriptions and `@cost` directives and the `PageInfo` excerpt drops its four
  descriptions; chapters 3, 4 and 5 all say so when they elide and this chapter
  did not. Both now say so.
- **Two request bodies were not valid JSON.** They wrapped inside the `query`
  string literal, so a reader typing one under decision 34 would send a
  malformed body. Chapter 4 already had the answer: put the operation in its own
  block, stand it in with a placeholder, and wrap the envelope between tokens.
- **A quotation gained a period the source does not have**, and a displayed
  quote's `~\autocite{}` sat on the wrong sentence under decision 61.
- **Versions named in sentences**, against decision 35: the package's federation
  version range, and `14.3.1` in the callout. Both removed; appendix A carries
  the numbers and decision 63 covers only the printed `@link` url.
- **`neighbours`**, the book's first en-GB spelling in prose. Decision 29 sets
  `en-US` and the exemption list is empty, and the gate did not catch it, which
  is a retro item rather than a licence.
- **A hardcoded chapter number in a subsection heading.**
- **Three claims that were true of a section and stated of the chapter**, or
  true of a later state and stated of the current one: that the chapter uses
  only one half of the decoded key, that the counts arrive "without a router in
  sight" while the figure beside them draws a router, and that `@key` "was not
  before" in an import list that did not exist before.
- **An instruction a reader could follow into a wrong file.** The prose said
  `SpeakerType`'s guard takes `Speaker` in place of `Session`; both nouns swap,
  in both directions, and the shipped comment says so.
- **Voice.** The chapter carried no first person at all, against decision 26 and
  against chapters 4 and 5, which both use it for judgment. Four judgments are
  now in first person, at the points where the book is choosing rather than
  reporting.
- **Humanizer findings**, all accepted: an aphorism formula ("the currency of"),
  a four-fragment staccato run, a negative parallelism stacked on a rule of
  three, six uses of one "worth X-ing" frame in one chapter where earlier
  chapters use it once each, two difficulty-flattening constructions, a callout
  that announced itself, and a paragraph narrating its own authorial choice.

One finding was **rejected**, and the reason is here because a rejection that is
not written down cannot be told from an oversight:

- **"The counts table is typeset as `minted{text}`, the environment the psd1
  treats as captured tool output, and nothing in it came off a console."**
  Raised as unsure. Rejected: chapter 4 section 5 already displays a mapping
  the same way, `string Title -> title: String!`, and neither block claims to
  be a capture. The `AllowInCapturedListings` setting is a character-class
  exemption for output that carries punctuation this book does not use, not a
  declaration that every `minted{text}` block is a transcript. Nothing in either
  block needs the exemption.

Two of the auditor's findings could not be checked by the auditor itself,
because its tools did not include a shell: it could read the verification repo's
working tree but not `git show` the other three tags. Every C# and XML listing
in the chapter was therefore diffed against its tag afterwards, mechanically,
and all five match byte for byte: `Sessions.csproj` and `Program.cs` at `ch06`,
both type classes at `ch06-unguarded`, and `SessionType.cs` at `ch06`.
