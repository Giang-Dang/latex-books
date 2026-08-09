# Chapter 04 research - EF Core, DataLoaders, and the data middleware

Compiled 2026-08-09 for "Data Without the N+1".

Tags on facts:

- `[source]` - read out of `ChilliCream/graphql-platform` at tag `16.6.0`,
  commit `8fea46e9560c973eba1b9c899937f9a6bb02aaf9`, cloned at
  F:/repo/graphql-platform. Decision 32 makes this the authority for internals.
- `[docs]` - the v16 documentation, read from `website/content/docs/` in the
  same clone, so it is pinned to the same commit as the code it describes.
- `[measured]` - produced by running Mosaic on this machine. Reproduction steps
  are given with the number.
- `[nuget]` - read from a package's own nuspec on nuget.org.

## Contents

- A. Version baseline
- B. The DataLoader source generator
- C. Batching internals: who decides when a batch goes
- D. Where docs and source disagree
- E. EF Core integration surface
- F. The v16 data middleware (filtering, sorting, paging, projections)
- G. What Mosaic was changed into
- H. Measurements
- I. Reproduction recipes
- J. Left unmeasured, and who owns it

## A. Version baseline

| Component | Version | Source |
|---|---|---|
| HotChocolate.Data | 16.6.0 | `[nuget]` |
| HotChocolate.Data.EntityFramework | 16.6.0 | `[nuget]`; its nuspec carries `repository commit="8fea46e9560c973eba1b9c899937f9a6bb02aaf9"`, the same commit the 16.6.0 tag resolves to, so the package and the tree read for this chapter are the same build |
| GreenDonut / GreenDonut.Data / GreenDonut.Data.EntityFramework | 16.6.0 | `[nuget]` |
| Microsoft.EntityFrameworkCore | 10.0.10 | `[nuget]`, latest stable in the 10.x band |
| Npgsql.EntityFrameworkCore.PostgreSQL | 10.0.3 | `[nuget]`; its net10.0 group requires `Microsoft.EntityFrameworkCore [10.0.4, 11.0.0)`, which is why the pin is 10.0.10 and not 10.0.0 |
| PostgreSQL | 18-alpine | container image tag used in docker-compose |

`HotChocolate.Data.EntityFramework` 16.6.0 declares four target framework
groups - net8.0, net9.0, net10.0, net11.0 - each pinning a different EF Core
minimum (8.0.15, 9.0.4, 10.0.0, 11.0.0-preview.6). Mosaic is net10.0, so the
floor is EF Core 10.0.0 and the Npgsql provider raises it to 10.0.4. `[nuget]`

## B. The DataLoader source generator

### What triggers it

`DataLoaderInspector` matches any **method** carrying
`GreenDonut.DataLoaderAttribute`. `[source]`
(`src/HotChocolate/Core/src/Types.Analyzers/Inspectors/DataLoaderInspector.cs`)

`DataLoaderInfo`'s constructor validates three things and reports a diagnostic
rather than throwing: the method must have at least one parameter, its
accessibility must be public / internal / protected-internal, and it must not
be generic. `[source]` (`Models/DataLoaderInfo.cs`)

The containing class does **not** have to be `partial`. This differs from
`[QueryType]` and `[ObjectType<T>]`, which do, and it is worth stating because
the two attribute families otherwise look alike.
Confirmed by compiling Mosaic. `[measured]`

### How the name is derived

`DataLoaderInfo.GetDataLoaderName` strips a leading `Get`, then a trailing
`Async`, then a trailing `DataLoader`, then appends `DataLoader`. The interface
is that with an `I` in front. So
`GetReviewsByProductIdAsync` produces `ReviewsByProductIdDataLoader` and
`IReviewsByProductIdDataLoader`. `[source]` (`Models/DataLoaderInfo.cs`)

`[DataLoader("Name")]` overrides it, and the name is positional, not a
property. `[docs]` calls this out explicitly: `[DataLoader(Name = "X")]` does
not compile.

### How the kind is chosen

`DataLoaderGenerator.WriteDataLoader` decides from the return type, in this
order: `[source]` (`Generators/DataLoaderGenerator.cs`)

1. `IsReturnTypeDictionary` - the task's result implements
   `IReadOnlyDictionary<TKey,_>` or `IDictionary<TKey,_>` with a matching key
   type: **Batch**.
