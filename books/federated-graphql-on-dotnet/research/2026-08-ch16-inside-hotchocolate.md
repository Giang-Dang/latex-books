# Inside HotChocolate: the executor - facts verified 2026-08-12

Everything tagged `[source]` was read out of `ChilliCream/graphql-platform` at
tag `16.6.0`, commit `8fea46e9560c973eba1b9c899937f9a6bb02aaf9`, cloned at
`F:/repo/graphql-platform` (decision 32). Paths below are relative to that root.
`[measured]` means it was run on this machine and the recipe is in section N.

Chapter 3 walked the thirteen request middleware and stopped at
`OperationExecutionMiddleware`. Chapter 4 measured DataLoader batching from the
outside. This chapter goes inside both, and pays four debts chapter 3 and
chapter 15 recorded rather than guessed at.

## A. What `OperationCompiler.Compile` produces

**[source]** `Execution/Processing/OperationCompiler.cs:82-156`. Compilation is
two phases. First the document is rewritten:

```csharp
// Before we can plan an operation, we must de-fragmentize it and remove static include conditions.
var result = _documentRewriter.RewriteDocument(document, operationName);
```

Then exactly one selection set is built - the root one - and handed to a new
`Operation`:

```csharp
var selectionSet = BuildSelectionSet(SelectionPath.Root, fields, rootType, ...);
compilationContext.Register(selectionSet, selectionSet.Id);
var operation = new Operation(id, hash, document, operationDefinition, rootType,
    _schema, selectionSet, compiler: this, includeConditions, deferConditions, ...);
```

`BuildSelectionSet` (lines 289-509) constructs a `Selection` per field, with its
resolver pipeline, arguments and include/defer information, and **never recurses
into that field's own child selection set**. Everything below the root is
compiled later; section B is where.

**[source]** The rewriter is constructed with `removeStaticallyExcludedSelections:
true` (`OperationCompiler.cs:34-37`). `RewriteDocument` returns a document with
no fragment definitions and no `FragmentSpreadNode` at all: spreads are inlined,
inline fragments whose type condition equals the current type context are merged
away, and only inline fragments with a genuinely different type condition
survive as syntax
(`Fusion/src/Fusion.Utilities/Rewriters/InlineFragmentOperationRewriter.cs`,
`CollectInlineFragment` 238-255, `CollectFragmentSpread` 303-339).

### A.1 The rewriter belongs to Fusion, and the plain engine imports it

**[source]** `OperationCompiler.cs:5` is `using HotChocolate.Fusion.Rewriters;`,
and `Core/src/Types/HotChocolate.Types.csproj:69` is:

```xml
<ProjectReference Include="..\..\..\Fusion\src\Fusion.Utilities\HotChocolate.Fusion.Utilities.csproj" />
```

The coupling is wider than that one line. The same project file also references
`Fusion.Language` (line 76) and **link-compiles four Fusion source files
directly into `HotChocolate.Types`** (lines 89-101): `JsonHelpers.cs`,
`JsonReaderHelper.cs`, `MetaDbEventSource.cs` and `ThrowHelper.cs`, all from
`Fusion/src/Fusion.Execution/Text/Json/`.

So the step that removes fragments from every single-service HotChocolate
request is owned by the project named after the federation gateway. Worth one
paragraph and no more: it is a fact about how the repository is laid out, not
about how a graph behaves.

### A.2 `OperationCompilerMetrics` is dead, and so is the test that used it

**[source]** `Execution/Processing/OperationCompilerMetrics.cs` is ten lines and
declares three fields: `Selections`, `SelectionSetVariants`, `BacklogMaxSize`.
A repo-wide grep for the type name over every `.cs` outside `obj/` and `bin/`
returns **exactly one line**, the declaration itself. Nothing constructs it and
nothing reads it. (An earlier draft of this note said three lines, which was a
grep for three different strings at once and not for the type name.)

**[source]** Its counterpart is
`Core/test/Execution.Tests/Processing/OperationCompilerTests.cs:1804`,
`Ensure_Selection_Backlog_Does_Not_Exponentially_Grow`. The test still builds a
three-level self-referential interface query and still calls
`OperationCompiler.Compile`, and then asserts this and nothing else (verified at
lines 1877-1884):

```csharp
        // assert
        // Note: Metrics are no longer accessible with static method
```

**Correction worth recording, because I made it myself.** My first reading took
`BacklogMaxSize` as evidence that the compiler works through an iterative work
list. It does not, at this tag.

**The first version of this correction was itself wrong, and the audit caught
it.** It said the word appears in exactly two files, both about schema type
references, and nowhere under `Execution/Processing/`. That was a `head -20` of
a longer result read as the whole of it. The word is all over the executor:
`Execution/Processing/WorkScheduler.cs:30,55` documents `Register` as putting
work on "the task backlog", `WorkScheduler.Execute.cs:123` calls `_work` a
backlog in a comment, and `Fetching/BatchDispatcher.cs:97` builds a real one,
`var backlog = new PriorityQueue<Batch, long>();`, which is the batch evaluation
queue section F is about.

The claim that survives is narrow and checkable: **the compiler** has no
backlog. `grep -rni backlog` over `Execution/Processing/` returns five lines,
two of them inside the dead struct and three in `WorkScheduler`, and none in
`OperationCompiler.cs` or any of its partial files. The struct records the
high-water mark of a work list the compiler no longer keeps, and the reason it
no longer keeps one is section B: nothing accumulates, because everything below
the root is compiled on demand.

The lesson generalises past the fact and is now a writing rule: a name is not a
source, and a truncated grep is not a search.

A test named for a bound that no longer checks the bound, and the type it used
to check it with left behind as dead code. That is the honest shape of it, and
the chapter should not dress it up as anything more sinister.

