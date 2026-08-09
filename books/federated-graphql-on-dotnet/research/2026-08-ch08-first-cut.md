# Chapter 08 research - the first cut, extracting Catalog

Research date: 2026-08-09. Every number and every listing in this file was
captured from a running system on the author's machine, or read out of a
primary source at a pinned version. Where the two disagree the running system
wins and the disagreement is recorded in section J.

The chapter's companion code is `mosaic-graph` at tag `ch08`. Unlike chapter 7,
this one changes Mosaic itself: the single service becomes two subgraphs.

## Contents

- A. Version baseline
- B. What was extracted, and what moved
- C. Where the federation attributes have to go
- D. The key is a global object identifier, and nothing decodes it
- E. What each subgraph publishes
- F. `_entities` by hand, measured
- G. The three things that stopped the two schemas composing
- H. The request pipeline is unchanged
- I. Measurements
- J. Where docs and behaviour disagree
- K. A defect inherited from chapter 4
- L. What the gate asserts
- M. Reproduction recipes
- N. Left unmeasured, and who owns it
- O. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; source read at tag `16.6.0`, commit `8fea46e9560c973eba1b9c899937f9a6bb02aaf9`, cloned at F:/repo/graphql-platform |
| wgc (Cosmo CLI) | 0.129.7 | pinned exactly in `package.json` |
| Federation version HotChocolate emits | v2.6 | `@link` line of both published schemas |
| .NET SDK | 10.0.302 | `dotnet --version` |
| PostgreSQL | 18-alpine | `docker-compose.yml` |

No router and no Cosmo Router image are involved in this chapter. Composition
is run once as a gate (section G) and is chapter 9's subject.

## B. What was extracted, and what moved

Catalog is the domain that references nobody, which is what made it the first
one out. `git` recorded the move rather than a delete and an add. Measured with
`git diff --find-renames --summary ch07 ch08`:

```
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/CatalogRegistration.cs (81%)
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/Data/CatalogDataLoaders.cs (87%)
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/Data/CatalogSeedData.cs (98%)
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/Data/CatalogService.cs (68%)
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/Data/ProductConfiguration.cs (96%)
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/Model/ProductCategory.cs (73%)
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/Types/CatalogQueries.cs (97%)
rename src/{Mosaic.Api => Mosaic.Catalog}/Catalog/Types/ProductNode.cs (55%)
```

Eight files, not nine. `Catalog/Model/Product.cs` is *not* in that list: a file
of that name exists on both sides now, holding two different types, so git sees
a modification on one side and a new file on the other rather than a rename.
An intermediate commit did report nine renames, because at that moment
`Mosaic.Api` had no `Product.cs` at all; the number to quote is the one at the
tag.

Added and deleted lines per moved file, from
`git diff --find-renames -M20% --numstat ch07 ch08`:

| File | +/- | What changed |
|---|---|---|
| `CatalogRegistration.cs` | 2 / 2 | `using`, `namespace` |
| `CatalogDataLoaders.cs` | 2 / 2 | `using`, `namespace` |
| `CatalogSeedData.cs` | 2 / 2 | `using`, `namespace` |
| `ProductConfiguration.cs` | 2 / 2 | `using`, `namespace` |
| `ProductCategory.cs` | 1 / 1 | `namespace` |
| `CatalogQueries.cs` | 3 / 3 | two `using`s and the `namespace`; no root field touched |
| `ProductNode.cs` | 29 / 8 | both methods kept; comments rewritten and extended |
| `CatalogService.cs` | 25 / 39 | see below |

So five of the eight changed nothing but where they say they live. That is the
number the chapter quotes.

New in `src/Mosaic.Catalog/`: `Program.cs`, `Dockerfile`, `Properties/`,
`appsettings*.json`, `Catalog/Data/CatalogDbContext.cs`,
`Catalog/Data/CatalogDataRegistration.cs`,
`Catalog/Data/CatalogDatabaseSeeder.cs`, `Catalog/Model/ProductKey.cs`,
`Federation/PageCursorExtension.cs`.

