# HotChocolate 16 for a first service - facts verified 2026-08-08

Source research for chapter 02. Two kinds of fact live here and they are not
equally durable, so each one is tagged:

- **[web]** - verified on 2026-08-08 by fetching a primary source: the NuGet v3
  registration and flat-container APIs, the package nuspecs, the
  `ChilliCream/graphql-platform` repository at tag `16.6.0`, or the v16
  documentation tree in that repository under `website/content/docs/hotchocolate/`.
- **[measured]** - verified on this machine on 2026-08-08 by building, running or
  decompiling the thing itself. These are ours. The book's rules require saying
  so in the prose when a number or behaviour came from our own measurement, and
  these are the facts a reader cannot check by reading a docs page.

Division of labour with the other two research files:

- `2026-08-federation-landscape.md` owns the current-state one-liners: which
  products exist, who ships what, what the gateway market looks like. It is the
  planning file, deliberately shallow.
- `2026-08-ch01-scaling-and-federation-history.md` owns history and case studies.
- **This file owns HotChocolate 16 as an API you actually type**: package
  versions and target frameworks, the shape of the setup code, the authoring
  styles, the defaults that change behaviour on day one, and every number the
  chapter's companion code produces. Where this file and the landscape file
  disagree about a HotChocolate fact, this one wins; corrections owed to the
  landscape file are collected in section L.

Everything in sections A through K is chapter 02 material only. Chapter 03
onward re-verifies against this file rather than against memory.

## A. Package versions and what they target

- **[web]** `HotChocolate.AspNetCore` **16.6.0** was published
  **2026-08-05T11:17:19.85Z**. `HotChocolate.ApolloFederation` 16.6.0 was
  published one second earlier, at **11:17:18.457Z**. The GitHub release tagged
  `16.6.0` is stamped **11:20:48Z** the same day, about three minutes after the
  packages.
  <https://www.nuget.org/packages/HotChocolate.AspNetCore>
  <https://www.nuget.org/packages/HotChocolate.ApolloFederation>
  <https://github.com/ChilliCream/graphql-platform/releases/tag/16.6.0>
  The release notes credit named engineers: michaelstaib, glen-84,
  tobias-tengler, apereiratl. Useful if the chapter wants to say the project has
  more than one maintainer.
- **[web, and confirmed locally against the package cache]** The 16.6.0 nuspec
  declares four target frameworks: **`net8.0`, `net9.0`, `net10.0`, `net11.0`**.
  Read out of `~/.nuget/packages/hotchocolate.aspnetcore/16.6.0/hotchocolate.aspnetcore.nuspec`
  on this machine.
  CORRECTION owed to `2026-08-federation-landscape.md`, which says only "Targets
  .NET 8+". That is true but understates it in the direction that matters: a
  `net11.0` asset already ships in the current stable release, so the package is
  ahead of the runtime most readers have installed, not behind it. Do not write
  "supports .NET 8 through 10".
- **[web]** Hot Chocolate 16, the major version, was **announced 2026-05-11** in
  a post bylined Michael Staib.
  <https://chillicream.com/blog/2026/05/11/hot-chocolate-16/>
  IMPORTANT: 2026-05-11 is the major version's announcement. **2026-08-05 is
  16.6.0's release date.** Three months apart. Do not write "HotChocolate 16.6,
  released in May" - that sentence merges two real dates into a false one.
- **[measured]** The companion repo pins `16.6.0` for all three HotChocolate
  packages through central package management, in one property
  (`$(HotChocolateVersion)` in `Directory.Packages.props`), and runs on SDK
  `10.0.302` pinned in `global.json` with `rollForward: latestFeature`. The
  book's baseline is therefore: **HotChocolate 16.6.0 on .NET 10**.

## B. The template package

- **[measured]** The template package id is **`HotChocolate.Templates`**.
  `dotnet new install HotChocolate.Templates` succeeded on this machine and
  reported `HotChocolate.Templates@16.6.0`. It registers three templates:
  **`graphql`**, **`graphql-gateway`**, **`graphql-azf`**. Re-confirmed with
  `dotnet new uninstall` (which lists what is installed without removing
  anything), output verbatim: `HotChocolate.Templates` / `Version: 16.6.0` /
  `Author: ChilliCream authors and contributors`.
- **IMPORTANT NEGATIVE FINDING [web]:** **`ChilliCream.HotChocolate.Templates`
  does not exist.** That id returns BlobNotFound from the NuGet flat container.
  It is a plausible-looking guess (the org prefix is right for other ChilliCream
  properties) and it is wrong. If the chapter prints an install command, print
  the one above and nothing else.

