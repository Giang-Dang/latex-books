# The life of a request in HotChocolate 16.6.0 - facts verified 2026-08-08

Source research for chapter 03. Same tagging convention as the chapter 02 file:

- **[source]** - read out of the `ChilliCream/graphql-platform` working tree at
  tag **`16.6.0`**, commit **`8fea46e9560c973eba1b9c899937f9a6bb02aaf9`**. The
  tree is cloned at `F:\repo\graphql-platform`; every path below is relative to
  it. This replaces the chapter 02 file's `[web]` tag for internals: reading the
  tree at a tag beats fetching a docs page, and the SPEC's rule on pinning
  internals claims is satisfied by naming the commit.
- **[measured]** - observed on this machine on 2026-08-08 by running the
  companion service at tag `ch03` and reading what it printed.

Division of labour with the other research files:

- `2026-08-federation-landscape.md` owns the shallow current-state one-liners.
- `2026-08-ch01-scaling-and-federation-history.md` owns history and case studies.
- `2026-08-ch02-hotchocolate-16.md` owns HotChocolate as an API you type:
  packages, authoring styles, day-one defaults, and the chapter 02 numbers.
- **This file owns the execution pipeline**: what middleware exists, in what
  order, which caches sit where, what the diagnostic events see, and where the
  service scopes come from. Chapter 16 goes deeper into the same machinery and
  should start here rather than from memory.

## A. The default pipeline is twelve middleware, and it is a list

**[source]** `AddDefaultPipeline` in
`src/HotChocolate/Core/src/Types/Execution/DependencyInjection/RequestExecutorBuilderExtensions.UseRequest.cs`
(line 676) adds exactly twelve, in this order:

```
1  InstrumentationMiddleware
2  ExceptionMiddleware               (added as CommonMiddleware.UnhandledExceptions)
3  TimeoutMiddleware
4  DocumentCacheMiddleware
5  DocumentParserMiddleware
6  DocumentValidationMiddleware
7  OperationCacheMiddleware
8  OperationResolverMiddleware
9  SkipWarmupExecutionMiddleware
10 OperationVariableCoercionMiddleware
11 ConcurrencyGateMiddleware
12 OperationExecutionMiddleware
```

Each entry is a `RequestMiddlewareConfiguration(RequestMiddleware Middleware,
string? Key)`. The keys are public constants on
`WellKnownRequestMiddleware` (`src/HotChocolate/Core/src/Execution.Abstractions/`),
which is what makes `UseRequest(..., before:, after:)` usable from application
code.

**[source]** `RequestExecutorManager.CreatePipeline` (line 519) assembles it:

1. if the pipeline list is empty, run the default pipeline factory;
2. run every registered modifier, **in registration order**;
3. compose the delegate chain backwards, from the last entry to the first.

Step 3 happens **once per executor**, not per request. That is why
`ConcurrencyGateMiddleware` can check at factory time whether a gate is
configured and, if not, return `next` unwrapped so there is no per-request cost.
The comment in that file says so in as many words.

## B. What the service actually runs is thirteen

**[source + measured]** `AddGraphQLServer()`
(`src/HotChocolate/AspNetCore/src/AspNetCore/Extensions/HotChocolateAspNetCoreServiceCollectionExtensions.cs`,
line 42) calls `AddCostAnalyzer()` unless `disableDefaultSecurity: true`.
`AddCostAnalyzer` ends with

```
.UseRequest(CostAnalyzerMiddleware.Create(), after: WellKnownRequestMiddleware.DocumentValidationMiddleware)
```

so **`CostAnalyzerMiddleware` is inserted at position 7**, after validation and
before the operation cache. Mosaic's measured pipeline, logged at startup:

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

`scripts/verify.ps1` asserts this list and its order at tag `ch03`.

- **IMPORTANT TRAP [measured], and it cost us a wrong number first time round.**
  `before:`/`after:` insertions are **pipeline modifiers**, and modifiers run in
  registration order. The first version of `AddPipelineReport()` was registered
  **before** `builder.AddGraphQL()`, so its modifier ran first and logged
  **twelve** middleware - the list as it stood before the cost analyzer inserted
  itself. The reporter has to be registered **after** `AddGraphQL()` to see the
  finished list. Program.cs says so in a comment. Do not print a twelve-item
  pipeline for a default ASP.NET Core server.