`CatalogService` changed behaviour in exactly one way: it no longer reports to
`ServiceCallCounter`. The constructor lost that parameter and gained
`CatalogDbContext` in place of `MosaicDbContext`, the six
`counter.RecordLookup()` calls went, and all five query methods therefore
became expression-bodied because nothing was left in the braces. The class
comment was rewritten as well, which is most of the remaining diff. No query
changed.

**Not changed by a character:** `Pricing/Types/ProductPricingNode.cs`,
`Inventory/Types/ProductInventoryNode.cs`,
`Reviews/Types/ProductReviewsNode.cs`. All three are
`[ObjectType<Product>]` partial classes hanging fields off a type declared in
another folder, which is the repository layout rule from chapter 2. Verified
with `git diff --stat` on the extraction commit: none of the three appears.

Changed in `src/Mosaic.Api/`:

- `Catalog/Model/Product.cs` - the five-field record replaced by a class with
  one property and a reference resolver
- `Catalog/Model/ProductKey.cs` - new
- `Ordering/Types/OrderLineNode.cs` - the DataLoader lookup replaced by
  `new() { Id = line.ProductId }`
- `Reviews/Types/ReviewMutations.cs` - the product existence check and
  `[Error<ProductNotFoundError>]` removed
- `Reviews/Types/ReviewErrors.cs`, `Reviews/Model/ReviewExceptions.cs` - the
  product error and its exception removed
- `Infrastructure/Data/MosaicDbContext.cs` - `DbSet<Product>` removed
- `Infrastructure/Data/DatabaseSeeder.cs` - Catalog seeding removed, the
  already-seeded probe moved from `Products` to `Prices`
- `Infrastructure/Federation/PageCursorExtension.cs` - new
- `Ordering/Data/OrderingService.cs` - see section K
- `Program.cs`, `Mosaic.Api.csproj`

### The database

Catalog got its own database, `catalog`, on the same PostgreSQL container.
`docker-compose.yml` needed no new service and no init script: EF Core's
`EnsureCreatedAsync` creates the database as well as the schema, and the
`mosaic` role is the container's `POSTGRES_USER` and can do it.

Every domain already carried its own private copy of the product identifier
pattern - `private static Guid ProductId(int n) => new($"a0000000-0000-4000-8000-{n:D12}");`
appears in `PricingSeedData`, `InventorySeedData`, `ReviewsSeedData` and
`OrderingSeedData`, each with a comment saying the duplication is deliberate.
So the split needed no new shared file and no seed data changes.

## C. Where the federation attributes have to go

This is the question the SPEC's open item posed, and the answer is that the two
attributes behave differently.

Measured with a probe project against HotChocolate 16.6.0, four placements,
each on its own type in one schema:

| Placement | `@key` emitted | Reference resolver registered | Side effect |
|---|---|---|---|
| Both on the runtime type | yes | yes | none |
| Both on the `[ObjectType<T>]` class | yes | **no** | a public field appears |
| `[Key]` on the type, `[ReferenceResolver]` on the class | yes | **no** | a public field appears |
| `[Key]` on the class, `[ReferenceResolver]` on the type | yes | yes | none |

`[Key]` works in either place. `[ReferenceResolver]` works only on the runtime
type.

### The failure is silent and it is worse than a no-op

With `[ReferenceResolver]` on a static method inside an `[ObjectType<T>]`
partial class, the source generator treats the method as an ordinary field.
Exported SDL from the probe, verbatim:

```
type Alpha implements Node @key(fields: "id") {
  id: ID!
  resolveByKey(id: UUID!): Alpha
  title: String!
}
```

`resolveByKey` is callable. Measured:

```
{ alphas { resolveByKey(id: "11111111-1111-1111-1111-111111111111") { title } } }
{"data":{"alphas":[{"resolveByKey":{"title":"alpha one"}},{"resolveByKey":{"title":"alpha one"}}]}}
```