## C. What `dotnet new graphql` actually emits

All of section C is **[measured]**: the template was installed, a project was
scaffolded from it, and the result was compiled and run.

- The generated `Program.cs`, verbatim and complete:

  ```
  var builder = WebApplication.CreateBuilder(args);

  builder.AddGraphQL().AddTypes();

  var app = builder.Build();

  app.MapGraphQL();

  app.RunWithGraphQLCommands(args);
  ```

  Seven lines of code. This is the honest "hello world" for v16 and it is worth
  printing exactly as-is, because it names no type, no schema and no query root.
- The generated csproj references three packages: `HotChocolate.AspNetCore`,
  `HotChocolate.AspNetCore.CommandLine`, and `HotChocolate.Types.Analyzers`
  (the last as an analyzer, with `PrivateAssets=all`). It targets `net10.0` and
  sets `LangVersion` to `preview`.
  NOTE for the chapter: the companion repo deliberately sets `LangVersion` to
  `latest` rather than `preview`, and moves the framework and language settings
  into `Directory.Build.props`. If the chapter prints the template csproj and
  then Mosaic's csproj, that difference is visible and should be explained
  rather than glossed.
- Root types are declared with `[QueryType]` on a **`public static partial
  class`**. A Roslyn source generator (that is what `HotChocolate.Types.Analyzers`
  is) finds them at compile time and emits the registration method.
- `app.RunWithGraphQLCommands(args)` is what enables
  `dotnet run -- schema export --output <path>`. Verified by running it: it
  writes the SDL to the given path **and a sibling `<name>-settings.json`**.
  That second file is an unannounced side effect; the companion repo deletes it
  rather than committing it. Worth one sentence in the chapter, because a reader
  who runs the command and then `git status` will see it.

## D. The module attribute, and the trap that hides behind it

- **[measured]** `Properties/ModuleInfo.cs` in the template carries
  `[assembly: Module("Types")]`. The attribute is **assembly-scoped, not
  folder-scoped**, and the generated method takes its name from the attribute's
  argument: `Module("Types")` generates `AddTypes()`, `Module("Mosaic")`
  generates `AddMosaic()`, `Module("Catalog")` generates `AddCatalog()`. All
  three were compiled and run.
  This is the single fact that makes the book's folder-per-domain layout work:
  one attribute at the assembly root collects marked types from every folder, so
  adding a domain folder changes nothing central.
- **IMPORTANT NEGATIVE FINDING [measured, from the actual compiler error]:**
  renaming the module without updating `Program.cs` does **not** produce a
  missing-method error, which is what everyone expects. `AddTypes()` still
  resolves - to two `params` overloads on
  `SchemaRequestExecutorBuilderExtensions`, one taking `params Type[]` and one
  taking `params ITypeDefinition[]` - and the zero-argument call is ambiguous
  between them. The compiler says:

  ```
  CS0121: The call is ambiguous between the following methods or properties
  ```

  So the diagnostic for "you renamed your module" is an overload-resolution
  error mentioning types the reader has never heard of. This is a good, cheap,
  concrete example of a generated-code failure mode and belongs in the chapter.

## E. Three entry points with almost the same name

**[web + measured]** All three exist in 16.6.0 and they are not interchangeable.

- `builder.AddGraphQL()` on **`IHostApplicationBuilder`** - the documented v16
  shape, what the template emits. It forwards to `AddGraphQLServer()`.
- `AddGraphQLServer()` - **still present, and NOT marked `[Obsolete]`** in
  16.6.0. It is simply no longer the shape the docs lead with. Every pre-16
  tutorial, every StackOverflow answer, and most of the reader's existing code
  uses it. The chapter should say plainly that it still works, so readers do not
  "fix" working code.
- `services.AddGraphQL()` on **`IServiceCollection`** - exists, and **does not
  apply the ASP.NET Core defaults**. A reader who reaches for it because the
  name matched will get a subtly different server.

Three similarly named entry points with different behaviour is a real hazard for
a first-service chapter. Treat it as content, not trivia.

## F. Authoring styles: there are two named ones, and the old name is retired

- **[web]** The v16 docs have a heading **"Schema Authoring Styles"** naming
  exactly **two**: **implementation-first** and **code-first**.
  Verbatim: "Hot Chocolate offers two C# authoring styles, both of which produce
  GraphQL SDL."
  <https://chillicream.com/docs/hotchocolate/v16/defining-a-schema>
