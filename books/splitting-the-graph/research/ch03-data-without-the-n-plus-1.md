# Chapter 3 - Data Without the N+1

Research note for the chapter that moves the conference into SQLite and fixes
the per-parent speaker lookup. Web sources accessed **2026-08-19**; everything
else was measured on this machine on the same date.

Like chapter 2, this is mostly a compiler-and-wire chapter rather than a
sourced one, and the same rule applies: where the published documentation and
the machine disagreed, the machine is the finding and the documentation is
recorded as the disagreement. Chapter 3 produced more of those than chapter 2
did, and two of them changed the design of the chapter.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| Tags this chapter uses | `ch03` (branch `main`), `ch03-naive`, `ch03-starved`, `ch03-hc14` (branch `hc14`) |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| EF Core on `main` | 10.0.11 |
| EF Core on `hc14` | 9.0.19 |
| Gate | `pwsh verify.ps1`, run on each of the four branches. All printed PASS on 2026-08-19 |

Every count and every response quoted below is asserted by `verify.ps1`, and
**which tag asserts which** is the thing to keep straight, because the chapter
walks through four states and three of them are not the final one:

| Tag | Branch | What it is | What its `verify.ps1` asserts |
|-----|--------|-----------|-------------------------------|
| `ch03-naive` | `ch03-naive` | SQLite in, speaker resolver querying once per session | the **5** statements the chapter opens with, and the 1 for the same request without the nested field |
| `ch03-starved` | `ch03-starved` | projection on, `[Parent]` without its requirement, before paging | the null-in-every-speaker response, HTTP 200, no `errors` key, still 2 statements |
| `ch03` | `main` | the finished chapter: DataLoader, projection, paging | **2** statements with speakers, 1 without, correct speaker names, the paged schema |
| `ch03-hc14` | `hc14` | the same on 14.3.1 | the same counts, and the schema differences the callout prints |

So the way to reproduce anything below is to check out the tag named beside it
and run the script. That is a change from chapter 2, where the one interesting
count needed instrumentation the book did not ship; see "How the counts are
taken" below for why chapter 3 does not have that problem.

`ch03-naive` and `ch03-starved` are branches rather than commits on `main`
because the repository holds one state per file and the chapter needs three.
Nothing is built on either; each ends at its tag. SPEC decision 51 records the
rule and decision 53 records where it stops.

## Packages, and how the versions were fixed

Read from `https://api.nuget.org/v3-flatcontainer/<id>/index.json` and the
matching `.nuspec`, not from a docs page.

- `HotChocolate.Data.EntityFramework` **16.6.1**, targets net8.0, net9.0,
  net10.0 and net11.0. This is the package that supplies
  `RegisterDbContextFactory<T>()`. It depends on `GreenDonut.Data`,
  `GreenDonut.Data.EntityFramework`, `HotChocolate.Data` and
  `Microsoft.EntityFrameworkCore`.
- `Microsoft.EntityFrameworkCore.Sqlite` **10.0.11** is the latest stable 10.x
  and targets **net10.0 only**. This is why the `hc14` branch cannot have it.
- `Microsoft.EntityFrameworkCore.Sqlite` **9.0.19** is the latest stable 9.x
  and is what `hc14` pins. 8.0.30 is the latest 8.x; either would work on
  net8.0 and 9.0.19 was chosen as the newer of the two.
- `HotChocolate.Data.EntityFramework` **14.3.1** exists and targets net6.0
  through net9.0.

Attempting EF Core 10 on the `hc14` branch fails at restore rather than at
build, which is the useful failure:

```
error NU1202: Package Microsoft.EntityFrameworkCore.Sqlite 10.0.11 is not
compatible with net8.0 (.NETCoreApp,Version=v8.0). Package
Microsoft.EntityFrameworkCore.Sqlite 10.0.11 supports: net10.0
(.NETCoreApp,Version=v10.0)
```