## C. Parsing does not happen in the parser middleware (over HTTP)

This is the most surprising finding in the file and it is fully measured.

**[source]** `DefaultHttpRequestParser`
(`src/HotChocolate/AspNetCore/src/AspNetCore.Pipeline/Parsers/`) builds a
`Utf8GraphQLRequestParser` with the document cache and hash provider and parses
the request body at the transport layer. Inside
`src/HotChocolate/Language/src/Language.Web/Utf8GraphQLRequestParser.cs`
(lines 404-426) it computes the document hash, checks the document cache, and
only calls `Utf8GraphQLParser.Parse` on a miss.

**[source]** `DocumentParserMiddleware.InvokeAsync` opens its
`_diagnosticEvents.ParseDocument(context)` scope **only** in the
`query is OperationDocumentSourceText` branch. Over HTTP the document arrives
already parsed, so the middleware takes the `OperationDocument parsed` branch
and the scope never opens.

**[measured]** Consequence: the `ParseDocument` diagnostic event **never fires
for GraphQL over HTTP**. Every timeline line the companion service has ever
printed shows `parse -`, including on a cold cache. The parse phase you can
instrument from inside the execution pipeline is not where HTTP parsing happens.

- **[measured] A syntax error never reaches the execution pipeline at all.**
  Three distinct unparseable documents were posted to a warmed-up service after
  one good request. The service logged **one** timeline line, from the good
  request. All three syntax errors returned HTTP 400 with
  `extensions.code = HC0011` and the message
  `Expected a `RightBrace`-token, but found a `EndOfFile`-token.` and produced
  no diagnostic events, because they were rejected by the transport's parser
  before an executor was involved. Reproduce with `scratchpad/syntax.ps1`-style
  steps: post `{ products { title `, count the timeline lines.
  This also refines chapter 02's account: chapter 02 correctly reported HC0011
  for a syntax error and no code for an unknown field, but attributed both to
  validation running "before a single resolver is called". The unknown-field
  error is validation, in the pipeline; the syntax error is the transport.

## D. The document cache short-circuits validation, not just parsing

**[source]** `DocumentCacheMiddleware` sits at position 4, **before** the
parser. On a hit it sets `documentInfo.IsValidated = true` along with the
document. `DocumentValidationMiddleware` then reads

```
if (!documentInfo.IsValidated || _documentValidator.HasNonCacheableRules)
```

so a cached document skips validation entirely **unless the validator has rules
that cannot be cached**. Worth naming precisely: the cache is not a "parse
cache", it is a "we have already accepted this document" cache.

**[source]** The write happens on the way **out**, after `await _next(context)`,
and only if `IsValidated` is true. A document that fails validation is never
cached. If the id and the hash differ, the document is added under both keys.

**[measured]** Timeline for the same document sent twice to a warmed-up service:

```
parse - validate 0.204ms compile 0.097ms coerce - execute 0.492ms total 0.931ms (document cache miss, operation cache miss, 146 resolvers)
parse - validate -        compile -        coerce - execute 1.049ms total 1.065ms (document cache hit,  operation cache hit,  146 resolvers)
```

**[measured] Captured log lines quoted verbatim by the chapter**, recorded here
so the prose can be checked against them rather than against rounded values:

```
parse - validate 16.690ms compile 11.515ms coerce - execute 41.541ms total 88.061ms (document cache miss, operation cache miss, 146 resolvers)
parse - validate 2.246ms compile 1.033ms coerce 2.480ms execute 8.890ms total 16.770ms (document cache miss, operation cache miss, 17 resolvers)
parse - validate - compile - coerce 0.038ms execute 0.617ms total 0.710ms (document cache hit, operation cache hit, 13 resolvers)
parse - validate - compile - coerce 0.064ms execute 1.298ms total 1.562ms (document cache hit, operation cache hit, 15 resolvers)
```