2. `IsReturnTypeLookup` - the result is `ILookup<TKey,_>`: **Group**.
3. Otherwise the first parameter is taken as a single key: **Cache**.

The distinction that matters in practice is what a missing key yields. A batch
loader whose value type is an array (`Dictionary<Guid, Review[]>`) is still a
**batch** loader, so an unknown key resolves to `null`, not to an empty array.
Only `ILookup<TKey,TValue>` gives an empty array. `[docs]` states the same, and
the code above is why.

### Parameters other than the key

`DataLoaderInfo.CreateParameters` classifies every parameter after the first,
in this order: `CancellationToken`, `ISelectorBuilder`, `IPredicateBuilder`,
`PagingArguments`, `SortDefinition<T>`, `QueryContext<T>`, anything carrying
`[DataLoaderState]`, and finally - as the fallback - a service. `[source]`

The fallback matters: a mistyped well-known parameter does not fail, it becomes
a service resolution that fails at runtime instead.

### Registration

Two assembly attributes can emit the registration:

- `[assembly: DataLoaderModule("X")]` produces `AddX()` on `IServiceCollection`
  and is what `[docs]` shows.
- `[assembly: Module("X")]` - the type module Mosaic already declares - emits
  `builder.AddDataLoader<...>()` for every generated loader into the same
  `AddX()` it already generates for types.
  `[source]` (`Generators/TypeModuleSyntaxGenerator.cs` line 101 and 113 call
  `ModuleFileBuilder.WriteRegisterDataLoader`).

So Mosaic needs no new module attribute: `AddMosaic()` picks the DataLoaders up
because `[assembly: Module("Mosaic")]` is already there.
Confirmed by reading the generated `Mosaic.Module.g.cs`. `[measured]`

## C. Batching internals: who decides when a batch goes

This is the part the chapter walks, and it lives in two places.

### GreenDonut's half: accumulating keys

`DataLoaderBase<TKey,TValue>` keeps one `_currentBatch`. `LoadAsync(key)` takes
the lock, asks the promise cache for the key, and on a miss calls
`GetOrCreatePromiseUnsafe(..., scheduleOnNewBatch: true)`. `[source]`
(`src/GreenDonut/src/GreenDonut/DataLoaderBase.cs`)

`GetOrCreatePromiseUnsafe` adds the key to the current batch if it has room
(`current.Size < _maxBatchSize`, or no limit when `_maxBatchSize == 0`),
otherwise schedules the full one and rents a new batch from
`BatchPool<TKey>.Shared`. `MaxBatchSize` defaults to **1024**. `[source]`
(`DataLoaderOptions.cs`)

The list-taking overload `LoadAsync(keys)` is different in one respect worth
noting: it passes `scheduleOnNewBatch: false` and schedules once at the end,
under the comment `// we dispatch after everything is enqueued.` `[source]`

Deduplication is not in the batch, it is in the promise cache: `LoadAsync` calls
`Cache.GetOrAddTask(cacheKey, ...)` before ever touching a batch, so a repeated
key returns the existing promise and never reaches `Keys`. `[source]`

`Batch<TKey>` carries the state the dispatcher reads:
`Status` (`Enqueued = 1`, `Touched = 2`), `CreatedTimestamp`,
`ModifiedTimestamp`, and `Touch()`, which is
`Interlocked.Exchange(ref _status, Touched)` returning whether the previous
value was already `Touched`. Every `GetOrCreatePromise` resets the status to
`Enqueued` and restamps `ModifiedTimestamp`. `[source]` (`Batch.cs`)

So `Touch()` returning true means: nothing added a key to this batch since the
last time somebody looked.

### HotChocolate's half: deciding to dispatch

`IBatchDispatcher` extends `IBatchScheduler`, and the default implementation is
`BatchDispatcher`. It is registered **scoped**, so there is one per request:
`services.AddScoped<IBatchDispatcher>(...)`. `[source]`
(`src/HotChocolate/Core/src/Types/Execution/DependencyInjection/InternalServiceCollectionExtensions.cs`
lines 117-119)

`Schedule(batch)` does no work. It adds the batch to a `HashSet<Batch>`,
increments `_openBatches`, and raises `Enqueued`. `[source]`
(`BatchDispatcher.IBatchScheduler.cs`)

