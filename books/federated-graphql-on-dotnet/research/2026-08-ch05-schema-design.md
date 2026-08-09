# Chapter 05 research - schema design that survives change

Compiled 2026-08-09 for "Schema Design That Survives Change".

Tags on facts:

- `[source]` - read out of `ChilliCream/graphql-platform` at tag `16.6.0`,
  commit `8fea46e9560c973eba1b9c899937f9a6bb02aaf9`, cloned at
  F:/repo/graphql-platform. Decision 32 makes this the authority for internals.
- `[docs]` - the v16 documentation, read from `website/content/docs/` in the
  same clone, so it is pinned to the same commit as the code it describes.
- `[measured]` - produced by running Mosaic on this machine. Reproduction steps
  are given with the number.
- `[spec]` - the GraphQL specification or the Relay server specification.

## Contents

- A. Version baseline
- B. What `[ID]` does, and what it does not do until you ask
- C. Global object identification through the source generator
- D. Connections on a child field: batch paging and DataLoader branching
- E. Deprecation, and what cannot be deprecated
- F. Errors: the array, and the payload
- G. Subscriptions in one process
- H. Measurements
- I. Where docs and source or compiler disagree
- J. What chapter 5 changed in Mosaic
- K. A correction to chapter 04
- L. Reproduction recipes
- M. Left unmeasured, and who owns it

## A. Version baseline

Unchanged from chapter 04 except for one added package.

| Component | Version | Source |
|---|---|---|
| HotChocolate.* | 16.6.0 | pinned in `Directory.Packages.props` |
| HotChocolate.Subscriptions.InMemory | 16.6.0 | new in this chapter. `AddInMemorySubscriptions` lives in its own package, not in `HotChocolate.AspNetCore` `[source]` (`src/HotChocolate/Core/src/Subscriptions.InMemory/DependencyInjection/InMemorySubscriptionsServiceCollectionExtensions.cs`) |
| Microsoft.EntityFrameworkCore | 10.0.10 | unchanged |
| PostgreSQL | 18-alpine | unchanged |

Providers that exist alongside the in-memory one: Redis, NATS, Postgres
(`LISTEN`/`NOTIFY`), RabbitMQ. `[source]` (project folders under
`src/HotChocolate/Core/src/Subscriptions.*`). Only in-memory needs no
infrastructure. `[docs]`

## B. What `[ID]` does, and what it does not do until you ask

This is the chapter's biggest single finding and it was measured, not read.

**At tag `ch04`**, with `[ID]` on `ProductNode.GetId` and no
`AddGlobalObjectIdentification()` anywhere:

```
{ productById(id: "a0000000-0000-4000-8000-000000000001") { id sku } }
-> {"data":{"productById":{"id":"a0000000-0000-4000-8000-000000000001",
             "sku":"MOS-FRN-0001"}}}
```

The `id` field answers with the **raw Guid**, and a raw Guid is accepted as an
`[ID]` argument. `[measured]`

**At tag `ch05`**, with `AddGlobalObjectIdentification()` registered:

```
{ products { id } }
-> {"data":{"products":[{"id":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB"}, ...]}}

{ productById(id: "a0000000-0000-4000-8000-000000000001") { sku } }
-> {"errors":[{"message":"The node ID string has an invalid format.",
      "path":["productById"],
      "extensions":{"originalValue":"a0000000-0000-4000-8000-000000000001"}}],
    "data":{"productById":null}}
```

`[measured]`

`UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAB` base64-decodes to 24 bytes: the ASCII text
`Product:` followed by the 16 raw bytes of the Guid in `Guid.ToByteArray()`
order. `[measured]`

So `[ID]` on its own is close to inert. Turning global object identification on
changes the wire format of **every** identifier in the schema at once, in both
directions. That is a breaking change for every client holding a stored id, and
it is invisible in the SDL: `id: ID!` before and `id: ID!` after.

## C. Global object identification through the source generator

`AddGlobalObjectIdentification()` adds the `Node` interface and the `node` /
`nodes` root fields. At least one type must implement `Node` or the schema fails
to build. `[docs]`

The exported fields:

```graphql
node("ID of the object." id: ID!): Node @cost(weight: "10")
nodes("The list of node IDs." ids: [ID!]!): [Node]! @cost(weight: "10")
```

`[measured]` (from `schema/mosaic.graphql` at tag `ch05`)

### The documented route is not the generated route

`[docs]` (`defining-a-schema/relay.md`) describes `[Node]` on the class, with a
node resolver found by naming convention: a static method called `Get`,
`GetAsync`, `Get{TypeName}` or `Get{TypeName}Async`.

That is the reflection route, implemented in `NodeAttribute.OnConfigure`.
`[source]` (`src/HotChocolate/Core/src/Types/Types/Relay/Attributes/NodeAttribute.cs`)

The **source generator** has a separate route that the documentation does not
mention at all: `[NodeResolver]` on a method inside an `[ObjectType<T>]` class.
`ObjectTypeFileBuilder` then emits

```csharp
descriptor
    .ImplementsNode()
    .ResolveNode(resolvers.ResolveProductAsync().Resolver!);
```

`[source]` (`Types.Analyzers/FileBuilders/ObjectTypeFileBuilder.cs` lines 42-52)

No `[Node]` attribute is required, and no naming convention applies. Mosaic uses
this route because every domain type is already an `[ObjectType<T>]` partial
class. Confirmed by building and by reading the exported SDL. `[measured]`

### The rules the generator enforces, none of them documented

All are compile-time errors with their own diagnostic ids. `[source]`
(`Types.Analyzers/Errors.cs`)

| Code | Rule |
|---|---|
| HC0104 | The first parameter of a node resolver must be named `id` |
| HC0092 | That parameter must **not** carry `[ID]`; the node resolver already declares it as an ID |
| HC0093 | The method must be public |
| HC0083 | A node resolver may have only one field argument, `id` |
| HC0084 | Same rule, reported against the offending argument |

HC0104's title in the source is "NodeResolver First Parameter Must Be Named
'id'". The docs say only "accepts the ID as its first parameter".

### What Mosaic implements

Four types implement `Node`: `Product`, `Customer`, `Review`, `Order`.
`OrderLine` does not, and that is deliberate: it has no identifier in the domain
model at all, which is why chapter 04 gave it a shadow key.

Two of the four had no by-identifier lookup before this chapter.
`OrderingService.GetOrdersByIdsAsync` and `ReviewsService.GetReviewsByIdsAsync`
were both added for it, each behind a new batch DataLoader, because
`nodes(ids:)` resolves many identifiers in one request.

## D. Connections on a child field

### `[UseConnection]` does not make a field a connection

Measured the hard way. A resolver annotated `[UseConnection]` returning
`Connection<Review>` produced `reviews: [Review!]!` in the SDL - a list, no
error, no warning. `[measured]`

The attribute's own summary says what it is for: "This attribute allows to
override the global paging options for a specific field." Its `TryConfigure`
adds a paging **validation** middleware and sets `PagingOptions`. It never
rewrites the field type. `[source]`
(`Types.CursorPagination/Extensions/UseConnectionAttribute.cs`)

`[UsePaging]` is the one that rewrites: its `TryConfigure` calls
`ofd.UsePaging(...)`. `[source]` (`UsePagingAttribute.cs`)

What actually made the field a connection in Mosaic is the **return type**,
`PageConnection<Review>`, which carries `[GraphQLName("{0}Connection")]` and
declares an implicit conversion from `Page<TNode>`. `[source]`
(`Types.CursorPagination.Extensions/PageConnection.cs` line 88)

So a reader who annotates a list-returning resolver with `[UseConnection]` gets
a list and no diagnostic. This is the chapter's second silent failure.

### Batch paging: one statement for many parents

`ToBatchPageAsync` returns `Dictionary<TKey, Page<TValue>>`. `[source]`
(`GreenDonut.Data.EntityFramework/Extensions/PagingQueryableExtensions.cs`
lines 310, 354, 402)

It calls `QueryHelpers.EnsureOrderPropsAreSelected(source)` first, so the cursor
keys come from the `OrderBy` already on the queryable. Mosaic orders by
`CreatedAt` then `Id`, and the identifier is the tiebreaker that makes the order
total.