The type is still in the `_Entity` union, because `[Key]` did land, so the
schema composes and a router will call `_entities` against it. What comes back:

```
{"errors":[{"message":"Unexpected Execution Error","path":["_entities"]}],"data":null}
```

That is the same masked error chapter 7 met, and it means the same thing:
HotChocolate threw `EntityResolver_NoResolverFound` inside.

### Why, from the source

`ReferenceResolverAttribute.TryConfigure` (read at 16.6.0, commit `8fea46e`,
`src/HotChocolate/ApolloFederation/src/ApolloFederation/Resolvers/ReferenceResolverAttribute.cs`)
acts only when the descriptor it is handed is an `IObjectTypeDescriptor` or an
`IInterfaceTypeDescriptor`. A method inside a type extension class is compiled
into a field, so the descriptor is an object *field* descriptor and every
branch falls through. Nothing throws.

`HotChocolate.Types.Analyzers` has no knowledge of the attribute at all:
grepping the generator's source for `ReferenceResolver` returns only unrelated
matches on `SourceReferenceResolver`. The only federation attribute it knows
about is `HotChocolate.Types.Composite.ShareableAttribute`, which belongs to
the Composite Schemas stack rather than to Apollo Federation.

### What a reference resolver may take as parameters

Measured, all in one resolver:

- the key, by name, as a `string` - works
- an application-registered service (`services.AddSingleton<ProbeLookup>()`) -
  works
- `IResolverContext` - works
- a service registered only in the *schema* services, such as
  `INodeIdSerializerAccessor` - **does not work**. It is not recognised as a
  service by `InferredServiceParameterExpressionBuilder`, which asks
  `IServiceProviderIsService` about the *application* container, so the
  federation argument builder claims the parameter and tries to read
  `serializerAccessor` out of the representation. The resolver then throws on a
  null.

HotChocolate's own certification schema takes a service this way
(`ApolloFederation.Tests/CertificationSchema/AnnotationBased/Types/Product.cs`,
`GetProductById(string id, Data repository)`), so service injection is the
supported shape; only the container matters.

## D. The key is a global object identifier, and nothing decodes it

Mosaic turned `Product.id` into a Relay global identifier in chapter 5. In
chapter 8 the same field becomes the federation `@key`, and the two features do
not know about each other.

**Measured**: grepping the entire source of `HotChocolate.ApolloFederation` at
16.6.0 for `NodeId` or `Relay` returns nothing.

### What the key looks like on the wire

```
{ products { id sku title } }
{"data":{"products":[{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB","sku":"MOS-FRN-0001","title":"Larsen Oak Dining Table"}, ...
```

`UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB` is base64 of `Product:` followed by the
sixteen bytes of `a0000000-0000-4000-8000-000000000001`. The GraphQL type name
travels inside the key, which is what makes the two services agree: both name
the type `Product`.

### The reference resolver receives it undecoded

Measured with a probe whose reference resolver echoed its arguments back:

```
id-arrived-as=Rm94dHJvdDoRERERERERERERERERERER | service=probe-lookup | context=ok
```

The parameter is read out of the representation by
`ApolloFederation/Resolvers/ArgumentParser.cs`, which walks the key path,
coerces the literal with the field's scalar (`ID`, which yields the string
unchanged) and then hands it to `DefaultTypeConverter`. A parameter declared
`Guid` therefore fails to convert, `GetValue` returns `default`, and the
resolver is handed `Guid.Empty`.

**Measured consequence**: a subgraph whose reference resolver takes a `Guid`
answers `{"data":{"_entities":[null]}}` for a perfectly valid key. Not an
error. A null.

`[ID]` on the parameter changes nothing. Measured: an entity whose reference
resolver was declared `ResolveByKey([ID] Guid id)` resolved when handed the raw
Guid string and returned null when handed the encoded key, which is the exact
opposite of what the attribute suggests.

### The decode that works

