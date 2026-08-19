# Chapter 2 - Hot Chocolate from Zero

Research note for the first chapter that ships code. Web sources accessed
**2026-08-19**; everything else was measured on this machine on the same date.

This chapter is the opposite case to chapter 1. Almost nothing here is an
external claim. The compiler and the wire settled most of it, and where the
published documentation and the machine disagreed, the machine is recorded as
the finding and the documentation as the disagreement.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph`, branches `main` and `hc14`, tags `ch02` and `ch02-hc14` |
| .NET SDK | 10.0.303 |
| .NET runtimes present | `Microsoft.AspNetCore.App` 8.0.30, 9.0.19, 10.0.11 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| Gate | `pwsh verify.ps1`, run on each branch. Both printed PASS on 2026-08-19 |

Every count and every quoted response below is asserted by `verify.ps1`, so the
way to reproduce this note is to check out the tag and run the script. The one
exception is the resolver-call count, which needed instrumentation and is
written up under its own heading.

## How the project was created

Run on 2026-08-19 with SDK 10.0.303, from the repository's `src/` directory.
Recorded because the chapter prints these commands and a reader typing them
has to land on the same project the rest of the chapter describes.

```
dotnet new web -n Sessions
cd Sessions
dotnet add package HotChocolate.AspNetCore
dotnet add package HotChocolate.AspNetCore.CommandLine
dotnet add package HotChocolate.Types.Analyzers
```

`dotnet new web` produced the `Properties/launchSettings.json` the chapter
replaces, with `applicationUrl` set to `http://localhost:5130` and
`launchBrowser` true. The book pins port 5001 and turns the browser launch off,
so that every printed request has one address and running the service does not
open a window. The port allocation for the whole book, decided here: Sessions
5001, Speakers 5002, Ratings 5003.

## Packages, and how the versions were fixed

`https://api.nuget.org/v3-flatcontainer/<id>/index.json` was read directly for
each package rather than trusting a docs page.

- `HotChocolate.AspNetCore` latest stable **16.6.1**, published 2026-08-15.
  `16.6.2-p.1` exists and is a prerelease.
- `HotChocolate.ApolloFederation` is on the identical version sequence, so the
  family moves in lockstep. Nothing in this chapter uses it; recorded because
  SPEC decision 6 rests on the two shipping together.
- `HotChocolate.AspNetCore.CommandLine` and `HotChocolate.Types.Analyzers` both
  exist under those exact ids and both are at 16.6.1.
- **14.3.1 is the last stable 14.x.** There is no 14.3.2 and no stable 14.4.0;
  14.4.0 shipped only as `-p.1` through `-p.10`. This confirms the version SPEC
  decision 10 assumed.
- 14.3.1 was published **2026-04-10**, more than a year after 14.3.0
  (2024-12-16) and after the whole 15.x line. It is a late backport patch
  released weeks before 16.0.0, not a routine patch in the 14 cadence. Worth
  knowing before treating "the last 14" as "the end of 14's active life".

Target frameworks, read out of each nuspec:

- `HotChocolate.AspNetCore` 16.6.1 targets **net8.0, net9.0, net10.0 and
  net11.0**. A reader on .NET 8 can move to Hot Chocolate 16 without changing
  framework, which is the single most useful thing the chapter's callout can
  tell them.
- `HotChocolate.AspNetCore` 14.3.1 targets net6.0, net7.0, net8.0, net9.0 and
  **not** net10.0. This is why `hc14` is on `net8.0` and it is the reason SPEC
  decision 10 gives, confirmed.

**Correction to the SPEC version baseline.** That table says HotChocolate 16.6.0
and marks it "to verify; a newer 16.x is likely". The verified figure is 16.6.1.
It also implies 16's ceiling is .NET 10; net11.0 is in the package.

## The first service, as the machine accepted it

The chapter's service is `src/Sessions` at tag `ch02`. Seven files, all printed
in the chapter in full.

### `AddTypes()` is not the call, and this cost the most time

The get-started documentation says the template "calls a source-generated
`AddTypes` method that registers all types decorated with attributes like
`[QueryType]` in the current assembly"
(https://chillicream.com/docs/hotchocolate/get-started-with-graphql-in-net-core,
accessed 2026-08-19). Written literally into a project named `Sessions`, that
does not compile:

