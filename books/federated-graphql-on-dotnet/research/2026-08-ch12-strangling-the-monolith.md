# Chapter 12 research - strangling the monolith

Research date: 2026-08-10. Every number and every listing in this file was
captured from a running service on the author's machine, or read out of a
primary source at a pinned version. Internals claims are read from
`ChilliCream/graphql-platform` at tag `16.6.0`, commit `8fea46e`, cloned at
F:/repo/graphql-platform (decision 32). Composer claims are read from
`@wundergraph/composition` 0.63.2, which is what wgc 0.129.7 bundles, under
`node_modules/` in the companion repo.

The chapter's companion code is `mosaic-graph` at tag `ch12`. What is new is
almost everything: `src/Mosaic.Api` is gone, five services took its place, and
`src/Mosaic.ServiceDefaults` is the first project in the repository that is not
a service.

## Contents

- A. Version baseline
- B. The graph before: what was left in the monolith, and what pointed at what
- C. The order the dependencies decide
- D. What the extraction actually consisted of
- E. The three kinds of duplication, and the one shared library
- F. `@override`: what the composer does with it, nine ways
- G. Progressive `@override`, and where it stops
- H. The first composition warning in the book
- I. Composition across six subgraphs, and what the messages became
- J. The query plan, before and after
- K. What it cost: resolvers, statements, and the number that moved for a
  strange reason
- L. Nullability at the boundary, five more times
- M. What the mutation lost
- N. What the gate asserts
- O. Reproduction recipes
- P. Left unmeasured, and who owns it
- Q. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; unchanged since chapter 8 |
| graphql-platform source | tag `16.6.0`, commit `8fea46e` | `git log --oneline -1` in F:/repo/graphql-platform |
| WunderGraph Cosmo Router | 0.337.1 | `ghcr.io/wundergraph/cosmo/router:0.337.1`, pinned in `docker-compose.yml` |
| wgc (Cosmo CLI) | 0.129.7 | pinned exactly in `package.json`; unchanged since chapter 9 |
| @wundergraph/composition | 0.63.2 | `node_modules/@wundergraph/composition/package.json`; this is what wgc 0.129.7 bundles and what every composer claim below is read from |
| Microsoft.EntityFrameworkCore.Relational | 10.0.10 | new at this chapter; `Directory.Packages.props` |
| .NET SDK | 10.0.302 | `dotnet --version` |
| node | 24.15.0 | `node --version` |
| Apollo Federation specification | v2.15 | unchanged from the SPEC baseline |

## B. The graph before: what was left in the monolith

At tag `ch11`, `src/Mosaic.Api` held five domains and 2,069 lines of C# across
them, plus 633 lines of `Infrastructure/`. Counted with:

```powershell
Get-ChildItem -Recurse -Path src\Mosaic.Api -Filter *.cs |
  Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' } |
  ForEach-Object {
    $d = ($_.FullName -replace [regex]::Escape((Resolve-Path src\Mosaic.Api).Path + '\'),'') -split '\\' | Select-Object -First 1
    [pscustomobject]@{ Domain = $d; Lines = (Get-Content $_.FullName | Measure-Object -Line).Lines } } |
  Group-Object Domain |
  ForEach-Object { [pscustomobject]@{ Domain=$_.Name; Files=$_.Count; Lines=($_.Group | Measure-Object Lines -Sum).Sum } } |
  Sort-Object Lines -Descending
```

| Folder | Files | Lines |
|---|---|---|
| Reviews | 12 | 943 |
| Infrastructure | 12 | 633 |
| Ordering | 10 | 462 |
| Pricing | 9 | 284 |
| Catalog (the stub) | 3 | 200 |
| Accounts | 8 | 197 |
| Inventory | 7 | 183 |
| Program.cs | 1 | 107 |
| Properties | 1 | 6 |

## C. The order the dependencies decide

Which domain references which, read off the type files rather than off the
folder names. A reference here means "a field in this domain returns a type
another domain owns", which is the only kind of reference that survives an
extraction: chapter 2's rule means there are no navigation properties to unpick.