### A.3 What is not baked in: variables, and the bitmask that proves it

Chapter 3 established from the outside that one compiled operation serves every
variable set. This is the mechanism.

**[source]** Two different things happen to `@skip` and `@include`:

1. **Literal booleans are eliminated at rewrite time**, permanently, for that
   `Operation`. `IsIncluded`/`TryCheckIsIncluded`
   (`InlineFragmentOperationRewriter.cs:430-513`) only inspect
   `BooleanValueNode`; a `VariableNode` argument is left alone.
2. **Variable-driven conditions become a bitmask.** At compile time each
   occurrence records a bit (`OperationCompiler.cs:248-252`):

```csharp
if (IncludeCondition.TryCreate(fieldNode, out var includeCondition))
{
    var index = includeConditions.IndexOf(includeCondition);
    pathIncludeFlags |= 1ul << index;
}
```

and per request exactly one `ulong` is computed from the actual variable values
(`Operation.cs:261-277`, `CreateIncludeFlags`), which each `Selection` tests
against its own compile-time pattern with a single AND (`Selection.cs:288-330`,
`IsIncluded`). So the compiled operation is variable-value-independent, and what
varies per request is one 64-bit integer.

**[source]** That design has a hard ceiling, and it throws rather than degrading
(`IncludeConditionCollection.cs:16-25`, verified):

```csharp
public bool Add(IncludeCondition item)
{
    if (_dictionary.Count == 64)
    {
        throw new InvalidOperationException(
            "The maximum number of include conditions has been reached.");
    }

    return _dictionary.TryAdd(item, _dictionary.Count);
}
```

Sixty-four **distinct** `(skip variable, include variable)` pairs per operation.
Distinct is doing work there: a hundred fields all carrying `@skip(if: $hide)`
share one bit. `@defer(if:)` has its own independent collection and its own
mask (`Operation.cs:279-295`).

**[source]** The same "not baked in" line runs through ordinary field arguments:
`OperationCompiler.CoerceArgumentValues.cs:44-113` eagerly coerces only
leaf-typed literals that contain no variable and no input-object value
(`CanBeCompiled`, lines 92-113); everything else is stored uncoerced and
resolved per request.

## B. The operation keeps compiling after it has been cached

This is the finding I did not expect and it is the chapter's spine.

**[source]** `Operation.cs:179-214`, verified in full:

```csharp
var key = (selection.Id, typeContext.Name);

if (!_selectionSets.TryGetValue(key, out var selectionSet))
{
    lock (_sync)
    {
        if (!_selectionSets.TryGetValue(key, out selectionSet))
        {
            selectionSet =
                _compiler.CompileSelectionSet(
                    this, selection, objectType,
                    _includeConditions, _deferConditions,
                    ref _elementsById, ref _lastId);
            _selectionSets.TryAdd(key, selectionSet);
        }
    }
}
```

Backing field at `Operation.cs:20`:
`private readonly ConcurrentDictionary<(int, string), SelectionSet> _selectionSets = [];`

So a selection set below the root is compiled **the first time execution reaches
it, for that concrete object type**, and then memoised for the life of the
`Operation` - which is the life of the operation cache entry. The key is
`(Selection.Id, concrete type name)`, so one field selected once compiles as
many selection sets as there are concrete types actually returned through it.

`_elementsById` (`object[]`) and `_lastId` (`int`) are passed **by reference**
into the compiler and mutated in place under `_sync`. A cached `Operation` is
therefore not an immutable artefact: it is a partially compiled one that grows,
under a lock, driven by the shapes real traffic returns.

Called from `Selection.GetSelectionSet` (`Selection.cs:268-276`) and, at request
time, from `ValueCompletion.Object.cs:23` and `SelectionCollection.cs`.

**Why a federation book cares.** Abstract types cluster at subgraph boundaries.
An interface field whose rare implementation shows up once an hour pays a
locked, one-time compilation on the request that first returns it, long after
the operation was "compiled" and cached. It is not a leak and not a bug; it is a
latency shape that no cache-hit counter will show you, because both caches
report a hit.

**Not measured.** See section M: I did not turn this into a timing, and the
chapter says so rather than implying a number.

## C. Pure, or a task: what decides, and what the resolver count counts

### C.1 Decision 73 re-verified at this tag, unchanged

**[source]** `DiagnosticEvents.ResolveFieldValue` is raised at exactly two call
sites, both wrapping genuine asynchronous work:

- `Execution/Processing/Tasks/ResolverTask.Execute.cs:13`
- `Execution/Processing/Tasks/BatchResolverTask.cs:129`

**[source]** A pure resolver is invoked from a third path with no diagnostic
event and no task at all
(`Execution/Processing/Tasks/ResolverTaskFactory.cs:290-337`):

```csharp
if (resolverContext.TryCreatePureContext(selection, selectionSetType, fieldValue, parent, out var childContext))
{
    // if we have a pure context we can execute out pure resolver.
    resolverResult = selection.PureResolver!(childContext);
    executedSuccessfully = true;
}
```

So the number this book has printed since chapter 3 counts resolver **tasks**,
and a pure field is invisible to it. Decision 73 stands exactly as written.

### C.2 Purity is decided three times, in three different places

This is sharper than "a resolver with no await", which is what decision 73 says
and which is true only by accident of C# syntax.