The generated statement is a window function. Captured with the EF Core command
log at `Information`, for `reviews(first: 3)`: `[measured]`

```sql
SELECT r1.product_id, r3.id, r3.body, r3.created_at, r3.customer_id,
       r3.product_id, r3.rating
FROM (
    SELECT r.product_id
    FROM reviews AS r
    WHERE r.product_id = ANY (@productIds)
    GROUP BY r.product_id
) AS r1
LEFT JOIN (
    SELECT r2.id, r2.body, r2.created_at, r2.customer_id, r2.product_id, r2.rating
    FROM (
        SELECT r0.id, r0.body, r0.created_at, r0.customer_id, r0.product_id,
               r0.rating,
               ROW_NUMBER() OVER(PARTITION BY r0.product_id
                                 ORDER BY r0.created_at, r0.id) AS row
        FROM reviews AS r0
        WHERE r0.product_id = ANY (@productIds)
    ) AS r2
    WHERE r2.row <= 4
) AS r3 ON r1.product_id = r3.product_id
ORDER BY r1.product_id, r3.product_id, r3.created_at, r3.id
```

Note `r2.row <= 4` for `first: 3`. It fetches n+1 rows per parent, which is how
`hasNextPage` is answered without a second query.

### DataLoader branching

`PagingArguments` in a `[DataLoader]` method is not a service parameter. The
generator emits `context.GetRequiredState<PagingArguments>("key")` for it.
`[source]` (`Types.Analyzers/FileBuilders/DataLoaderFileBuilder.cs` line 427)

What puts it in that state is `.With(pagingArguments)` in the resolver:

```csharp
var branchKey = pagingArguments.ComputeHash(context);
var state = new PagingState<TValue>(pagingArguments, context);
return (IQueryDataLoader<TKey, Page<TValue>>)dataLoader.Branch(branchKey, CreateBranch, state);
```

`[source]` (`GreenDonut.Data/Extensions/GreenDonutPaginationBatchingDataLoaderExtensions.cs`
lines 45-57)

`ComputeHash` hashes `first`, `after`, `last`, `before` and, if present, the
`QueryContext`'s selector, predicate and sorting. `[source]` (same file, line
184, and `Internal/DataLoaderStateHelper.cs`)

A branch is a `QueryDataLoader<TKey,TValue>` wrapping the same base loader under
a different key, with its own state and its own promise cache. `[source]`
(`DataLoaderStateHelper.CreateBranch`)

So: same page shape, one branch, one batch, one statement. Different page shape,
different branch, and the two cannot serve each other's promises. Without
branching a shared cache would hand the second caller the first caller's page.

### A missing key is still null

`ToBatchPageAsync` returns entries only for keys that have rows. Three of
Mosaic's twenty-five products have no reviews. `Product.reviews` is non-nullable,
so the service fills the gaps:

```csharp
foreach (var productId in productIds)
{
    pages.TryAdd(productId, Page<Review>.Empty);
}
```

`Page<T>.Empty` exists (`ValueCursorPage<T>.Empty`). `[source]`
(`GreenDonut.Data.Primitives/Page.cs` line 203)

This is chapter 04's `ILookup`-versus-`Dictionary` lesson returning in a new
shape. There is no `ILookup` escape here, because the value is a page rather
than a sequence, so the empty answer has to be supplied deliberately.

## E. Deprecation

`@deprecated` applies to output fields, input fields, arguments and enum values
with no configuration. `[GraphQLDeprecated("reason")]` and .NET's
`[Obsolete("reason")]` behave identically for all of those. `[docs]`
(`defining-a-schema/versioning.md`)

Mosaic deprecates `Query.products`, and it goes on answering. The field in the
exported SDL: `[measured]`

```graphql
products: [Product!]!
  @cost(weight: "10")
  @deprecated(
    reason: "Returns the whole catalog with no upper bound on its size. Use `browseProducts`, which pages, filters and sorts."
  )
```

### What cannot be deprecated