```csharp
var accessor = context.Schema.Services?.GetService(typeof(INodeIdSerializerAccessor))
    as INodeIdSerializerAccessor;
var nodeId = accessor.Serializer.Parse(formattedId, typeof(Guid));
```

Measured returns: `TypeName` `Foxtrot`, `InternalId` the Guid, CLR type `Guid`.

Two details that cost time:

- The second argument is the type of the **internal identifier**, not the
  entity type. `Parse(id, typeof(Foxtrot))` throws
  `NodeIdMissingSerializerException: No serializer registered for type 'Foxtrot'`.
  This matches what HotChocolate does for an `[ID]` argument: read
  `Types/Relay/Serialization/GlobalIdInputValueFormatter.cs`, which calls
  `_serializer.Parse(formattedId, runtimeType)` with the runtime type of the
  id value.
- The accessor is registered in the schema services
  (`SchemaBuilder.Setup.cs:601`, `services.TryAddSingleton<INodeIdSerializerAccessor>`),
  not in the request services. Measured: `context.Services.GetService(...)`
  returns null; `context.Schema.Services.GetService(...)` returns it.

`Parse(id, typeof(string))` also succeeds and returns the sixteen raw bytes
read as a string, which is a silent wrong answer rather than an error.

### The type name check makes no observable difference in Mosaic

Measured both ways at tag `ch08`. A representation carrying a real customer key
under `"__typename": "Product"`, sent to Catalog:

```
{"data":{"_entities":[null]}}
```

The same null with the `nodeId.TypeName` comparison removed. Mosaic's internal
identifiers are `Guid`s, so a customer's decodes to a value no product has ever
had and the DataLoader misses either way. The check is insurance against an
identifier space where the internal value is not globally unique: with integer
keys, `Customer:5` and `Product:5` encode to different strings that decode to
the same `5`, and a resolver ignoring the type name would answer with product 5.
The chapter says exactly this rather than claiming a difference it cannot show,
and the lab exercise asks the reader to find the same non-result.

### A `__typename` the subgraph cannot resolve

Also measured, because the lab sends one. A valid product key under
`"__typename": "Customer"`, to either subgraph:

```
{"errors":[{"message":"Unexpected Execution Error","path":["_entities"]}],"data":null}
```

Not a null. `Customer` is not in Catalog's `_Entity` union at all, so this is
chapter 7's `EntityResolver_NoResolverFound` again rather than a failed lookup.
The two failure modes are worth being able to tell apart: a null means the
subgraph understood the question and had no answer, and this means it did not
understand the question.

## E. What each subgraph publishes

Both files are committed: `schema/catalog.graphql` and `schema/mosaic.graphql`.
Both are what `_service { sdl }` returns, checked by the gate.

### Catalog

```
schema
  @link(
    url: "https://specs.apollo.dev/federation/v2.6"
    import: ["@key", "@shareable", "@tag", "FieldSet"]
  ) {
  query: Query
}

type Query {
  products: [Product!]! @deprecated(reason: "...")
  browseProducts(...): ProductConnection! @listSize(...)
  productById(id: ID!): Product
  productBySku(sku: String!): Product
  _service: _Service!
  _entities(representations: [_Any!]!): [_Entity]!
}

type Product implements Node @key(fields: "id") {
  id: ID!
  sku: String!
  title: String!
  description: String
  category: ProductCategory!
}

union _Entity = Product
```

`@shareable` is in the import list because HotChocolate put it there for
`PageInfo`; see section G.

### Mosaic

```
type Product @key(fields: "id") {
  availableQuantity: Int!
  price: Money!
  reviews(first: Int, after: String, last: Int, before: String): ReviewConnection!
  averageRating: Float
  id: ID!
}
```

No `implements Node`: Mosaic has no node resolver for `Product`, only a
reference resolver. `id` is last because it is declared on the class while the
other four arrive from three `[ObjectType<Product>]` extensions.