1. **Source generator, on the declared return type.**
   `Types.Analyzers/Helpers/SymbolExtensions.cs:1102-1147` (`GetResultKind`):
   anything returning `Task<T>`, `ValueTask<T>`, `IExecutable`, `IQueryable`,
   `IAsyncEnumerable<T>` or bare `Task`/`ValueTask` is classified as its own
   kind; everything else falls through to `return ResolverResultKind.Pure;`
   (line 1146). Because C# requires an `async` method to return
   `Task`/`ValueTask`/`void`, "no await" and "non-awaitable return type" coincide
   for ordinary code - but the test applied is on the **signature**, not on a
   scan of the body.
   `Types.Analyzers/Models/Resolver.cs:77-80` additionally requires the resolver
   not be a node or batch resolver and that **every parameter** is itself pure.
2. **Schema build, on whether any middleware exists.** `Types/ObjectField.cs:192-209`:
   the generated pure delegate is only kept if `IsPureContext()`, which is
   `skipMiddleware || (context.GlobalComponents.Count == 0 && fieldMiddlewareDefinitions.Count == 0)`.
   One global field middleware registered anywhere in the schema and **no field
   is pure**. The file states the consequence as an axiom rather than deriving
   it: `// by definition, fields with pure resolvers are parallel executable`.
3. **Operation compile, per selection, on the directives in the query text.**
   `OperationCompiler.CompileResolver.cs:41-61`, verified in full:

```csharp
private static PureFieldDelegate? TryCreatePureField(
    Schema schema, ObjectField field, FieldNode selection)
{
    if (field.PureResolver is not null && selection.Directives.Count == 0)
    {
        return field.PureResolver;
    }

    for (var i = 0; i < selection.Directives.Count; i++)
    {
        if (schema.DirectiveTypes.TryGetDirective(selection.Directives[i].Name.Value, out var type)
            && type.Middleware is not null)
        {
            return null;
        }
    }

    return field.PureResolver;
}
```

Only a directive with a registered `DirectiveType.Middleware` demotes a pure
field, and only for that one selection. `@skip` and `@include` have no
middleware - they are consumed as bitmask data, section A.3 - so **a field
carrying `@skip` is still resolved by a `PureFieldDelegate`**.

**[source]** The classification is visible per selection as
`Selection.Strategy` (`SelectionExecutionStrategy`: `Default`, `Serial`, `Pure`,
`Batch`), and `Selection.InferStrategy` (`Selection.cs:758-781`) gives serial
precedence over pure: a field already marked serial cannot become pure even with
a pure resolver present.

### C.3 Where the mutation serial rule is enforced

**[source]** `Types/ObjectType.Initialization.cs:180-189`, with its own comment:

```csharp
if (((RegisteredType)context).IsMutationType ?? false)
{
    // if this type represents the mutation type we flag all fields as serially executable
    // so that the operation compiler and execution engine will uphold the spec
    // algorithm to execute mutations serially.
    foreach (var field in definition.Fields)
    {
        field.IsParallelExecutable = false;
    }
}
```

Because nothing but the root returns the mutation type, this marks root mutation
fields and nothing else, which is exactly the spec's rule and needs no special
case in the scheduler.

## D. The scheduler: two stacks, and one preference

**[source]** `OperationExecutionMiddleware.cs:238` calls
`_queryExecutor.ExecuteAsync(operationContext)`, which is precisely where
chapter 3 stopped. Below it is `WorkScheduler`
(`Execution/Processing/WorkScheduler*.cs`), one per operation context, holding
two queues (`WorkScheduler.Pooling.cs:15-16`): `_work` and `_serial`.

**[source]** `WorkQueue` is not a queue. Verified in full at
`Execution/Processing/WorkQueue.cs:6-8`:

```csharp
internal sealed class WorkQueue
{
    private readonly Stack<IExecutionTask> _immediateStack = new();
    private readonly Stack<IExecutionTask> _deferredStack = new();
```

`TryTake` pops immediate first, then deferred (lines 27-37). So within a bucket
the order is last-pushed-first, and the only ordering guarantee is that
immediate work precedes deferred work.

**[source]** `WorkScheduler.Execute.cs:132-171` (`TryTake`) prefers parallel work
absolutely: `var isParallel = !_work.IsEmpty || _work.HasRunningTasks;` (line
138). A serial task is dequeued only when the parallel queue is empty **and**
has nothing running, one at a time, and the drive loop then awaits that one task
before continuing (lines 76-79). Its own comment: *"Parallel work is always
preferred, so we take a single serial task and see if this results in more
parallel work."*

**[source]** `_buffer = new IExecutionTask?[ProcessorCount * 2]`
(`WorkScheduler.Execute.cs:8`) is **not a concurrency limit**. It bounds how many
tasks are drained per lock acquisition; each non-serial task is then started with
`BeginExecute` and not awaited (lines 60-73, comment: *"if work is NOT serial we
will just enqueue it and not wait for it to finish"*). Concurrency is bounded by
the thread pool, not by HotChocolate.

## E. `RunTask` counts nothing you have been measuring

Chapter 3 recorded `RunTask` as unverified and said to state nothing about it.
Settled here, and the answer is that for an ordinary request it fires zero times.

**[source]** The call graph is three links long and I verified every one:

1. `RunTask` is raised from exactly one place,
   `Execution/Processing/OperationContext.IExecutionTaskContext.cs:59-62`:

```csharp
IDisposable IExecutionTaskContext.Track(IExecutionTask task)
{
    AssertInitialized();
    return DiagnosticEvents.RunTask(task);
}
```

2. `Track` is called from exactly one place,
   `Abstractions/Execution/Tasks/ExecutionTask.cs:66`:
   `using (Context.Track(this))`.
3. Exactly two types derive from `ExecutionTask`. Verified with
   `grep -rn ": ExecutionTask\b"` over `src/`:
   - `Execution/Processing/Tasks/DeferTask.cs:7`
   - `Execution/Processing/Tasks/ResolverTaskFactory.cs:393`, the private
     `NoOpExecutionTask`, registered only when every root field was skipped, with
     the comment *"in the case all root fields are skipped we execute a dummy
     task in order to not have extra logic for this case"* (call sites at lines
     83-86 and 138-141).

