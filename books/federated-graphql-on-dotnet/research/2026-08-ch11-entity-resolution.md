# Chapter 11 research - entity resolution done right

Research date: 2026-08-09. Every number and every listing in this file was
captured from a running service on the author's machine, or read out of a
primary source at a pinned version. Internals claims are read from
`ChilliCream/graphql-platform` at tag `16.6.0`, commit `8fea46e`, cloned at
F:/repo/graphql-platform (decision 32).

The chapter's companion code is `mosaic-graph` at tag `ch11`. Two things are
new: `Product.shippingCost` in `Mosaic.Api`, the first field in Mosaic that
cannot be answered without Catalog; and `samples/entity-resolution`, two tiny
subgraphs where a reference resolver writes down every call made to it.

## Contents

- A. Version baseline
- B. What `_entities` does with a list of representations
- C. Measured: batching, and what breaks it
- D. How a required field reaches the resolver
- E. `@requires` on Mosaic: the code and the schema
- F. `@requires` on the wire
- G. What `@requires` costs
- H. What the composer says about `@external`
- I. `@provides`, and why Mosaic has no honest use for one
- J. Nullability at the boundary
- K. Where docs and behaviour disagree
- L. What the gate asserts
- M. Reproduction recipes
- N. Left unmeasured, and who owns it
- O. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; unchanged since chapter 8 |
| graphql-platform source | tag `16.6.0`, commit `8fea46e` | `git log --oneline -1` and `git describe --tags` in F:/repo/graphql-platform |
| WunderGraph Cosmo Router | 0.337.1 | `ghcr.io/wundergraph/cosmo/router:0.337.1`, pinned in `docker-compose.yml` |
| wgc (Cosmo CLI) | 0.129.7 | pinned exactly in `package.json`; unchanged since chapter 9 |
| .NET SDK | 10.0.302 | `dotnet --version` |
| node | 24.15.0 | `node --version` |
| Apollo Federation specification | v2.15 | unchanged from the SPEC baseline |

## B. What `_entities` does with a list of representations

Read out of the source tree, not inferred.
`src/HotChocolate/ApolloFederation/src/ApolloFederation/Resolvers/EntitiesResolver.cs`
at tag `16.6.0` is the whole of it, and the shape is two loops. [source]

The first loop walks the representations. For each one it looks the type name
up in the schema, checks that the type carries a `ReferenceResolver` feature,
**clones the resolver context**, puts the type and the representation into the
clone's local state, and starts a task. It does not await it. The source says
why in a comment: \enquote{We clone the resolver context here so that we can
split the work into subtasks that can be awaited in parallel and produce
separate results.}

The second loop awaits the tasks in order and writes the results into an array
at the representation's index.

Three consequences the chapter uses:

1. **One call per representation.** There is no batch-shaped entry point. A
   reference resolver never sees the list.
2. **Every call is started before any is awaited.** That is the condition a
   DataLoader needs: N `LoadAsync` calls enqueue N keys before the first one
   blocks, so one batch forms.
3. **A failure is scoped to its index.** The second loop branches first on
   `task.IsCompleted`: a finished task is inspected for `task.Exception`
   without being awaited, and only the unfinished branch has a `try`/`catch`
   around the await. Either branch sets `result[i] = null` and calls
   `ReportError`, which appends the index to the field path. Nothing else in
   the batch is affected. The branch that matters for section C's naive
   resolver is the first one, because a synchronous resolver is always already
   complete by the time the second loop reaches it.

`ThrowHelper.EntityResolver_NoResolverFound()` is thrown when neither an
object type nor an interface type with a reference resolver matches
`__typename`. That is a throw out of the whole field rather than a per-index
null.

## C. Measured: batching, and what breaks it

Measured on `samples/entity-resolution`, tag `ch11`, through
`scripts/entity-cases.mjs`. `Widget` has a DataLoader-backed reference
resolver; `Gadget` is the same entity with a resolver that fetches one key at a
time. Both write to a static log the subgraph exposes as
`Query.resolutionLog`.

Four widgets in one `_entities` call. Case `batch-is-one-lookup`:

```
enter  Widget/w1
enter  Widget/w2
enter  Widget/w3
enter  Widget/w4
lookup 4 keys: w1, w2, w3, w4
leave  Widget/w4
leave  Widget/w3
leave  Widget/w2
leave  Widget/w1
entries: 4 on 1 thread(s)
```

All four entered before the store was touched; one journey for four keys; and
the four returns are in a different order from the four entries, which is
GreenDonut completing them as the batch resolves rather than in key order. The
`entries:` line is derived by the log itself from the managed thread id of each
`enter`, because a raw thread number is a different number on every run.

Four gadgets, same call shape. Case `naive-is-four-lookups`:

```
enter  Gadget/w1
lookup 1 key: w1
leave  Gadget/w1
enter  Gadget/w2
lookup 1 key: w2
leave  Gadget/w2
enter  Gadget/w3
lookup 1 key: w3
leave  Gadget/w3
enter  Gadget/w4
lookup 1 key: w4
leave  Gadget/w4
entries: 4 on 1 thread(s)
```

This is the finding worth having, and it is not \enquote{four lookups instead
of one}. It is that the four calls ran **in sequence**. Section B's first loop
starts a task per representation, but a task whose body completes
synchronously - which the naive resolver's does, because the store hands back a
`Task.FromResult` - runs to completion inside the loop iteration that started
it. The concurrency in `EntitiesResolver` is exactly as real as the awaits
inside the resolver it calls, and no more.

Four representations of the same key. Case `duplicate-keys-collapse`:

```
enter  Widget/w1
enter  Widget/w1
enter  Widget/w1
enter  Widget/w1
lookup 1 key: w1
leave  Widget/w1
leave  Widget/w1
leave  Widget/w1
leave  Widget/w1
entries: 4 on 1 thread(s)
```

Four resolver calls, one key looked up: the DataLoader deduplicates within the
batch. Four entities come back, all populated.

## D. How a required field reaches the resolver

Also read out of the source tree.
`Resolvers/ExternalSetterExpressionHelper.cs` and
`Features/ExternalSetter.cs` at tag `16.6.0`. [source]

The reference resolver does **not** receive the required fields. It receives
the key parameters it declares, returns an entity, and then
`EntitiesResolver.ResolveEntityInternalAsync` does this:

```csharp
var entity = await resolver(context);

if (entity is not null
    && type.Features.TryGet(out ExternalSetter? externalSetter))
{
    externalSetter.Invoke(context.Schema, type, representation, entity);
}
```

The setter is a compiled expression tree built once per type at schema build.
`ExternalSetterExpressionHelper.BuildFiller` walks the object type's fields and
emits a `TrySetExternal` call for every field whose member is a settable
property. `ReferenceResolverHelper.TrySetExternal` writes the value only if the
representation carries one at that path.

Two details of that walk matter and neither is documented:

- **Key fields are skipped.** The source comment: fields in a `@key`
  \enquote{identify the entity and are owned by the reference resolver}, so the
  resolver's values are preserved rather than overwritten.
- **`@external` is not consulted for object types.** `TryAddExternalSetter` has
  two overloads. The object-type one delegates to `BuildFiller`, which tests
  only that the field's member is a `PropertyInfo` with a setter. The
  interface-type one checks
  `field.Directives.ContainsDirective<ExternalDirective>()` on every field. The
  object overload is the one that runs for every entity in this book. The class
  summary states the intended rule in general terms, in a sentence that wraps
  across two source lines: "The representation is authoritative wherever it
  carries a value, while resolver values survive where it is silent."

Measured, case `representation-overwrites-owned-field`, on the sample's
`Widget`, whose `name` is owned by that subgraph and carries no `@external`:

```
representation 0 -> Hex bolt
representation 1 -> NOT WHAT THE STORE SAYS
representation 2 -> Split washer
```

Representation 1 carried `name: "NOT WHAT THE STORE SAYS"` and won.
Representation 2 carried a field the type does not have, `nonsense: 42`, and
was ignored. The router never sends fields it was not asked to send, so this is
not reachable through a router; it is reachable by anything that can post to
the subgraph. Chapter 25 owns whether a subgraph should be reachable at all.

The practical consequence for chapter 11's own code: the property behind an
`@external` field **must have a setter**. A get-only property compiles,
composes, and answers null for every entity.