A non-null argument or input field **with no default value** cannot be
deprecated. Deprecating a required input would silently break every query that
supplies it. `[docs]`, stated as a warning. The same restriction applies to
`@requiresOptIn`.

### Object type deprecation is off by default and tracks an open RFC

`@deprecated` on an object type needs `ModifyOptions(o => o.EnableObjectDeprecation = true)`.
It is **not** in the released specification: it tracks graphql-spec RFC #997,
which is still open. `[docs]`

Two consequences worth knowing if it is ever turned on:

- `[Obsolete]` on a class does **not** deprecate the type; only
  `[GraphQLDeprecated]` does. The docs give the reason: honouring `[Obsolete]`
  would silently deprecate types across existing codebases the moment the option
  was enabled.
- A field that is not itself deprecated **cannot return** a deprecated object
  type; the schema fails to build. Reaching one through an interface or a union
  is fine.

Mosaic does not enable it. Verified only from `[docs]`; not measured.

### `@requiresOptIn`

The other half of the versioning story and the mirror image of `@deprecated`:
`@deprecated` marks what is going away, `@requiresOptIn` marks what is not
stable yet. Off by default (`EnableOptInFeatures`), repeatable, hides the
element from introspection until a consumer names the feature via
`fields(includeOptIn: [...])`. `__schema { optInFeatures }` lists them and
`OptInFeatureStability(...)` declares a stability level. `[docs]`

Mosaic does not use it. Cited for the chapter, not measured.

## F. Errors

### Two mechanisms, and the choice between them

Field errors go in the `errors` array; the field returns null and the rest of
the query still resolves. `[docs]` (`resolvers/errors.md`)

By default an exception is **not** passed through: the client gets
`"Unexpected Execution Error"`. `GraphQLException` is sent as-is.
`AddErrorFilter` rewrites a typed exception into a coded error. `[docs]`

### Mutation conventions

`AddMutationConventions(applyToAllMutations: true)` generates the input and
payload types. `submitReview(rating, body, ...)` became: `[measured]`

```graphql
type Mutation {
  submitReview(input: SubmitReviewInput!): SubmitReviewPayload! @cost(weight: "10")
}

type SubmitReviewPayload {
  review: Review
  errors: [SubmitReviewError!]
}

union SubmitReviewError =
  | ProductNotFoundError
  | CustomerNotFoundError
  | RatingOutOfRangeError
  | DuplicateReviewError
```

Services and `CancellationToken` are excluded from the generated input; only
parameters that map to GraphQL arguments appear. `[docs]`

### `[Error<T>]` exists and the docs do not show it

`[docs]` shows only `[Error(typeof(X))]`. `ErrorAttribute<TError>` is a sealed
generic subclass in the same file. `[source]`
(`src/HotChocolate/Core/src/Types.Errors/ErrorAttribute.cs` line 41)

Mosaic uses `[Error<ProductNotFoundError>]`, which matches the `[ObjectType<T>]`
style the rest of the codebase already uses.

The attribute's own doc comment says its argument may be "the type of the
exception, the class with factory methods or the error with an exception as the
argument". Mosaic points it at the **error class**, which carries
`public static XError CreateErrorFrom(XException ex)`. Pointing it at the
exception instead copies the exception's `Message` onto the payload and leaves
nowhere to put a code.

Naming: pointing `[Error]` at an exception rewrites `FooException` to `FooError`
in the schema. Pointing it at a class already called `FooError` leaves the name
alone. `[docs]` and `[measured]`

### A custom error interface

`AddErrorInterfaceType<IMosaicError>()` replaces the built-in `Error` interface,
which carries only `message`. Mosaic's carries `message` and `code`:
`[measured]`

```graphql
interface Error {
  message: String!
  code: String!
}

type RatingOutOfRangeError implements Error {
  message: String!
  code: String!
  min: Int!
  max: Int!
}
```

Error classes do not have to implement the C# interface; matching properties are
enough. `[docs]` Mosaic implements it anyway so the compiler catches an error
type that forgets its code.

### Measured responses

All four are HTTP 200 with `data` non-null. `[measured]`