The work is in `CoordinatorAsync`, a single loop started on the first
`BeginDispatch` and shared by the whole request. Its evaluation round, in
`EvaluateAndDispatchAsync` and `EvaluateOpenBatches`: `[source]`
(`BatchDispatcher.cs`)

1. Reap completed dispatches; if any completed, reset the no-dispatch streak.
2. If `_openBatches == 0`, return and wait for a signal.
3. Load the enqueued batches into a `PriorityQueue<Batch,long>` keyed on
   `ModifiedTimestamp`, so the batch nobody has touched for longest is
   evaluated first. A single open batch skips the queue entirely
   (`EvaluateSingleOpenBatches`).
4. For each batch, dispatch it when
   `batch.Touch() && (now - ModifiedTimestamp) >= BatchSettleTimeUs`,
   **or** when `(now - CreatedTimestamp) > MaxBatchWaitTimeUs`.
5. If nothing was dispatched, `await Task.Yield()` and go round again. After
   the streak exceeds `max(2 * BatchSettleTimeUs, 2000 us)` the yield becomes
   `await Task.Delay(1)`.

Defaults, from `BatchDispatcherOptions`: `[source]`

| Option | Default | Meaning |
|---|---|---|
| `BatchSettleTimeUs` | 250 us | minimum quiet time before a batch may go |
| `MaxBatchWaitTimeUs` | 50 000 us (50 ms) | forced dispatch regardless of quiet time; 0 disables |
| `MinEscalationThresholdUs` | 2 000 us | private const; floor on the back-off threshold |

Two conditions, not one: a batch goes when it has been quiet for a quarter of a
millisecond **and** survived two evaluation rounds untouched, or when it is 50
ms old whatever else is happening.

The comment on the yield is theirs and is the clearest statement of the design:

```
// Yield between evaluation rounds so executing resolvers get time
// to add more data requirements to the open batches. Under load the
// yield queues behind real work, which widens the aggregation window.
```

### The other scheduler

`AutoBatchScheduler.Schedule` is `Task.Run(() => batch.DispatchAsync())` with
the exception swallowed, and its own summary says it "prioritizes low latency
over batching efficiency by executing each batch as soon as it is scheduled".
`[source]` (`AutoBatchScheduler.cs`)

It is what a DataLoader gets outside a HotChocolate request. Inside one, the
scoped `BatchDispatcher` is injected instead by `ExecutionDataLoaderScope`,
whose private `DataLoaderServiceProvider` intercepts requests for
`IBatchScheduler` and hands back the dispatcher. `[source]`
(`Fetching/ExecutionDataLoaderScope.cs`)

## D. Where docs and source disagree

`[docs]` (`batching/dataloader.md`, "How Execution Works") says:

> once no more resolver work is immediately ready, each pending batch is
> dispatched
>
> The dispatch trigger is "no more ready work", not a fixed schedule and not
> one dispatch per level of the query.

The second half is right and the first half is not the mechanism. Nothing in
`BatchDispatcher` observes resolver readiness. It observes *the batch*: two
untouched evaluation rounds plus a 250 us quiet window, with a 50 ms ceiling.
"No more ready work" is the usual *consequence* - resolvers stop adding keys,
so the batch settles - but the settle time and the ceiling are both real and
both observable. Decision 32 says the source wins; the chapter says so.

`[docs]` is right and useful on: the three method shapes, name derivation,
`MaxBatchSize = 1024`, split batches dispatching concurrently, per-request
cache lifetime, and the warning that the `IReadOnlyList<TKey>` handed to a
fetch method is rented and must not outlive the call.

## E. EF Core integration surface

`HotChocolate.Data.EntityFramework` 16.6.0 exposes exactly two extension
methods on `IRequestExecutorBuilder`: `[source]`
(`src/HotChocolate/Data/src/EntityFramework/Extensions/EntityFrameworkRequestExecutorBuilderExtensions.cs`
- the file is 54 lines including doc comments)

- `RegisterDbContextFactory<T>()`, which adds a
  `ContextFactoryParameterExpressionBuilder<T>` so the resolver compiler can
  inject a `T` built from the registered factory.
- `AddDbContextCursorPagingProvider(...)`, which registers
  `EfQueryableCursorPagingProvider`.