`ResolverTask` and `BatchResolverTask` implement `IResolverTask` directly and
never pass through `ExecutionTask.ExecuteInternalAsync`, so they never raise it.

**So `RunTask` fires once per `@defer` branch, once in the all-fields-skipped
edge case, and otherwise never.** Mosaic serves no `@defer` (decision 88:
`EnableDefer` defaults off and no subgraph turns it on), so on this graph the
count is zero for everything.

**[source]** Both events sit behind the **same** flag. `IExecutionDiagnosticEvents.cs`
documents `EnableResolveFieldValue` as gating both (lines 86, 115), and
`AggregateExecutionDiagnosticEvents.cs:14` builds one filtered array,
`_resolverListener`, reused by `ResolveFieldValue` (189-204) and `RunTask`
(214-229). A listener that opts in to per-field timings also starts receiving
defer-branch orchestration events, and the names point the wrong way round:
`RunTask` sounds general and is the rare one.

**[source]** The interface's own doc comment (lines 111-121) offers
*"such as DataLoader batch execution or other background processing tasks"* as
the example. DataLoader dispatch does not go through `IExecutionTask` at all -
section F - so the example describes no code path that raises this event at
16.6.0.

## F. When a DataLoader batch actually goes out

This explains decision 37's 398-out-of-400, which has been carried as
"`BatchDispatcher`'s documented settle-time behaviour" since chapter 4 without
anybody reading the mechanism.

**[source]** A batch is enqueued when its **first** key is requested, not its
last: `GreenDonut/DataLoaderBase.cs:393-426` calls `ScheduleBatchUnsafe` on
batch creation, reaching `BatchDispatcher.Schedule`
(`Fetching/BatchDispatcher.IBatchScheduler.cs:19-34`).

**[source]** Every subsequent key resets the batch's state.
`GreenDonut/Batch.cs:37-43`, verified:

```csharp
public Promise<TValue> GetOrCreatePromise<TValue>(TKey key, bool allowCachePropagation)
{
    // we mark the batch as enqueued even if we did not really enqueued something.
    // as long as there are components interacting with this batch its good to
    // keep it in enqueued state.
    Interlocked.Exchange(ref _status, Enqueued);
    _modifiedTimestamp = Stopwatch.GetTimestamp();
```

**[source]** Dispatch eligibility is a two-round quiet check.
`GreenDonut/Batch.cs:31-35`, verified:

```csharp
public override bool Touch()
{
    var previous = Interlocked.Exchange(ref _status, Touched);
    return previous == Touched;
}
```

`Touch()` returns true only if the batch was **already** touched on the previous
evaluation round, that is, no key arrived in between. The dispatcher then also
requires the settle time to have elapsed
(`Fetching/BatchDispatcher.cs`, `EvaluateMultipleOpenBatches` 298-328 and the
single-batch path 330-357):

```csharp
var shouldDispatch =
    batch.Touch()
    && TicksToUs(now - batch.ModifiedTimestamp) >= batchSettleTimeUs;
if (!shouldDispatch && maxBatchAgeUs != 0)
    shouldDispatch = TicksToUs(now - batch.CreatedTimestamp) > maxBatchAgeUs;
```

**[source]** Defaults, verified at `Fetching/BatchDispatcherOptions.cs:8-9`:

```csharp
private const long DefaultMaxBatchWaitTimeUs = 50_000;
private const long DefaultBatchSettleTimeUs = 250;
```

250 microseconds of quiet, or 50 milliseconds of age, whichever comes first.

**[source]** The executor asks for a dispatch when it runs out of *runnable*
work, which is not the same as having collected every key.
`WorkScheduler.Execute.cs:209-239`:

```csharp
if (!isWaitingForTaskCompletion)
{
    isWaitingForTaskCompletion = _work is { HasRunningTasks: true, IsEmpty: true };
}
...
if (isWaitingForTaskCompletion)
{
    _signal.Reset();
    if (Interlocked.CompareExchange(ref _hasBatches, 0, 1) == 1)
    {
        _batchDispatcher.BeginDispatch(_ct);
    }
}
```

**This is the whole of decision 37.** Nothing anywhere synchronises "the batch
is ready" with "every resolver that will ever add a key has added one". A
straggling key that arrives more than 250 microseconds after the previous one,
across two evaluation rounds, finds its batch already dispatched and starts a
second one - which is the fourth SQL statement, twice in four hundred runs. The
mechanism is unambiguous; **the attribution of the delay to thread-pool
scheduling specifically is not measured** and the chapter must not claim it.
See section M.

**[source]** Two unrelated things are both called batching and the chapter must
not conflate them:

- `BatchResolverTask` / `WorkScheduler.RegisterBatchEntry` / `_pendingBatches`:
  HotChocolate's own grouping of resolver invocations sharing a field-selection
  path, gated on ancestor paths draining (`WorkScheduler.Batching.cs:118-135`).
- GreenDonut's `Batch<TKey>` / `BatchDispatcher`: DataLoader key batching, gated
  on the settle time above.

## G. Three middleware that exist so that a request will not run

### G.1 Position 10, and what a warmup request is for

Chapter 3 printed `SkipWarmupExecutionMiddleware` at position 10 and never said
what it does. **[source]**
`Core/src/Execution.Pipeline/SkipWarmupExecutionMiddleware.cs:5-14` is the whole
of it:

```csharp
public async ValueTask InvokeAsync(RequestContext context)
{
    if (context.IsWarmupRequest())
    {
        context.Result = new WarmupExecutionResult();
        return;
    }

    await next(context).ConfigureAwait(false);
}
```