| Domain | Contributes to | References |
|---|---|---|
| Catalog | owns `Product` | nobody |
| Pricing | `Product.price`, `Product.shippingCost` | nobody (the `@requires` on `category` is a declaration, not a call) |
| Inventory | `Product.availableQuantity` | nobody |
| Accounts | owns `Customer` | nobody |
| Reviews | `Product.reviews`, `Product.averageRating`, owns `Review` | Accounts, through `Review.author` |
| Ordering | owns `Order`, `OrderLine` | Accounts through `Order.customer`, Catalog through `OrderLine.product` |

So three leaves (Pricing, Inventory, Accounts), then Reviews, then Ordering.
That is the order `federation/mosaic.yaml` lists them in and the order the
chapter extracts them in.

Grepped with:

```
git grep -n "ObjectType<" ch11 -- 'src/*.cs'
```

which gives eleven lines: ten attributes plus one mention in a comment in
`Mosaic.Api/Properties/ModuleInfo.cs`. Eight of the ten are in `Mosaic.Api`,
seven of those on a domain type and the eighth on the empty partial that marks
`PageCursor` shareable. Four of the ten are `[ObjectType<Product>]`: Pricing,
Inventory and Reviews inside the monolith, and Catalog's own `ProductNode` in
the other service.

## D. What the extraction actually consisted of

Measured from git, after the fact:

```
git diff --stat ch11 HEAD -- src/
git diff -M --summary ch11 HEAD -- src/ | grep -c 'rename'
```

The five domain folders moved with `git mv` and their contents changed only in
their `namespace` and `using` lines, except for the five files section L and M
describe. Everything else in each new service is new: a `Program.cs`, a
`DbContext`, a data registration, a seeder, a csproj, a Dockerfile, a launch
profile, two appsettings files and a `ModuleInfo.cs`.

That is **ten files per service, not eleven**, and the compose entry is an
eleventh thing but not an eleventh file: it is a stanza inside
`docker-compose.yml`, which the five services share. Fifty files and five
stanzas. Counted uniformly across all five with:

```
find src/Mosaic.Pricing src/Mosaic.Inventory src/Mosaic.Accounts \
     src/Mosaic.Reviews src/Mosaic.Ordering -type f \
     -not -path '*/obj/*' -not -path '*/bin/*' \
     \( -name '*.csproj' -o -name 'Program.cs' -o -name '*DbContext.cs' \
        -o -name '*DataRegistration.cs' -o -name '*DatabaseSeeder.cs' \
        -o -name 'Dockerfile' -o -name 'launchSettings.json' \
        -o -name 'appsettings*.json' -o -name 'ModuleInfo.cs' \) | wc -l
```

which answers 50, ten for each of the five.

Ports and databases, which are the only per-service facts a reader needs:

| Subgraph | Port | Database | Project |
|---|---|---|---|
| catalog | 5101 | `catalog` | `src/Mosaic.Catalog` |
| pricing | 5102 | `pricing` | `src/Mosaic.Pricing` |
| inventory | 5103 | `inventory` | `src/Mosaic.Inventory` |
| accounts | 5104 | `accounts` | `src/Mosaic.Accounts` |
| reviews | 5105 | `reviews` | `src/Mosaic.Reviews` |
| ordering | 5106 | `ordering` | `src/Mosaic.Ordering` |

Nothing in `docker-compose.yml` creates a database. EF Core's
`EnsureCreatedAsync` does, on each service's first start, exactly as it did for
Catalog in chapter 8. Five services were added to the compose file and no
storage.

**Three of the six subgraphs have no root field**, and this is not an
omission. Pricing, Inventory and Reviews contribute only fields to entities
somebody else owns, so the only way into them is a representation. All three
needed an explicit `AddQueryType()`: the source generator emits a query type
when it finds a `[QueryType]` class, there is none in those three, and
`AddApolloFederation` puts `_service` and `_entities` on a query type without
creating one. The schema build fails with:

```
1. The schema builder was unable to identify the query type of the schema.
   Either specify which type is the query type or set the schema builder to
   non-strict validation mode.
```

and never mentions federation. Measured by omitting the call and running
`dotnet run --project src/Mosaic.Pricing -- schema export`.

## E. The three kinds of duplication, and the one shared library

The chapter's argument about what is copied and what is shared. Counted at tag
`ch12`:

| Thing | Copies | Why a copy |
|---|---|---|
| `ProductKey.TryDecode` | 3 (Pricing, Inventory, Reviews) | the format of a key is a contract between services |
| `CustomerKey.TryDecode` | 1 (Accounts) | the same file with one type name changed |
| `Product` stub | 4 (Pricing, Inventory, Reviews with a reference resolver; Ordering without) | four services need somewhere to hang a field or a reference |
| `Customer` stub | 2 (Reviews, Ordering), plus the real one in Accounts | two services reference a customer and neither can resolve one |
| `ProductCategory` | 1 copy (Pricing) beside Catalog's | the only field in the graph that needs to read one |
| `Money` | 2 (Pricing, Ordering), both `@shareable` | an object type two subgraphs declare |
| `PageCursorExtension` | 2 (Catalog, Reviews) | the two subgraphs that have a connection |

`Mosaic.ServiceDefaults` holds what is not a contract: `RequestTimeline`,
`RequestTimelineListener`, `PipelineReportExtensions`, `ServiceCallCounter`,
`RequestLookupCount`, `ServiceCallCountingExtensions`, `SqlCommandCounter`,
`SnakeCaseNaming`, and `MosaicSubgraphDefaults` with the four extension methods
every service calls. It needs `Microsoft.EntityFrameworkCore.Relational`
explicitly, because `DbCommandInterceptor` is a relational type and the six
services only get it transitively through the Npgsql provider.

`Money` is the only one of the copies the composer inspects field by field.
Both declarations carry `[Shareable]` on the record, which
`ShareableAttribute.TryConfigure` applies to the object type descriptor, marking
every field.

Measured 2026-08-10 rather than reasoned about, because the first draft of the
chapter claimed the error "names the type rather than the two services" and that
is false. Copy `schema/` and `federation/mosaic.yaml` to a scratch directory,
strip `@shareable` from `type Money` in both `pricing.graphql` and
`ordering.graphql`, and compose:

```
sed -i 's/^type Money @shareable {/type Money {/' schema/pricing.graphql schema/ordering.graphql
npx wgc router compose -i federation/mosaic.yaml -o out.json
```

Exit 1, no config written, and the message is per field, not per type:

```
The Object "Money" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "amount" is defined in the following subgraphs: "pricing", "ordering".
 However, it is not declared "@shareable" in any of them.
 The field "currency" is defined in the following subgraphs: "pricing", "ordering".
 However, it is not declared "@shareable" in any of them.
```

So the type is named once in the heading and both subgraphs are named twice,
once per field. A two-field value type produces four lines under the heading for
the single missing attribute. This is the same error shape the `duplicate-field`
composition case and the `two-owners-no-override` override case already assert,
which is why it is recorded here rather than committed as a seventh composition
case: nothing about it is new except which type it lands on.

## F. `@override`: what the composer does with it, nine ways

All nine are cases in `scripts/override-cases.mjs`, which both verify scripts
run. Each one takes the six committed schemas, applies literal edits that must
match exactly once, composes with wgc 0.129.7, and asserts what the composer
said and where the composed routing table sends the field.

What the cases simulate needs stating plainly, because it is the one thing in
the script that is not the repository as it stands. `@override` moves a field
from the subgraph that has it to the subgraph taking it over, so a case needs a
"before" in which two subgraphs declare the same field. At tag `ch12` no two do:
the extraction is finished and every field has exactly one owner. So each case
adds `availableQuantity` back to `catalog` - which stands in for the monolith -
and applies `@override` in `inventory`. The edit is fictional; everything the
composer says about it is not.

| Case | Exit | What it produces |
|---|---|---|
| `baseline` | 0 | six schemas as committed; `Product.availableQuantity` routed to `inventory` |
| `two-owners-no-override` | 1 | shareability error naming `"catalog", "inventory"` |
| `override-takes-the-field` | 0 | composes; the field is routed to `inventory` alone |
| `override-a-subgraph-that-is-not-there` | 0 | a **warning**, config written |
| `override-a-subgraph-that-is-not-there-suppressed` | 0 | same config, byte identical, no warning printed |
| `override-a-typo-with-a-real-loser` | 1 | a shareability error naming neither `@override` nor the misspelling |
| `override-from-yourself` | 1 | `Cannot override field ... source and target subgraph names are both` |
| `override-declared-twice` | 1 | `must only be declared on one single instance of a field` |
| `progressive-override-is-rejected` | 1 | `does not define the following argument that is provided: "label"` |