```
error CS0121: The call is ambiguous between the following methods or
properties: 'SchemaRequestExecutorBuilderExtensions.AddTypes(
IRequestExecutorBuilder, params System.Type[])' and
'SchemaRequestExecutorBuilderExtensions.AddTypes(IRequestExecutorBuilder,
params HotChocolate.Types.ITypeDefinition[])'
```

The generator does not emit `AddTypes`. It emits a method named after the
assembly. Read out of the generated file itself, obtained with
`dotnet build -p:EmitCompilerGeneratedFiles=true -p:CompilerGeneratedFilesOutputPath=../gen`.

**Two generators write into that directory**, which is why the chapter does not
say "one file appears": Hot Chocolate's output lands under
`HotChocolate.Types.Analyzers/`, and the ASP.NET Core SDK's own
`PublicProgramSourceGenerator` writes `PublicTopLevelProgram.Generated.g.cs`
alongside it.

The Hot Chocolate file **at the hello-world state of section 1**, complete
below its header of `// <auto-generated/>`, `#nullable enable`,
`#pragma warning disable` and five `using` directives. This is the version the
chapter prints, and it is the version that exists at that point in the chapter:

```csharp
namespace Microsoft.Extensions.DependencyInjection
{
    public static partial class SessionsTypesRequestExecutorBuilderExtensions
    {
        public static IRequestExecutorBuilder AddSessionsTypes(this IRequestExecutorBuilder builder)
        {
            builder.AddTypeExtension(typeof(global::Sessions.Query));
            builder.ConfigureSchema(
                b => b.TryAddRootType(
                    () => new global::HotChocolate.Types.ObjectType(
                        d => d.Name(global::HotChocolate.Types.OperationTypeNames.Query)),
                    HotChocolate.Language.OperationType.Query));
            return builder;
        }
    }
}
```

The chapter wraps that signature and drops the `global::` prefixes on Hot
Chocolate's own type names to fit the measure, and says so in the sentence
above the listing.

**The same file at tag `ch02`**, once `SessionType` exists, which is what the
chapter's claim in section 3 rests on. Two statements are added and no
existing one changes, and the generator also begins emitting a second file,
`SessionType.<hash>.hc.g.cs`:

```csharp
            builder.AddTypeExtension(typeof(global::Sessions.Query));
            builder.ConfigureDescriptorContext(ctx => ctx.TypeConfiguration.TryAdd<global::Sessions.Session>(
                "Sessions::Sessions.SessionType",
                () => global::Sessions.SessionType.Initialize));
            builder.ConfigureSchema(...unchanged...);
            builder.AddType<ObjectType<global::Sessions.Session>>();
```

So the attributed types the generator found went from `Query` alone to `Query`
and `SessionType`. `Session` and `Speaker` carry no attribute and are reached
through the resolvers' signatures.

So the call is `AddSessionsTypes()` in a project called `Sessions`, and it is
a different identifier in every project. The documentation's `AddTypes()` reads
as a fixed API name and is not one. **The chapter must show the generated name
and say where it comes from**, or every reader whose project is not called what
ours is will hit CS0121 on their first build.

One trap discovered while finding this out: `CompilerGeneratedFilesOutputPath`
pointing inside the project directory makes the next build fail with CS0111,
because the emitted file is then compiled alongside the generator's own output.
Emit to a path outside the project, or delete it afterwards. `gen/` is in the
repo's `.gitignore` for this reason.

### `builder.AddGraphQL()`, not `builder.Services.AddGraphQLServer()`

Both compile on 16.6.1 and both compile on 14.3.1; this was tried each way. The
project template and the get-started page use `builder.AddGraphQL()`, and the
command-line documentation page uses `builder.AddGraphQL().AddQueryType<Query>()`
in the older imperative style, so ChilliCream's own pages are not consistent
about which idiom to teach. The chapter uses `builder.AddGraphQL()` with the
generated `AddSessionsTypes()`, which is the template's shape and compiles on
both versions covered.

### A `[QueryType]` class does not have to be `partial` at 16.6.1