## E. `@requires` on Mosaic: the code and the schema

`Product.shippingCost` is the first Mosaic field that needs something Catalog
owns. The rate is a property of what the thing is; what the thing is belongs to
Catalog.

`src/Mosaic.Api/Catalog/Model/Product.cs` gains:

```csharp
[External]
[GraphQLNonNullType]
public ProductCategory? Category { get; set; }
```

`src/Mosaic.Api/Pricing/Types/ProductPricingNode.cs` gains
`GetShippingCostAsync`, carrying `[Requires("category")]`, taking `[Parent]
Product` and the same `IPriceByProductIdDataLoader` that `price` uses.
`src/Mosaic.Api/Pricing/Model/ShippingRates.cs` holds the table: furniture
39.00, lighting 9.90, storage 7.90, kitchen 5.90, textiles 4.90, waived at or
above 100 in the product's own currency except for furniture.

`[GraphQLNonNullType]` on a nullable C# property is deliberate and section H
records why: the two nullabilities are right about different things.

The published SDL, from `schema/mosaic.graphql` at tag `ch11`:

```graphql
type Product @key(fields: "id") {
  availableQuantity: Int!
  price: Money!
  shippingCost: Money! @requires(fields: "category")
  reviews(...): ReviewConnection!
  averageRating: Float
  id: ID!
  category: ProductCategory! @external
}
```

The `@link` import list grew two entries on its own, with nothing in
`Program.cs` changed:

```graphql
import: ["@external", "@key", "@requires", "@shareable", "@tag", "FieldSet"]
```

`ProductCategory` is declared a second time, in
`src/Mosaic.Api/Catalog/Model/ProductCategory.cs`, with the same five members
Catalog has. It is a copy on purpose, like `ProductKey`, and unlike
`ProductKey` it is visible in the schema, so the composer checks it.

## F. `@requires` on the wire

Captured from the router with Advanced Request Tracing rather than from a
subgraph log, because Mosaic has no request-body logging and chapter 10
recorded that it never will have. The header is `X-WG-Trace: true`; two other
spellings were tried, `X-WG-Trace-Enabled` and `X-WG-Include-Trace`, and both
are ignored. Development mode is what makes it work without a graph token.

The query, with `category` deliberately **not** selected by the client:

```graphql
{ browseProducts(first: 2) { nodes { title shippingCost { amount } } } }
```

What the router sent Catalog, out of `extensions.trace.fetches`:

```json
{
  "query": "query($a: Int){browseProducts(first: $a){nodes {title category __typename id}}}",
  "variables": { "a": 2 }
}
```

`category` is in that document because `shippingCost` requires it. The client
never sees it.

What the router then sent Mosaic:

```json
{
  "query": "query($representations: [_Any!]!){_entities(representations: $representations){... on Product {__typename shippingCost {amount}}}}",
  "variables": {
    "representations": [
      { "__typename": "Product", "category": "KITCHEN", "id": "UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAW" },
      { "__typename": "Product", "category": "FURNITURE", "id": "UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAE" }
    ]
  }
}
```

The representation is a key plus a required field. That is the whole mechanism.

The same trace corroborates chapter 10's `localhost_fallback_inside_docker`
finding from a direction that chapter did not have: `load_stats.connect_done`
carries `err: "dial tcp 127.0.0.1:5101: connect: connection refused"` while
`get_conn.host_port` is `host.docker.internal:5101`. The router tries the
written URL, fails, and falls back.

The query plan for the same document, from `X-WG-Include-Query-Plan` with
`X-WG-Skip-Loader`. Two things are new against chapter 10's plan. The
`representations` array has two entries rather than one:

```json
"representations": [
  { "kind": "@key", "typeName": "Product",
    "fragment": "fragment Key on Product { __typename id }" },
  { "kind": "@requires", "typeName": "Product", "fieldName": "shippingCost",
    "fragment": "fragment Requires_for_shippingCost on Product { category }" }
]
```

and the `dependencies` array is no longer uniform, which is the thing chapter
10 predicted and could not show:

```json
{
  "coordinate": { "typeName": "Product", "fieldName": "shippingCost" },
  "isUserRequested": true,
  "dependsOn": [
    { "fetchId": 0, "subgraph": "catalog",
      "coordinate": { "typeName": "Product", "fieldName": "category" },
      "isKey": false, "isRequires": true },
    { "fetchId": 0, "subgraph": "catalog",
      "coordinate": { "typeName": "Product", "fieldName": "id" },
      "isKey": true, "isRequires": false }
  ]
}
```

Fetch count does not change: two fetches before and two after. The extra
dependency travels in the fetch that was already going.

The order of the two `representations` entries was observed both ways across
runs (`@key` first in one plan, `@requires` first in another). Nothing in the
chapter depends on the order, and the Postman assertion sorts before comparing.

The embedded query strings above are collapsed from the router's four-space
indentation, as chapters 7 and 10 did. Nothing else is changed.

## G. What `@requires` costs

Measured against Mosaic's own request timeline, which chapter 3 built and
chapter 4 extended. The query is sent through the router, warm, with and
without `shippingCost` and nothing else different:

```graphql
{ browseProducts(first: 25) { nodes { title price { amount currency }
    shippingCost { amount currency } availableQuantity averageRating } } }
```

| selection | resolvers | SQL |
|---|---|---|
| without `shippingCost` | 76 | 3 |
| with `shippingCost` | 101 | 3 |

Six runs of each, all six identical both times.

`Product.reviews` is deliberately out of that selection. A resolver runs per
review author, so a query that walks the reviews counts differently once
anything has submitted one, and `postman/mosaic-federation` submits a review on
every pass. The first draft of this note measured the full storefront query and
recorded 144 and 169; both are correct on a freshly seeded database and neither
survives the collection that runs before them in the gate, which is how the
discrepancy was found. `averageRating` still reaches the review table, so the
statement count is not being dodged.

Twenty-five more resolvers, one per product, and no more database work at all:
`GetShippingCostAsync` calls the same `IPriceByProductIdDataLoader` that
`price` calls, so the second `LoadAsync` for a key finds it already resolved.
Reproduced twice by hand, and then made a step of both verification scripts,
which warm both documents, send each one once more, and read the two numbers
back out of Mosaic's console. That is decision 62's split applied to counts
rather than timings: a count is the same on every machine, so it belongs in a
gate.

Catalog does more work than it did - one more column in its projection - and
Catalog reports nothing, for the reason chapter 10 recorded. That is not
measured here and the chapter says so.

Answers, for the record: of the 25 seeded products, 9 ship free. All furniture
pays 39 whatever it costs; the most expensive item in the catalogue is a
1690.00 sofa and it pays 39. To count the nine again, with the stack up:

```
curl -s -X POST http://localhost:3002/graphql -H 'content-type: application/json' \
  -d '{"query":"{ browseProducts(first: 25) { nodes { title category shippingCost { amount } } } }"}' \
  | node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{
      const n=JSON.parse(s).data.browseProducts.nodes;
      console.log(n.filter(p=>p.shippingCost.amount===0).length,'of',n.length,'ship free');})"
```

Nothing in the gate asserts the nine. The Postman collection asserts the rule
that produces it, plus that at least one product ships free and not all of them
do, which is what stops a waive-everything bug from passing.

## H. What the composer says about `@external`

wgc 0.129.7, against the real committed pair with one literal edit, through
`scripts/entity-cases.mjs`.

**An `@external` field nothing requires is an error.** Case `external-unused`,
which removes the `@requires` and leaves the `@external`:

```
We found composition errors, while composing.
Please check the errors below:
The subgraph "mosaic" could not be federated for the following reason:
The Object field "Product.category" is invalidly declared "@external". An Object field should only be declared
"@external" if it is part of a "@key", "@provides", or "@requires" field set, or the field is necessary to satisfy an
Interface implementation. In the case that none of these conditions is true, the "@external" directive should be
removed.
```

The composer draws that message inside a box of Unicode rules with an
`ERROR_MESSAGE` heading; the box and the heading are stripped by the case
script and are not part of what it said. The wrapping is wgc's own.

This settles both flags chapter 9 left open, and chapter 9's own wording is the
one to keep: `--suppress-warnings` was untested there because Mosaic produced
no warnings, and `--ignore-external-keys` was assigned here because it needs an
`@external`.