The full diff of `schema/mosaic.graphql` against tag `ch07` is 44 insertions
and 140 deletions. What left: `node`, `nodes`, `products`, `browseProducts`,
`productById`, `productBySku`, `ProductConnection`, `ProductEdge`,
`ProductNotFoundError`, `ProductCategory`, all four product filter and sort
inputs, and `Product`'s `sku`, `title`, `description` and `category`. What
arrived: the `@link`, `_service`, `_entities`, `_Any`, `_Entity`, `FieldSet`,
`@key`, `@shareable`.

One line worth keeping: `OrderLine.product` lost its `@cost(weight: "10")`,
because it stopped being a resolver-backed field. That was before the cost
defaults were turned off in section G, so it is a real observation about the
field rather than a side effect of the setting.

## F. `_entities` by hand, measured

All of it typed at one subgraph with no router anywhere.

### Mosaic, one representation

```
query($r:[_Any!]!){ _entities(representations:$r){ ... on Product { id price { amount currency } availableQuantity averageRating } } }
{"r":[{"__typename":"Product","id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB"}]}
```

```
{"data":{"_entities":[{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB","price":{"amount":1249.00,"currency":"EUR"},"availableQuantity":12,"averageRating":4.25}]}}
```

### Catalog, two representations

```
{"data":{"_entities":[{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB","title":"Larsen Oak Dining Table","sku":"MOS-FRN-0001"},{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAC","title":"Larsen Dining Chair","sku":"MOS-FRN-0002"}]}}
```

### A key that does not decode

Both of these answer with a null entity and no `errors` key:

```
{"r":[{"__typename":"Product","id":"not-a-key"}]}
{"r":[{"__typename":"Product","id":"a0000000-0000-4000-8000-000000000001"}]}
```

```
{"data":{"_entities":[null]}}
```

The second one is the interesting one: a raw Guid, which is what the same
identifier looked like before chapter 5, is now indistinguishable from garbage.

### An order line hands out a key it cannot resolve

```
{ ordersByCustomer(customerId: "Q3VzdG9tZXI6AAAAwAAAAECAAAAAAAAAAQ==") { id total { amount currency } lines { quantity unitPrice { amount } product { id } } } }
```

```
{"data":{"ordersByCustomer":[{"id":"T3JkZXI6AAAA0AAAAECAAAAAAAAAAQ==","total":{"amount":2812.00,"currency":"EUR"},"lines":[{"quantity":1,"unitPrice":{"amount":1249.00},"product":{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB"}},{"quantity":6,"unitPrice":{"amount":229.00},"product":{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAC"}},{"quantity":1,"unitPrice":{"amount":189.00},"product":{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAH"}}]},{"id":"T3JkZXI6AAAA0AAAAECAAAAAAAAAAg==","total":{"amount":238.00,"currency":"EUR"},"lines":[{"quantity":2,"unitPrice":{"amount":119.00},"product":{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAY"}}]}]}}
```

The first line's `product.id` is character for character what Catalog answers
for the same product. That is the whole contract, visible in one response.

## G. The three things that stopped the two schemas composing

Composition was run with `npx wgc router compose -i federation/mosaic.yaml`.
None of this appears in the chapter as composition work - chapter 9 owns that -
but all three had to be fixed for the tag to be shippable, and each one is a
property of the subgraphs rather than of the composer.

### 1. `Query.node` and `Query.nodes` cannot be in two subgraphs

```
The Object "Query" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "node" is defined in the following subgraphs: "catalog", "mosaic".
 However, it is not declared "@shareable" in any of them.
 The field "nodes" is defined in the following subgraphs: "catalog", "mosaic".
 However, it is not declared "@shareable" in any of them.
```

`@shareable` would be wrong rather than merely awkward: each subgraph can only
resolve its own node types, so a router free to send `node(id:)` to either one
would return null for half the identifiers.

Fix: `AddGlobalObjectIdentification(registerNodeInterface: false)` in both.
Measured, that keeps the node id serializer (so `[ID]` still encodes), keeps
the `Node` interface in the schema, keeps `implements Node` on the types that
have node resolvers, and removes only the two root fields. Verified by
exporting the schema with the flag both ways.