Where it sits is the entire design. Position 10 is after the document cache (4),
parsing (5), validation (6), the cost analyzer (7), the operation cache (8) and
the compiler (9), and before variable coercion (11) and execution (13). A warmup
request is therefore parsed, validated, costed and **compiled**, and then
dropped. It populates both caches and touches no resolver, no variable coercion
and no database.

**[source]** The marker is set through global state, not the request body
(`Execution.Abstractions/Execution/Extensions/OperationRequestBuilderExtensions.cs:23-25`):

```csharp
/// Marks this request as a warmup request that will bypass security measures and skip execution.
public static OperationRequestBuilder MarkAsWarmupRequest(
    this OperationRequestBuilder builder)
    => builder.SetGlobalState(ExecutionContextData.IsWarmupRequest, true);
```

read back by `WarmupRequestContextExtensions.cs:18-23` as a `ContextData` key
whose constant is `"HotChocolate.AspNetCore.Warmup.IsWarmupRequest"`
(`ExecutionContextData.cs:18`). An HTTP client supplies query, variables,
operation name and extensions and has no route to global state, so this is
in-process only. Say that explicitly: it is not a hole.

**[source]** The doc comment says "security measures", plural. Repo-wide,
`IsWarmupRequest` is consulted by exactly two middleware: the one above, and
`PersistedOperations.Pipeline/Execution/Pipeline/OnlyPersistedOperationsAllowedMiddleware.cs:38`,
`if (!_options.OnlyAllowPersistedDocuments || context.IsWarmupRequest())`. One
security measure, not several, and it belongs to chapter 25's subject
(persisted-operations-only), so cross-reference rather than spend it here.

**[source]** Warmup tasks are registered in **schema** services and run
sequentially on executor creation
(`Types/Execution/RequestExecutorManager.Warmup.cs:5-22`):

```csharp
var warmupTasks = executor.Schema.Services
    .GetServices<IRequestExecutorWarmupTask>();

if (!isInitialCreation)
{
    warmupTasks = warmupTasks.Where(t => !t.ApplyOnlyOnStartup);
}

foreach (var warmupTask in warmupTasks)
{
    await warmupTask.WarmupAsync(executor, cancellationToken).ConfigureAwait(false);
}
```

Every `AddWarmupTask` overload goes through `ConfigureSchemaServices`
(`AspNetCore/Extensions/HotChocolateAspNetCoreServiceCollectionExtensions.Warmup.cs`),
which is the same schema-versus-application service-provider distinction that
forced `AddApplicationService<ILoggerFactory>()` into `MosaicSubgraphDefaults`
for the chapter 3 listener - a distinction the reader already owns.

`ExportSchemaOnStartup` (same file, 387-402) is implemented as a warmup task.
Mosaic does not use it: its schemas come from the `schema export` CLI command,
which both verify scripts call.

### G.2 The two authorization middleware, read out of the source at last

Owed by chapter 15, which located them in a startup log. One call registers
both, and a validation rule with them.

**[source]** `Core/src/Authorization/Extensions/AuthorizeRequestExecutorBuilder.cs:28-52`,
`AddAuthorizationCore`, verified in full:

```csharp
builder.Services.TryAddSingleton<IRequestContextEnricher, AuthorizationContextEnricher>();
builder.Services.TryAddSingleton(new AuthorizationCache());
builder.ConfigureSchema(sb => sb.AddAuthorizeDirectiveType());
builder.AddValidationRule(
    (s, _) => new AuthorizeValidationRule(
        s.GetRequiredService<AuthorizationCache>()));

var prepareAuthorization = PrepareAuthorizationMiddleware.Create();
builder.UseRequest(
    prepareAuthorization.Middleware,
    key: prepareAuthorization.Key,
    before: WellKnownRequestMiddleware.DocumentValidationMiddleware);

var authorizeRequest = AuthorizeRequestMiddleware.Create();
builder.UseRequest(
    authorizeRequest.Middleware,
    key: authorizeRequest.Key,
    after: WellKnownRequestMiddleware.DocumentValidationMiddleware);
```

So chapter 15's `before:`/`after:` reading off a startup log was right, and this
is the line that puts them there - the same named-neighbour mechanism chapter 3
described for the cost analyzer.

**[source]** `PrepareAuthorizationMiddleware` is five lines
(`Core/src/Authorization/Pipeline/PrepareAuthorizationMiddleware.cs:5-21`):

```csharp
public ValueTask InvokeAsync(RequestContext context)
{
    context.EnsureAuthorizationRequestDataExists();
    return next(context);
}
```

`EnsureAuthorizationRequestDataExists`
(`Core/src/Authorization/Extensions/AuthorizationFeatureExtensions.cs:105-111`)
resolves the `IAuthorizationHandler` out of the request scope and stores it in a
request feature. That is all it prepares. It has to run before validation
because the validation rule below runs *during* validation, and because
everything downstream calls `context.GetAuthorizationHandler()`, which throws
`"Authorization handler not found."` if the feature was never seeded.

**[source]** `AuthorizeRequestMiddleware.cs:10-46` is the enforcing half, and it
refuses by not calling `next`:

```csharp
var directives = context.GetAuthorizeDirectives();
if (directives.Length > 0)
{
    var handler = context.GetAuthorizationHandler();
    ...
    if (result is not AuthorizeResult.Allowed)
    {
        context.Result = CreateErrorResult(result);
        return;
    }
}
await next(context);
```

Which is mechanically why `[Authorize(apply: Validation)]` can refuse a whole
request before any resolver: the pipeline stops here, above the operation cache,
the compiler and the executor.