### F.1 The control, and what `@override` is suppressing

Without the directive, two subgraphs declaring `availableQuantity`:

```
The Object "Product" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "availableQuantity" is defined in the following subgraphs: "catalog", "inventory".
 However, it is not declared "@shareable" in any of them.
```

With `@override(from: "catalog")` on Inventory's copy, the same pair composes
and nothing is printed. The composer's walker says why in as many words, in
`node_modules/@wundergraph/composition/dist/v1/federation/walkers.js` line 31:

```
// overridden fields should not trigger shareable errors
```

### F.2 What a successful `@override` changes, and where it is visible

The client schema is identical with and without one. The only difference is in
the routing table, which the case reads out of the composed execution config's
`engineConfig.datasourceConfigurations`:

```
without @override:  the pair does not compose at all
with    @override:  Product.availableQuantity -> inventory
```

Catalog still declares the field in its own schema and the router will never
ask it for one.

### F.3 Overriding a key field composes, and quietly should not

Probed outside the case script, on a two-subgraph pair, because the effect is
about what the composer allows rather than about Mosaic:

```
type Widget @key(fields: "id") { id: ID! name: String! }          # subgraph a
type Widget @key(fields: "id") { id: ID! @override(from: "a")     # subgraph b
                                 price: Float! }
```

Composes with exit 0. The routing table then reads:

```
ds 0 (a): Query{widgets} Widget{name}       keys Widget:id
ds 1 (b): Query{pricedWidgets} Widget{id,price}   keys Widget:id
```

Subgraph `a` has lost `id` from the fields it can provide while keeping it as
its key. **The runtime consequence was not measured** and the chapter says so;
what is measured is that the composer permits it and that the owner's routing
entry loses the field. See section P.

### F.4 A root field can be overridden

Also probed outside the case script. `Query.legacyReport` declared in `a` and
in `b` with `@override(from: "a")` composes, and the routing table gives
`Query{legacyReport}` to `b`.

## G. Progressive `@override`, and where it stops

HotChocolate has it. `src/HotChocolate/ApolloFederation/src/ApolloFederation/
Types/Directives/OverrideAttribute.cs` takes `(string from, string? label =
null)`, and `OverrideDirective.cs` declares both. The `label` argument only
reaches the schema when the subgraph links federation 2.7, and the gate for
that is `OverrideLegacySupportAttribute`:

```csharp
// prior to version 2.7 @override only specified "from" parameter
if (descriptor.GetFederationVersion() < FederationVersion.Federation27)
{
    var desc = (IDirectiveTypeDescriptor<OverrideDirective>)descriptor;
    desc.BindArgumentsExplicitly();
    desc.Argument(t => t.From);
}
```

The library's own test proves the two forms.
`OverrideDirectiveTests.OverrideDirective_Progressive_Annotation` builds a
schema with `AddApolloFederation(FederationVersion.Federation27)` and its
snapshot contains:

```
directive @override(from: String!, label: String) on FIELD_DEFINITION
```

`HotChocolate.ApolloFederation` 16.6.0 defaults to `FederationVersion.Default`,
which is `Federation26`, so Mosaic's six subgraphs emit the one-argument form.

The composer has the one-argument form and only that.
`node_modules/@wundergraph/composition/dist/v1/constants/directive-definitions.js`
line 524:

```javascript
// directive @override(from: String!) on FIELD_DEFINITION
exports.OVERRIDE_DEFINITION = {
    arguments: [
        {
            kind: graphql_1.Kind.INPUT_VALUE_DEFINITION,
            name: (0, utils_1.stringToNameNode)(string_constants_1.FROM),
            ...
```

Composing a subgraph that links 2.7 and writes a label:

```
The subgraph "inventory" could not be federated for the following reason:
The 1st instance of the directive "@override" declared on coordinates "Product.availableQuantity" is invalid for the
following reason:
 The definition for "@override" does not define the following argument that is provided: "label".
```

Exit code 1, no config written. **Progressive `@override` is unavailable on this
stack**, and the failure is at composition rather than at the router. Apollo's
own documentation describes the feature as an Enterprise GraphOS one and notes
that the router caches query plans with the set of unique overridden labels
contributing to the cache key~[apollo2026migratefields].