The first is a cold process, and section K explains why it is not a measurement
of validation. The other three are the one-document, three-variable-sets run of
section F.

## E. The operation cache, and single-flight compilation

**[source]** `OperationCacheMiddleware`
(`src/HotChocolate/Core/src/Types/Execution/Pipeline/OperationCacheMiddleware.cs`)
holds a `ConcurrentDictionary<string, Lazy<TaskCompletionSource<Operation>>>` of
in-flight compilations. If two requests for the same uncached operation arrive
together, one becomes the "single-flight leader" and compiles; the others await
its result rather than compiling the same document again. The leader caches the
operation **before** removing the in-flight entry, so there is no window where
the operation is in neither structure. The comments in that file are unusually
good and are worth quoting rather than paraphrasing.

**[source]** `OperationResolverMiddleware` is where compilation happens, inside
`_diagnosticEvents.CompileOperation(context)`, by calling
`OperationCompiler.Compile(...)`. Note the naming: the middleware is called
`OperationResolver`, the field holding the compiler is called
`_operationPlanner`, and the class is `OperationCompiler`. Three names for one
step; the chapter should pick one and say why the others exist.

**[measured]** Compilation of the catalog-with-reviews document costs
**0.076-0.110 ms** on a warmed-up process (five novel documents, five samples).
Validation of the same document costs **0.184-0.355 ms**. So validation is the
more expensive of the two by roughly a factor of three, which is the opposite of
what "compile" sounds like it should mean.

## F. Variables are coerced per request, the operation is not

**[measured]** Sending one document with three different variable sets: the
first is a cache miss on both caches, the next two hit both. The compiled
operation does not depend on the variable values. Coercion time on a warm path
is **0.034-0.064 ms**; the first request through the coercion path paid
**2.480 ms**, which is JIT, not work.

**[measured]** The `CoerceVariables` diagnostic does not fire for a document
with no variables: those timeline lines show `coerce -`.

## G. Resolver DI scopes, and what chapter 02 owed chapter 03

This is the payoff on chapter 02's lookup-counter bug and it is now measured
rather than described.

**[source]** `ResolverTask.ExecuteResolverPipelineAsync`
(`src/HotChocolate/Core/src/Types/Execution/Processing/Tasks/ResolverTask.Execute.cs`,
line 130):

```csharp
if (_context.Field.DependencyInjectionScope == DependencyInjectionScope.Resolver)
{
    var serviceScope = _operationContext.Services.CreateAsyncScope();
    _context.Services = serviceScope.ServiceProvider;
    _context.RegisterForCleanup(serviceScope.DisposeAsync);
    ...
}
```

So the extra scope is **per field, and conditional**, not unconditional.

**[source]** `SchemaOptions` (`src/HotChocolate/Core/src/Types/SchemaOptions.cs`,
lines 127-133) sets the defaults, and they are **asymmetric**:

```csharp
DefaultQueryDependencyInjectionScope    = DependencyInjectionScope.Resolver;
DefaultMutationDependencyInjectionScope = DependencyInjectionScope.Request;
```

`ObjectField.CompleteResolver` picks between them on `isMutation` unless the
field states its own. So **queries get a scope per resolver; mutations share the
request scope** - which is what you want when a mutation's resolvers have to
share a transaction.

**[source]** Per-field overrides exist in both styles: `UseRequestScope()` /
`UseResolverScope()` on `IObjectFieldDescriptor`, and the attributes
`[UseRequestScope]` / `[UseResolverScope]`, both `AttributeTargets.Method`.
Mosaic is implementation-first, so the attributes are the relevant form.

**[source]** `MiddlewareContext.RequestServices => _operationContext.Services`,
and `OperationContext` is initialised from `RequestContext.RequestServices`.
Line 133 above replaces `_context.Services`, never `RequestServices`. So
`IResolverContext.RequestServices` is the request's provider and an injected
parameter is the resolver's.

**[measured]** `samples/resolver-scopes` at tag `ch03`. One request asking for
two default-scope fields and two `[UseRequestScope]` fields:

```json
{"data":{
  "a":{"injected":1,"fromRequestServices":2},
  "b":{"injected":3,"fromRequestServices":2},
  "c":{"injected":2,"fromRequestServices":2},
  "d":{"injected":2,"fromRequestServices":2}}}
```

A second, identical request returns 4/5, 6/5, 5/5, 5/5. Read it as: the two
unannotated fields each got their own probe (1 and 3), neither of which is the
request's probe (2); both annotated fields got the request's probe. The ordering
1, 2, 3 also shows the first resolver's scope is created before anything asks
for the request-scoped instance.

## H. Diagnostic events: the API, and the registration trap

**[source]** Two interfaces. `ICoreExecutionDiagnosticEvents`
(`Execution.Abstractions`) carries the transport-agnostic events:
`ExecuteRequest`, `ParseDocument`, `ValidateDocument`, `CoerceVariables`,
`ExecuteOperation`, `AddedDocumentToCache`, `RetrievedDocumentFromCache`,
`RequestError`, `ValidationErrors`, and the executor lifecycle.
`IExecutionDiagnosticEvents` (`Types`) adds `CompileOperation`,
`ResolveFieldValue`, `RunTask`, `AnalyzeOperationCost`, `OperationCost`,
`AddedOperationToCache`, `RetrievedOperationFromCache`, and the subscription
events.

Phase events return `IDisposable`; the engine opens the scope before the phase
and disposes it after, so timing a phase means timing the scope. Fact events
return `void`.

**[source]** `ExecutionDiagnosticEventListener` is the base class with virtual
no-ops, and `EnableResolveFieldValue` defaults to **false**.
`AggregateExecutionDiagnosticEvents` filters listeners on that property once, in
its constructor, so a listener that does not opt in is never consulted for
per-field events.

- **IMPORTANT TRAP [source + measured].** `AddDiagnosticEventListener<T>`
  registers the listener in the **schema** service provider
  (`ConfigureSchemaServices`), which does not inherit the application's
  registrations. Injecting `ILoggerFactory` into a listener therefore fails
  unless `AddApplicationService<ILoggerFactory>()` is also called. Verified by
  deleting the line: startup fails, not the first request, with

  ```
  System.InvalidOperationException: Unable to resolve service for type
  'Microsoft.Extensions.Logging.ILoggerFactory' while attempting to activate
  'Mosaic.Api.Infrastructure.Diagnostics.RequestTimelineListener'.
  ```

  This is chapter 02's eager-initialisation point collecting: the failure is a
  container that never becomes healthy rather than a listener that silently
  never fires. Chapter 02's research file section I flagged the cross-
  registration requirement in the abstract; this is the concrete failure.

- **[source]** The same requirement covers more than listeners. Error filters
  (`RequestExecutorBuilderExtensions.ErrorFilter.cs`) and HTTP request
  interceptors (`HotChocolateAspNetCoreServiceCollectionExtensions.Http.cs`)
  both register through `ConfigureSchemaServices`, so anything they inject from
  the application container needs `AddApplicationService<T>()` too. Recorded
  here so chapter 16 inherits it rather than rediscovering it.

## I. Resolvers counted, and what is not a resolver

**[measured]** With `EnableResolveFieldValue => true`, the catalog-with-reviews
query reports **146 resolvers** - exactly the 146 domain-service lookups chapter
02 counted. The identity is not a coincidence and it is not trivial:

- `products` (1), `reviews` per product (25), `author` per review (120) are
  resolver methods, each doing one lookup. 1 + 25 + 120 = 146.
- `title`, `rating` and `displayName` are plain record properties. They are read
  directly and **never appear in the resolver count**. `{ products { title } }`
  reports **1 resolver**, not 26.

**[measured]** Resolver counts vary with data, which is worth saying before a
reader reruns it: the product-page query reported 17, 13 and 15 resolvers for
products 1, 2 and 3, because those products have 12, 8 and 10 reviews.

## J. Leaving the pipeline early, visibly

**[source]** `HttpContextExtensions.TryGetCostSwitch` reads the
**`GraphQL-Cost`** header (`HttpHeaderKeys.Cost`). The value `report` adds the
cost report to the response extensions; `validate` stops after costing.