**[source]** `ApplyPolicy` (`Core/src/Authorization/ApplyPolicy.cs`) has three
members: `BeforeResolver = 0` (the default, `AuthorizeAttribute.cs:66`),
`AfterResolver = 1`, `Validation = 2`. The first two are a **field** middleware,
`AuthorizeMiddleware`, inserted per guarded field at schema build by
`AuthorizationTypeInterceptor.ApplyAuthMiddleware`
(`AuthorizationTypeInterceptor.cs:408-464`); `BeforeResolver` checks and skips
the resolver, `AfterResolver` runs the resolver and then overwrites the result.
`Validation` gets no field middleware at all - the interceptor `continue`s past
it (lines 446-451) - and is handled by the request middleware above.

Mosaic uses `BeforeResolver` everywhere, which is why chapter 15's refusals
arrive as field errors with a `path` and HTTP 200 rather than as a bare 401.

### G.3 The consequence chapter 15 did not know it was buying

This closes chapter 3's first owed item and it is the chapter's headline.

**[source]** `Core/src/Validation/DocumentValidator.cs:54,68`, verified:

```csharp
_nonCacheableRules = [.. rules.Where(rule => !rule.IsCacheable)];
...
public bool HasNonCacheableRules => _nonCacheableRules.Length > 0;
```

Computed once, when the validator is built, from a static property of each rule.

**[source]** `Core/src/Authorization/AuthorizeValidationRule.cs:14`, verified:

```csharp
public bool IsCacheable => false;
```

Hard-coded. Not gated on whether any field uses `apply: Validation`, not gated
on anything. And `AddAuthorizationCore` registers it unconditionally, per G.2.

**[source]** `Core/src/Execution.Pipeline/DocumentValidationMiddleware.cs:37-47`,
verified:

```csharp
if (!documentInfo.IsValidated || _documentValidator.HasNonCacheableRules)
{
    using (_diagnosticEvents.ValidateDocument(context))
    {
        var result =
            _documentValidator.Validate(
                context.Schema,
                documentInfo.Id,
                documentInfo.Document,
                context.Features,
                documentInfo.IsValidated);
```

Two things follow, and the second is the one to print.

1. Chapter 3's "a document cache hit skips validation" is a **binary** statement
   about a **narrowed** behaviour. The last argument is `onlyNonCacheable`, and
   on a cache hit it is `true`, so with non-cacheable rules present the
   middleware re-runs *only those rules* rather than all of them
   (`DocumentValidator.cs:108-158`, `rules = onlyNonCacheable ? _nonCacheableRules : _allRules`).
2. **Calling `.AddAuthorization()` is by itself enough to make
   `HasNonCacheableRules` true forever.** So the validation phase re-opens on
   every document-cache hit, for every request, whether or not the operation
   touches a guarded field.

**[source]** There is a second, independent trigger nobody has met yet.
`AddGraphQLServer()`
(`AspNetCore/Extensions/HotChocolateAspNetCoreServiceCollectionExtensions.cs:57-67`)
disables introspection unless the host environment is Development, and the rule
it uses for that is registered `isCacheable: false`
(`Validation/Extensions/ValidationBuilderExtensions.cs:348-356`). So **any**
HotChocolate server acquires a non-cacheable rule the day it runs outside
Development, authorization or not. Every Mosaic service runs with
`ASPNETCORE_ENVIRONMENT=Development` in compose, in launch settings and in both
verify scripts, so this trigger does not fire here - but it would in production,
and the chapter should say so rather than leaving a reader with a
Development-only fact.

**[source]** Cost analysis is not involved. `AddCostAnalyzer` registers a
request-pipeline middleware, not an `IDocumentValidatorRule`
(`CostAnalysis/DependencyInjection/CostAnalyzerRequestExecutorBuilderExtensions.cs:27-70`),
so decision 51's `ApplyCostDefaults = false` has no bearing on any of this.

**Mosaic's split, from the companion repo at `ch15`.** `AddMosaicAuthorization()`
is `builder.AddAuthorization()` and nothing else
(`src/Mosaic.ServiceDefaults/Security/MosaicSecurityDefaults.cs:160-162`). It is
called by exactly three services - `Mosaic.Accounts/Program.cs:26`,
`Mosaic.Ordering/Program.cs:26`, `Mosaic.Reviews/Program.cs:38` - and
`Mosaic.Nodes/Program.cs:12` carries a comment saying it deliberately does not.

That is the **same three-versus-four split as decision 95's middleware counts,
produced by the same single line**, and nobody noticed the second consequence.
Predicted, then measured in section M: on a repeat request, Accounts, Reviews
and Ordering re-open the validation phase on a document-cache hit and the other
four do not.

## H. Single-flight compilation, and where chapter 3's excerpt stopped

Chapter 3's second owed item. The mechanism spans **two** middleware, and
chapter 3 quoted only the first.

**[source]** `Types/Execution/Pipeline/OperationCacheMiddleware.cs:13-14` holds
the in-flight table:

```csharp
private readonly ConcurrentDictionary<string, Lazy<TaskCompletionSource<Operation>>> _inFlightOperations =
    new(StringComparer.Ordinal);
```

**[source]** Leader election, lines 63-89, with the comments chapter 3's note
said to quote rather than paraphrase:

```csharp
// No operation is cached and no compilation is in progress.
// Use a Lazy<TCS> so that under burst conditions only one TCS is materialized
// even if multiple requests race through GetOrAdd concurrently.
inFlightOperation = new Lazy<TaskCompletionSource<Operation>>(
    static () => new TaskCompletionSource<Operation>(
        TaskCreationOptions.RunContinuationsAsynchronously));
var cachedInFlightOperation = _inFlightOperations.GetOrAdd(operationId, inFlightOperation);

if (ReferenceEquals(cachedInFlightOperation, inFlightOperation))
{
    // We won the race! This request is the single-flight leader
    // responsible for compiling and signaling all followers.
    isSingleFlightLeader = true;
    context.Features.Set(inFlightOperation.Value);
}
```