| Case | `review` | `errors[0].__typename` | code |
|---|---|---|---|
| valid | the new review | (`errors` is null) | - |
| repeat submission | null | `DuplicateReviewError` | `DUPLICATE_REVIEW` |
| rating 9 | null | `RatingOutOfRangeError` | `RATING_OUT_OF_RANGE` |
| unknown product | null | `ProductNotFoundError` | `PRODUCT_NOT_FOUND` |

`RatingOutOfRangeError` also returned `"min":1,"max":5`.

### The cost of a union of errors

`errors` is a union, so a client cannot select `message` on it directly.
Attempting it: `[measured]`

```
"A union type cannot declare a field directly. Use inline fragments or
 fragments instead."
extensions: {"type":"SubmitReviewError",
             "specifiedBy":"https://spec.graphql.org/September2025/#sec-Field-Selections"}
```

The working form is `errors { __typename ... on Error { message code } }`. The
custom interface is what makes that one fragment cover every member; with the
default interface a client would still get `message` this way but not a code.

Incidental but worth recording: HotChocolate 16.6.0 points at the **September
2025** edition of the specification. `[measured]`

## G. Subscriptions in one process

`[SubscriptionType]` on a partial static class; `[Subscribe]` on the field;
`[EventMessage]` on the parameter that receives the payload. `[docs]`

Mosaic uses the custom subscribe resolver form,
`[Subscribe(With = nameof(SubscribeToReviewsAsync))]`, rather than a `[Topic]`
placeholder. The subscribe resolver receives the field's arguments like any
other resolver, so the topic string is built by a function both ends call:

```csharp
public static string ReviewAdded(Guid productId) => $"reviewAdded:{productId}";
```

The documented alternative is `[Topic($"{{{nameof(productId)}}}")]`, which
interpolates the argument value into the topic. That works, and it leaves the
exact string an argument formats into as something you discover by running it.
Not measured; Mosaic took the explicit route instead.

Transports: WebSocket needs `app.UseWebSockets()`; server-sent events work
through `MapGraphQL` with nothing added. `[docs]`

Measured end to end over SSE: `[measured]`

```
POST /graphql, Accept: text/event-stream
subscription { onReviewAdded(productId: "...") { id rating body author { displayName } } }

-> event: next
   data: {"data":{"onReviewAdded":{"id":"UmV2aWV3Og7knwGk/wp1qg9QZb4xFzc=",
          "rating":5,"body":"Boils fast, pours clean.",
          "author":{"displayName":"Sofia Ferrari"}}}}
```

The `id` on the event is the same one the mutation's payload returned, and
`author` was resolved inside the subscription's own execution - a DataLoader
ran per event, not per subscription.

The in-memory provider is single-process. Events are lost on restart and are not
shared across instances. `[docs]` Chapter 14 owns the federated and
multi-instance story.

## H. Measurements

Machine: Windows 11, .NET SDK 10.0.302, PostgreSQL 18-alpine in Docker Desktop
on the same box, service built in Release, twenty warm-up requests before any
measured run.

### H1. The counts did not move

The chapter's query, in the shape the connection requires:

```
{ products { title reviews(first: 12) { nodes { rating author { displayName } } } } }
```

`first: 12` because the most-reviewed product has exactly 12 reviews, so this
asks for all 120.

```
parse - validate - compile - coerce - execute 5.405ms total 5.529ms
    (document cache hit, operation cache hit, 146 resolvers, 3 SQL)
```

146 resolvers and 3 statements, the same two numbers chapter 04 ended on. The
field changed shape and the batching did not. `[measured]`

Seed distribution, review count per product in `products` order: `[measured]`

```
12 8 10 3 6 5 8 4 7 0 2 9 5 3 4 6 0 6 3 8 2 0 4 1 4
```

Sum 120, maximum 12, three zeros.

### H2. A smaller page does less work

Same query with `first: 3`: `[measured]`

```
parse - validate - compile - coerce - execute 4.323ms total 4.373ms
    (document cache hit, operation cache hit, 88 resolvers, 3 SQL)
```

88 resolvers rather than 146: 1 for `products`, 25 for `reviews`, and 62 authors,
because 62 is the sum of `min(3, count)` over the twenty-five products. Still 3
statements. The window function returns fewer rows; it does not run more times.