- **[web]** **"Annotation-based" is retired terminology.** The documentation tabs
  are now `<Implementation>` and `<Code>`; the old `<Schema>` tab is gone from
  the tab set entirely.
  CONSEQUENCE FOR THE BOOK: `SPEC.md` currently describes chapter 02 as
  "annotation-based vs code-first vs schema-first". Both halves of that are now
  wrong for v16: the first style has been renamed, and schema-first is no longer
  a documented peer of the other two (section G). The SPEC line needs updating
  as part of drafting; this file does not edit it.
- **[web]** The descriptor API is **unchanged** despite v16's rearchitected type
  system: `ObjectType<T>`, `IObjectTypeDescriptor<T>` and `Configure(...)` are
  all intact. So a code-first listing from a v13 or v14 book still compiles. This
  is reassuring and worth saying, because "rearchitected type system" in the
  release announcement reads as if it broke everything.

## G. Schema-first: supported, shipped, and undocumented

This is the most useful finding in the file, because the true statement is
narrow and every search result gets it wrong in one direction or the other.

- **[web]** There is **no schema-first page anywhere in the v16 docs tree.** The
  whole of `website/content/docs/hotchocolate/` at tag `16.6.0` was enumerated;
  no such page exists. Not moved, not renamed - absent.
- **[measured]** The API nevertheless **ships un-obsoleted in 16.6.0**:
  `AddDocumentFromString`, `AddDocumentFromFile`, `BindRuntimeType<T>(string)`
  and `AddResolver<T>(string)` are all present with no `[Obsolete]` attribute.
  Verified two ways: by reflection over the shipped `HotChocolate.Types.dll`,
  and by compiling and running a working sample
  (`samples/three-approaches/Mosaic.Sample.SchemaFirst`).
- **[web]** It is also under live test in the repository at that tag:
  `Core/test/Types.Tests/SchemaFirstTests.cs`, and
  `Core/test/Execution.Tests/Integration/HelloWorldSchemaFirst/`.
- So the accurate sentence is: **supported and tested, but undocumented in v16.**
  Not deprecated, not removed, and not something to recommend casually either.
- **IMPORTANT NEGATIVE FINDING [web]:** three schema-first APIs that older
  tutorials use are gone or changed in v16:
  - `BindComplexType` is **gone** - zero hits in the repository at tag `16.6.0`.
    `BindRuntimeType` replaces it.
  - `AddSchemaConfiguration` is now **`internal`**.
  - `AddType` overloads take **`ITypeDefinition`**, not `INamedType`.
- **IMPORTANT NEGATIVE FINDING about search results themselves [web]:** dead
  v10-era schema-first documentation from the **retired
  `ChilliCream/hotchocolate-docs` repository ranks highly** in search and is
  wrong for 16.x. A **`develop.chillicream.com` staging host** also surfaces in
  results. Neither may be cited, and a reader following either will write code
  that does not compile. This is a good reason for the chapter to show the
  working v16 wiring: it is genuinely hard to find elsewhere.

## H. Introspection is off by default outside Development

- **[web + measured]** `AddGraphQLServer()` calls `DisableIntrospection(...)`
  gated on `IHostEnvironment.IsDevelopment()`. So **introspection is disabled by
  default in any non-Development environment**, out of the box, with no
  configuration. The error code returned is **`HC0046`**.
- **[measured] It bit us, which is why it is in the chapter.** The companion
  repo's verify script started the service with `--no-launch-profile`. That flag
  skips `launchSettings.json`, which is where `ASPNETCORE_ENVIRONMENT=Development`
  lives, so ASP.NET Core fell back to Production, introspection was off, and the
  Postman collection's introspection request failed with **HTTP 400**. Fixed by
  setting `ASPNETCORE_ENVIRONMENT=Development` explicitly. The same reasoning is
  why `docker-compose.yml` sets that variable and says why in a comment.
  This is a much better teaching example than an abstract warning: the failure is
  a 400 on a request that worked ten minutes earlier, and nothing in the message
  says "environment".