### 2. HotChocolate's cost directives are not the ones the composer knows

```
The value ""10"" provided to argument "@cost(weight: ...)" is not a valid "Int!" type.
The definition for "@listSize" does not define the following argument that is provided: "slicingArgumentDefaultValue"
```

Reported for every resolver-backed field in both subgraphs. HotChocolate writes
`weight` as a `String`; wgc 0.129.7 carries a definition whose `weight` is
`Int!`.

The `@listSize` half is acknowledged in HotChocolate's own source. `CostOptions`
(`src/HotChocolate/CostAnalysis/src/CostAnalysis/Options/CostOptions.cs`)
declares:

```csharp
/// <summary>
/// Defines if the non-spec slicing argument default value shall be applied.
/// </summary>
public bool ApplySlicingArgumentDefaultValue { get; set; } = true;
```

Fix, in both services:

```csharp
.ModifyCostOptions(options =>
{
    options.ApplyCostDefaults = false;
    options.ApplySlicingArgumentDefaultValue = false;
})
```

`ApplyCostDefaults` and `SkipAnalyzer` are separate settings in the same class,
so this removes the automatically stamped weights and leaves the analyzer and
its limits in place. Chapter 5's cost numbers for `Product.reviews` were
measured with the defaults on and do not survive this; chapter 25 owns cost.

### 3. `PageCursor` is not shareable and `PageInfo` is

```
The Object "PageCursor" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "page" is defined in the following subgraphs: "catalog", "mosaic".
 The field "cursor" is defined in the following subgraphs: "catalog", "mosaic".
```

`FederationTypeInterceptor.OnAfterCompleteName` (16.6.0, commit `8fea46e`)
carries this, verbatim including the typo:

```csharp
// if we find a PagingInfo we will make all fields sharable.
if (configuration is ObjectTypeConfiguration typeCfg
    && typeCfg.Name.Equals(PageInfoType.Names.PageInfo))
```

It matches one type name. `PageCursor` is the type `PageInfo.forwardCursors`
and `backwardCursors` return (`GreenDonut.Data.PageCursor`), so it enters the
schema through the type that was just fixed and is left alone. Any two
subgraphs that both have a connection hit this.

Fix, in both services, and it is the same mechanism the repository already uses
to extend a type it does not own:

```csharp
[Shareable]
[ObjectType<PageCursor>]
public static partial class PageCursorExtension;
```

Measured result: `type PageCursor @shareable { ... }` in both schemas, and the
composition succeeds.

## H. The request pipeline is unchanged

Chapter 3 printed thirteen middleware in order. Measured after
`AddApolloFederation()`, the pipeline report at start-up:

```
Request pipeline: 13 middleware
  1. InstrumentationMiddleware
  2. ExceptionMiddleware
  3. TimeoutMiddleware
  4. DocumentCacheMiddleware
  5. DocumentParserMiddleware
  6. DocumentValidationMiddleware
  7. CostAnalyzerMiddleware
  8. OperationCacheMiddleware
  9. OperationResolverMiddleware
  10. SkipWarmupExecutionMiddleware
  11. OperationVariableCoercionMiddleware
  12. ConcurrencyGateMiddleware
  13. OperationExecutionMiddleware
```

Identical list, identical order. Federation adds fields to the schema, not
middleware to the pipeline. `CostAnalyzerMiddleware` is still there after
`ApplyCostDefaults = false`, which is the evidence that the setting turns off
the stamped weights rather than the analyzer.

**Measured on Mosaic only.** `AddPipelineReport()` is Mosaic's, added in
chapter 3, and `Mosaic.Catalog` does not register it. Catalog's pipeline was
never printed and the chapter says so rather than assuming the two are alike.
Giving Catalog the same report would be a reasonable thing for chapter 23 to
do when it instruments both services.

## I. Measurements