`RegisterDbContextFactory<T>` does not register the factory itself. `[docs]`
warns about this in bold and the source confirms it: the method only adds the
parameter expression builder. `AddDbContextFactory<T>` or
`AddPooledDbContextFactory<T>` is still required.

The scope rule from chapter 03 is what makes the factory necessary. `[docs]`:

> When using the default scope for queries, each resolver that accepts a scoped
> `DbContext` receives a **separate** instance.

and

> Changing the default scope for queries will likely result in the error "A
> second operation started on this context before a previous operation
> completed"

That is `DefaultQueryDependencyInjectionScope = Resolver` seen from the data
layer, which chapter 03 read out of `RequestExecutorOptions` and
`ResolverTask.Execute.cs`.

## F. The v16 data middleware

Registration methods on `IRequestExecutorBuilder`, all in
`HotChocolate.Data`: `AddFiltering`, `AddSorting`, `AddProjections`,
`AddQueryContext`, `AddPagingArguments`, `AddCursorKeySerializer`. `[source]`
(`Data/src/Data/Extensions/HotChocolateDataRequestBuilderExtensions.cs` and
`HotChocolatePaginationMappingsRequestExecutorBuilderExtensions.cs`)

`[docs]` (`projections.md`) is explicit that the v16 way is not the v13-era
`[UseProjection]` middleware:

> In Hot Chocolate v16, `QueryContext<T>` is the recommended way to apply
> projections. It combines projection, filtering, and sorting into a single
> parameter

`QueryContext<T>` carries three nullable pieces - `Selector`
(`Expression<Func<T,T>>?`, built from the selection set), `Predicate`
(`Expression<Func<T,bool>>?`, from `[UseFiltering]`), and `Sorting`
(`SortDefinition<T>?`, from `[UseSorting]`) - and `.With(query)` applies them
in the order filter, sort, project. `[docs]`, and `QueryContext.cs` in
`GreenDonut.Data.Primitives` confirms the shape. `[source]`

`AddFiltering()` and `AddSorting()` register `QueryContext<T>` support, so
`AddProjections()` is not needed for the `QueryContext` route. `[docs]`

Paging: `AddPagingArguments()`, a `PagingArguments` resolver parameter, and
`ToPageAsync(pagingArgs, ct)` from `GreenDonut.Data.EntityFramework` returning
`Page<T>`; a resolver returning `PageConnection<T>` gets a Relay connection in
the schema. `[docs]` (`pagination.md`)

`ToPageAsync` and `ToBatchPageAsync` both live in
`GreenDonut.Data.EntityFramework/Extensions/PagingQueryableExtensions.cs`.
`[source]`

## G. What Mosaic was changed into

Two tags, because the chapter needs a before and an after that a reader can
check out.

- `ch04-ef` - the same schema and the same seed data, moved off
  `List<T>` in memory onto PostgreSQL through EF Core. Still one lookup per
  key: the domain services keep their single-key methods and gain nothing.
- `ch04` - DataLoaders behind the same resolvers, plus the paged, filtered and
  sorted `browseProducts` field.

Decisions taken while building, with reasons:

1. **`products` is not paginated.** Chapters 02 and 03 measured
   `{ products { title reviews { rating author { displayName } } } }` and the
   whole book's before-and-after hangs on it. Putting `[UseFiltering]` and
   paging on `products` would change that query's shape and invalidate two
   chapters of numbers. The data middleware goes on a new field,
   `browseProducts`, and the chapter says why.
2. **The seed data is unchanged.** `InMemory*Data` classes stay and become the
   seeder, so 25 products, 120 reviews and every identifier are byte-identical
   to `ch02` and `ch03`. `scripts/verify.ps1` keeps asserting them.
3. **`MosaicDataOptions.LookupDelay` is removed.** It existed so that a lookup
   could be made to cost something while the data was in memory. A Postgres
   round trip costs something on its own, so the knob is now a way to lie about
   the measurement rather than a way to take one.
4. **The counter counts SQL commands, not service calls.** The service-lookup
   counter from `ch02` stays and still reports 146; a new counter, driven by an
   EF Core `DbCommandInterceptor`, reports how many commands actually reached
   Postgres. Those two numbers are equal at `ch04-ef` and are 146 and 3 at
   `ch04`, which is the whole chapter in one line of log.