- **IMPORTANT NEGATIVE FINDING - a live documentation bug [web + measured]:** the
  v16 security/introspection page tells the reader to call

  ```
  builder.AddGraphQL().AllowIntrospection(false)
  ```

  **That method does not exist on `IRequestExecutorBuilder` in 16.6.0.**
  `AllowIntrospection` is defined only on `OperationRequestBuilder`, where it is
  a per-request override, not a server setting. The builder-level API is
  `DisableIntrospection(bool)` and
  `DisableIntrospection(Func<IServiceProvider, ValidationOptions, bool>)`.
  **The documented code will not compile.** Verified by attempting it.
  <https://chillicream.com/docs/hotchocolate/v16/security/introspection>
  Print the working call, and consider saying that the docs are wrong here -
  it is checkable, it is current, and it is exactly the kind of thing that costs
  a reader an afternoon.
- **[web]** **Nitro** (the IDE, formerly Banana Cake Pop, renamed 2024-10-07) is
  still served at the GraphQL endpoint by default when a browser hits it, and
  appending **`?sdl`** to the endpoint downloads the schema. "Banana Cake Pop"
  appears nowhere in the current documentation, so do not use the old name even
  parenthetically except when explaining the rename.
  **[measured]** `curl -s http://localhost:5101/graphql?sdl` returns the SDL, and
  the companion repo uses exactly that to cross-check the three sample services
  against each other without going through the exporter.

## I. Other v16 defaults a first service walks into

All **[web]**, cross-checked against the migration guide and the behaviour of
the running companion service.

- **Eager schema initialization is now the default.** Schema errors fail at
  **startup**, not on the first request. Two consequences for the chapter:
  `InitializeOnStartup()` should be **deleted** from any carried-over code, and
  the opt-out is `ModifyOptions(o => o.LazyInitialization = true)`.
  **[measured]** This is also why `docker-compose.yml` needs a `start_period` on
  its healthcheck: schema building happens before `/health` answers.
- **Request batching is disabled by default**, as a security measure.
  `MaxBatchSize` defaults to **1024**.
- **Schema-level components need cross-registration.** Error filters, diagnostic
  listeners and HTTP request interceptors have to be registered with
  `AddApplicationService<T>()`. A component that silently never fires is the
  failure mode.
- **Twelve new Error-severity analyzers, `HC0092` through `HC0106`.** Error
  severity means they break the build, not warn. Relevant to a chapter whose
  companion repo compiles with `TreatWarningsAsErrors`.

## J. What we measured ourselves: schema shape

Everything in sections J and K is **[measured]** in the companion repo. The
chapter must attribute these as our own observations, not as documented
behaviour, because none of them is stated in the docs.