All on the author's machine, 2026-08-09, Release build, PostgreSQL 18 in
Docker, both services started with `MOSAIC_RESET_DATABASE=1`. Resolver and SQL
counts come from Mosaic's own request timeline (chapters 3 and 4); Catalog has
no timeline, so its statements were counted by turning EF Core command logging
on and counting `Executed DbCommand` lines.

### The catalog page, before and after

| | as one service (tag `ch05`) | as two subgraphs (tag `ch08`) |
|---|---|---|
| how it is asked | `{ products { title reviews(first: 12) { nodes { rating author { displayName } } } } }` | `_entities` with 25 representations, selecting the same `reviews` |
| resolvers | 146 | 146 |
| SQL in this service | 3 | **2** |
| reviews returned | 120 | 120 |

The resolver count is the same for a reason rather than by luck: it was
1 root field + 25 review connections + 120 authors, and it is now
1 `_entities` field + 25 + 120. The statement that left is the one that
selected the products, which Catalog runs instead.

The timeline line the first of those runs produced, captured from Mosaic's
console and printed in the chapter:

```
parse - validate 5.019ms compile 2.203ms coerce 3.270ms execute 188.741ms total 204.336ms
    (document cache miss, operation cache miss, 146 resolvers, 2 SQL)
```

Those five millisecond figures are one cold request on one machine, and the
chapter says so: it is the first `_entities` call of a freshly started process,
so `execute` includes the runtime warming up and both caches missing. The
numbers that are meant to survive are the two counts at the end. A warm repeat
of the same request on the same machine reported `total 4.866ms` with both
caches hitting, which is the same contrast chapter 3 measured and is not
re-argued here.

Five consecutive runs of the `_entities` query reported 2, 2, 2, 3, 2. The 3 is
the DataLoader settle-time behaviour decision 37 already documented: a batch
occasionally dispatches before its last keys arrive. The gate asserts that at
least one run hit 2 and that no run exceeded 3.

### The reference resolver behind a DataLoader

Catalog, 25 product keys:

| how the keys were sent | statements |
|---|---|
| all 25 in one `_entities` call | **1** |
| the same 25, one call at a time | **25** |

Both produce identical data. This is the number that makes representation
batching worth caring about, and it is invisible from the response.

### Smaller shapes, for the record

| request | resolvers | SQL |
|---|---|---|
| Mosaic `_entities`, 1 representation, `price` + `availableQuantity` | 3 | 2 |
| Mosaic `_entities`, 25 representations, `price` + `availableQuantity` | 51 | 2 |

51 is 1 + 25 + 25. Twenty-five products cost the same two statements as one.

### Seeded counts

Catalog logs `Seeded 25 products into a newly created database.`
Mosaic logs `Seeded 25 prices, 120 reviews, 12 customers and 8 orders into a newly created schema.`

## J. Where docs and behaviour disagree

- `[ID]` on a reference resolver parameter reads as though it will decode a
  global identifier. It does nothing at all; see section D.
- HotChocolate's `ApplySlicingArgumentDefaultValue` is documented in its own
  source as "the non-spec slicing argument default value" and is on by default,
  so the out-of-the-box subgraph publishes something the composer rejects.
- The `_Service` description shipped by HotChocolate is still wrong in the way
  chapter 7 recorded: it claims the SDL "does not include the additions of the
  federation spec", and it does.
- `OrderingService`'s own doc comment claimed order lines were owned and
  therefore did not need an `Include`. `OrderConfiguration` in the same
  repository says in as many words that they are related entities. The comment
  was wrong; see section K.

## K. A defect inherited from chapter 4

`OrderingService.GetOrdersByCustomerAsync` and `GetOrdersByIdsAsync` never
called `.Include(o => o.Lines)`. `OrderLine` is a related entity with a shadow
key, not an owned type, so the navigation was never loaded. Consequences, both
reproduced at tag `ch07` before anything in chapter 8 was written:

- `Order.lines` answered `[]` for every order
- `Order.total` threw, because it throws on an empty line collection