## H. The first composition warning in the book

Chapter 9 had nothing to say about `--suppress-warnings` because Mosaic produced
no warnings. Chapter 11 could only report that the flag does not touch an error.
This is the first warning.

`@override(from: "legacy-monolith")` where no subgraph by that name exists, and
where nothing else declares the field, so there is no duplication to report
instead:

```
The following warnings were produced while composing:
The Object type "Product" defines the directive "@override(from: "legacy-monolith")" on the following field:
"availableQuantity".
The required "from" argument of type "String!" should be provided with an existing subgraph name.
However, a subgraph by the name of "legacy-monolith" does not exist.
If this subgraph has been recently deleted, remember to clean up unused "@override" directives that reference this
subgraph.
```

Exit code 0. The execution config is written and the graph is unchanged:
`Product.availableQuantity` is still routed to `inventory`.

With `--suppress-warnings`, the same compose prints nothing and writes a
**byte-identical** config. Asserted in the case script by comparing the two
files, not by comparing hashes computed by hand.

The warning's factory is
`node_modules/@wundergraph/composition/dist/v1/warnings/warnings.js`,
`invalidOverrideTargetSubgraphNameWarning`.

### H.1 The same typo with a real loser is not a warning

Misspell `from:` when the field genuinely is in two subgraphs and the override
does not apply, so the duplication comes back:

```
The Object "Product" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "availableQuantity" is defined in the following subgraphs: "catalog", "inventory".
 However, it is not declared "@shareable" in any of them.
```

The word `katalog` appears nowhere in the output, and neither does `@override`.
The case asserts both absences.

### H.2 The duplicate-override message is malformed

Two subgraphs both claiming the same field from a third:

```
The "@override" directive must only be declared on one single instance of a field. However, an "@override" directive
was declared on more than one instance of the following field: " The field "Product.availableQuantity" declares an
@override directive in the following subgraphs: "pricing", "inventory".".
```

The second sentence is interpolated already formatted, so it arrives wrapped in
its own quotes with a leading space inside them. The case asserts it as written
rather than as intended.

## I. Composition across six subgraphs, and what the messages became

Chapter 9's open items asked for composition across more than two subgraphs.
Six compose, first time, with no edit to any schema:

```
npx wgc router compose -i federation/mosaic.yaml -o federation/supergraph.json
Router execution config successfully written to "F:/repo/mosaic-graph/federation/supergraph.json".
```

**Chapter 9's printed messages do not reproduce at this tag**, and that is a
finding rather than an inconvenience. The subgraph named `mosaic` does not
exist, so `scripts/composition-cases.mjs` makes the same six mistakes in
`pricing` instead, and the composer says different words about three of them:

| Case | At `ch09`-`ch11` | At `ch12` |
|---|---|---|
| `unsatisfiable-key` | four unresolvable fields named | two, because the other two belong to subgraphs whose key is still resolvable |
| `missing-key` | `defined and declared "@shareable" in the following subgraph: "catalog"` | `...following subgraphs: "catalog", "inventory", "reviews", "ordering"` |
| `key-mismatch` | two subgraphs named | five |
| `duplicate-field`, `incompatible-type`, `enum-drift` | same shape, different subgraph names | same |

The message got more informative as the graph got larger, in one specific way:
a shareability error now names every subgraph that got it right. It still does
not contain the word "key".

## J. The query plan, before and after

Captured with `X-WG-Include-Query-Plan: true` and `X-WG-Skip-Loader: true`
against the router on 3002, for the query the Postman router collection sends:

```graphql
{
  browseProducts(first: 3) {
    nodes {
      title
      price { amount currency }
      availableQuantity
      averageRating
      reviews(first: 2) { totalCount nodes { rating author { displayName } } }
    }
  }
}
```

At `ch11` the plan was a `Sequence` of two: catalog, then one `BatchEntity`
against mosaic. At `ch12`:

```
Sequence
  Single catalog id=0 depends=[] path=
  Parallel
    BatchEntity pricing   id=1 depends=[0] path=browseProducts.nodes
    BatchEntity inventory id=2 depends=[0] path=browseProducts.nodes
    BatchEntity reviews   id=3 depends=[0] path=browseProducts.nodes
  BatchEntity accounts    id=4 depends=[3] path=browseProducts.nodes.@.reviews.nodes.@.author
```