The get-started page says "The class must be `partial`". The book's `Query.cs`
declares `public static class Query`, with no `partial`, and it compiles, the
generator picks it up, and the field appears in the schema. Tried on 16.6.1 and
on 14.3.1, and neither rejected it. Recorded as a disagreement between the
documentation and the compiler rather than resolved: the documented requirement
may be true of some other generator feature this chapter does not use, and the
chapter simply does not make a claim either way.

### The generated schema

Exported with `dotnet run -- schema export --output schema.graphql`, which is
what `RunWithGraphQLCommands(args)` in `Program.cs` makes available. It writes
two files: `schema.graphql`, and a `schema-settings.json` the book does not use
(a Nitro workspace file that records whatever URL the export run bound, which is
`http://localhost:5000/graphql` and not the port `launchSettings.json` pins).
`schema-settings.json` is gitignored.

The exported schema at tag `ch02`, in full, is
`src/Sessions/schema.graphql` in the verification repo. The facts the chapter
takes from it, each asserted by `verify.ps1`:

| Fact | Evidence |
|------|----------|
| `GetSessions()` becomes `sessions` | the `Get` prefix is dropped |
| `GetSessionById(int id)` becomes `sessionById(id: Int!)` | argument name and type carried over |
| `string Title` becomes `title: String!` | non-nullable reference type becomes non-null |
| `string? Abstract` becomes `abstract: String` | nullable reference type becomes nullable |
| `DateTimeOffset StartsAt` becomes `startsAt: DateTime!` | a custom scalar, not a built-in |
| `Session.speaker` is listed **first**, before the record's own members | the type extension's field precedes the runtime type's |
| every field carries `@cost(weight: "10")` | cost analysis is on with no configuration |
| `speakerId` does not appear | `[property: GraphQLIgnore]` on the positional record parameter |
| every field has a description | `<summary>` and `<param>` XML comments, once `GenerateDocumentationFile` is on |

The `<param>` result is worth recording because it is not obvious: on a
positional record, `<param name="Id">Stable identifier...</param>` on the
record's own doc comment becomes the GraphQL field description. Without
`<GenerateDocumentationFile>true</GenerateDocumentationFile>` in the csproj, no
description reaches the schema at all - measured both ways.

`@cost` is **not** a 16-only feature. The 14.3.1 export carries the same
`@cost(weight: "10")` on the same fields. Checked because it looked like a v16
addition and it is not.

## On the wire

All captured with `curl -s -i` against `http://localhost:5001/graphql` on
2026-08-19, tag `ch02`.

A valid request:

```
POST /graphql
Content-Type: application/json

{"query":"{ sessions { title speaker { name } } }"}
```

answers

```
HTTP/1.1 200 OK
Content-Type: application/graphql-response+json; charset=utf-8
```

The media type is `application/graphql-response+json`, not `application/json`.

A request naming a field that does not exist:

```
{"query":"{ sessions { titel } }"}
```

answers **HTTP 400 Bad Request**, with a body carrying `errors` and **no `data`
key at all**:

```json
{"errors":[{"message":"The field `titel` does not exist on the type `Session`.",
"locations":[{"line":1,"column":14}],"extensions":{"type":"Session",
"field":"titel","responseName":"titel",
"specifiedBy":"https://spec.graphql.org/September2025/#sec-Field-Selections"}}]}
```

The `specifiedBy` extension names the specification edition the server
validates against: **September2025** on 16.6.1. On 14.3.1 the same request
returns `https://spec.graphql.org/October2021/#sec-Field-Selections-on-Objects-Interfaces-and-Unions-Types`,
and additionally carries a `"path":["sessions"]` member that 16 does not.

Asking for a session that is not there is not an error:

```
{"query":"{ sessionById(id: 99) { title } }"}
```

answers `HTTP 200` with `{"data":{"sessionById":null}}`, because the schema
declares `sessionById: Session` and not `Session!`.

## How many times the speaker resolver runs

The one measurement in this note that `verify.ps1` does not assert, because
making it would mean shipping the instrumentation in the book's own listing.

Procedure, reproducible on tag `ch02`:

1. Add `Console.WriteLine($"RESOLVER speaker session={session.Id}");` as the
   first statement of `SessionType.GetSpeaker`.
2. `dotnet build && dotnet run --no-build`.
3. Send `{ sessions { title speaker { name } } }` once.
4. Count the `RESOLVER speaker` lines on standard output.
5. Send `{ sessions { titel } }` once and count again.