### H3. Paired latency, ch04 against ch05

Both measured in one sitting, alternating tags with `bin` and `obj` deleted
between them, because chapter 04's research file records that measuring them
hours apart says nothing. Ten warm runs each, `total` off the timeline, sorted.
`[measured]`

| Tag | Field shape | Ten runs, sorted (ms) |
|---|---|---|
| `ch04` | `reviews` as `[Review!]!` | 5.743 5.924 5.946 6.130 6.480 6.560 6.662 6.730 7.074 7.260 |
| `ch05` | `reviews(first: 12)` as a connection | 8.333 8.385 8.858 9.017 9.260 9.368 9.556 9.691 9.838 10.178 |

Means: 9.2484 ms for `ch05` against 6.4509 ms for `ch04`, a gap of 2.8, for the
same 120 reviews. The chapter rounds these to 9.2 and 6.5 and says "under three
milliseconds" for the difference. **The connection is slower here, and the chapter says so.** A window
function partitioned over the parent key is more work than a plain scan, and at
120 rows the bound it buys is worth nothing. What it buys is that the number
stops depending on how many reviews a product has.

An earlier pass the same afternoon measured the ch05 shape at 4.9-7.3 ms, on the
same code, purely because the machine was quieter. Only the paired figures above
mean anything.

### H4. What the cost analyzer learned

`GraphQL-Cost: validate` on the same query, varying only the page size:
`[measured]`

| Query | fieldCost | typeCost |
|---|---|---|
| `reviews` as a list, at tag `ch04` | 30 | 4 |
| `reviews(first: 2)` | 41 | 7 |
| `reviews(first: 5)` | 71 | 13 |
| `reviews(first: 50)` | 521 | 103 |
| `reviews` with no page argument | 121 | 23 |

The ch04 figures are the ones that tag's Postman collection asserted and passed;
the rest were measured directly at ch05.

The connection's field carries a `@listSize` directive whose `slicingArguments`
name `first` and `last`, with `slicingArgumentDefaultValue: 10`: `[measured]`

```graphql
reviews(first: Int, after: String, last: Int, before: String): ReviewConnection!
  @listSize(
    assumedSize: 50
    slicingArguments: ["first", "last"]
    slicingArgumentDefaultValue: 10
    sizedFields: ["edges", "nodes"]
    requireOneSlicingArgument: false
  )
  @cost(weight: "10")
```

So the cost is linear in the page: ten per review, and the no-argument case
resolves to the default of ten reviews. The list form cost 30 whatever came
back. This is the strongest argument in the chapter for connections, and it is
not about pagination at all: an unbounded list cannot be costed, so it cannot be
rate-limited, budgeted or refused.

### H5. `totalCount` costs a statement here, and did not in chapter 04

Selecting `totalCount` on the nested connection adds a statement: `[measured]`

```sql
SELECT r.product_id AS "Key", count(*)::int AS "Count"
FROM reviews AS r
WHERE r.product_id = ANY (@productIds)
GROUP BY r.product_id
```

The timeline then reports 4 SQL rather than 3.

Chapter 04 measured the opposite for `browseProducts`, where the count arrived
as a correlated subquery inside the page's own statement and cost no extra round
trip. Both are true. A root connection can fold its count into its own query; a
batched child connection is already a window over a group, and the count of each
group is a second aggregate.

### H6. Two branches in one request

Measured after the audit, because the branching figure originally asserted a
scenario nothing had run. One product, two aliased pages of its reviews:

```graphql
{ productBySku(sku: "MOS-FRN-0001") {
    a: reviews(first: 2) { nodes { id } }
    b: reviews(first: 5) { nodes { id } } } }
```

```
parse - validate - compile - coerce - execute 4.816ms total 4.865ms
    (document cache hit, operation cache hit, 3 resolvers, 3 SQL)
```

Three statements: one for `productBySku`, and one for each branch. The database
log shows the two window cuts, `row <= 3` and `row <= 6`, which is the n+1 rule
applied to `first: 2` and `first: 5` separately. `[measured]`