## H. Measurements

All on the author's machine: Windows 11, .NET SDK 10.0.302, PostgreSQL
18-alpine in Docker Desktop on the same box, service built in Release. The
query throughout is the catalog-with-reviews query chapters 02 and 03 used:

```
{ products { title reviews { rating author { displayName } } } }
```

### H1. The headline counts

| Tag | Resolvers | Service lookups | SQL commands |
|---|---|---|---|
| `ch02` / `ch03` (in memory) | 146 | 146 | n/a |
| `ch04-ef` (PostgreSQL, no DataLoaders) | 146 | 146 | 146 |
| `ch04` (DataLoaders) | 146 | 3 | 3 |

The resolver count never moves. That is the sentence the chapter is built on:
the engine runs the same 146 resolvers either way, and what changed is what a
resolver does when it gets there. `[measured]`

### H2. Warm latency

Twenty warm-up runs, then ten measured, reading `total` off the request
timeline. Both caches hit on every measured run.

The two tags were measured **back to back in one sitting**, because they must
be. An earlier pass measured `ch04-ef` at 10.1-12.2 ms and a later one, on the
same code, at 19.0-20.1 ms; the machine was doing different things. Only a
paired measurement says anything about the change.

| Tag | Ten runs, sorted (ms) |
|---|---|
| `ch04-ef` | 9.22 9.67 9.86 10.45 11.45 12.06 12.91 13.71 14.16 44.63 |
| `ch04` | 3.90 3.92 4.03 4.04 4.54 5.29 5.48 5.63 5.78 7.37 |

Nine of ten in each column fall in 9.2-14.2 and 3.9-5.8 respectively; the 44.63
is a laptop being a laptop and is quoted rather than dropped. So roughly twelve
milliseconds against roughly five, for the same answer, on a database on the
same machine with 25 products and 120 reviews.

Two caveats the chapter must carry: the ratio is the transportable claim, not
the milliseconds; and this is the friendliest possible network, so the gap on a
real one is wider, not narrower. `[measured]`

Representative full timeline lines, both captured from the runs above:

```
parse - validate - compile - coerce - execute 12.674ms total 12.716ms
    (document cache hit, operation cache hit, 146 resolvers, 146 SQL)

parse - validate - compile - coerce - execute 4.365ms total 4.414ms
    (document cache hit, operation cache hit, 146 resolvers, 3 SQL)
```

A trap worth recording: `dotnet build` after `git checkout <tag>` did not always
replace `bin/Release/net10.0/Mosaic.Api.dll`, and a stale binary measured the
wrong tag while reporting the right one. The tell was a `ch04-ef` checkout
reporting 3 SQL. Delete `bin` and `obj` between tags.

### H3. The three statements

Captured with `Microsoft.EntityFrameworkCore.Database.Command` at
`Information`. `[measured]`

```sql
SELECT p.id, p.category, p.description, p.sku, p.title
FROM products AS p
ORDER BY p.id

SELECT r.id, r.body, r.created_at, r.customer_id, r.product_id, r.rating
FROM reviews AS r
WHERE r.product_id = ANY (@productIds)
ORDER BY r.created_at, r.id

SELECT c.id, c.display_name, c.email
FROM customers AS c
WHERE c.id = ANY (@ids)
```

`Contains` over a list becomes `= ANY (@keys)` on Npgsql, which is one
parameter rather than one per key. The plan is therefore reusable whatever the
page size, which is not true of the `IN (@p0, @p1, ...)` other providers emit.

The third statement carries twelve keys, not 120. Deduplication happens in the
promise cache inside `LoadAsync`, before a key ever reaches a batch. `[source]`

### H4. The batch that splits

The count is 3 nearly always and occasionally 4. Measured over 400 warm
requests in one process: **398 reported 3, two reported 4**. In both of the
two, the duplicated statement was the customers one, issued twice.
`[measured]`

That is section C's mechanism seen from outside. The 120 author resolvers
enqueue into one batch; the coordinator dispatches a batch it has seen
untouched across two evaluation rounds and for at least `BatchSettleTimeUs`
(250 us by default). When the stragglers are late, the batch goes with what it
has and the rest form a second one. The answers are identical.