**Not added, and worth recording.** `Microsoft.EntityFrameworkCore.Design` is
not referenced by either branch. It is the package the `dotnet ef` tooling
needs, and this chapter creates the database with `EnsureCreated()` rather than
with migrations, so nothing in the book uses it. `HotChocolate.Data` is not
referenced directly either; it arrives transitively through
`HotChocolate.Data.EntityFramework`.

## SQLite will not sort a DateTimeOffset

The first thing that broke, and the reason `ConferenceContext` has a value
converter in it at all. Chapter 2's `GetSessions()` ordered an in-memory list
by `StartsAt`. The same `OrderBy` against SQLite throws at request time:

```
SQLite does not support expressions of type 'DateTimeOffset' in ORDER BY
clauses. Convert the values to a supported type, or use LINQ to Objects to
order the results on the client side.
```

Thrown from
`SqliteQueryableMethodTranslatingExpressionVisitor.TranslateOrderBy`, so it is
the SQLite provider refusing to translate, not EF Core in general.

Three fixes were considered. Changing `Session.StartsAt` to `DateTime` was
rejected because it edits a record chapter 2 printed and changes the type a
reader already typed out. Ordering by `Id` was rejected because it silently
substitutes insertion order for schedule order and would still be sitting there
when the data stopped agreeing. The one taken is a value converter on the
property, which keeps the record and the schema exactly as chapter 2 printed
them:

```csharp
model.Entity<Session>()
    .Property(s => s.StartsAt)
    .HasConversion(
        v => v.UtcDateTime,
        v => new DateTimeOffset(v, TimeSpan.Zero));
```

The column is then written as `2026-09-14 09:00:00` rather than
`2026-09-14 09:00:00+00:00`, and `ORDER BY "s"."StartsAt"` translates.

**The chapter does not print that exception message.** SPEC decision 48 says
every response the book quotes is asserted by `verify.ps1`, and a failure the
corrected code cannot produce cannot be asserted. The prose states the
limitation and shows the converter; the message lives here. See the chapter's
retro: chapter 11 has to print a deliberately broken listing and will need a
mechanism for this.

## Moving the resolver to the database attaches a cost weight

Not looked for. Found by diffing the exported schema against `ch02` after the
move, which is the habit chapter 2's own development-loop section argues for.

At `ch02` the field exports as `speaker: Speaker`. At `ch03-naive` it exports
as `speaker: Speaker @cost(weight: "10")`, and nothing in the chapter asked
for that.

Isolated by compiling four shapes of the same method in the `ch03-naive`
project and exporting the schema each time. Only the resolver's signature
changed between runs:

| `SessionType.GetSpeaker...` | `speaker` exports as |
|---|---|
| chapter 2's exactly: `Speaker? GetSpeaker([Parent] Session)`, reading `ConferenceData` | `speaker: Speaker` |
| `async Task<Speaker?>`, `[Parent]` only, no service, `await Task.Yield()` then read `ConferenceData` | `speaker: Speaker @cost(weight: "10")` |
| synchronous, `[Parent] Session` plus `ConferenceContext db` | `speaker: Speaker @cost(weight: "10")` |
| the chapter's: `async`, `[Parent] Session`, `ConferenceContext db`, `CancellationToken` | `speaker: Speaker @cost(weight: "10")` |

So **either** returning a `Task` **or** taking a service parameter attaches the
weight, each on its own, and the chapter-2 method compiled unchanged in the
chapter-3 project still exports bare. That last row is the control: it rules
out the new package references being the cause.

The chapter states both arms. `verify.ps1` on `ch03-naive` asserts the
resulting line so the claim fails a run rather than ageing on the page.

Not established: what rule Hot Chocolate is actually applying. "Resolver that
might do work" fits all four rows and is a guess, so the chapter describes what
changes the output rather than naming a rule.

## `RegisterDbContextFactory<T>()` changes nothing observable here

Measured because the chapter prints the call and I could not say what it did.