`--suppress-warnings` makes no difference to this error: the case runs the same
edit twice, once plain and once with the flag, and asserts the exit codes
match. They do, at 1. An orphaned `@external` is an error and the flag does not
touch it.

`--ignore-external-keys` also makes no difference, measured on the healthy
pair: `wgc router compose --ignore-external-keys -i federation/mosaic.yaml`
produces a file `cmp` reports as identical to the one composed without it.
Mosaic's `@external` field is not part of a key. `Product` is keyed on `id`,
which Mosaic resolves itself, so there is no external key to ignore. A schema
written in the federation v1 style, where key fields carry `@external`, would
give the flag something to do.

**`@requires` naming a field the subgraph also owns is an error.** Case
`requires-not-external`, which removes the `@external` and leaves the
`@requires`:

```
The subgraph "mosaic" could not be federated for the following reason:
The field "Product.shippingCost" in subgraph "mosaic" defines a "@requires" directive with the following field set:
 "category".
However, neither the field "Product.category" nor any of its field set ancestors are declared "@external".
Consequently, "Product.category" is already provided by subgraph "mosaic" and should not form part of a "@requires"
directive field set.
```

The two errors are each other's mirror and between them they pin the pair: the
directive and the declaration only make sense together.

**A nullable `@external` copy silently weakens the field for every client.**
Case `external-nullability-wins`. Catalog declares `category: ProductCategory!`.
Declare Mosaic's `@external` copy as `category: ProductCategory` and the pair
composes, with nothing said:

```
catalog owns it and declares it     ProductCategory!
mosaic declares its @external copy  ProductCategory
the client-facing schema says       ProductCategory
the composer said                   nothing
```

This is why `[GraphQLNonNullType]` is on a `ProductCategory?` property in
section E. The schema declaration is a copy of somebody else's contract and has
to match it. The C# property is not a copy of anything; it holds a value that
arrives for some representations and not others, and a non-nullable enum
property would answer `FURNITURE` for absent, zero being a value of every C#
enum.

An earlier draft of the companion code shipped the nullable form, and the only
way it was noticed was by reading the composed client schema.

## I. `@provides`, and why Mosaic has no honest use for one

`@provides` says: on this path, I can hand you these fields of that entity
without you making a second call. It is only true when the promising subgraph
holds a copy of the data. Mosaic holds no Catalog data at all - decision 49
made that the point of the extraction - so there is nothing it can honestly
promise. The chapter says so and demonstrates `@provides` on a sample instead,
under decision 31.

`samples/entity-resolution` has a second subgraph, `crates`. A `Crate` holds a
widget and remembers what it was called on the day it was packed. Two fields
return the same object:

```graphql
type Crate {
  widget: Widget! @provides(fields: "name")
  widgetByKey: Widget!
  id: ID!
  label: String!
}

type Widget @key(fields: "id", resolvable: false) {
  id: ID!
  name: String! @external
}
```

`resolvable: false` is the correct declaration here and it composes: nothing in
this subgraph can turn a widget key into a widget, and the key exists only so
`@provides` has an entity to point at.

Measured through a real router, case `provides-skips-the-hop`:

```
widget      @provides(fields: "name")   1 fetch:  crates
widgetByKey no promise                  2 fetches: crates then catalog
the second fetch's path                 crates.@.widgetByKey
```

The `@` in that path is new against chapter 10's `browseProducts.nodes`: it is
how the router writes a step through a list.

And the cost, case `provides-serves-what-it-stored`. Widget `w2` is packed
under a name Catalog does not agree with, on purpose:

```
Crate one   w1  router says "Hex bolt"        catalog says "Hex bolt"
Crate two   w2  router says "Butterfly nut"   catalog says "Wing nut"
Crate three w3  router says "Split washer"    catalog says "Split washer"
Crate four  w9  router says "Unknown part"    catalog says null
```

Three things in one table. The promise is kept. The promise is wrong for w2 and
no error is raised anywhere. And w9, a key Catalog has never heard of, answers
perfectly well through the `@provides` path, which means the directive also
hides a broken reference.

## J. Nullability at the boundary

`_entities` returns `[_Entity]!`: a non-null list of nullable elements. Every
measurement below follows from that one signature.