**[measured]** The catalog-with-reviews query with `GraphQL-Cost: validate`:

```json
{"extensions":{"operationCost":{"fieldCost":30,"typeCost":4}}}
```

HTTP 200, **no `data` key at all**, and the timeline for that request shows
`execute -` and `0 resolvers` with a document cache hit. With
`GraphQL-Cost: report` the same numbers appear alongside a full `data`.

`fieldCost` 30 ties straight back to chapter 02's cost-directive finding: the
three async resolver fields in that query each carry `@cost(weight: "10")`, and
the plain properties carry none. `MaxFieldCost` and `MaxTypeCost` both default
to 1000 (`CostAnalysis/src/CostAnalysis/Options/CostOptions.cs`), so nothing is
rejected here; the numbers are reported, not enforced.

## K. Numbers this chapter may quote, and how to reproduce them

All **[measured]** on the author's Windows 11 box, 2026-08-08, service built in
Release at tag `ch03`, started with `ASPNETCORE_ENVIRONMENT=Development` and
`ASPNETCORE_URLS=http://localhost:5100`.

| Number | Value | How |
|---|---|---|
| Middleware in Mosaic's pipeline | 13 | startup log; asserted by `verify.ps1` |
| Middleware in the framework default | 12 | source, section A |
| Resolvers for catalog-with-reviews | 146 | timeline log; asserted by `verify.ps1` |
| Resolvers for `{ products { title } }` | 1 | timeline log |
| Validate, warmed process, novel document | 0.184-0.355 ms | five novel documents, aliased so each is unique |
| Compile, warmed process, novel document | 0.076-0.110 ms | same five |
| Coerce, warm | 0.034-0.064 ms | product-page query, three variable sets |
| Total in-pipeline, both caches hit | 0.638-3.805 ms | ten runs after twenty warm-up runs |
| `fieldCost` / `typeCost` | 30 / 4 | `GraphQL-Cost: validate` |

**Reproduction recipe**, because the shape matters more than the values: warm
the process with twenty runs of the query first, then time. A cold first request
reported `validate 16.7ms compile 11.5ms execute 41.5ms total 88.0ms`, and
almost all of that is JIT rather than parsing or validation. Quoting the cold
numbers as the cost of validation would be wrong, and it is the mistake this
file exists to prevent.

- **CAUTION for the prose.** The honest summary is *not* "the caches turn 88 ms
  into 2 ms". On a warmed-up process the caches save roughly 0.26-0.47 ms out of
  a 0.752-1.326 ms in-pipeline total for this query - about a third, and worth
  having, but not dramatic. The dramatic first-request number is the runtime
  warming up. Say which is which.
  The five novel-document totals were 1.326, 0.752, 0.838, 0.931 and 0.937 ms,
  which is where the chapter's "between 0.75 and 1.33 ms" comes from. The warm
  fully-cached totals ranged 0.638-3.805 ms across twelve samples, clustering
  near 1.1 ms, so the chapter says "one or two" rather than "roughly one".

## L. Corrections owed to other files

- `2026-08-ch02-hotchocolate-16.md`, section K, error shapes: correct on both
  payloads, but chapter 02's prose says validation runs "before a single
  resolver is called" for both. True for the unknown field; the syntax error is
  rejected by the transport parser and never enters the pipeline. Chapter 03
  states the distinction; chapter 02's sentence is not wrong enough to reprint,
  but do not repeat it as-is.
- No corrections owed to `SPEC.md`'s chapter 03 TOC line, which reads "parsing,
  validation, operation compilation, resolvers, middleware; first source-guided
  walk". All five are covered. Parsing turns out to be covered by explaining
  where it is *not*, which is a better section than the one that was planned.

## M. Listing provenance

Paths relative to `F:\repo\mosaic-graph` at tag **`ch03`** (commit `63493f0`).