This is the branching mechanism from section D seen from outside, and it is the
lab's exercise 4.

### H7. Two real error responses from Mosaic

Both measured, and both used in the chapter in place of the documentation's
examples. `[measured]`

A field error that does not terminate the request. `node` with a well-formed
identifier naming a type no resolver is registered for:

```json
{"errors":[{"message":"There is no node resolver registered for type `Widget`.",
  "path":["node"]}],
 "data":{"node":null}}
```

`data` is present, the field is null, and any sibling field would still have
resolved.

The same failure where the field cannot be null. A `Customer` identifier passed
to `submitReview`, whose `productId` argument is `[ID<Product>]`:

```json
{"errors":[{"message":"The node id type name `Customer` does not match the expected type name `Product`.",
  "path":["submitReview"]}],
 "data":null}
```

`submitReview` returns `SubmitReviewPayload!`, so there is nowhere to write a
null and the error propagates to the root. Same class of failure, same array,
and the difference in blast radius is entirely down to one exclamation mark.

Worth noting what these are not: neither is masked as `Unexpected Execution
Error`, because both are HotChocolate's own errors rather than an exception
escaping a resolver. Nothing in Mosaic throws an unhandled exception on any
input tried, so the masking behaviour is cited from `[docs]` and the chapter
says so.

## I. Where docs and source or compiler disagree

1. **`[NodeResolver]` is undocumented.** `[docs]` describes only the reflection
   `[Node]` route with its naming convention. The generator route, its emitted
   `ImplementsNode().ResolveNode(...)`, and its five diagnostics (HC0083,
   HC0084, HC0092, HC0093, HC0104) appear nowhere in the documentation. See
   section C.

2. **`[UseConnection]` does not create a connection.** Its name reads as though
   it does. It sets paging options; the return type creates the connection. No
   diagnostic fires when the two disagree. See section D.

3. **`[Error<T>]` is undocumented.** Only `[Error(typeof(T))]` appears in
   `[docs]`. The generic form is in the source. See section F.

4. **`GetValue<bool>` throws on `"1"`.** Not a HotChocolate matter, but it cost
   time and it is in the chapter. `configuration.GetValue<bool>("X")` with `X=1`
   raises `InvalidOperationException: Failed to convert configuration value '1'
   ... to type 'System.Boolean'`, unhandled, and the host fails to start. Only
   `true` and `false` parse. Mosaic's other switch is `MOSAIC_KEEP_DATABASE=1`,
   so `=1` is the shape a reader copies. `[measured]`

5. **`schema export --output` resolves relative paths against the project
   directory**, not the working directory, so the README's
   `--output schema/mosaic.graphql` run from the repository root fails with
   `DirectoryNotFoundException` for
   `src/Mosaic.Api/schema/mosaic.graphql`. An absolute path works. `[measured]`
   Minor; noted so the next chapter does not rediscover it.

## J. What chapter 5 changed in Mosaic

Tag `ch05`. One tag, not two: unlike chapter 04 there is no before-and-after
worth checking out, because the before is tag `ch04`.

1. `AddGlobalObjectIdentification()`, and `[NodeResolver]` on `Product`,
   `Customer`, `Review` and `Order`. Two new by-id service methods and two new
   DataLoaders to back them.
2. `Product.reviews` from `[Review!]!` to `ReviewConnection!`, behind
   `ToBatchPageAsync` and a branched DataLoader. The `ILookup` loader is gone.
3. `Query.products` deprecated in favour of `browseProducts`.
4. `submitReview`, mutation conventions on globally, four typed domain errors,
   and a custom `Error` interface carrying a code.
5. `onReviewAdded(productId:)` over the in-memory provider, published by the
   mutation after the write commits.
6. `MOSAIC_RESET_DATABASE` in the seeder; both verify scripts set it.

Two of these are breaking changes: 1 and 2. The chapter does not pretend
otherwise, and the contrast with 3 is the chapter's spine.

### The verification gate

`scripts/verify.ps1` and `scripts/verify.sh` both pass. The Postman collection
went from 10 requests and 36 assertions to **19 requests and 74 assertions**.
Two consecutive runs of `verify.ps1` both passed, which is the check that
matters for the database reset. `[measured]`