**Against Mosaic, a representation that cannot be answered.** Case
`requires-missing-on-the-wire`: three representations, the middle one carrying
no `category`, all three selecting `shippingCost`.

```
entities: 5.9, null, 39
error: Unexpected Execution Error at _entities.1.shippingCost
```

`shippingCost` throws, `Money!` cannot be null, so the null propagates up to
the `_Entity` element, which is nullable and absorbs it. The neighbours are
untouched. The message a client gets is `Unexpected Execution Error`; the real
reason is in the server log and nowhere else.

**Against Mosaic, a key that does not decode.** Measured directly rather than
through the case script, because chapter 8's gate already asserts it: the
element is null and **there is no error at all**. A reference resolver that
returns null is a subgraph saying \enquote{not mine}, and a reference resolver
that throws is a subgraph saying \enquote{something went wrong}. Both produce a
null in the same position and only one of them tells the client anything.

**Through a router, a key nothing can resolve.** Case
`dangling-key-nulls-the-answer`, on the sample, asking for the path with no
`@provides` so the router really goes to Catalog:

```
data: null
error: Cannot return null for non-nullable field 'Query.crates.widgetByKey.name'.
path: crates.3.widgetByKey.name
```

One crate out of four holds a widget key Catalog has never heard of, and the
whole response is `data: null`. The chain is every link non-null:
`name: String!` inside `widgetByKey: Widget!` inside `[Crate!]!` inside
`crates: [Crate!]!`. Nothing between the failure and the root is nullable, so
the null walks all the way out.

This is the measured version of a claim chapter 8 made and did not test.
`OrderLineNode.GetProduct`'s doc comment said a dangling identifier "surfaces
as a null product at the router". It surfaces as a null product only if the
field it hangs from is nullable. `OrderLine.product` is `Product!` inside
`lines: [OrderLine!]!`, so on that path it surfaces as a null response. The
comment is corrected at tag `ch11` and now says so.

## K. Where docs and behaviour disagree

- Apollo's own page on contributing entity fields says the router
  \enquote{includes the `size` and `weight` of the `Product` object passed to
  the resolver}. In HotChocolate the required values do not reach the resolver
  at all: they are written onto the object the resolver returned, afterwards,
  by a compiled setter (section D). A resolver that reads them from its
  parameters gets nothing; a resolver that reads them off `[Parent]` gets them.
  Both descriptions are true of the wire and only one is true of the code.
- Cosmo's documentation for `@requires` states the three rules correctly and
  matches what wgc 0.129.7 enforces (section H).
- HotChocolate's `ExternalAttribute` doc comment says `@external` \enquote{is
  only required on fields referenced by the @requires and @provides directive}.
  That is a statement about what is required, and wgc goes further: an
  `@external` field referenced by none of them is rejected.
- Nothing in HotChocolate's documentation describes the external setter, the
  key-field exemption, or the fact that the object-type path ignores
  `@external`. All three are read out of the source.

## L. What the gate asserts

`scripts/entity-cases.mjs`, eleven cases, run by both `verify.ps1` and
`verify.sh`. Three compose an edited schema pair, one asks Mosaic's
`_entities`, and seven use `samples/entity-resolution`, which the script starts
and stops itself on ports 5305, 5306 and 3103.

```
external-unused                       an @external field nothing requires is an error, not a warning
requires-not-external                 @requires naming a field this subgraph also owns is an error
external-nullability-wins             a nullable @external copy makes the field nullable for every client
requires-missing-on-the-wire          a representation with no required field costs that one entity and no other
batch-is-one-lookup                   every representation enters the resolver before any of them leaves it
naive-is-four-lookups                 the same entity without a DataLoader resolves one representation at a time
duplicate-keys-collapse               four representations of one entity are four calls and one lookup
representation-overwrites-owned-field a representation can set a field the subgraph owns and never marked @external
provides-skips-the-hop                @provides turns a two-fetch plan into a one-fetch plan
provides-serves-what-it-stored        the provided value comes from the promising subgraph, right or wrong
dangling-key-nulls-the-answer         one unresolvable key takes the whole response with it
```

`postman/mosaic-entities.postman_collection.json` is the other half: five
requests and nineteen assertions, two against the router and three against a
subgraph directly, because a router cannot be made to send a representation
with a required field missing.