Present since chapter 4. No gate caught it because no request in
`postman/mosaic.postman_collection.json` had ever asked for an order. Chapter 8
found it because `OrderLine.product` is where a federated Mosaic hands a key to
Catalog, which made it the first time the book had a reason to read an order
line.

Chapter 4's prose is not wrong about this - it says plainly that the lines are
not owned, because an owned collection is a navigation and `OrderLine` is a
positional record. Only the service's comment and the missing `Include` were
wrong. Fixed at tag `ch08`, and the gate now asks for an order.

## L. What the gate asserts

`scripts/verify.ps1` and `scripts/verify.sh`, both of which have to stay in
step:

- both projects build in Release with warnings as errors
- `schema/catalog.graphql` and `schema/mosaic.graphql` match a fresh export
- both subgraphs publish exactly those files through `_service { sdl }`
- Catalog answers `products` with 25 rows
- Mosaic answers `_entities` with 25 representations, returning 120 reviews,
  reporting 146 resolvers and 2 SQL commands
- Catalog resolves 25 representations in one call for 1 statement
- an undecodable key produces a null entity and no error
- an order's lines are not empty and its total is 2812.00
- `wgc router compose -i federation/mosaic.yaml` succeeds
- the federated-wire section from chapter 7, unchanged
- the Postman collection `postman/mosaic-federation.postman_collection.json`

## M. Reproduction recipes

```
git checkout ch08
docker compose up -d mosaic-db
dotnet run --project src/Mosaic.Catalog     # :5101
dotnet run --project src/Mosaic.Api         # :5100
```

The federation-attribute probe of section C is not in the repository; it was a
throwaway project with five entity types, one per placement, exported with
`dotnet run -- schema export` and queried over HTTP. To rebuild it: one
`[QueryType]`, one type per row of the table in section C, and
`AddApolloFederation()` plus `AddGlobalObjectIdentification()` in `Program.cs`.

To count Catalog's statements:

```
$env:ASPNETCORE_ENVIRONMENT = 'Development'
${env:Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command} = 'Information'
```

then count `Executed DbCommand` in its console. Note the brace syntax: the
category name contains dots, and PowerShell needs `${env:...}` to set it.

To reproduce the composition errors of section G, revert one setting at a time
in either `Program.cs` and run
`npx wgc router compose -i federation/mosaic.yaml -o /tmp/out.json`.

## N. Left unmeasured, and who owns it

- **Anything a router does with these two subgraphs.** No router runs in this
  chapter. Chapter 10 owns it.
- **The supergraph the composer produced.** It was written and discarded;
  chapter 9 takes it apart.
- **`@requires`, `@provides`, `@external`, `@override`.** None is used here.
  Chapters 11 and 12.
- **Whether the reference resolver is called concurrently for one batch.**
  Chapter 7 read `EntitiesResolver.ResolveAsync` and found that it is; nothing
  in this chapter measured it against a DataLoader, which is chapter 11's
  subject.
- **The cost of the extraction in latency.** Neither service was timed. There
  is no router, so the only honest comparison would be one subgraph against the
  old monolith answering different questions. Chapter 10.
- **What happens when Catalog is down and Mosaic is asked for a product.**
  Nothing asks. Chapter 24.
- **Subscriptions and mutations through a federated graph.** `submitReview` and
  `onReviewAdded` still work against Mosaic directly and were not exercised
  through anything else. Chapters 12 and 14.
- **Whether `Query.node` can be given back to a federated graph.** Chapter 13.

## O. Bibliography keys

Reused from chapter 7, no new entries needed for the federation surface:

- `apollo2026subgraphspec` - the subgraph specification: `_service`,
  `_entities`, representations, the `[_Entity]` nullability
- `apollo2026shareable` - `@shareable` semantics, for section G

New:

- `graphqlspec2026costdraft` - only if the chapter names the cost specification
  draft that HotChocolate follows. Check the byline and status before citing;
  if it is a draft with no named editor, say so in the prose or drop it and
  describe the disagreement without a citation.