- **Multiple `[ObjectType<T>]` classes in one assembly all contribute fields to
  the same GraphQL type.** Confirmed first with a throwaway spike, then in
  production use across five domain folders (`Pricing`, `Inventory`, `Reviews`,
  `Ordering` and `Accounts` all hang fields on Catalog's `Product`). This is the
  mechanism the whole book depends on: `Product` is a Catalog record, but
  `Product.price` lives in `Pricing/Types/ProductPricingNode.cs` and
  `Product.reviews` in `Reviews/Types/ProductReviewsNode.cs`.
- **Field order in the exported SDL: extension-declared fields come BEFORE the
  runtime type's own inferred properties.** Visible in `schema/mosaic.graphql`:
  `Product` lists `id`, `availableQuantity`, `price`, `reviews`, `averageRating`
  and only then `sku`, `title`, `description`, `category`. Not documented
  anywhere; it matters because the chapter prints that SDL and a reader will
  wonder why the ordering looks arbitrary.
- **Scalar mapping, all read off the generated SDL:**
  - `Guid` maps to a **`UUID`** scalar - **unless** the member carries `[ID]`,
    which produces **`ID!`**. This is why `ProductNode` exists at all: a
    fifteen-line class whose entire job is to restate `Product.Id` as an `ID`.
  - `DateTimeOffset` maps to the **`DateTime`** scalar (note the name mismatch),
    `@specifiedBy` `https://scalars.graphql.org/chillicream/date-time.html`.
  - `decimal` maps to **`Decimal`**,
    `@specifiedBy` `https://scalars.graphql.org/chillicream/decimal.html`.
- **HotChocolate strips both the `Get` prefix and the `Async` suffix.**
  `GetPriceAsync` produces the field **`price`**. Two transformations, not one;
  a reader who knows about `Get` will still be surprised by `Async`.
- **`GraphQLIgnoreAttribute`'s `AttributeTargets` value is 448**
  (`Field | Property | Method`), which **excludes `Parameter`**. Consequence: on
  a positional record you must write **`[property: GraphQLIgnore]`**; a bare
  `[GraphQLIgnore]` on a positional parameter is **CS0592**. Cheap to state,
  saves a confusing five minutes.

## K. What we measured ourselves: runtime behaviour and numbers

- **[measured 2026-08-08] Latency of the catalog-with-reviews query.** Mean
  **3.0 ms** over ten runs (min 2.7, max 3.5), against a warmed-up service. To
  reproduce: build Release, start
  `src/Mosaic.Api/bin/Release/net10.0/Mosaic.Api.dll` with
  `ASPNETCORE_URLS=http://localhost:5100` and
  `ASPNETCORE_ENVIRONMENT=Development`, POST
  `{ products { title reviews { rating author { displayName } } } }` three times
  to warm up, then time ten more with a stopwatch around each call. Machine:
  the author's Windows 11 development box, so the absolute number is worth
  nothing on its own; what matters for the chapter is that 146 in-memory list
  scans cost single-digit milliseconds, which is why the shape survives review.
  Chapter 02 quotes this with explicit "I timed" framing, per the SPEC rule on
  numbers we measured ourselves.
  CORRECTION: an earlier draft of chapter 02 said "about eleven milliseconds".
  That number was never measured and has been replaced with this one.
- **Resolver DI scoping, and the bug it caused.** **HotChocolate resolves each
  resolver's injected services from its own DI scope.** A counter registered as
  scoped is therefore constructed afresh for every resolver invocation, sees
  exactly one lookup, and can never report a request's total. Our first attempt
  logged **`1`, one hundred and forty-six times**. The fix is that request-level
  state has to hang off `HttpContext`: `ServiceCallCounter` reads a
  `RequestLookupCount` out of `context.Items`, and middleware
  (`ServiceCallCountingExtensions`) puts it there and logs the total after
  `next()`. **This is worth a full paragraph in the chapter** - it is the kind of
  thing that looks like a broken counter and is actually a correct understanding
  of the execution model.
- **Cost directives distinguish a resolver class from an `AddResolver`
  delegate.** A delegate is **opaque to the cost analyzer**, gets the default
  resolver cost, and its field is exported carrying **`@cost(weight: "10")`**. A
  resolver **class** is compiled by HotChocolate, which can see the method is
  synchronous and takes nothing but field arguments, treats it as a **pure
  resolver**, and emits **no cost directive at all**. **Async resolvers also
  carry `@cost(weight: "10")`.**
  This made two otherwise identical sample schemas **differ by 318 bytes** until
  it was found. Present state, verified today: all three
  `schema/samples/*.graphql` files are **byte-identical**, 13 lines, 147 bytes,
  SHA-256 `e2a5377037...`. The same effect is visible at scale in
  `schema/mosaic.graphql`, where every async resolver field carries
  `@cost(weight: "10")` and the plain record properties do not.
- **Error shapes, captured from the running service.**
  - **Unknown field:** HTTP **400**. `extensions` carries `type`, `field`,
    `responseName` and `specifiedBy` pointing at
    `https://spec.graphql.org/September2025/#sec-Field-Selections`. There is
    **no `code`** in extensions, and **no `data` key at all** in the response.
  - **Syntax error:** HTTP **400**, with `extensions.code` = **`HC0011`**.
  Two validation failures, two different extension shapes. A client that assumes
  `extensions.code` is always present is wrong on the first one.
- **Seeded data, counted from the source at tag `ch02`:** **25 products**
  (`InMemoryCatalogData`), **120 reviews** (`InMemoryReviewsData`, spread
  unevenly - three products have none, which is why `averageRating` is
  nullable), **12 customers** (`InMemoryAccountsData`), **8 orders**
  (`InMemoryOrderingData`).
- **The chapter's headline number.** The query

  ```
  { products { title reviews { rating author { displayName } } } }
  ```

  costs **146 domain-service lookups**: 1 for the product list, 25 for the
  per-product reviews, 120 for the per-review authors. 1 + 25 + 120 = 146.
  **How to reproduce, two ways:**
  1. `pwsh scripts/verify.ps1` in the companion repo. It asserts the number:
     `$ExpectedProductCount = 25`, `$ExpectedReviewCount = 120`,
     `$ExpectedLookupCount = 146`, and fails the run if the log line disagrees.
  2. Run the service and read the log line, which reads verbatim:
     `Service lookups this request: 146`.
  If this number ever changes, the prose is wrong, not the code - that is the
  explicit contract written into the verify script's comments.
- **Container facts.**
  - `mcr.microsoft.com/dotnet/aspnet:10.0` is **Ubuntu noble**.
  - **.NET 10 ships NO Debian tag.** The available families are `10.0-noble`,
    `-noble-chiseled`, `-alpine*`, `-azurelinux3.0*` and `-resolute*`; the only
    `trixie` tag is a preview. Anyone carrying a `-bookworm` habit over from
    .NET 8 will not find an equivalent.
  - The non-chiseled image contains **neither `curl` nor `wget`** - only `bash`.
    A container healthcheck that shells out to an HTTP client therefore needs one
    installed; the companion `Dockerfile` does `apt-get install curl` and says
    why. Chiseled would remove the shell too, which is why it is not used here.
  - **Image size 388MB, base 349MB.** So Mosaic itself adds roughly 39MB on top
    of the runtime image.
  - **Startup to healthy: about 5 seconds.**

## L. Corrections owed to the other research files

Recorded here rather than applied, because other agents are editing those files
concurrently and this file's brief is to touch nothing else.

- `2026-08-federation-landscape.md`, "Targets .NET 8+": true but understated.
  The 16.6.0 nuspec ships `net8.0`, `net9.0`, `net10.0` **and `net11.0`**. See
  section A.
- `SPEC.md`, chapter 02 line: "annotation-based vs code-first vs schema-first".
  v16 names two styles, **implementation-first** and **code-first**, and
  "annotation-based" is retired terminology. Schema-first is supported but has
  no page in the v16 docs. See sections F and G. The chapter can still cover
  three approaches - the companion repo builds all three - but it has to name
  them the way v16 names them and be explicit that the third is undocumented.
- Companion repo erratum, found while building the provenance table below:
  `src/Mosaic.Api/Properties/ModuleInfo.cs` has a comment saying the generator
  emits **`AddMosaicTypes()`**. It does not; it emits **`AddMosaic()`**, which is
  what `Program.cs` on the next line actually calls. The sample project's
  equivalent comment is correct. Fix the comment before printing that file as a
  listing, or the listing contradicts itself on the page.

## M. Listing provenance

Every listing chapter 02 might print, mapped to its source. All paths are
relative to `F:\repo\mosaic-graph` at tag **`ch02`** (commit `0826d96`, dated
2026-08-08). Line counts were taken today; they are there so the chapter can
judge what fits on a page. Rule of thumb used below: **up to about 40 lines
prints whole**, beyond that plan an excerpt.

| # | Path | Lines | What the listing shows | Page fit |
|---|------|-------|------------------------|----------|
| 1 | *(not in repo)* generated by `dotnet new graphql` | 7 | The template's whole `Program.cs`. Quoted verbatim in section C; regenerate to re-verify. | whole |
| 2 | *(not in repo)* generated csproj | 16 | Three package references, `net10.0`, `LangVersion preview`. | whole |
| 3 | `src/Mosaic.Api/Program.cs` | 34 | Mosaic's composition root: six domain registrations, `builder.AddGraphQL().AddMosaic()`, counting middleware, `RunWithGraphQLCommands`. | whole |
| 4 | `src/Mosaic.Api/Properties/ModuleInfo.cs` | 6 | `[assembly: Module("Mosaic")]` and why it is assembly-scoped. NOTE the comment erratum in section L. | whole |
| 5 | `src/Mosaic.Api/Mosaic.Api.csproj` | 16 | The analyzer reference with `PrivateAssets=all`; everything else inherited. | whole |
| 6 | `Directory.Packages.props` | 20 | Central package management, one pinned `$(HotChocolateVersion)`. | whole |
| 7 | `Directory.Build.props` | 17 | `net10.0`, nullable, implicit usings, `TreatWarningsAsErrors`. | whole |
| 8 | `global.json` | 6 | SDK `10.0.302`, `rollForward: latestFeature`. | whole |
| 9 | `src/Mosaic.Api/Catalog/Model/Product.cs` | 14 | A positional record as the domain model; comment states which fields other domains contribute. | whole |
| 10 | `src/Mosaic.Api/Catalog/Data/CatalogService.cs` | 34 | Three single-key lookups, no batch overload, each calling `counter.RecordLookupAsync`. The source of the 146. | whole |
| 11 | `src/Mosaic.Api/Catalog/Types/CatalogQueries.cs` | 31 | `[QueryType]` on a static partial class; `Get` prefix stripping; `[ID] Guid` argument. | whole |
| 12 | `src/Mosaic.Api/Catalog/Types/ProductNode.cs` | 15 | `[ObjectType<Product>]`; `[ID]` forcing `ID!` instead of `UUID`; `[Parent]`. | whole |
| 13 | `src/Mosaic.Api/Pricing/Types/ProductPricingNode.cs` | 29 | A **second** `[ObjectType<Product>]` in a different folder adding `price`. The book's central mechanism. | whole |
| 14 | `src/Mosaic.Api/Infrastructure/ServiceCallCounter.cs` | 39 | The per-resolver-scope finding, with the reasoning in the doc comment. | whole |
| 15 | `src/Mosaic.Api/Infrastructure/RequestLookupCount.cs` | 16 | `Interlocked.Increment`; resolvers run concurrently. | whole |
| 16 | `src/Mosaic.Api/Infrastructure/ServiceCallCountingExtensions.cs` | 26 | Middleware that attaches the counter to `HttpContext.Items` and logs the total. | whole |
| 17 | `src/Mosaic.Api/Infrastructure/MosaicDataOptions.cs` | 14 | `LookupDelay`, defaulting to zero - why the naive lookups feel free. | whole |
| 18 | `samples/three-approaches/Mosaic.Sample.ImplementationFirst/Program.cs` | 11 | Names no type; `AddCatalog()` came from the module attribute. | whole |
| 19 | `samples/three-approaches/Mosaic.Sample.ImplementationFirst/CatalogTypes.cs` | 23 | Both marked classes for the implementation-first sample. | whole |
| 20 | `samples/three-approaches/Mosaic.Sample.CodeFirst/Program.cs` | 15 | `AddQueryType<QueryType>().AddType<ProductType>()` - nothing is discovered. | whole |
| 21 | `samples/three-approaches/Mosaic.Sample.CodeFirst/CatalogTypes.cs` | 41 | `ObjectType<T>` + `Configure(IObjectTypeDescriptor<T>)`, every field spelled out. | borderline; consider splitting `QueryType` from `ProductType` |
| 22 | `samples/three-approaches/Mosaic.Sample.SchemaFirst/Program.cs` | 31 | SDL raw string literal, `AddDocumentFromString`, `BindRuntimeType<T>`, `AddResolver<T>`. The undocumented v16 wiring. | whole |
| 23 | `samples/three-approaches/Mosaic.Sample.SchemaFirst/QueryResolvers.cs` | 18 | Resolver class; the doc comment carries the pure-resolver/cost-directive reasoning. | whole |
| 24 | `schema/samples/*.graphql` (all three) | 13 each, 147 bytes each | The payoff: three authoring styles, byte-identical SDL. Print once, not three times. | whole |
| 25 | `schema/mosaic.graphql` | 84 (2094 bytes) | Mosaic's full schema: `@cost` on async resolvers, `DateTime`/`Decimal` scalars, extension-before-inferred field order. | **excerpt** - print `type Product` and `type Query`, not the scalar and directive declarations at the bottom |
| 26 | `docker-compose.yml` | 44 | One service, `ASPNETCORE_ENVIRONMENT=Development` with the introspection reason in a comment, healthcheck `start_period` for eager schema init. | whole, but heavily commented - consider trimming comments for print |
| 27 | `src/Mosaic.Api/Dockerfile` | 56 | Two stages; restore-layer caching from four root files; `apt-get install curl` because the image has neither curl nor wget. | **excerpt** - runtime stage is the interesting half |
| 28 | `src/Mosaic.Api/Properties/launchSettings.json` | 14 | Where `ASPNETCORE_ENVIRONMENT=Development` lives, and therefore what `--no-launch-profile` throws away. | whole |
| 29 | `postman/mosaic.postman_collection.json` | 306 | Do not print. Reference it and show one request's body instead. | reference only |
| 30 | `scripts/verify.ps1` | 646 | Do not print. Quote the four constants (`$VerifyQuery`, 25, 120, 146) from lines 60-75. | reference only |
| 31 | `README.md` | 116 | Not a listing. Source for the lookup-count explanation and the tag table. | reference only |
| 32 | `samples/three-approaches/README.md` | 164 | Not a listing, but the best existing prose on the three styles - mine it, do not copy it. | reference only |

## N. Candidate bib keys

Proposed keys for chapter 02, in chapter 01's naming style (lowercase author or
org + year + short slug, no punctuation). **Another agent is writing the actual
entries; this is the shared plan, not the entries.** Nothing below is in
`refs.bib` yet.