Five fetches in three steps. Three of them are parallel because they depend on
the same key and on nothing else. The fifth is not, because its keys do not
exist until Reviews has answered, and its path is the first in this book with
two list traversals in it.

Every dependency in the plan is a key. Asserted in the router collection by
walking `fetch.dependencies[].dependsOn[]` and checking `isKey` and
`coordinate.fieldName === "id"` on every one.

The whole query answers correctly across five services; the response is in
section O's recipe.

### J.1 The lab's two predictions, measured 2026-08-10

Both were written from the plan in section J rather than run, and one of them
was wrong. Stack up as in section O, then send the lab's exercise 1 query with
the two plan headers, dropping one field at a time:

| Query | Plan |
|---|---|
| `title price reviews { author }` | `Sequence [ catalog, Parallel [ pricing, reviews ], accounts ]` |
| the same minus `price` | `Sequence [ catalog, reviews, accounts ]` - **no `Parallel` node at all** |
| the same minus `reviews` as well | `Sequence [ catalog ]` |

So a `Parallel` node with one child is not what Cosmo emits: the node
disappears rather than shrinking. The first draft of the lab said "one fetch
leaves the parallel node and the node stays", which is the opposite. Note also
that this query's parallel node has **two** children and not the three section J
prints, because it asks nothing of Inventory.

Exercise 3's claim was right. The same query without the headers, then the last
timeline line out of each service:

| Subgraph | resolvers | SQL |
|---|---|---|
| catalog | 1 | 1 |
| pricing | 4 | 1 |
| inventory | - | - |
| reviews | 4 | 1 |
| accounts | 1 | 1 |
| ordering | - | - |

Four services, four statements, and Inventory is silent alongside Ordering.

## K. What it cost

Measured through the router, warm, on the storefront query at 25 products, read
off each subgraph's own request timeline. Counts rather than timings, so they
belong in the gate (decision 66).

The query, which deliberately stops short of `Product.reviews` for the reason
decision 66 records:

```graphql
{ browseProducts(first: 25) { nodes { title price { amount currency }
    shippingCost { amount currency } availableQuantity averageRating } } }
```

| Subgraph | resolvers (no shippingCost) | SQL | resolvers (with) | SQL |
|---|---|---|---|---|
| catalog | 1 | 1 | 1 | 1 |
| pricing | 26 | 1 | 51 | 1 |
| inventory | 26 | 1 | 26 | 1 |
| reviews | 26 | 1 | 26 | 1 |
| accounts | - | - | - | - |
| ordering | - | - | - | - |
| **total** | **79** | **4** | **104** | **4** |

Chapter 11 printed 76 and 101 resolvers and 3 statements for the same query,
measured on `Mosaic.Api` alone. The arithmetic between the two tags:

- 101 became 103 across pricing, inventory and reviews, because there are three
  `_entities` root fields where there was one.
- Catalog's row - 1 resolver, 1 statement - is the one chapter 11 could not
  print, because Catalog had no instrumentation until this chapter. Chapter
  10's open item called that "half of every federated query is unobserved".
- So the statement count did not move at all. Four statements before and four
  after; three of them were counted and one was not.

Accounts and ordering report nothing, and the gate asserts that they report
nothing. That assertion is what would catch the router fetching from a service
the query never mentions.

### K.1 The number that moved for a strange reason

The `_entities` query the gate sends Reviews directly:

```graphql
query($representations: [_Any!]!) {
  _entities(representations: $representations) {
    ... on Product { reviews(first: 12) { nodes { rating author { id } } } }
  }
}
```

| | `ch11` (on `Mosaic.Api`) | `ch12` (on `reviews`) |
|---|---|---|
| resolvers | 146 | 26 |
| SQL | 2 | 1 |
| lookups | 2 | 1 |

The statement is the author batch leaving for Accounts, which is what an
extraction does. The resolver count is stranger and is worth being exact about.

The engine still produces 120 authors. What it no longer does is run 120
resolver **tasks** to get them. `ReviewNode.GetAuthor` takes a parent and
returns a new object with no await in it, so HotChocolate compiles it to a
`PureFieldDelegate` and runs it inline. Grepped at tag `16.6.0`, commit
`8fea46e`:

```
src/HotChocolate/Core/src/Types/Execution/Processing/Tasks/ResolverTask.Execute.cs:13:
    using (DiagnosticEvents.ResolveFieldValue(_context))
src/HotChocolate/Core/src/Types/Execution/Processing/Tasks/BatchResolverTask.cs:129:
    using (DiagnosticEvents.ResolveFieldValue(contexts[0]))
```

Those two are the only places the event is raised, and
`OperationCompiler.CompileResolver.cs` line 46 is where a field with a
`PureResolver` and no directives is compiled to one:

```csharp
if (field.PureResolver is not null && selection.Directives.Count == 0)
{
    return field.PureResolver;
}
```

Which means chapter 3's resolver count has always measured resolver tasks
rather than fields resolved, and nobody noticed because until chapter 12 every
field on this path did something asynchronous.

## L. Nullability at the boundary, five more times

Decision 65 said chapter 12 would apply chapter 11's rule five more times. It
applies to three fields and is argued against for the others, which is a
deviation and is recorded as a decision.

The distinction the chapter draws:

- **A reference to an entity another subgraph owns** can dangle. The router has
  to go and find the thing, and it may not be there. These are nullable.
- **A field this subgraph contributes to an entity the router has already
  located** cannot dangle in the same way. There is no second lookup; the
  subgraph either has the row or it does not, and its answer is authoritative.

| Field | Before | After | Why |
|---|---|---|---|
| `Review.author` | `Customer!` | `Customer` | a reference; and since section M the write path cannot check it |

`ReviewNode.GetAuthorAsync` at `ch11` spans lines 42 to 55 of
`src/Mosaic.Api/Reviews/Types/ReviewNode.cs`, so fourteen lines counting the
three inline comments and the blank, ten without them. `GetAuthor` at `ch12` is
two. The chapter prints fourteen against two, which is the method as each tag
actually writes it; both have doc comments above them and neither count
includes those. Reproduce with:

```
git show ch11:src/Mosaic.Api/Reviews/Types/ReviewNode.cs | sed -n '42,55p'
sed -n '61,62p' src/Mosaic.Reviews/Reviews/Types/ReviewNode.cs
```

| `Order.customer` | `Customer!` | `Customer` | a reference |
| `OrderLine.product` | `Product!` | `Product` | a reference; chapter 8's doc comment claimed this was already safe and chapter 11 measured that it was not |
| `Product.price` | `Money!` | `Money!` | contributed; a missing price is a broken invariant between two databases, and Pricing throws rather than answering a null that means nothing |
| `Product.shippingCost` | `Money!` | `Money!` | contributed; chapter 11 measured what it does with no category and that behaviour is unchanged |
| `Product.availableQuantity` | `Int!` | `Int!` | contributed, and total: a product Inventory has never counted reads as zero |

The composed client schema confirms the three changes:

```graphql
type OrderLine { product: Product  quantity: Int!  unitPrice: Money! }
type Review implements Node { id: ID!  author: Customer  rating: Int! ... }
type Order implements Node { id: ID!  customer: Customer  total: Money! ... }
```

## M. What the mutation lost

Decision 52 recorded that `submitReview` gave up its product check at chapter 8,
and said chapter 12 would argue about whether `@requires` is worth taking to get
it back. The answer is that it cannot be taken.

`@requires` feeds a field resolver on an entity the router has already located.
`submitReview` is a root field handed a customer identifier by a client that may
have invented it; there is no entity to locate and no subgraph the router would
consult. The three options were a synchronous call to Accounts on the write
path, an error type nothing can raise, and accepting the write. Chapter 12 takes
the third, which is chapter 8's answer applied a second time.

So `CustomerNotFoundError` and `CustomerNotFoundException` are gone. The payload
union is down to two members from four:

```graphql
union SubmitReviewError = RatingOutOfRangeError | DuplicateReviewError
```

Measured, and asserted in the subgraph collection: a review submitted against a
`Customer` node id nobody has seeded succeeds, `payload.errors` is null, and the
response contains no `CUSTOMER_NOT_FOUND`. The rule Reviews still owns -
one customer reviews one product once - still raises `DUPLICATE_REVIEW`.