This is why `scripts/verify.ps1` sends the query five times and asserts that
at least one run hit 3 and that no run exceeded 4, rather than asserting an
exact number against a single sample. Asserting exactly 3 once would fail
roughly one run in two hundred.

### H5. `browseProducts`

A three-field page, title only:

```sql
SELECT p.title
FROM products AS p
ORDER BY p.title, p.id
LIMIT @p
```

Filtered and sorted (`where: { category: { eq: LIGHTING } }`,
`order: [{ title: DESC }]`), selecting `nodes { title }`:

```sql
SELECT p.title
FROM products AS p
WHERE p.category = @p
ORDER BY p.title DESC, p.id
LIMIT @p1
```

One column, because the selection set asked for one field. Filter, sort,
tiebreaker and limit in one statement, one round trip. `[measured]`

The same filter and order, selecting `nodes { title category averageRating }`,
which is the Postman collection's "Filtered and sorted" request. Two statements:

```sql
SELECT p.id, p.title, p.category
FROM products AS p
WHERE p.category = @p
ORDER BY p.title DESC, p.id
LIMIT @p1

SELECT r.product_id AS "ProductId", avg(r.rating::double precision) AS "Average"
FROM reviews AS r
WHERE r.product_id = ANY (@productIds)
GROUP BY r.product_id
```

`p.id` is in the first statement only because `averageRating`'s resolver
declares `[Parent("Id")]`; see H6.2. The aliases in the second come from the
anonymous projection in `ReviewsService.GetAverageRatingsByProductIdsAsync`.
`[measured]`

With `totalCount` selected, still **one** statement, not two:

```sql
SELECT (
    SELECT count(*)::int
    FROM products AS p0), p.title
FROM products AS p
ORDER BY p.title, p.id
LIMIT @p
```

A correlated subquery, evaluated once. Worth stating plainly because the
received wisdom is that a total count costs a second query. `[measured]`

### H6. Two things that fail silently, and did

Both were found by running the service, not by reading anything.

1. **`totalCount` without `IncludeTotalCount`.** The connection type carries a
   non-nullable `totalCount` field whether or not the resolver can answer it.
   Without `[UseConnection(IncludeTotalCount = true)]` every query selecting it
   returns `Cannot return null for non-nullable field`, code `HC0018`, and
   `"data": null`. The schema advertises a field that always fails.
   `[measured]`

2. **Projection dropping a resolver-backed key.** `Product.id` is produced by a
   resolver, because `[ID]` has to encode the raw Guid. A projection builds its
   `SELECT` list from properties in the selection set, so it never selects
   `products.id` on account of the `id` field. Asking `browseProducts` for
   `{ id title }` returned an all-zero Guid for every product, and the
   `endCursor` built from the sort tiebreaker carried
   `00000000-0000-0000-0000-000000000000` with it. No error anywhere.
   `[measured]`

   The fix is `[Parent("Id")]`: `ParentAttribute` takes an optional `requires`
   string naming what the resolver needs from the parent. `[source]`
   (`src/HotChocolate/Core/src/Abstractions/ParentAttribute.cs`)

   Curiously, *not* selecting `id` was fine before the fix, because the paging
   machinery adds the sort keys to the selector itself. The failure only
   appears when a client asks for the field, which is the worst possible
   distribution of a bug.

### H7. What EF Core would not accept

Measured against EF Core 10.0.10 by compiling and running, not read anywhere:

- A **navigation** cannot bind to a constructor parameter. This is the
  documented rule and the error states it: *"only mapped properties can be
  bound to constructor parameters. Navigations to related entities, including
  references to owned types, cannot be bound."*
- A **complex property** cannot either, and the error does not say so. Moving
  `Money` from `OwnsOne` to `ComplexProperty` produced the identical message
  for `ProductPrice(Guid ProductId, Money Amount)`.
- Before the snake_case pass was extended to `GetComplexProperties`, `Money`'s
  columns arrived quoted and in mixed case in the middle of an otherwise
  lower-case statement, which is how the omission was found: `[measured]`

  ```sql
  SELECT p.product_id, p."Amount_Amount", p."Amount_Currency"
  FROM prices AS p
  WHERE p.product_id = ANY (@productIds)
  ```