Procedure, on `main` at `ch03`: delete the `.RegisterDbContextFactory<ConferenceContext>()`
line from `Program.cs`, rebuild, export the schema, and run the chapter's
requests.

Result: the project compiles, the exported schema is byte-identical, every
response is identical, and the statement counts are identical. The DataLoader
still batches and `ConferenceContext` still resolves as a resolver parameter,
because `AddDbContextFactory<T>()` registers the context type as a scoped
service in addition to the factory - which is also visible in the generated
DataLoader, whose `FetchAsync` does
`scope.ServiceProvider.GetRequiredService<ConferenceContext>()` against a scope
it opened itself.

The call stays in the book because it is what the documentation pairs with a
factory registration and it is what I would ship. **The chapter says outright
that it cannot tell the reader what the call buys**, which is decision 38's
precedent applied to a mechanism rather than to a claim.

Not established: whether it changes which context instance a resolver receives.
That is a question about resolvers running concurrently, which is its own open
item.

## The source-generated DataLoader

`[DataLoader]` is `GreenDonut.DataLoaderAttribute`, and the generator that
reads it is in `HotChocolate.Types.Analyzers` - the same package chapter 2
already installed for `[QueryType]`. Nothing new had to be added for the
DataLoader itself.

The method the book prints, at tag `ch03`:

```csharp
[DataLoader]
public static async Task<Dictionary<int, Speaker>>
    GetSpeakerByIdAsync(
        IReadOnlyList<int> ids,
        ConferenceContext db,
        CancellationToken ct)
    => await db.Speakers
        .Where(s => ids.Contains(s.Id))
        .ToDictionaryAsync(s => s.Id, ct);
```

The generated file, obtained with
`dotnet build -p:EmitCompilerGeneratedFiles=true -p:CompilerGeneratedFilesOutputPath=../gen`
(and note chapter 2's trap still applies: the output path must be outside the
project directory or the next build fails with CS0111). Two facts the chapter
rests on, read out of it rather than assumed:

```csharp
public interface ISpeakerByIdDataLoader
    : global::GreenDonut.IDataLoader<int, global::Sessions.Speaker>
{
}

public sealed partial class SpeakerByIdDataLoader
    : global::GreenDonut.DataLoaderBase<int, global::Sessions.Speaker>
    , ISpeakerByIdDataLoader
```

- The name is the method's, with `Get` stripped from the front and `Async` from
  the end: `GetSpeakerByIdAsync` becomes `ISpeakerByIdDataLoader`. The same
  naming rule chapter 2 met on `AddSessionsTypes`, applied to a different
  input.
- The base class is `DataLoaderBase<TKey, TValue>`, not `BatchDataLoader<,>`.
  `BatchDataLoader<,>` and `GroupedDataLoader<,>` do exist and are the base
  classes for a hand-written loader; the generator does not use them.

The fetch body shows where the `ConferenceContext` parameter comes from:

```csharp
await using var scope = _services.CreateAsyncScope();
var p1 = scope.ServiceProvider.GetRequiredService<global::Sessions.ConferenceContext>();
var temp = await global::Sessions.SpeakerDataLoader.GetSpeakerByIdAsync(keys, p1, ct)
```

so the generator opens a DI scope per batch and resolves every extra parameter
from it. The DbContext a batch uses is private to that batch.

Missing keys resolve to `default`, i.e. `null`, not to an exception - read from
the generated `CopyResults`, which does `resultMap.TryGetValue` and falls back
to `Result<Speaker?>.Resolve(default(Speaker))`.

### Registration is automatic, and the documentation says it is not

**The largest documentation disagreement in this chapter.** ChilliCream's
current DataLoader page
(https://chillicream.com/docs/hotchocolate/fetching-data/batching/dataloader,
accessed 2026-08-19) describes registration as a two-step opt-in under a
heading of its own, "Registration". Quoted verbatim, because the chapter quotes
the first of these:

> Declare a DataLoader module for your assembly. The source generator then
> emits a registration extension method named after the module:

> `AddCatalogDataLoaders()` registers every generated DataLoader with the
> dependency injection container.

with `[assembly: DataLoaderModule("CatalogDataLoaders")]` and
`builder.Services.AddCatalogDataLoaders();` shown as the two things to write.

Neither is needed. The book's project has no `DataLoaderModule` attribute and
no extra registration call, and the generated `AddSessionsTypes()` - the same
method chapter 2 printed - grew a line by itself:

```csharp
public static IRequestExecutorBuilder AddSessionsTypes(this IRequestExecutorBuilder builder)
{
    builder.AddTypeExtension(typeof(global::Sessions.Query));
    builder.ConfigureDescriptorContext(...);
    builder.AddDataLoader<global::Sessions.ISpeakerByIdDataLoader, global::Sessions.SpeakerByIdDataLoader>();
    ...
}
```

Verified by running: the DataLoader resolves and batches with `Program.cs`
unchanged from chapter 2 except for the DbContext wiring. The chapter follows
the compiler and says the attribute is the whole of the registration, which is
the same thing chapter 2 said about `[QueryType]`.

## The projection, and why it is not `[UseProjection]`

`[UseProjection]` exists at 16.6.1 (`HotChocolate.Data.UseProjectionAttribute`,
registered with `AddProjections()`), it compiles against this book's `Session`,
and it throws on every request:

```
System.ArgumentException: Type 'Session' does not have a default constructor
(Parameter 'type')
   at System.Linq.Expressions.Expression.New(Type type)
   at HotChocolate.Data.Projections.Expressions.QueryableProjectionScopeExtensions.CreateMemberInit
```

Its EF Core provider builds the projected value with `Expression.New` plus a
member initialiser, which needs a parameterless constructor and settable
properties. **A positional record cannot be the target of `[UseProjection]`**,
and positional records are exactly what chapter 2 printed. Confirmed
independently at 14.3.1: the same code fails the same way, so this is not a
16 regression.

The route that does work on records is `QueryContext<T>`:

```csharp
[UsePaging(DefaultPageSize = 2, MaxPageSize = 10)]
public static IQueryable<Session> GetSessions(
    ConferenceContext db,
    QueryContext<Session> query)
    => db.Sessions
        .OrderBy(s => s.StartsAt)
        .With(query);
```

Where the pieces live, established by compiling rather than by reading:

| Thing | Namespace | Package |
|---|---|---|
| `QueryContext<T>` | `GreenDonut.Data` | `GreenDonut.Data`, transitive |
| `.With(query)` on `IQueryable<T>` | **`System.Linq`** | `GreenDonut.Data`, transitive |
| `AddQueryContext()` | `Microsoft.Extensions.DependencyInjection` | `HotChocolate.Data` |
| `AddPagingArguments()` | `Microsoft.Extensions.DependencyInjection` | `HotChocolate.Types.CursorPagination.Extensions` |

`QueryContext<T>` is **not** in `HotChocolate.Data`, which is the first place
to look and produces `CS0246: The type or namespace name 'QueryContext<>' could
not be found`. The `.With` extension being in `System.Linq` is why it resolves
with no using directive of its own.

### Order matters: OrderBy before With

`.With(query)` appends a `Select` that rebuilds the entity from the selected
fields only. Ordering after it therefore orders over a partly-default object
and EF Core cannot translate it:

```
The LINQ expression 'DbSet<Session>()
    .OrderBy(s => new Session(
        0, s.Title, null, 0, 01/01/0001 12:00:00 SA +00:00, 0
    ).StartsAt)' could not be translated.
```

`OrderBy` before `With` translates. Recorded because the failure names a
constructor call the reader never wrote, which makes it hard to search for.

### The silent one: a projection starves the resolver

The defect worth the most page space in this chapter, because nothing reports
it. With the projection on and the resolver declared as chapter 2 left it:

```csharp
public static async Task<Speaker?> GetSpeakerAsync(
    [Parent] Session session,
    ISpeakerByIdDataLoader speakerById,
    CancellationToken ct)
    => await speakerById.LoadAsync(session.SpeakerId, ct);
```