Section G's two rows are steps of both verification scripts rather than numbers
typed out of a terminal. Each script warms both documents three times, sends
each one once more, and reads the last `... resolvers, ... SQL)` line out of
Mosaic's console, asserting 76 and 101 resolvers and 3 statements for both.

Two existing assertions had to move, and neither was loosened:

- Chapter 10's collection asserted that the composed `Product` carries nine
  fields, by name. It carries ten now. The list is updated and still exact.
- Chapter 9's `enum-drift` case used to add a `ProductCategory` enum to
  Mosaic's schema, because Mosaic had no reason to declare one. Mosaic declares
  one now, so the edit produced a duplicate type and a different error. The case
  shortens the real declaration instead. The composer's message is unchanged, so
  chapter 9's listing and prose both stand.

## M. Reproduction recipes

Everything below is run from the root of `mosaic-graph` at tag `ch11`.

```
# the whole gate
pwsh scripts/verify.ps1

# just chapter 11's cases; starts and stops the sample itself
node scripts/entity-cases.mjs
node scripts/entity-cases.mjs --list
node scripts/entity-cases.mjs --print batch-is-one-lookup

# the wire capture in section F, with the stack up
curl -s -X POST http://localhost:3002/graphql \
  -H 'content-type: application/json' -H 'X-WG-Trace: true' \
  -d '{"query":"{ browseProducts(first: 2) { nodes { title shippingCost { amount } } } }"}'
```

Section G's numbers: send the query in that section through the router with and
without `shippingCost`, three times each to warm both documents, then once more
each, reading the last `parse - validate - compile - coerce ...` line out of
Mosaic's console after each. Both selections must be measured in one sitting,
which is chapter 4's rule. Both verification scripts do exactly this and assert
the four numbers, so `pwsh scripts/verify.ps1` reproduces them without any of
it being done by hand.

A trap that cost real time and will cost it again. `.gitattributes` keeps
`*.graphql` at LF, and `dotnet run -- schema export` writes CRLF on Windows.
The verify script compares schemas with line endings normalised, so it says
nothing; `composition-cases.mjs` does literal string edits and every one of
them fails with \enquote{matched 0 times}; and the composed execution config
embeds each subgraph's SDL verbatim and content-addresses it, so the committed
`federation/supergraph.json` stops matching a fresh compose. Normalise the file
after every export.

## N. Left unmeasured, and who owns it

- Whether the router's plan cache keys on anything in section F. Chapter 17.
- `@requires` naming a field set with nesting, or one that spans more than one
  subgraph. Chapter 13's harder modelling problems are the natural place.
- `@override`, the fourth directive of this family. Chapter 12 owns it and
  chapter 6 introduced it.
- `@provides` where the promising subgraph genuinely is a cache, with an
  invalidation story. Chapter 24 owns caching.
- What a subgraph should do about a representation that can set its own fields
  (section D). Chapter 25 owns whether a subgraph is reachable at all.
- Enum drift as a subject rather than as a composition case: chapter 13 owns
  shared enums and scalars, and this chapter only establishes that Mosaic now
  has a second declaration of one.
- Anything about `@interfaceObject`. Chapter 13.
- Concurrency at the batch under load: the sample proves the order of calls, not
  what happens when two `_entities` requests overlap. Chapter 24.
- Whether `--ignore-external-keys` does anything on a schema whose key fields
  really are `@external`. Section H shows it changing nothing on Mosaic and
  says why; nothing here builds the federation v1 style schema that would
  exercise it. Appendix C is the natural home.

## O. Bibliography keys

| key | what it is | used for |
|---|---|---|
| `apollo2026contributefields` | Apollo, \enquote{Contribute and Reference Entity Fields}, GraphOS schema design docs | what `@requires` and `@external` mean, and the computed-field vocabulary |
| `cosmo2026requires` | WunderGraph Cosmo, \enquote{@requires} directive reference | the three rules the composer enforces |
| `apollo2026subgraphspec` | Apollo Federation subgraph specification | `_entities`, `[_Entity]!` and the representation shape |

Both vendor pages are cited only for what the specification requires, never for
what this build does. Everything about HotChocolate's behaviour is read out of
the source tree at tag `16.6.0` or measured.