- A collection navigation must be a type EF Core can add to, so
  `IReadOnlyList<OrderLine>` is refused where `List<OrderLine>` is accepted.
  A positional record's backing field has the declared type, so the read-only
  interface leaves nothing to fill.

Consequence for Mosaic: `Order.Lines`, `OrderLine.UnitPrice` and
`ProductPrice.Amount` all became `init` properties outside their primary
constructors. Nothing else in the model changed, and the GraphQL schema did
not change at all.

### H8. The schema did not move

`schema/mosaic.graphql` at tag `ch04-ef` is byte-identical to tag `ch03`. The
entire data layer was replaced and the contract did not shift by one
character. Verified by exporting and diffing. `[measured]`

At tag `ch04` the only difference is the new `browseProducts` field and the
types it drags in: `ProductConnection`, `ProductEdge`, `PageInfo`,
`PageCursor`, `ProductFilterInput`, `ProductSortInput` and the operation input
types. 84 lines to 225.

## I. Reproduction recipes

Every number above comes back from these. PostgreSQL must be up:
`docker compose up -d mosaic-db`.

1. **The counts.** Run the service, send the query, read the log. Both numbers
   are printed by the service itself:

   ```
   Service lookups this request: 3
   parse - validate - compile - coerce - execute 4.9ms total 5.0ms
       (document cache hit, operation cache hit, 146 resolvers, 3 SQL)
   ```

2. **Warm latency.** Send the query twenty times to settle the runtime and both
   caches, then read `total` off the next ten timeline lines. A first request
   to a fresh process reports around 205 ms and is almost entirely the runtime
   jitting itself; chapter 03's section on the caches explains why that number
   is worthless.

3. **The statements.** Set
   `Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command` to
   `Information` in the environment and read the log. On PowerShell the key
   contains dots, so it needs
   `${env:Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command}`.

4. **The split batch.** Send the query 400 times warm and count the reported
   SQL numbers:
   `grep -oE "[0-9]+ SQL\)" log | sort -n | uniq -c`.

5. **The before.** `git checkout ch04-ef` in the companion repo and repeat 1
   and 2. The tag exists so this is one command rather than an exercise in
   deleting code.

6. **The interceptor under concurrency.** Fire ten copies of the query at the
   service at once (`for i in $(seq 1 10); do curl ... & done; wait`) and check
   that ten timeline lines each report their own counts rather than one line
   reporting ten times the work. This is what establishes that the
   `IHttpContextAccessor` in `SqlCommandCounter` still resolves the right
   request from inside a batch dispatch.

7. **The two silent failures.** Delete `[UseConnection(IncludeTotalCount =
   true)]` from `GetBrowseProductsAsync` and select `totalCount`; delete the
   `"Id"` from `[Parent("Id")]` on `ProductNode.GetId` and select
   `browseProducts { nodes { id } }`. Both are exercises in the chapter's lab.

## J. Left unmeasured, and who owns it

- **Batching under real concurrency.** Everything here is one client on one
  machine. `BatchDispatcher`'s own comment says the aggregation window widens
  under load, because the coordinator's `Task.Yield` queues behind real work.
  That is plausible and untested here. Chapter 24 owns load testing.
- **`MaxBatchSize` splitting.** The default is 1024 and Mosaic's largest batch
  is 25 keys, so the split path in `GetOrCreatePromiseUnsafe` never ran. The
  claim that split batches dispatch concurrently is `[docs]`, unverified.
- **`DataLoaderServiceScope`.** Mosaic leaves it at `Default`, which creates a
  dedicated scope per fetch. `OriginalScope` was not tried, and the failure
  mode it is supposed to prevent - a `DbContext` outliving a resolver - was not
  provoked.
- **Cross-request caching.** There is none, by design, and this was not tested;
  `[docs]` states it and `DataLoaderBase`'s per-request instance makes it
  structurally true.
- **Index usage.** The indexes in the configurations are justified by query
  shape, not by a plan. 25 products and 120 reviews is far below the point at
  which PostgreSQL prefers an index to a sequential scan, so `EXPLAIN` here
  would prove nothing. Chapter 24 is where a dataset large enough to measure
  belongs.
- **Migrations.** Mosaic uses `EnsureCreatedAsync`, so nothing in this book has
  exercised `dotnet ef migrations`. Chapter 22 owns the deployment story and
  should say plainly that a real service migrates.