## K. A correction to chapter 04

Chapter 04's Postman collection carries an assertion named "the projection kept
the identifier":

```javascript
const raw = Buffer.from(node.id, "base64").toString("utf8");
pm.expect(raw).to.not.include("00000000-0000-0000-0000-000000000000");
```

At tag `ch04` ids were raw Guids, not base64 (section B). Base64-decoding
`a0000000-0000-4000-8000-000000000001` yields binary noise, and so does
base64-decoding `00000000-0000-0000-0000-000000000000`. Neither contains the
literal zero-Guid text, so **the assertion passes whichever value it is given**.
Verified with node: `[measured]`

```
"a0000000-0000-4000-8000-000000000001" -> contains zero-guid: false
"00000000-0000-0000-0000-000000000000" -> contains zero-guid: false
```

The assertion could never have caught the bug it was written for. The prose of
chapter 04 is right about the bug, right about `[Parent("Id")]` as the fix, and
wrong only about the gate: the collection was not catching it.

Chapter 04's prose also says `[ID]` "has to encode the raw `Guid` into an opaque
identifier". At tag `ch04` it did not encode anything. `Product.id` is
resolver-backed because the author wrote a method for it, and the projection
failure follows from that alone, so the finding stands and the stated reason
does not.

Fixed at tag `ch05`: the assertion now decodes the id, checks the length is 24
bytes, checks the ASCII prefix is `Product:`, and checks the trailing sixteen
bytes are not all zero. That fails when the identifier is wrong.

## L. Reproduction recipes

PostgreSQL must be up: `docker compose up -d mosaic-db`.

1. **The counts.** Run the service, send the H1 query, read the timeline line.

2. **The window function.** Set
   `Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command` to
   `Information` and send `reviews(first: 3)`. On bash the variable name
   contains dots, which bash will not assign, so use
   `env 'Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command=Information' dotnet run ...`.

3. **The cost table.** `-H 'GraphQL-Cost: validate'` on the query, varying
   `first`. The response carries only `extensions.operationCost` and no `data`.

4. **The `[ID]` change.** `git checkout ch04`, delete `bin` and `obj`, run, and
   ask for `products { id }`. Then the same at `ch05`.

5. **Paired latency.** Alternate the two tags in one sitting, deleting `bin` and
   `obj` between them, twenty warm-up requests then ten measured. Measuring them
   an hour apart measures the machine.

6. **The subscription.** POST the subscription document with
   `Accept: text/event-stream` and leave the connection open, then send the
   mutation from a second terminal.

7. **The reset.** Run `pwsh scripts/verify.ps1 -KeepDatabase` twice in a row.
   Without `MOSAIC_RESET_DATABASE` the second run fails on the review count.

## M. Left unmeasured, and who owns it

- **`@requiresOptIn` and object-type deprecation.** Both cited from `[docs]`,
  neither enabled in Mosaic, neither measured. Object-type deprecation tracks an
  open RFC and should be re-checked before any chapter relies on it.
- **`[Topic]` placeholder formatting.** Mosaic uses an explicit subscribe
  resolver, so the exact string a `Guid` argument interpolates into a topic was
  never established.
- **WebSocket transport.** Only server-sent events were exercised.
  `app.UseWebSockets()` is registered and graphql-ws was not tested. Chapter 14
  and chapter 18 own the transports.
- **Subscriptions under more than one subscriber, or across a restart.** The
  in-memory provider's stated limits were not provoked.
- **Cursor stability across a write.** Nothing checked what happens to an open
  cursor into `reviews` when a review is inserted ahead of it. Keyset
  pagination makes this better behaved than offsets, but "better" was not
  measured. Chapter 13 owns cross-boundary pagination.
- **`MaxPageSize`.** Left at the default of 50 and never approached; chapter 25
  owns request limits.
- **Whether the deprecation is enforced anywhere.** It is a message in the
  schema and nothing rejects a query that uses `products`. Chapter 22 owns
  breaking-change detection and the deprecation workflow, and is where
  `wgc check` turns this into a gate.