Result on 2026-08-19: **4 lines for the valid request**, one per session, in
session id order 1, 2, 3, 4; **0 lines for the invalid request**. Four sessions
are in `ConferenceData`, so the resolver runs once per parent object and the
rejected request runs no resolver at all.

The instrumentation was reverted immediately and is not in the tag. This count
carries figure 2's lane B and nothing else in the chapter; the chapter does not
print the number 4 as a claim about resolver calls, because a reader who typed
the code out of the book would have to add the same line to see it, and
chapter 3 is where that instrumentation becomes the reader's own.

## What happens when the attribute is missing

Two different failures, checked separately on a scratch worktree of tag `ch02`
because the chapter states both and neither was obvious.

**Case one, a second class with no attribute.** Added `SpeakerQuery`, a static
class with a `GetSpeakers()` method and no `[QueryType]`, while `Query` kept
its attribute. Result: the build passes with no warning, the service starts,
the existing fields answer, and `speakers` is **absent from the exported
schema**. Nothing is logged. This is the silent case.

**Case two, the only class with an attribute loses it.** Removed `[QueryType]`
from `Query` with no other root class present. Result: the build still passes,
and the failure comes at schema construction:

```
HotChocolate.SchemaException: The schema builder was unable to identify the
query type of the schema. Either specify which type is the query type or set
the schema builder to non-strict validation mode.
```

**When the loud one fires, checked because the chapter says "startup".** Running
the app rather than the exporter, the process does not get as far as listening:

```
fail: Microsoft.Extensions.Hosting.Internal.Host[11]
      Hosting failed to start
      HotChocolate.SchemaException: For more details look at the `Errors` property.
   at HotChocolate.AspNetCore.Warmup.RequestExecutorWarmupService.WarmupAsync(...)
   at HotChocolate.AspNetCore.Warmup.RequestExecutorWarmupService.StartAsync(...)
   at Microsoft.Extensions.Hosting.Internal.Host.StartAsync(...)
```

`RequestExecutorWarmupService` is a hosted service, so the schema is built
during host start and the process exits before it accepts a request. The
chapter is entitled to say startup, and to say that the schema a request is
validated against was built at startup. This was worth measuring: a reasonable
reading of Hot Chocolate is that the executor is created lazily on first
request, and on 16.6.1 with `MapGraphQL` it is not.

The chapter prints both failures because they are opposites with the same
cause, and only one of them is findable.

## The hello-world request

Also captured on a scratch worktree of tag `ch02`, reduced to `Program.cs`,
`Query.cs`, the csproj and the launch profile, with `Query` returning a single
`Hello()` string. It is a state the repository does not keep a tag for, since
it exists only inside the chapter's first section.

The CS0121 message the chapter prints came from that build and is quoted with
its `Program.cs(5,6):` prefix and its fully qualified type names as the
compiler emits them. After changing the call to `AddSessionsTypes()`:

```
POST /graphql, {"query":"{ hello }"}
HTTP/1.1 200 OK
Content-Type: application/graphql-response+json; charset=utf-8
{"data":{"hello":"world"}}
```

## The listing column budget: 73

Measured rather than estimated, because a listing wider than the measure wraps
with a continuation arrow and the build log says nothing about it.

Procedure: a `minted:text` listing of lines 70 to 76 columns wide, each ending
in a digit run with no break point, placed in a chapter file, built with the
book's own geometry and `\setminted` settings, and read off the page.