| Source | Key | URL |
|--------|-----|-----|
| Staib, Hot Chocolate 16 announcement, 2026-05-11 | `staib2026hc16` | <https://chillicream.com/blog/2026/05/11/hot-chocolate-16/> |
| Hot Chocolate v16 get-started | `chillicream2026getstarted` | <https://chillicream.com/docs/hotchocolate/v16/get-started-with-graphql-in-net-core> |
| Hot Chocolate v16 defining a schema (the two authoring styles) | `chillicream2026schema` | <https://chillicream.com/docs/hotchocolate/v16/defining-a-schema> |
| Hot Chocolate v16 migration guide (15 to 16) | `chillicream2026migration` | <https://chillicream.com/docs/hotchocolate/v16/migrating/migrate-from-15-to-16> |
| Hot Chocolate v16 endpoints | `chillicream2026endpoints` | <https://chillicream.com/docs/hotchocolate/v16/server/endpoints> |
| Hot Chocolate v16 security: introspection (cite WITH the section H caveat) | `chillicream2026introspection` | <https://chillicream.com/docs/hotchocolate/v16/security/introspection> |
| Hot Chocolate v16 batching | `chillicream2026batching` | <https://chillicream.com/docs/hotchocolate/v16/server/batching> |
| NuGet, HotChocolate.AspNetCore | `nuget2026hcaspnetcore` | <https://www.nuget.org/packages/HotChocolate.AspNetCore> |
| NuGet, HotChocolate.Templates | `nuget2026hctemplates` | <https://www.nuget.org/packages/HotChocolate.Templates> |
| NuGet, HotChocolate.Types.Analyzers | `nuget2026hcanalyzers` | <https://www.nuget.org/packages/HotChocolate.Types.Analyzers> |
| GitHub, graphql-platform at tag 16.6.0 | `chillicream2026platform` | <https://github.com/ChilliCream/graphql-platform/tree/16.6.0> |
| GitHub, 16.6.0 release notes | `chillicream2026release1660` | <https://github.com/ChilliCream/graphql-platform/releases/tag/16.6.0> |
| Postman, GraphQL client docs | `postman2026graphql` | <https://learning.postman.com/docs/sending-requests/graphql/graphql-overview/> |
| Microsoft, .NET 10 | `microsoft2026dotnet10` | <https://dotnet.microsoft.com/en-us/download/dotnet/10.0> |
| Mosaic companion repository, tag ch02 | `dang2026mosaic` | <https://github.com/Giang-Dang/mosaic-graph/tree/ch02> |