the request `{ sessions { title speaker { name } } }` answers **HTTP 200 with
`"speaker": null` on every session** and no error anywhere. The captured SQL
says why:

```
-- statement 1
SELECT "s"."Title"
FROM "Sessions" AS "s"
ORDER BY "s"."StartsAt"
-- statement 2
SELECT "s"."Id", "s"."Bio", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" = @ids1
```

`SpeakerId` was never selected, so every `Session` handed to the resolver
carried `SpeakerId = 0`, all four keys deduplicated to the single key `0`, and
no speaker has id 0. The fix is to declare what the resolver reads:

```csharp
[Parent(nameof(Session.SpeakerId))] Session session
```

after which statement 1 becomes `SELECT "s"."Title", "s"."SpeakerId"` and the
answers are correct. `ParentAttribute`'s string constructor sets a `Requires`
property, documented as "a string representing the property requirements for
the parent object".

**This state is tag `ch03-starved`**, and its `verify.ps1` asserts the damage
rather than the fix: the four titles correct, `null` in every speaker, HTTP
200, no `errors` key, and still two statements, because the batching is working
perfectly on the wrong key. The tag sits before `[UsePaging]`, which is where
the chapter meets it, so `sessions` is still a bare list there and statement 1
carries no `LIMIT`. On `main` the same requests assert the corrected answers.

**One thing measured here that I had assumed the other way.** `sessionById` is
starved identically, not spared. It takes a `QueryContext` of its own, so
asking `{ sessionById(id: 3) { title speaker { name } } }` at `ch03-starved`
returns the right title and a null speaker. The defect follows the projection
rather than the field, which is the property that makes it dangerous: adding a
projection to one query changes every resolver on the type it returns. Both
assertions are in that branch's script.

## Paging

`[UsePaging]`, `[UseOffsetPaging]` and `[UseConnection]` all exist as types at
16.6.1. The book uses `[UsePaging]`.

**`[UseConnection]` was tried first and silently did nothing.** With
`[UseConnection(DefaultPageSize = 2, MaxPageSize = 10)]` on a method returning
`Task<PageConnection<Session>>`, the field exported as `sessions:
[Session!]!` - an ordinary list - and the `PagingArguments` parameter leaked
into the schema as a required GraphQL argument named `paging`:

```
The argument `paging` is required.
```

Adding `AddPagingArguments()` removed the leaked argument but the field still
did not become a connection. No configuration was found that made
`[UseConnection]` produce one, and **this is recorded as not established rather
than as a defect**: the attribute may need something else that was not tried.
`[UsePaging]` was substituted and worked first time, so the search stopped
there. Anything the book says about paging is about `[UsePaging]`.

`[UsePaging]` on the `IQueryable<Session>` returned above produces:

```graphql
sessions(
  first: Int
  after: String
  last: Int
  before: String
): SessionsConnection
  @listSize(
    assumedSize: 10
    slicingArguments: ["first", "last"]
    slicingArgumentDefaultValue: 2
    sizedFields: ["edges", "nodes"]
    requireOneSlicingArgument: false
  )
  @cost(weight: "10")
```

with `SessionsConnection`, `SessionsEdge` and `PageInfo` generated from the
field name. The two paging options reach the schema as `@listSize` arguments -
`MaxPageSize` as `assumedSize` and `DefaultPageSize` as
`slicingArgumentDefaultValue` - which is why `verify.ps1` can assert them out
of the exported file.

The slice is done in SQL, not in memory: `LIMIT @p` appears in statement 1.

`DefaultPageSize = 2` is deliberately small. The seed holds four sessions, so a
default page of two is what makes `hasNextPage: true` observable without
inventing more data.

## The counts, and how they are taken

The instrument is `StatementLog`, a `DbCommandInterceptor` that overrides
`ReaderExecuting` and `ReaderExecutingAsync` and prints a numbered marker plus
the command text. It is registered only under `IsDevelopment()`.