Result on 2026-08-19: **73 columns fit and 74 wraps.** Every C# file the
chapter prints was rewrapped to 73 or under, and the two blocks that cannot be
(the project file, whose package identifiers are fixed, and the exported
schema, whose directive descriptions are the vendor's) declare
`fontsize=\footnotesize` of their own. The compiler error listing additionally
declares `breakanywhere`, because a fully qualified .NET type name offers no
break point at all and `breaklines` cannot help it.

This number belongs in `check-chapter.psd1` as `Listings.MaxLineLength`; see
the chapter's retro.

## Nitro, and where the IDE actually comes from

The GraphQL endpoint answers a browser with the Nitro IDE. Where that HTML is
fetched from is a default, and the default reaches the internet.

Measured, same URL, same build, only `Program.cs` differing:

Both responses are `HTTP/1.1 200 OK` with `Content-Type: text/html`, and the
chapter prints those two lines with the two below:

| `Tool.ServeMode` | `Server:` header | `Last-Modified:` |
|------------------|------------------|------------------|
| default (`ServeMode.Latest`) | `cloudflare` | Thu, 13 Aug 2026 10:13:03 GMT |
| `ServeMode.Embedded` | `Kestrel` | Tue, 09 Jun 2026 09:05:20 GMT |

The default's response also carries `cf-ray`, `cf-cache-status: DYNAMIC`,
`Access-Control-Allow-Origin: *` and a `Content-MD5`, none of which the chapter
prints. The embedded response instead carries `Content-Length: 1033`,
`Accept-Ranges: bytes` and an `ETag`.

A localhost endpoint cannot produce a `Server: cloudflare` header and a
`cf-ray` on its own, so under the default the app is fetching the IDE over the
internet and passing it through. Corroborating evidence, all from the build
output at tag `ch02`:

- `ChilliCream.Nitro.App.dll` ships in the output folder and is 17,884,160
  bytes, which is the IDE itself, so the `Embedded` copy is genuinely local.
- The assembly contains the host `https://get-nitro.chillicream.com`, which
  resolves and is itself behind Cloudflare (301 to
  `https://chillicream.com/products/nitro`, `Server: cloudflare`).
- It also contains a type named `NitroAppCdnMiddleware`.
- Reflecting on `ChilliCream.Nitro.App.ServeMode` at runtime gives exactly
  `Latest`, `Insider`, `Embedded` and a `Version(string)` factory.
- The embedded response's `Last-Modified` matches the assembly's own file date
  of 9 June 2026, and the default response's is 13 August 2026, later than the
  build.

The book pins `ServeMode.Embedded`, so what a reader sees matches the package
they installed.

**Checked and not settled.** Whether the default fails with no internet access
was *not* established. Setting `HTTP_PROXY` and `HTTPS_PROXY` to a dead port
did not change the behaviour - the response still came back with Cloudflare
headers - which means .NET did not honour those variables on this machine
rather than that the fetch is offline-capable. The chapter therefore says the
IDE is fetched over the internet, which is directly observed, and says nothing
about what happens when there is none.

Also present on `NitroAppOptions`: `GaTrackingId` and `DisableTelemetry`. Both
default to null. Nothing was measured about what the IDE sends, and the chapter
makes no claim about it.

## The 14 to 16 difference, as the compiler reported it

`hc14` is the same seven files with a different csproj. Building the `main`
source against 14.3.1 produced exactly two errors, in one file:

```
error CS1660: Cannot convert lambda expression to type 'GraphQLServerOptions'
because it is not a delegate type
error CS0122: 'ServeMode' is inaccessible due to its protection level
```

so the whole difference a chapter-2 reader meets is:

| | 16.6.1 | 14.3.1 |
|---|---|---|
| `WithOptions` takes | `Action<GraphQLServerOptions>` | a `GraphQLServerOptions` |
| serve mode type | `ChilliCream.Nitro.App.ServeMode` | `HotChocolate.AspNetCore.GraphQLToolServeMode` |
| target framework | `net10.0` | `net8.0` (14 does not target net10.0) |

Everything else compiled unchanged: `[QueryType]`, the generated
`AddSessionsTypes()`, `[ObjectType<Session>]`, `[Parent]`,
`[property: GraphQLIgnore]`, `builder.AddGraphQL()`, `MapGraphQL()` and
`RunWithGraphQLCommands(args)`. The generated schema is identical for the
`Query`, `Session` and `Speaker` types, down to field order.

`Program.cs` at tag `ch02-hc14`, which is the listing the callout prints and
the only file that differs between the branches:

```csharp
using HotChocolate.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

builder
    .AddGraphQL()
    .AddSessionsTypes();

var app = builder.Build();

app.MapGraphQL()
    .WithOptions(new GraphQLServerOptions
    {
        Tool = { ServeMode = GraphQLToolServeMode.Embedded }
    });

app.RunWithGraphQLCommands(args);
```

`verify.ps1` builds and exercises this branch, so decision 11's rule that a
callout may only say what the branch compiled is enforced by a run rather than
by memory.

Where the two exports differ:

| | 16.6.1 | 14.3.1 |
|---|---|---|
| byte order mark on `schema.graphql` | none | `EF BB BF` |
| `DateTime` description | "represents a date and time with time zone offset information" | "represents an ISO-8601 compliant date time type" |
| `DateTime` `@specifiedBy` | `https://scalars.graphql.org/chillicream/date-time.html` | `https:\/\/www.graphql-scalars.com\/date-time` (escaped in the output as shown) |
| `@specifiedBy` directive definition | not emitted | emitted |
| directive definitions | printed across several lines | printed on one line |

All five are asserted or covered by `verify.ps1` on the branch that produces
them, except the last two, which are formatting and are visible in the two
committed `schema.graphql` files.

## External sources

Only three carry anything the chapter prints.

### The Nitro rename

Rafael Staib, *Introducing Nitro*, ChilliCream blog, 7 October 2024.
https://chillicream.com/blog/2024-10-07-introducing-nitro

Named ChilliCream engineer on ChilliCream's own blog describing ChilliCream's
own product. **Passes the SPEC's Sources rule**, and the prose names him.

> By renaming Banana Cake Pop and Barista to Nitro, we're simplifying our
> ecosystem and making it easier for developers to navigate and interact with
> our suite of products.

Corroborated independently by the 13-to-14 migration guide, which carries a
section headed "Banana Cake Pop and Barista renamed to Nitro", placing the
rename at the 13-to-14 boundary.

### The Hot Chocolate 16 release

Michael Staib, *Hot Chocolate 16*, ChilliCream blog, 11 May 2026.
https://chillicream.com/blog/2026-05-11-hot-chocolate-16

Byline confirmed in the page's own metadata (`<meta name="author"
content="Michael Staib">` and matching JSON-LD). **Passes**, and the prose
names him.

> Hot Chocolate 16 brings a new type system, better scalar contracts, safer
> defaults, improved batching, semantic introspection, and a new GraphQL error
> mode.

**Claim checked and found false.** The phrase "execution engine" does not
appear anywhere on that page. Version 16 is announced as a new **type system**,
with the batching engine reworked separately. Anything describing 16 as a new
execution engine is not sourced from ChilliCream and must not be written.

### The get-started documentation

*Get started with GraphQL in .NET Core*, ChilliCream Docs, accessed
2026-08-19.
https://chillicream.com/docs/hotchocolate/get-started-with-graphql-in-net-core

Unsigned vendor documentation. Used the way chapter 1's note uses the Apollo
subgraph specification: as the artifact rather than as a claim about an
outcome, and only where the compiler agreed with it. The two places it did not
agree - `AddTypes()` and the `partial` requirement - are recorded above as
disagreements, and the chapter follows the compiler.

**A trap for anyone re-checking this.** `chillicream.com/docs/hotchocolate/v14/...`
and `.../v16/...` both redirect to one unversioned current page. A `/v14/` URL
does not show v14-era documentation. Real historical content comes from
git tags on `github.com/ChilliCream/graphql-platform`, under `templates/server/`.
`web.archive.org` has no snapshots of these docs pages at all, so the fallback
chapter 1 used is not available here.

## Not used, and why

- **`dotnet new install HotChocolate.Templates` and `dotnet new graphql`.** This
  is what the get-started page teaches, and the chapter does not use it. A
  template writes files the book would then have to show anyway, and SPEC
  decision 15 requires the reader to be able to type the whole system out of
  the page. The chapter starts from `dotnet new web`, which produces a project
  small enough to print in full.
- **`RunWithGraphQLCommandsAsync`.** The command-line documentation page uses
  the async overload with `return await`; the project template uses the
  synchronous `RunWithGraphQLCommands(args)`. Both exist. The book uses the
  synchronous one, matching the template, and does not discuss the choice.
- **`AddApplicationService<T>()`.** The 15-to-16 migration guide records that
  application services must now be cross-registered into the schema service
  provider. Nothing in this chapter injects a service into anything, so the
  change is invisible here. It will matter in chapter 3.
- **Any timing.** SPEC decision 19. Nothing in this chapter was timed.