The companion repo is **public** at <https://github.com/Giang-Dang/mosaic-graph>,
tag `ch02`. `newman` is pinned at **6.2.2** (current latest) as a local dev
dependency in `package.json`.

Already in `refs.bib` and reusable from chapter 01 if chapter 02 needs them:
`graphqlorg2026federation`. Nothing else from chapter 01 is likely to be cited
here.

## O. UNVERIFIED, or could not be confirmed - do not cite casually

Everything under this heading failed verification today. Each item says what
would have to happen to promote it.

- **The Hot Chocolate 16 blog post's `onError` and semantic-introspection body
  text would not extract**, across **two** fetch attempts. The post's existence,
  date and byline are confirmed; the prose is not. **Re-fetch before quoting
  anything about `__search` or `__definitions`.** Do not paraphrase from the
  landscape file's one-line summary as if it were the post.
- **`ChilliCream/graphql-workshop`** (last pushed 2026-05-15): **unconfirmed
  whether it is actually pinned to HotChocolate 16.x.** Do not recommend it as a
  v16 learning resource until someone opens its package files. A workshop still
  on 14.x would send readers straight into the renamed-API problems of sections
  F and G.
- **Any dated 2025-2026 change to Postman's GraphQL support.** Postman's docs
  carry **no visible last-modified dates**, so "Postman added X in year Y" cannot
  be sourced. Related trap: Postman's "automatic schema imports" blog post is by
  **Giridhar, dated 2022-03-17**, and is **NOT a current source** - it is four
  years old and describes a UI that has changed.
- **Postman doc URLs are churning.** `/docs/sending-requests/graphql/...` still
  resolves, but the overview page now links
  `/docs/use/send-requests/protocols/graphql/...`. Both work today. Whichever is
  used, re-check it at copy-edit time, and prefer linking Postman's GraphQL
  overview page rather than a deep link into a subsection.
- Reminder on scope: nothing in this file has been verified for **Fusion** or for
  `HotChocolate.ApolloFederation` beyond its version and publish timestamp
  (section A). Subgraph behaviour belongs to a later chapter's research and must
  not be inferred from anything here.