It exists because the obvious alternative prints a timing. EF Core's own
`LogTo` with `RelationalEventId.CommandExecuted` emits
`Executed DbCommand (1ms) [Parameters=...]`, and SPEC decision 19 puts no
milliseconds in this book. `RelationalEventId.CommandExecuting` with
`DbContextLoggerOptions.None` avoids the duration but still prefixes each
statement with a 113-column `Executing DbCommand [Parameters=[...],
CommandType='Text', CommandTimeout='30']` line, which is over the book's
73-column listing budget and carries nothing a reader needs.

One thing had to be silenced either way. EF Core also reports commands through
the application logging pipeline at Information, so without

```csharp
builder.Logging.AddFilter(
    "Microsoft.EntityFrameworkCore.Database.Command",
    LogLevel.Warning);
```

every statement is printed twice, once by the interceptor and once by the
framework with its duration attached.

Procedure for any count below. Each row names the tag it was taken at, and the
request differs between tags because the chapter changes the field's shape as
it goes: before paging `sessions` is a bare list, after it a connection.

1. Check out the tag, then `pwsh verify.ps1`, which deletes `conference.db`
   first so the seed is the same every run.
2. Or by hand: delete `src/Sessions/conference.db`, `dotnet run`, send one
   request, and read the last `-- statement N` marker on standard output. The
   counter is process-wide and never reset, so one request per start.

Counts on 2026-08-19, four sessions and three distinct speakers:

| Tag | Request | Statements |
|-----|---------|-----------|
| `ch03-naive` | `{ sessions { title speaker { name } } }` | **5** |
| `ch03-naive` | `{ sessions { title } }` | 1 |
| `ch03-starved` | `{ sessions { title speaker { name } } }` | 2 |
| `ch03` | `{ sessions(first: 10) { nodes { title speaker { name } } } }` | **2** |
| `ch03` | `{ sessions(first: 10) { nodes { title } } }` | 1 |
| `ch03` | `{ sessions { nodes { title } pageInfo { hasNextPage } } }`, default page of 2 | 1 |

The naive figure of 5 is one statement for the list and one per session, and it
is what `ch03-naive` exists to assert. Its `SessionType.GetSpeakerAsync`
queries the DbContext directly:

```csharp
public static async Task<Speaker?> GetSpeakerAsync(
    [Parent] Session session,
    ConferenceContext db,
    CancellationToken ct)
    => await db.Speakers
        .FirstOrDefaultAsync(s => s.Id == session.SpeakerId, ct);
```

Statement 1 at that tag selects all six columns and carries no `LIMIT`, because
neither the projection nor the paging exists yet:

```
SELECT "s"."Id", "s"."Abstract", "s"."DurationMinutes", "s"."SpeakerId", "s"."StartsAt", "s"."Title"
FROM "Sessions" AS "s"
ORDER BY "s"."StartsAt"
```

The four repeated statements after it are byte-identical to each other:

```
SELECT "s"."Id", "s"."Bio", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" = @session_SpeakerId
LIMIT 1
```

The batched version asks once, and asks for **three** keys rather than four,
because Ada Fischer gives two of the four sessions and the DataLoader
deduplicates:

```
SELECT "s"."Id", "s"."Bio", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" IN (@ids1, @ids2, @ids3)
```

A single distinct key emits `WHERE "s"."Id" = @ids1` instead of an `IN` list.
Seen when a page of two happens to hold two sessions by the same speaker.

**No timing was taken.** SPEC decision 19; the point of the chapter is the
count, and a count is what a reader who typed the code out of the book can
reproduce.

## The 14 delta, as the compiler reported it

`hc14` at tag `ch03-hc14` carries the same files on 14.3.1, `net8.0` and EF
Core 9.0.19. What compiled unchanged, which is nearly all of it:

- `[DataLoader]` and the generated `ISpeakerByIdDataLoader`. The attribute and
  the generator both ship in 14.3.1.