| # | Path | Lines | What it shows | Page fit |
|---|------|-------|---------------|----------|
| 1 | *(source tree)* `RequestExecutorBuilderExtensions.UseRequest.cs` 676-690 | 15 | `AddDefaultPipeline`, the twelve, in order | whole |
| 2 | *(startup log)* | 14 | Mosaic's thirteen | whole |
| 3 | `src/Mosaic.Api/Infrastructure/Diagnostics/PipelineReportExtensions.cs` | 54 | reading the pipeline back through named options | **excerpt** - the `AddPipelineReport` body |
| 4 | `src/Mosaic.Api/Infrastructure/Diagnostics/RequestTimelineListener.cs` | 120 | the listener, `EnableResolveFieldValue`, scope timing | **excerpt** - class declaration plus three overrides |
| 5 | `src/Mosaic.Api/Infrastructure/Diagnostics/RequestTimeline.cs` | 45 | the scoped per-request record | **excerpt** |
| 6 | `src/Mosaic.Api/Program.cs` 31-42 | 12 | `AddApplicationService` + `AddDiagnosticEventListener`, and the ordering comment | whole |
| 7 | *(timeline log)* | 2 | cold and warm, side by side | whole |
| 8 | *(source tree)* `DocumentValidationMiddleware.cs` 37-47 | 11 | `!IsValidated \|\| HasNonCacheableRules` | whole |
| 9 | *(source tree)* `ResolverTask.Execute.cs` 128-137 | 10 | the conditional resolver scope | whole |
| 10 | *(source tree)* `SchemaOptions.cs` 127-133 | 7 | the query/mutation asymmetry | whole |
| 11 | `samples/resolver-scopes/ScopeTypes.cs` | 49 | the two fields | **excerpt** - the two resolver methods |
| 12 | *(response)* scope sample JSON | 5 | 1/2, 3/2, 2/2, 2/2 | whole |
| 13 | *(response)* `GraphQL-Cost: validate` | 1 | extensions only, no data | whole |
| 14 | *(response)* syntax error | 1 | HC0011 | whole |
| 15 | `scripts/verify.ps1` | 748 | do not print; quote `$ExpectedPipeline` and `$ExpectedResolverCount` | reference only |
| 16 | *(source tree)* `OperationCacheMiddleware.cs` 46-89 | 44 | single-flight compilation | **excerpt** - the leader/follower branch |

## N. Candidate bib keys

Nothing new is strictly needed: the chapter's load-bearing claims are source and
measurement, not documentation. Reusable from chapter 02's block:
`chillicream2026source` (the repository at a tag - **the entry's tag needs to
read 16.6.0 and the commit named in the note**), `chillicream2026migrate16`,
`dang2026mosaic` (companion repo - the chapter cites tag `ch03`).

| Source | Key | URL |
|--------|-----|-----|
| Hot Chocolate v16 instrumentation docs | `chillicream2026instrumentation` | <https://chillicream.com/docs/hotchocolate/v16/server/instrumentation> |

Fetch and check that page before citing it. It was **not** consulted for any
fact in this file, and the chapter 02 experience with the introspection page
says a v16 docs page can disagree with 16.6.0.

## O. UNVERIFIED - do not state these

- **Whether `DocumentValidator.HasNonCacheableRules` is true for a default
  ASP.NET Core server.** The branch was read; which shipped rules are
  non-cacheable was not established. The measured behaviour (validation skipped
  on a document-cache hit) implies it is false for Mosaic's configuration, but
  do not generalise to servers with custom validation rules.
- **`RunTask` / execution-task counts.** `EnableResolveFieldValue` also gates
  `RunTask`, which was never overridden or measured. Say nothing about task
  counts, DataLoader batching or the scheduler; that is chapter 04 and 16
  material.
- **Subscriptions.** No subscription passed through any of this. The
  subscription-specific events exist in the interface and were not exercised.
- **The `@defer`/`@stream` path.** `OperationExecutionMiddleware` has commented-
  out `// TODO: DEFER` blocks at tag 16.6.0. Interesting, and chapter 18's
  problem, not this chapter's. Do not describe incremental delivery from it.
- **Whether the timings hold on any other machine.** They are single-box, single
  run-set numbers from a laptop. The ratios (validate costs more than compile;
  caches save about a third of a warm request) are the claim; the absolute
  milliseconds are illustration.