**The correction chapter 3 owes itself:** `OperationCacheMiddleware` does not
compile. It stores the winning `TaskCompletionSource` as a request feature and
falls through to `_next(context)`. The compile happens one middleware down, in
`OperationResolverMiddleware`, which signals the followers **as soon as
compilation finishes** rather than when the leader's request finishes
(`OperationResolverMiddleware.cs:37-64`):

```csharp
var inFlightOperation = context.Features.Get<TaskCompletionSource<Operation>>();

using (_diagnosticEvents.CompileOperation(context))
{
    try
    {
        operation = _operationPlanner.Compile(...);
        context.SetOperation(operation);
        inFlightOperation?.TrySetResult(operation);
    }
    catch (Exception ex)
    {
        inFlightOperation?.TrySetException(ex);
        throw;
    }
}
```

So the coalescing is of compilation, not of the request, which is what the name
promises and is not what chapter 3's excerpt suggested.

**[source]** The ordering chapter 3 described is real and the comment states the
invariant (`OperationCacheMiddleware.cs:105-136`): the leader's `finally` adds
the operation to the durable cache *before* removing the in-flight entry, inside
a nested `try`/`finally` so that a throwing diagnostic handler cannot leak the
entry.

```csharp
// Cache the operation before removing the in-flight entry so that
// there is no window where the operation is in neither structure.
```

**[source]** The failure path, which chapter 3 never asked about and which is
the interesting half. A leader that throws during compilation calls
`TrySetException` on the way out, so **every follower faults with the leader's
exception at its own await point** rather than hanging or retrying; the
in-flight entry is still removed in the `finally`, so the *next* request becomes
a fresh leader and tries again. There is a second guard for the case where the
pipeline produced no operation and did not throw:

```csharp
else if (inFlightOperation?.Value.Task.IsCompleted == false)
{
    // The pipeline completed without producing an operation and without
    // throwing. Signal followers so they do not hang indefinitely.
    inFlightOperation.Value.TrySetException(
        new InvalidOperationException(
            "The operation compilation task completed without a result."));
}
```

**[source]** There is no timeout in this middleware. Followers wait with
`.WaitAsync(context.RequestAborted)`, and `RequestAborted` by this point is
whatever `TimeoutMiddleware` replaced it with - a token linking the client's
abort to a per-request `CancellationTokenSource(options.ExecutionTimeout)`, 30
seconds by default (`TimeoutMiddleware.cs:31-43`,
`RequestExecutorOptions.cs:13,20-21`). So each follower's clock is its own and
starts when its own request entered the pipeline; a follower can time out while
the leader is still compiling, and that affects nobody else.

## I. Corrections owed to other files

- **`research/2026-08-ch03-request-lifecycle.md` section E** says compilation
  happens in `OperationResolverMiddleware` and describes the single-flight table
  as though `OperationCacheMiddleware` compiles. Both halves are half right and
  section H above is the whole of it. Not a chapter 3 prose error: chapter 3's
  prose says only that position nine compiles, which is true.
- **Chapter 3's prose, section 3.3 (two caches)**, says a document cache hit
  skips validation. True of the service chapter 3 measured and true today of
  Catalog, Pricing, Inventory and Nodes. False since chapter 15 for Accounts,
  Reviews and Ordering. Chapter 16 states this as a change rather than a
  correction, because nothing chapter 3 wrote was wrong when it was written -
  the same shape as decision 73.

## M. Numbers this chapter may quote, and how to reproduce them

All measured 2026-08-12 on this machine, against the companion repo at the
`ch16` tag. The companion artefact is `samples/executor-internals`, five cases
that assert their own results, plus one new step in both verification scripts.

### M.1 The validation phase on a document cache hit, on the real graph

**[measured]** Stack up with the chapter 15 compose line, then send the same
document to each of the seven subgraphs three times and read the last timeline
line each of them logged. Recipe:

```
for p in 5101 5102 5103 5104 5105 5106 5107; do
  for i in 1 2 3; do
    curl -s -X POST "http://localhost:$p/graphql" \
      -H 'Content-Type: application/json' \
      -d '{"query":"{ __typename }"}' > /dev/null
  done
done
docker logs mosaic-graph-mosaic-<name>-1 | grep 'parse ' | tail -1
```

Captured output, all seven, unedited:

```
catalog     parse - validate - compile - coerce - execute 0.108ms total 0.209ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
pricing     parse - validate - compile - coerce - execute 0.101ms total 0.190ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
inventory   parse - validate - compile - coerce - execute 0.105ms total 0.205ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
accounts    parse - validate 0.037ms compile - coerce - execute 0.090ms total 0.231ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
reviews     parse - validate 0.054ms compile - coerce - execute 0.140ms total 0.272ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
ordering    parse - validate 0.040ms compile - coerce - execute 0.099ms total 0.238ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
nodes       parse - validate - compile - coerce - execute 0.089ms total 0.182ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
```

Four dashes and three durations, and the three are exactly Accounts, Reviews and
Ordering, which are exactly the three that call `AddMosaicAuthorization()`.
Both caches hit in all seven, so the comparison is between services rather than
between a warm and a cold request.

**The claim is the dash, not the milliseconds.** The durations are single-machine
numbers and vary run to run; what is the same on every machine is whether the
phase opened at all. Gated on that basis in both verification scripts.

### M.2 The control, run because the rule says to run one