- `RegisterDbContextFactory<ConferenceContext>()`.
- `[UsePaging(DefaultPageSize = 2, MaxPageSize = 10)]`, producing the same
  `SessionsConnection` and `SessionsEdge`.
- `[Parent(nameof(Session.SpeakerId))]`.
- `AddDbContextFactory`, the value converter, and `StatementLog`.

The one thing that did not:

```
error CS0411: The type arguments for method
'GreenDonutQueryContextDataLoaderExtensions.With<TKey, TValue>(
IDataLoader<TKey, TValue>, QueryContext<TValue>?)' cannot be inferred from
the usage. Try specifying the type arguments explicitly.
```

Worth reading carefully. `GreenDonut.Data` **is** on the 14.3.1 branch and
`QueryContext<T>` resolves there, so the failure is not a missing package. What
is missing is the `IQueryable<T>` overload of `.With`; the only overload the
14.3.1 assembly offers takes an `IDataLoader`. So the projection is
unavailable on 14 in this form, and the branch's `Query.cs` drops the
`QueryContext` parameter and `Program.cs` drops `AddQueryContext()`.

Two further differences in the captured SQL are **EF Core's and not Hot
Chocolate's**, caused by the framework pin rather than the library:

| | EF Core 10.0.11 (`main`) | EF Core 9.0.19 (`hc14`) |
|---|---|---|
| paging parameter | `LIMIT @p` | `LIMIT @__p_0` |
| DataLoader key list | `IN (@ids1, @ids2, @ids3)` | `IN (SELECT "i"."value" FROM json_each(@__ids_0) AS "i")` |

The callout has to attribute those two correctly or it tells a reader that Hot
Chocolate 14 does something it does not.

**The statement counts are identical on both branches**, 2 and 1 for the same
requests. `verify.ps1` asserts them on both. That is the useful sentence for a
reader on 14: the DataLoader is worth exactly the same there, and only the
column list differs.

**Not measured, and therefore not claimed: the naive count on 14.** There is no
14 equivalent of `ch03-naive`; the `hc14` branch carries only what a live
callout quotes (decision 47), and the callout quotes the finished state. So the
callout says the counts are two and one, which were measured there, and says
nothing about five, which was not. An earlier draft of the callout said "five
before the DataLoader, two after" on both versions, which was an extrapolation
from `main` and exactly the kind of claim decision 11 exists to stop.

The full 14 statement 1, for comparison with the 16 projection:

```
SELECT "s"."Id", "s"."Abstract", "s"."DurationMinutes", "s"."SpeakerId", "s"."StartsAt", "s"."Title"
FROM "Sessions" AS "s"
ORDER BY "s"."StartsAt"
LIMIT @__p_0
```

## Claims checked and found false

Recorded so no later chapter re-derives them.

- **`AddApplicationService<T>()` is needed for a DbContext.** False, and it was
  chapter 2's own note that predicted it would matter here. The 15-to-16
  migration guide scopes that call to eight schema-configuration hooks -
  `AddHttpRequestInterceptor`, `AddSocketSessionInterceptor`, `AddErrorFilter`,
  `AddDiagnosticEventListener`, `AddOperationCompilerOptimizer`, the two
  document-storage backends, and `AddInstrumentation` with a custom
  `ActivityEnricher` - and states outright that "Service injection into
  resolvers is not affected by this change". The book's service registers no
  such hook. Built and run without it; nothing needs it.
  (https://chillicream.com/docs/hotchocolate/migrating/migrate-from-15-to-16,
  accessed 2026-08-19.)
- **The DataLoader needs `[assembly: DataLoaderModule]` and its own
  registration call.** False at 16.6.1; see above. The documentation says it
  does.
- **`RegisterDbContext<T>()`, without `Factory`, is available at 16.6.1.**
  False. Only `RegisterDbContextFactory<T>()` is exported.