## N. What the gate asserts

`pwsh scripts/verify.ps1` passes with 43 steps. Counted by piping the run to a
file and counting the `[ok]` lines above the `--- summary ---` marker, because
the summary repeats every one of them:

```
(Select-String -Path verify.log -Pattern '^\[ok\]').Count  # halve, or cut at the marker
```

New or changed at this chapter:

- schema drift and `_service` for six subgraphs rather than two
- `@key(fields: "id"` matched without the closing bracket, because Ordering's
  two keys carry `resolvable: false`
- catalog answers 25 products; reviews answers 25 representations with 120
  reviews; **accounts resolves all 12 customer keys reviews handed out**;
  **pricing prices all 25 representations catalog handed out**
- the request pipeline is the expected 13 middleware in **all six** services
- reviews reports 1 lookup, 26 resolvers, 1 SQL
- an order line answers a product key Catalog also answers
- six subgraphs compose; the config matches the committed one
- the six composition cases, with their new messages
- **the nine override cases**, which are new
- the router answers; the router cases pass unchanged; the entities cases pass
  with their Mosaic half pointed at Pricing
- the storefront cost table above, per subgraph, plus the two that must stay
  silent

`bash scripts/verify.sh` was brought to parity in the same commit, which is the
standing rule from the chapter 4 open item.

## O. Reproduction recipes

```
# the whole gate
pwsh scripts/verify.ps1

# chapter 12's cases alone; no service has to be running
node scripts/override-cases.mjs
node scripts/override-cases.mjs --print progressive-override-is-rejected
node scripts/override-cases.mjs --print override-a-subgraph-that-is-not-there

# the six-subgraph composition, by hand
npx wgc router compose -i federation/mosaic.yaml -o federation/supergraph.json

# the whole stack, for the plan in section J
docker compose up -d --build mosaic-db mosaic-catalog mosaic-pricing \
    mosaic-inventory mosaic-accounts mosaic-reviews mosaic-ordering mosaic-router
curl -sS http://localhost:3002/graphql \
  -H 'Content-Type: application/json' \
  -H 'X-WG-Include-Query-Plan: true' -H 'X-WG-Skip-Loader: true' \
  --data-binary @- <<'JSON' | jq .extensions.queryPlan
{"query":"{ browseProducts(first: 3) { nodes { title price { amount currency } availableQuantity averageRating reviews(first: 2) { totalCount nodes { rating author { displayName } } } } } }"}
JSON
```

## P. Left unmeasured, and who owns it

- **What a router does with a graph in which a key field was overridden.**
  Section F.3 measured that the composer allows it and that the owner's routing
  entry loses the field. Nothing here sent a query to a router loaded with that
  config. Chapter 17 walks the planner and owns the answer.
- **Progressive `@override` against a router that supports it.** Not
  reproducible on this stack at all, because composition refuses first.
  Chapter 28 compares the two stacks and is where an Apollo Router could be
  pointed at a 2.7 config.
- **The latency cost of going from two services to six.**
  `scripts/measure-router.mjs` was updated to time four hand-assembled calls
  against the router's four fetches, and deliberately not run for a printed
  number: decision 62 keeps timings out of a gate, and the hand-assembled row
  is sequential where the router's three entity fetches are parallel, so the
  comparison flatters the router. Chapter 24 owns performance.
- **Mutations through the router.** The mutation is exercised against the
  Reviews subgraph directly. Chapter 14 owns subscriptions through a router and
  is the natural place for the write path too.
- **`onReviewAdded` through the router.** Still outside the gate, for the reason
  decision 43 gives. Chapter 14.
- **Whether six services need six databases.** Asserted as policy rather than
  measured; nothing here compared the arrangement with six schemas in one
  database. Chapter 21 or 26.
- **`@interfaceObject`, nested `@requires`, shared enums as a subject.** Chapter
  13, unchanged from chapter 11's list.
- **What six services cost to operate.** Six unrelated request timelines is not
  observability, and the chapter says so rather than claiming the ch10 open item
  is closed. Chapter 23.

## Q. Bibliography keys

| Key | Used for |
|---|---|
| `apollo2026migratefields` | Apollo's own page on migrating entity and root fields, and the only source for the claim that progressive `@override` is a GraphOS Enterprise feature |