**[measured]** The sentence names `.AddAuthorization()` as the cause, so the run
that has to behave differently is one where that call is the only thing that
changed. Adding `.AddMosaicAuthorization()` to `Mosaic.Catalog` - a service with
no `[Authorize]` anywhere, no guarded field and no security registration at all -
and rebuilding that one container:

```
catalog     parse - validate 0.047ms compile - coerce - execute 0.132ms total 0.281ms (document cache hit, operation cache hit, 1 resolvers, 0 SQL)
```

Catalog's dash becomes a duration. Reverted immediately; the companion tree is
unchanged. This is the sharper control rather than the obvious one: removing the
call from Accounts would have varied the call *and* left `[Authorize]` attributes
behind, where adding it to Catalog varies the call and nothing else, and so
isolates the claim that the bare registration is sufficient.

### M.3 The same fact in isolation, in process

**[measured]** `samples/executor-internals`, case
`authorization-defeats-the-validation-cache`. Two executors over one schema,
differing in `.AddAuthorization()` and nothing else, each sent the same document
twice with a document id so the document cache engages:

```
== authorization-defeats-the-validation-cache
   without AddAuthorization -> 1 validation(s) over 2 requests, 1 document cache hit(s)
   with AddAuthorization    -> 2 validation(s) over 2 requests, 1 document cache hit(s)
   PASS
```

Same document-cache hit on both sides; only the authorized one re-validates.

### M.4 Pure fields cost no resolver task

**[measured]** Case `pure-fields-cost-no-task`. Three things, one asynchronous
root field, and a type whose `id`, `name` and `upper` are pure while `delayed`
returns a `Task<string>`:

```
== pure-fields-cost-no-task
   three things, nine pure fields selected -> 1 resolver tasks
   the same plus one async field per thing -> 4 resolver tasks
   PASS
```

One for the root; nine pure fields cost nothing; adding one awaitable field per
thing adds exactly three. Decision 73's claim, reproduced on a schema small
enough to count by hand.

### M.5 `RunTask` fires zero times until something defers

**[measured]** Case `run-task-counts-no-resolver`, on an executor with
`EnableDefer` turned on:

```
== run-task-counts-no-resolver
   plain      -> 4 resolver tasks, 0 execution tasks
   with defer -> execution tasks 3
   PASS
```

Four resolver tasks and zero execution tasks for the ordinary query. The same
listener, the same flag, the same request: `RunTask` counts nothing until a
`DeferTask` exists. Mosaic serves no `@defer`, so on the real graph the number
would be zero everywhere, which is why it is measured here and not added to the
seven services' timeline.

### M.6 A warmup request fills the operation cache

**[measured]** Case `warmup-fills-the-operation-cache`:

```
== warmup-fills-the-operation-cache
   first request, no warmup task -> document cache hits 0, operation cache hits 0
   first request, warmed         -> document cache hits 0, operation cache hits 1
   PASS
```

The first client request against a warmed executor compiles nothing, and still
runs its own resolver: the warmup request is the one that did not execute.

**The document cache stays cold here and that is not the warmup's doing.**
`DocumentCacheMiddleware` only consults the cache when the request carries a
`DocumentId` or a `DocumentHash` (source in section G.1's neighbourhood:
`Execution.Pipeline/DocumentCacheMiddleware.cs:37-77`), and only stores one when
the parsed document ended up with an id. An in-process request built from source
text carries neither. Over HTTP the transport supplies a hash, which is why
M.1's seven services all report a document cache hit and this case does not.
Worth stating in the chapter rather than hiding: it is the difference between
the two harnesses, and a reader who instruments in process will meet it.

### M.7 Single-flight compilation under a burst

**[measured]** Case `single-flight-compiles-once`. Thirty-two concurrent
requests for a document the executor has never seen:

```
== single-flight-compiles-once
   32 concurrent identical first-time requests -> 1 compilation(s)
   PASS
```

Run five times in a row, one compilation every time. This closes chapter 3's
second owed item: the mechanism was read there and never exercised, and it does
what its comments say.

## N. Left unmeasured, deliberately

- **The first-use compilation cost of a new concrete type** (section B). The
  mechanism is read; the latency is not measured. It would need a schema with a
  wide interface and a cold-versus-warm comparison for one concrete type, and
  decision 62 keeps timings out of gates anyway. State the mechanism, print no
  number.
- **Why a straggling DataLoader key is late** (section F). The settle-time race
  is the only mechanism in the source that can produce decision 37's fourth
  statement, and that much is safe to write. Which source of delay makes it late
  on two runs in four hundred - thread-pool scheduling, a collection, something
  else - is not measured and must not be asserted. Dropping `BatchSettleTimeUs`
  to 0 and re-running the 400-request loop would test whether the 250-microsecond
  window is load-bearing; not done.
- **`RequestExecutorOptions.AllowErrorHandlingModeOverride`'s default.** Needed
  only if the chapter claims a client can flip null propagation per request. Not
  read, so do not claim it.
- **`IExecutionTask.Next`/`Previous`.** Declared on the interface; no consumer
  found while reading, but no exhaustive search done. Do not call them unused in
  print without one.
- **`@stream` execution.** `ResolverTask.Execute.cs:171-233` is a commented-out
  `// TODO : DEFER` block at this tag. Chapter 18's subject; describe nothing
  from it.

## O. Still open at the time of writing

- The two authorization middleware, `PrepareAuthorization` and
  `AuthorizeRequest` (section G).
- `DocumentValidator.HasNonCacheableRules`, and which shipped validation rules
  are non-cacheable - chapter 3's first owed item.
- Single-flight compilation under a real burst - chapter 3's second owed item.
  `Core/test/Execution.Tests/Pipeline/OperationCompilerSingleFlightTests.cs`
  exists and has not been read.