- **`[UseDbContext(typeof(T))]` and `[ScopedService]`.** Neither type exists at
  16.6.1 **or** at 14.3.1 - both produce `CS0246`. They are Hot Chocolate 12
  and 13 API and a lot of still-circulating tutorial material uses them. Since
  this book covers only 14 and 16, neither is reachable and neither is
  mentioned.
- **`[UseProjection]` works on the book's types.** False; it throws on any
  positional record. See above.
- **`IBatchDataLoader` and `IGroupedDataLoader` are interfaces in GreenDonut.**
  False at 16.6.1. `IDataLoader` and `IDataLoader<TKey, TValue>` are the
  interfaces; `BatchDataLoader<,>` and `GroupedDataLoader<,>` are abstract base
  classes.

## Not established

- **Whether `[UseConnection]` can be made to work.** It compiles and does
  nothing here. `[UsePaging]` was substituted rather than the question being
  settled, so the book says nothing about `[UseConnection]` at all.
- **Whether Hot Chocolate ever resolves sibling list-item resolvers
  concurrently.** A DbContext is not thread-safe, so this decides whether the
  naive resolver was ever at risk of more than being slow. Four sessions with
  an artificial delay executed strictly one at a time, which shows nothing
  about a larger list or a different execution strategy. **No chapter claims
  anything about resolver concurrency**, and the naive resolver is criticised
  for its statement count only.
- **Whether requesting `totalCount` on the connection adds a `COUNT(*)`.** Not
  requested by any query the book prints, so not measured. It matters the first
  time a chapter prints a query that asks for it.
- **Whether the 14 branch would show the same DI conflicts.** Registering both
  `AddDbContext<T>` and `AddPooledDbContextFactory<T>` for one `T` fails at
  startup on 16 with `Cannot consume scoped service 'DbContextOptions<T>' from
  singleton 'IDbContextPool<T>'`. Not re-tried on 14. It is ASP.NET Core DI
  behaviour rather than Hot Chocolate's, so it probably reproduces, but that is
  an expectation and the book does not print it.

## Sources

Only three carry anything, and none of them carries a claim the chapter states
as fact - all three are cited or used as artifacts, in the sense SPEC decision
39 allows, and every place the compiler disagreed is recorded above.

### The DataLoader documentation

*Fetching Data - DataLoader*, ChilliCream Docs, accessed 2026-08-19.
https://chillicream.com/docs/hotchocolate/fetching-data/batching/dataloader

Unsigned vendor documentation, and the source of the registration claim the
compiler contradicts. Chapter 2's trap applies here too: the `/v14/` and
`/v16/` paths both redirect to one unversioned page, so this URL is not a
record of any particular version.

### The 15-to-16 migration guide

*Migrate from 15 to 16*, ChilliCream Docs, accessed 2026-08-19.
https://chillicream.com/docs/hotchocolate/migrating/migrate-from-15-to-16

Unsigned. Used only to settle what `AddApplicationService<T>()` is for, which
is a statement about the artifact rather than a claim about an outcome, and the
answer was then confirmed by building without it.

### The Entity Framework integration page

*Fetching Data - Entity Framework*, ChilliCream Docs, accessed 2026-08-19.
https://chillicream.com/docs/hotchocolate/fetching-data/integrations/entity-framework

Carries a byline - "Last updated on June 30, 2026 by Tobias Tengler" - so
unlike the other two it would pass the Sources rule if the chapter needed to
quote it. It does not: everything it says that the chapter uses was compiled.

### Not used

- **`GreenDonut` as a port of Facebook's DataLoader.** The package description
  says "GreenDonut is a port of facebook's DataLoader utility, written in C#
  for .NET Core and .NET Framework", which is a package description rather than
  a signed statement, and no attempt was made to trace the 2015 original to a
  named engineer. The chapter explains what batching does rather than where the
  pattern came from, so nothing was needed. A later chapter wanting the history
  has to do that sourcing itself.
- **Any timing.** SPEC decision 19. Nothing in this chapter was timed.
