# SPEC - Federated GraphQL on .NET

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Federated GraphQL on .NET**
Subtitle: *Building and running distributed graphs with HotChocolate and
WunderGraph Cosmo*
Author: Giang Dang

## Status

Chapters 01 to 09 drafted (09 on 2026-08-09). The companion repo is public at
https://github.com/Giang-Dang/mosaic-graph, tagged `ch02`, `ch03`, `ch04-ef`,
`ch04`, `ch05`, `ch07`, `ch08` and `ch09`. Mosaic is no longer one service. At
`ch08` Catalog lives in `src/Mosaic.Catalog` on port 5101 with its own database
and owns the `Product` entity; `src/Mosaic.Api` keeps the other five domains on
5100 and contributes `price`, `availableQuantity`, `reviews` and
`averageRating` to the same type. Both are Apollo Federation subgraphs, both
publish `_service` and `_entities`, and the two schemas compose. Neither service
changed at `ch09`, which adds the composed router execution config as a
committed file and five composition failures produced on purpose. Nothing routes
them yet.
Next action: chapter 10, the router, which now has `federation/supergraph.json`
to load. Chapter 09 owes it two questions it could not answer without a router:
what the router does with a config composed with the resolvability check off,
and whether the `GRAPHQL_SUBSCRIPTION_PROTOCOL_WS` in that config is what it
actually uses against a subgraph chapter 05 exercised over SSE.

## Decision log

Settled 2026-08-08 through a three-round requirements interview. A settled row
is re-opened only by recording what changed and why, in the row.

| # | Question | Decision |
|---|----------|----------|
| 1 | Purpose | Learn-by-writing deep dive, held to publication-grade rigor |
| 2 | Audience | Knows GraphQL basics, new to HotChocolate; Part I is the foundation |
| 3 | Spine | Apollo Federation v2 spec; subgraphs in HotChocolate (HotChocolate.ApolloFederation); composed, routed, and operated with WunderGraph Cosmo end to end |
| 4 | Versions | Written against current stable (HotChocolate 16.x); HotChocolate 14 differences live in appendix C, not the main text |
| 5 | Depth | Three altitudes: conceptual diagrams everywhere; source-guided walkthroughs selectively (pinned to version tags); wire-level always for federation mechanics |
| 6 | Alternatives | Fusion 16 deep with working code (ch 27); Apollo Router working-but-brief (ch 28); Hive, Grafbase, Mesh, stitching surveyed with a decision matrix; architectural alternatives to federation get ch 26 |
| 7 | Operations | Full dedicated part (VI); cloud-neutral, container-based |
| 8 | Running example | One threaded commerce system ("Mosaic"), monolith to federated across the book; isolated micro-examples for mechanisms |
| 9 | Venue | This latex-books pipeline (LuaLaTeX, latexmk, CI) |
| 10 | Length | 450-550 pages |
| 11 | Language | English |
| 12 | Voice | First-person practitioner; humanizer bar (library defaults in AGENTS.md) |
| 13 | Postman | First-class: dev-loop intro in ch 02; subgraph-level `_entities` and `_service` testing in ch 07-08; consolidated workbook in ch 19; Postman CLI smoke tests in CI |
| 14 | Automated testing | Full chapter (ch 20) plus composition checks in the CI/CD chapter (ch 22) |
| 15 | Cosmo demos | Router-only composition first (ch 09-10, no account needed); full self-hosted platform in ch 21; Cosmo Cloud as a sidebar |
| 16 | Companion code | Separate repo F:/repo/mosaic-graph; .NET 10 LTS; docker-compose baseline; Aspire in ch 27 and appendix B; chapter-tagged; created when ch 02 drafting starts |
| 17 | Listings and diagrams | minted (-shell-escape enabled in .latexmkrc) for C# and GraphQL; TikZ-native diagrams |
| 18 | Chapter apparatus | End-of-chapter "Your turn" labs tied to repo tags; recurring "Under the hood" sections plus dedicated Part IV; index maintained while writing, not retrofitted |
| 19 | Title | "Federated GraphQL on .NET" with the subtitle above; versions stay out of the main title |
| 20 | Demo name | "Mosaic" - PROVISIONAL, freely renameable until the companion repo is created |
| 21 | Illustrative SDL before the companion repo exists | Allowed, and only in the conceptual chapters that precede it. Short GraphQL SDL sketches may appear when the prose frames them as sketches rather than as code from the repo; no C# until the repo exists. This reads the "no listings that pretend to be real code" rule as a ban on fake provenance, not a ban on schema illustration. Settled 2026-08-08 while drafting ch 01. |
| 22 | Ch 01 "Your turn" lab | No-code assessment: the reader audits a graph they own, or GitHub's public schema, against the chapter's failure modes. Ch 01 predates the companion repo, so it cannot cite a repo tag; the repo-tag form of the lab resumes at ch 02. Settled 2026-08-08. |
| 23 | How SDL is typeset | Two environments. Executable GraphQL (queries, mutations, fragments) uses `\begin{minted}{graphql}`; SDL uses `\begin{graphqlsdl}`, defined in preamble/packages.tex as minted's Ruby lexer under an honest name. Reason: Pygments 2.19.2's graphql lexer has no SDL support and emits red Error boxes on type definitions, `!`, and block strings (315 Error tokens on a representative federation schema, versus 0 for Ruby, which handles `#` comments, type names and `@directives` correctly). A custom Pygments lexer was rejected because minted v3 requires a per-machine `.latexminted_config` to load one, which would break a fresh clone and the pre-commit hook. Revisit if Pygments gains an SDL lexer. Settled 2026-08-08 while drafting ch 01. |
| 24 | Demo name, settled | "Mosaic" confirmed 2026-08-08, closing the provisional status of decision 20. The companion repo is `mosaic-graph`, namespaces are `Mosaic.*`, and the name is now baked into a public repo, its tags and chapter 01's prose. Renaming from here is no longer a find-and-replace. |
| 25 | Chapter 02 repo slice | One project, in-memory seeded data, no EF Core and no Postgres. EF Core is chapter 04's subject and spending it early would cost that chapter its material. Settled 2026-08-08. |
| 26 | Companion repo hosting | Public on GitHub at https://github.com/Giang-Dang/mosaic-graph, so the "check out the tag" labs work for readers. Settled 2026-08-08. |
| 27 | Postman assets | The repo ships `postman/` with a collection and a local environment from tag `ch02` onward. Five requests, eighteen assertions, run by `scripts/verify.ps1` through newman so the collection is a gate rather than a convenience. Settled 2026-08-08. |
| 28 | Schema authoring style | Mosaic is **implementation-first** throughout; chapters 03-28 inherit this. Reasons, strongest first: HC 16's source generator and ~40 compile-time analyzers key off the attributes and descriptors get none of it; the generated registration is readable material for ch 03 and 16; `[ObjectType<T>]` lets a field live in its owning domain's folder with no central registration list, which is what makes ch 08's extraction a move rather than a rewrite; and `HotChocolate.ApolloFederation` is attribute-led. Descriptors remain the documented escape hatch and the only route to runtime-shaped schemas; the book says so in ch 02 so that reaching for one later reads as planned. Settled 2026-08-08. |
| 29 | Chapter tag convention | `chNN` marks the end-of-chapter state of the companion repo (`ch02`, `ch03`, ...); `chNN-<step>` if a chapter ever needs an intermediate state. Chapter prose references tags by name. Settled 2026-08-08. |
| 30 | The N+1 ships on purpose | Chapter 02's domain services are single-key with no batch overload anywhere, so the catalog-with-reviews query (`{ products { title reviews { rating author { displayName } } } }`, named that way in ch 02 to keep it distinct from the single-product "product page" query of the Postman section) costs 146 lookups. A request-scoped counter reports the number, ch 02 shows it and admits it without naming DataLoader, and ch 04 brings it to 3. Chapter 04 therefore fixes a real measured problem in Mosaic's own code rather than demonstrating on one invented for the occasion. Settled 2026-08-08. |
| 31 | Mechanism demos live in `samples/`, not in Mosaic | A micro-example that exists only to demonstrate one HotChocolate mechanism goes into its own project under `samples/`, never into `Mosaic.Api`. Chapter 03 needed two fields whose whole purpose was to expose service-scope identity; putting them in Mosaic would have added diagnostic noise to a storefront schema, changed the committed SDL and moved the assertions in `verify.ps1`. `samples/resolver-scopes` costs one project and keeps `schema/mosaic.graphql` a description of the product. This is decision 8's "isolated micro-examples for mechanisms" made concrete about where they live. Settled 2026-08-08. |
| 32 | Internals claims cite the source tree, not the docs | From chapter 03 on, an internals claim is verified by reading `ChilliCream/graphql-platform` at a release tag and naming the commit, and the tag is cloned locally rather than fetched page by page. The v16 documentation is cited only for things it is the authority on. Reason: chapter 02 found a documentation page whose sample code does not compile, and a chapter that walks the executor cannot be built on pages of that reliability. Research files tag such facts `[source]` rather than `[web]`. Settled 2026-08-08. |
| 33 | Chapter 03 TOC line rewritten | The approved line read "parsing, validation, operation compilation, resolvers, middleware; first source-guided walk". Drafting found that the document and operation caches are half of what the pipeline does, and that parsing is best covered by establishing where it does *not* happen. The line now names the caches and the diagnostic listener. Scope grew in detail, not in ambition, and the chapter still ends before DataLoaders. Settled 2026-08-08. |
| 34 | Chapter 04 ships two tags | `ch04-ef` is Mosaic on PostgreSQL with the naive single-key lookups intact; `ch04` adds the DataLoaders and the paged field. The chapter's whole argument is a before and an after, and both have to be checkable: a reader runs `git checkout ch04-ef` rather than being asked to delete code. Both tags pass `scripts/verify.ps1` with different expected numbers. This is the first use of decision 29's `chNN-<step>` form. Settled 2026-08-09. |
| 35 | `products` is never paginated | The data middleware went on a new root field, `browseProducts`, and `products` was left exactly as chapters 02 and 03 measured it. Every number those chapters print is a measurement of that field, so paginating it would make two chapters of evidence unreproducible. The chapter says outright that a real service would replace `products` and deprecate it, and hands that to ch 05. Settled 2026-08-09. |
| 36 | The lookup counter and the SQL counter are both kept | `ServiceCallCounter` counts questions asked of a domain service; a new EF Core `DbCommandInterceptor` counts statements that reach PostgreSQL. They were the same number for two chapters and stopped being the same number the moment a service could answer several questions at once. Both appear on the request timeline. Settled 2026-08-09. |
| 37 | Batching numbers are asserted over five runs, not one | Measured over 400 warm requests, 398 reported 3 statements and 2 reported 4: the customers batch occasionally dispatches before its last keys arrive, which is `BatchDispatcher`'s documented settle-time behaviour and not a fault. Both verify scripts now send the query five times and assert that at least one run hit 3 exactly and that no run exceeded 4. Asserting an exact number against one sample would fail about one run in two hundred. Settled 2026-08-09. |
| 38 | `sql`, `yaml` and `javascript` join the listing environments | Decision 23 named csharp, graphql, graphqlsdl, text and json. Chapter 04 needed three more: `sql` for generated statements, `yaml` for the compose file, and `javascript` for Postman test scripts. All three are stock Pygments lexers and render clean. Settled 2026-08-09. |
| 39 | Chapter 05 takes two breaking changes rather than adding fields beside the old ones | `Product.reviews` becomes a connection and every `id` changes format, and both break clients. The alternative, decision 35's move of adding a second field, was used once on purpose and is not the default. Reasons: `products` had two chapters of published measurements riding on it and so was worth preserving, where `reviews` had nothing riding on it but this book's own tests; and a schema that grows a second field every time the first one is wrong ends up as two schemas. Mosaic has no external clients, which is the only condition under which this is free, and that condition expires once. The chapter's spine is the contrast between these two and the `products` deprecation. Settled 2026-08-09. |
| 40 | `[ID]` did nothing until chapter 05, and the book says so | Measured: at tag `ch04`, `Product.id` answered with the raw `Guid` and accepted one as an argument, despite the `[ID]` attribute being present since ch 02. `AddGlobalObjectIdentification()` is what makes the attribute encode. The SDL is `id: ID!` before and after, so no schema-comparison tool can see the change. This is the chapter's headline finding and it also corrects a sentence of chapter 04; see open items. Settled 2026-08-09. |
| 41 | A verification run starts from a dropped and reseeded database | The Postman collection submits a review from ch 05 on, so a run leaves the database changed and the next run would find 121 reviews. Both scripts now start the service with `MOSAIC_RESET_DATABASE=1` and the seeder drops the schema first. The alternative, loosening the seeded-count assertions, is banned by this book's own rules. Cost is a second or two per run; the check is that `verify.ps1` passes twice in a row. Settled 2026-08-09. |
| 42 | Node resolvers use the source generator's `[NodeResolver]`, not the documented `[Node]` | The v16 documentation describes only the reflection route, with a method-naming convention resolved at schema build. The generator route is undocumented and enforces its rules at compile time instead: HC0104 (first parameter must be named `id`), HC0092 (no `[ID]` on it), HC0093 (must be public), HC0083 (only one field argument). Mosaic uses it because every domain type is already an `[ObjectType<T>]` partial class, so the node resolver sits in the folder of the domain that owns the type. Settled 2026-08-09. |
| 43 | The subscription is deliberately outside the verification gate | Newman speaks request and response; a subscription is a connection that stays open. Rather than build a second harness for one field, chapter 05 states plainly in its own prose that the two SSE transcripts it prints are the only evidence nothing re-checks, and that a later chapter breaking `onReviewAdded` would not fail the gate. Chapter 19 owns subscription testing and owes this a fix. Settled 2026-08-09. |
| 44 | Chapter 07 runs on a sample, not on Mosaic | The chapter needs a working federated graph, and it sits before ch 08 extracts Catalog and before ch 10 sets the router up properly. Federating Mosaic here would spend ch 08's subject. So `samples/federated-wire/` is two tiny subgraphs sharing one `Product` entity plus the Cosmo Router, three products and three reviews, existing only to be watched. This is decision 31 applied at a larger size: the sample is bigger than `resolver-scopes` but the rule is the same, and `Mosaic.Api` is untouched at tag `ch07`. Settled 2026-08-09. |
| 45 | Wire traffic is captured inside the subgraphs, not in Postman | The approved ch 07 TOC line said "captured in Postman". Postman cannot see a request the router makes to a subgraph; it can only see the two ends. Both sample subgraphs therefore call ASP.NET Core's `UseHttpLogging` with request and response bodies enabled, and every wire listing in the chapter is what the server process read. Two configuration details are load-bearing: `application/graphql-response+json` has to be added to `MediaTypeOptions` or bodies are dropped, and headers outside the default allow-list print as `[Redacted]` rather than vanishing, which is what makes "the router forwarded nothing" a measurement instead of an inference. Postman keeps decision 13's job: `_service` and `_entities` at the subgraph, and assertions on the router's query plan. TOC line updated in the same session. Settled 2026-08-09. |
| 46 | The federated-wire gate asserts the request bodies, not just the answers | `verify.ps1` and `verify.sh` compose with wgc, start both subgraphs and the router, check that what each subgraph publishes through `_service` is the committed file the composer reads, run a nine-request collection, and then grep the subgraph consoles for the exact two request bodies chapter 07 prints. The last check is the one that matters: three separate `_entities` calls instead of one batch would give the client an identical answer and pass every assertion on the data. A stale listing in the chapter now fails the build. Settled 2026-08-09. |
| 47 | Federation attributes go on the runtime type | `[ReferenceResolver]` does not work inside an `[ObjectType<T>]` partial class. Measured on a four-placement probe at HotChocolate 16.6.0: the source generator turns the method into an ordinary public field, no reference resolver is registered, the type is still in the `_Entity` union because `[Key]` did land, and `_entities` answers `Unexpected Execution Error`. `ReferenceResolverAttribute.TryConfigure` acts only on an object or interface type descriptor and a method in a type extension compiles to a field descriptor, so every branch falls through with no `else`. `[Key]` works in either place. This amends decision 28: fields stay in the folder of the domain that owns them, and what an entity *is* to other services is declared on the runtime type. Closes the chapter 08 open item. Settled 2026-08-09. |
| 48 | The federation key is chapter 5's global identifier, and each service decodes it | `Product.id` is a relay node id, so `@key(fields: "id")` carries base64 rather than a `Guid`. `HotChocolate.ApolloFederation` 16.6.0 mentions relay identifiers nowhere in its source; a reference resolver's key parameter is read out of the representation and converted to the parameter type, `[ID]` on it is inert, and a `Guid` parameter therefore gets `Guid.Empty` and answers **null rather than an error**. Each subgraph carries its own `ProductKey.TryDecode`, calling `INodeIdSerializer.Parse(id, typeof(Guid))` through `IResolverContext.Schema.Services`, and checks the decoded type name. The file is duplicated on purpose: the format of the key is a contract between two services, and a shared class would turn it into a project reference. Settled 2026-08-09. |
| 49 | Catalog takes its own database | `CatalogDbContext` points at a database named `catalog` on the same PostgreSQL container. EF Core's `EnsureCreatedAsync` creates it, so `docker-compose.yml` needed no init script and no second server. Two services sharing a server is a deployment detail; two services sharing a table would undo the extraction. Splitting the remaining five domains is chapter 12. Settled 2026-08-09. |
| 50 | `Query.node` and `Query.nodes` leave both subgraphs | Two subgraphs declaring them is a composition error, measured with wgc 0.129.7, and `@shareable` would be false: neither service can resolve the other's node types, so a router free to pick would answer null for half the identifiers. Both services pass `registerNodeInterface: false`, which keeps the node id serialiser, the `Node` interface, `implements Node` and every node resolver, and drops only the two root fields. Global identifiers survive the split; the field you hand them back to does not. Chapter 13 owns giving a federated graph a `node` field. Settled 2026-08-09. |
| 51 | Both subgraphs turn HotChocolate's cost defaults off | The composer rejects `@cost(weight: "10")` because its own definition takes an `Int!`, and rejects `@listSize`'s `slicingArgumentDefaultValue`, which HotChocolate's own option documents as "the non-spec slicing argument default value". `ModifyCostOptions` sets `ApplyCostDefaults = false` and `ApplySlicingArgumentDefaultValue = false` in both services. `SkipAnalyzer` and `EnforceCostLimits` are separate settings and stay on, so the analyzer and its limits survive; the automatic per-field weights do not, and neither do chapter 5's printed cost numbers for `Product.reviews`. Chapter 25 has to set weights deliberately. Also: `PageCursor` is marked `@shareable` by hand, because `FederationTypeInterceptor` auto-marks `PageInfo` by name and nothing marks the type `PageInfo.forwardCursors` returns. Settled 2026-08-09. |
| 52 | `submitReview` gives up its product check | Reviews cannot ask whether a product exists once Catalog is a separate service, so the check and `ProductNotFoundError` are both gone and the payload union lost a member, which is a breaking change. The alternatives were a synchronous call from Reviews to Catalog on the write path, which reintroduces the coupling the extraction was for, or leaving an error type in the schema that nothing can raise, which is a lie a client will write a branch for. Chapter 11 has `@requires`; chapter 12 argues about whether it is worth taking. Settled 2026-08-09. |
| 53 | Chapter 08 composes as a gate and shows none of it | `federation/mosaic.yaml` is created in chapter 08 and `wgc router compose` runs on every verification pass, but no composition output appears in the chapter. Composition is chapter 09's subject and spending it early would cost that chapter its material. What chapter 08 does own is the three subgraph settings above, because each is a property of a service rather than of the composer, and a chapter that produced two subgraphs which cannot be assembled would have shipped a broken tag. Settled 2026-08-09. |
| 54 | The single-service Postman collection is retired at `ch08` | Most of `postman/mosaic.postman_collection.json` asked port 5100 for `products`, which now lives on 5101, so it was deleted rather than patched. `postman/mosaic-federation.postman_collection.json` replaces it: 16 requests, covering both subgraphs, `_service`, `_entities` in both directions, the positional contract, an undecodable key, and the mutation with its three remaining typed errors. Chapter 19's workbook inherits the job of consolidating this properly. Settled 2026-08-09. |
| 55 | A finding that needs a listing needs a project | Chapter 08's headline finding was first measured on a throwaway probe, and the chapter printed its SDL. The independent audit called that out: a listing nobody can check out fails the rule that every listing is real code from the companion repo at the chapter's tag, however true the finding is. The probe became `samples/entity-attribute-placement` under decision 31, its SDL is committed, and both verify scripts assert the leak by name so that a HotChocolate release fixing it fails the gate rather than quietly making the chapter wrong. The rule going forward: if a measurement is load-bearing enough to print, it is load-bearing enough to commit. Settled 2026-08-09. |
| 56 | Chapter 09's composed config is committed, chapter 07's is not | `federation/supergraph.json` is tracked; `samples/federated-wire/supergraph.json` stays gitignored. Both are build artefacts of committed schemas, and the difference is that chapter 09 prints what is inside one of them. A listing a reader cannot open fails decision 55. Both verify scripts recompose and compare against the committed file, which works only because composition is deterministic: composed twice and compared with `cmp`, byte identical. A wgc upgrade that changes the config format therefore fails the gate rather than silently making the chapter wrong, which is the intended behaviour and not a maintenance problem to solve. `.gitignore` carries the reasoning beside the chapter 07 entry so the inconsistency reads as a decision. Settled 2026-08-09. |
| 57 | Composition cases are one node script, not two shell implementations | `scripts/composition-cases.mjs` mutates the real committed schema pair in memory, composes, and asserts the composer's messages; `verify.ps1` and `verify.sh` both call it. This is the first node script in the repository, and the alternative was writing the same mutate-compose-assert logic twice and letting it drift, which the chapter 04 open item records having already happened once to `verify.sh`. Each case's edit is a literal replacement that must match exactly once, so a schema change that invalidates a case fails with "matched 0 times" rather than composing the unedited pair and asserting nothing. Cases derive from the real schemas rather than a fixture, because an error message from a toy schema pair is a fact about the toy. Settled 2026-08-09. |
| 58 | Chapter 09's TOC line widened | The approved line read "satisfiability, reading composition errors, `wgc router compose` (router-only), supergraph anatomy". Drafting found that "supergraph anatomy" names an artefact that does not exist in this stack, which became the chapter's second section; and that two topics the line did not name earned sections of their own, the `--disable-resolvability-validation` flag and composition as a build gate. The line now names all six. Same form as decisions 33 and 45: scope grew in detail, not in ambition. Settled 2026-08-09. |
| 59 | Three numbers in chapter 09 were wrong until the audit, and all three had been "verified" | The independent auditor re-derived every number and found: the error catalogue is 123 errors, not 203, because 80 of the 203 declarations return a message `string` rather than an `Error`; the config composed with the resolvability check off differs from the good one in five leaves, not one, four of them being the schema edit echoing through content-addressed storage; and the four normalisation changes the chapter named all add bytes, so none of them could explain a document 903 bytes shorter, which turned out to be the federation entry points being stripped. Every one came from counting or diffing the wrong thing and reading the result as confirmation. The rule this leaves: a count is of a type, not of a line that mentions it, and a before-and-after needs the two sides to differ in exactly the one thing being claimed. Settled 2026-08-09. |
| 60 | Captured output may keep the punctuation the tool wrote | `Characters.Mode = 'Ascii'` stays, and gains `AllowInCapturedListings = @('minted:text')`. The rule that produced Ascii mode is that a stray Unicode character in a listing is a paste that went through something; the case it did not anticipate is that compilers, composers and linters write prose, and their prose has punctuation. Chapter 09 met it as a composition error containing a U+2014 em dash. Both halves of the exemption are required: the character must be inside `minted:text`, and the line must appear in a research note, by the same test the verbatim family uses. Prose is not in a listing and a typed listing traces to nothing, so neither can reach it, and a control character is never forgiven because a mangled `sed` is the one thing this family catches that nothing else would. The setting is library-wide and defaults to empty, so no other book is affected; `scripts/check-chapter.tests.ps1` covers the three cases it must refuse. Settled 2026-08-09, after the chapter first shipped without the listing. |

## Version baseline

Verified 2026-08-08; details and sources in
research/2026-08-federation-landscape.md. Re-verify before drafting chapters
that depend on them.

| Component | Version |
|-----------|---------|
| HotChocolate / HotChocolate.ApolloFederation | 16.6.0 (2026-08-05). Ships net8.0, net9.0, net10.0 and net11.0 assets; "targets .NET 8+" understates it. Re-confirmed from the nuspec 2026-08-08. Tag `16.6.0` resolves to commit `8fea46e9560c973eba1b9c899937f9a6bb02aaf9`; the tree is cloned at F:/repo/graphql-platform for the source-guided chapters (decision 32). |
| HotChocolate.Templates | 16.6.0. Note the id: `ChilliCream.HotChocolate.Templates` does not exist. |
| WunderGraph Cosmo Router | 0.337.1 (2026-08-05), image `ghcr.io/wundergraph/cosmo/router:0.337.1`, pinned in the companion repo's docker-compose.yml. Composed execution configs carry `compatibilityVersion: "1:0.63.2"`. |
| wgc (Cosmo CLI) | 0.129.7, pinned exactly in the companion repo's package.json beside newman |
| Federation version HotChocolate 16.6.0 emits | v2.6. `FederationVersion.Default = Federation26`, `Latest = Federation27`, so 2.7 is the ceiling against a spec at v2.15. Measured in the published SDL; see the ch07 research file. |
| ChilliCream Fusion (ch 27) | 16.5 |
| Apollo Federation specification | v2.15 (LTS, Jul 2026) |
| .NET | 10 (LTS) |

## Table of contents

Approved 2026-08-08. If drafting deviates, update this list in the same
session. Chapter folders in chapters/ carry the same scope lines.

### Part I - One Service Done Right

1. **Why One Graph Is Never Enough** - single-schema failure modes, team coupling, where federation fits, the Mosaic storefront, first pass at "do you need this" (ch 26 in full)
2. **HotChocolate, Quickly** - first service on .NET 10; implementation-first vs code-first (and what happened to schema-first); Mosaic monolith v1; the Postman dev loop
3. **The Life of a Request** - the thirteen request middleware and how they are composed; where parsing really happens; the document and operation caches; operation compilation; resolver service scopes; writing a diagnostic listener. First source-guided walk
4. **Data Without the N+1** - EF Core, DataLoader usage and batching internals, projections/filtering/sorting/pagination
5. **Schema Design That Survives Change** - abstract types, Relay conventions, error design, deprecation, single-service subscriptions

### Part II - Thinking in Entities

6. **The Federation Model** - supergraph/subgraphs, entity ownership, the Apollo Federation v2 directive tour, composition rules conceptually
7. **How a Federated Query Actually Runs** - query plans, representations, `_entities`/`_service`, exact router-subgraph HTTP traffic captured inside the subgraphs; `_entities` and `_service` exercised from Postman
8. **The First Cut: Extracting Catalog** - HotChocolate.ApolloFederation, reference resolvers, extending foreign entities; the global object identifier as a federation key, and decoding it; testing a naked subgraph in Postman before any router exists; the three subgraph defaults that only fail once two schemas meet
9. **Composition** - `wgc router compose` (router-only); what a router execution config actually contains, against Apollo's supergraph schema; satisfiability as a graph walk; reading composition errors and the causes they do not name; the flag that disables the check; composition as a build gate and what it structurally cannot see
10. **Enter the Router** - Cosmo Router locally: config, first federated query, reading query plans

### Part III - Decomposition in Practice

11. **Entity Resolution Done Right** - DataLoader-backed reference resolvers, representation batching internals, `@requires`/`@provides`, computed fields, boundary nullability
12. **Strangling the Monolith** - carving Orders/Inventory/Pricing/Accounts/Reviews, `@override` progressive migration, team contracts
13. **Hard Modeling Problems** - cross-subgraph pagination, abstract types across boundaries, shared enums/scalars, global ID design
14. **Real-Time in a Federated World** - subscriptions through the router, Cosmo EDFS with NATS/Kafka, `@defer`/`@stream` reality check
15. **Identity and Authorization Across the Graph** - JWT at router vs subgraph, claim forwarding, `@authorize`, `@authenticated`/`@requiresScopes`, public vs internal graphs

### Part IV - The Machinery

16. **Inside HotChocolate** - executor end to end: operation compiler, execution plans, middleware chains, resolver compilation, DataLoader scheduling (16.x source tags)
17. **Inside the Router and the Composer** - wgc composition (satisfiability algorithm), Cosmo normalization/planning/plan cache, entity fetch batching, Apollo Router planner contrast
18. **The Wire, Completely** - persisted operations/trusted documents, APQ, multipart `@defer` framing, graphql-ws vs SSE, compression, caching headers

### Part V - Confidence

19. **The Postman Federation Workbook** - collections, environments, JWT pre-request scripts, subscription testing, mock servers, Postman CLI in CI, Nitro sidebar
20. **Automated Tests That Catch Federation Bugs** - unit/integration/snapshot tests, reference-resolver tests, composition checks as tests, contract tests

### Part VI - Production

21. **The Platform: Self-Hosting Cosmo** - full stack via docker-compose, registry as source of truth, Cosmo Cloud sidebar
22. **CI/CD for a Federated Graph** - `wgc check` as PR gate, breaking-change detection, publish-on-deploy, router rollout, deprecation workflow
23. **Seeing Production: Observability** - OpenTelemetry across router and subgraphs, trace correlation, metrics, incident debugging
24. **Staying Up: Resilience and Performance** - partial failure semantics, nullability under failure, timeouts/retries/circuit breaking, caching, k6 load testing
25. **Locking Down: Security Hardening** - depth/complexity limits, introspection policy, persisted-operations-only, CORS, secrets, multi-tenancy

### Part VII - The Landscape and the Road Ahead

26. **Do You Actually Need Federation?** - modular monolith, BFFs, REST/gRPC aggregation, decision framework
27. **Fusion** - Fusion 16 hands-on: Composite Schemas spec, Nitro CLI/Aspire composition, wire protocol vs `_entities`, mixed graphs, Cosmo coexistence
28. **The Gateway Market and the Future** - Apollo Router hands-on plus licensing/GraphOS realities, Hive/Grafbase/Mesh/stitching survey, decision matrix, Composite Schemas trajectory

### Appendices

- A. **Toolchain Setup and the Mosaic Repo Tour**
- B. **Local Orchestration with .NET Aspire**
- C. **If You Are on HotChocolate 14** - mapping 14-era APIs and Fusion v1 to the current stack
- D. **Federation Directives Quick Reference** - Apollo Federation v2 and Composite Schemas side by side
- E. **Composition Errors, Decoded**

## Progress

Status values: not-started / outlined / drafted / reviewed / final.

| Chapter | Status | Notes |
|---------|--------|-------|
| Preface | not-started | write last; version-baseline stub in place |
| 01 | drafted | 2026-08-08. 11 pages, 7 sections, ~6,250 words, 3 TikZ figures, 24 index entries. Sources in research/2026-08-ch01-scaling-and-federation-history.md; 35 real citations replace the knuth1984 placeholder. Lab is the no-code audit of decision 22; its heading is a plain `\section*` with no TOC entry, so revisit whether the apparatus deserves a macro once ch 02-03 have used it too. Not yet reviewed for line-level prose. |
| 02 | drafted | 2026-08-08. 18 pages (15-32), 7 numbered sections plus the lab, ~6,600 words, 3 TikZ figures, 35 index entries, 7 citations, 27 listings. First chapter with C# and the first use of minted's csharp lexer; it renders clean. Sources in research/2026-08-ch02-hotchocolate-16.md, which also carries the listing-provenance table. Companion repo tag `ch02`; every listing traceable to a file there and `scripts/verify.ps1` passes. TOC line updated (decision 28) because HC 16 names two authoring styles, not three. Not yet reviewed for line-level prose. |
| 03 | drafted | 2026-08-08. 16 pages (33-48), 6 numbered sections plus the lab, ~5,900 words, 2 TikZ figures, 26 index entries, 1 citation, 29 listings. First source-guided chapter: everything internals-related is read out of `graphql-platform` at tag 16.6.0, commit `8fea46e`, cloned at F:/repo/graphql-platform. Sources in research/2026-08-ch03-request-lifecycle.md. Companion repo tag `ch03`; `scripts/verify.ps1` now also asserts the 13 middleware in order and the 146 resolvers. TOC line rewritten (decision 33) because the planned five-topic line missed the two caches, which turned out to be half the chapter. Not yet reviewed for line-level prose. |
| 04 | drafted | 2026-08-09. 18 pages (49-66), 6 numbered sections plus the lab, ~7,400 words, 2 TikZ figures, 2 citations to primary sources plus 6 more in refs.bib, 40 listings. First chapter with a database. Sources in research/2026-08-ch04-ef-core-and-dataloaders.md. Two companion tags, `ch04-ef` and `ch04` (decision 34), both passing `verify.ps1`. The chapter's spine is three numbers on one timeline line: 146 resolvers, 3 lookups, 3 SQL. Also the first use of the `sql`, `yaml` and `javascript` lexers (decision 38). TOC line unchanged: EF Core, DataLoader usage and batching internals, projections/filtering/sorting/pagination all landed as scoped. Not yet reviewed for line-level prose. |
| 05 | drafted | 2026-08-09. 24 pages (67-90), 6 numbered sections plus the lab, ~9,600 words, 2 TikZ figures, 8 citations to primary sources, 47 listings. Sources in research/2026-08-ch05-schema-design.md. Companion tag `ch05`, passing both verify scripts; the Postman collection went from 10 requests and 36 assertions to 19 and 74. The chapter's spine is one deprecation against two breaking changes (decision 39), and its headline finding is that `[ID]` was inert until this chapter (decision 40). TOC line unchanged: abstract types, Relay conventions, error design, deprecation and single-service subscriptions all landed as scoped, with abstract types arriving three times over as `Node`, the `Error` interface and the generated error union. Longest chapter so far, and the audit's structural note about section 5.4 being thinner than the rest is recorded below rather than fixed. Not yet reviewed for line-level prose. |
| 06 | drafted | 2026-08-09. 12 pages (91--102), 5 sections plus the lab, ~6,800 words, no figures, 3 citations, 30 listings (all SDL sketches). First conceptual chapter since ch01; no companion code (decision 21 applies). Sources in research/2026-08-ch06-federation-model.md. Covers the supergraph and subgraph model, entities and @key ownership, the field-level directives (@shareable/@external/@requires/@provides), the structural directives (@override/@interfaceObject/@inaccessible/@tag), and composition rules conceptually. Not yet reviewed for line-level prose. |
| 07 | drafted | 2026-08-09. 18 pages (103--120), 6 numbered sections plus the lab, ~8,400 words, 2 TikZ figures, 6 citations, 45 listings. Sources in research/2026-08-ch07-federated-query-execution.md. Companion tag `ch07`; Mosaic is untouched and the code is `samples/federated-wire/`, two subgraphs and the Cosmo Router (decision 44). Both verify scripts grew a federation section and pass. The chapter's spine is one query followed end to end: the plan the router prints, then the two request bodies the subgraphs logged, then what the second hop costs. Headline findings: HotChocolate 16.6.0 emits federation v2.6 against a spec at v2.15; the router never calls `_service`; a subgraph publishes no `_entities` at all if no root field reaches the entity; and the router forwards no client headers. TOC line corrected (decision 45). Not yet reviewed for line-level prose. |
| 08 | drafted | 2026-08-09. 18 pages (121--138), 6 numbered sections plus the lab, ~8,200 words, 2 TikZ figures, 52 index entries, 4 citations, 36 listings. Sources in research/2026-08-ch08-first-cut.md. Companion tag `ch08`, the first tag that changes Mosaic itself: `src/Mosaic.Catalog` on 5101 with its own database, `src/Mosaic.Api` on 5100 with five domains, both federation subgraphs, both gates passing and the two schemas composing. The chapter's spine is that the extraction was a file move and the schema was the work: eight files changed path, five of them changing nothing but their namespace and using lines, and the three `[ObjectType<Product>]` classes in Pricing, Inventory and Reviews did not change by a character. Headline findings: `[ReferenceResolver]` in an `[ObjectType<T>]` class silently becomes a public field (decision 47); the federation key is chapter 5's base64 identifier and nothing decodes it, so a `Guid` parameter answers null rather than erroring (decision 48); and three subgraph defaults block composition, of which `Query.node` in two subgraphs is the one that costs a feature (decisions 50 and 51). Measured: 146 resolvers and 2 SQL for the catalog page through `_entities`, against 146 and 3 as a monolith, and 1 statement for 25 representations in one call against 25 for the same keys one call at a time. Four citations, all to Apollo's own documentation for claims about what the specification requires rather than what this build does; everything else was measured or read out of the source tree. The TOC line was widened in the same session (decision 53 explains what was deliberately left out). Audited by a fresh agent, which found seven real defects; see decision 55 and the open items. Not yet reviewed for line-level prose. |
| 09 | drafted | 2026-08-09. 16 pages (139--154), 6 numbered sections plus the lab, ~7,400 words, 2 TikZ figures, 51 index entries, 5 citations, 36 listings. Sources in research/2026-08-ch09-composition.md. Companion tag `ch09`; neither service changed by a line, and the tag adds `federation/supergraph.json` (committed, decision 56) and `scripts/composition-cases.mjs` (decision 57). Both gates pass, both run to completion on this machine. The chapter's spine is that the artefact is not what its name says and the errors do not name their causes. Headline findings: a Cosmo router execution config carries no `join__` directives at all, splitting into a clean client schema plus a routing table where Apollo has one annotated document; each subgraph's SDL is in the file twice, verbatim and normalised, the normalised copy content-addressed under the SHA-1 of itself and stripped of `_service`, `_entities`, `_Service`, `_Entity` and `_Any`; satisfiability is one error out of 123 and renders as a query document; three different mistakes all report as a shareability error on the key field and none names a key; and `--disable-resolvability-validation` emits a config whose client schema is `===` identical to a healthy one. TOC line widened in the same session (decision 58). Audited by a fresh agent, which found three wrong numbers that had survived my own verification; see decision 59 and the open items. Not yet reviewed for line-level prose. |
| 10 | not-started | |
| 11 | not-started | |
| 12 | not-started | |
| 13 | not-started | |
| 14 | not-started | |
| 15 | not-started | |
| 16 | not-started | |
| 17 | not-started | |
| 18 | not-started | |
| 19 | not-started | |
| 20 | not-started | |
| 21 | not-started | |
| 22 | not-started | |
| 23 | not-started | |
| 24 | not-started | |
| 25 | not-started | |
| 26 | not-started | |
| 27 | not-started | re-verify Fusion facts before drafting |
| 28 | not-started | re-verify landscape facts before drafting |
| App A | not-started | |
| App B | not-started | |
| App C | not-started | |
| App D | not-started | |
| App E | not-started | |

## Writing rules (book-specific)

Library-wide defaults are in AGENTS.md; these are this book's additions.

- Every hands-on chapter includes a "verify it in Postman" step.
- Internals claims are pinned: name the HotChocolate 16.x source tag or Cosmo
  release a walkthrough was checked against.
- Code listings come from the mosaic-graph companion repo once it exists;
  until then, write no listings that pretend to be real code.
- A chapter that ships code is not drafted until `pwsh scripts/verify.ps1` in
  that repo prints PASS and the chapter's `chNN` tag is pushed. If a chapter
  legitimately changes one of the numbers the script asserts, update the script
  and say so in the commit message; never loosen an assertion to make a run
  pass.
- Each chapter ends with a "Your turn" lab referencing a companion-repo tag.
- Facts from research/2026-08-federation-landscape.md must be re-verified
  before drafting the chapters that use them (Parts VI and VII especially).
- Citations are `~\autocite{...}`, always with the tilde, so a bracketed number
  can never start a line on its own.
- Quoted material uses `\enquote{}` (csquotes), never literal quote characters.
- A figure's `tikzpicture` lives in figures/tikz/ as a bare picture; the
  `figure` environment, caption and label stay at the call site in the section
  file.
- Vendor-published sources are usable only when they quote a named engineer at
  the company being described, and the prose says whose blog it was.
- Numbers we measured ourselves rather than found published must say so in the
  text ("I counted..."), and the research file must record how to reproduce the
  count.
- Voice: first-person practitioner. First person singular, opinionated where
  experience warrants it and willing to concede. No contractions in my own
  voice; they appear only inside quoted material. Sentence length varies, and a
  short declarative sentence lands the end of a paragraph or a section.
  Sections end on a hinge into the next one. Claims are concrete - a company, a
  date, a number, a name - because the vague authority ("experts argue",
  "industry reports") is the failure this voice exists to avoid.
- Humanizer skill: humanizer. The book is in English, so a draft is judged
  against the English tone profiles, not the humanizer-vi ones.
- Spelling is British-leaning: organisation, centre, labelled, initialisation.
  Product and API names keep whatever spelling their vendor chose, so
  HotChocolate ships Types.Analyzers and its analyzers stay analyzers. The
  enforced variety and the four exemptions are in check-chapter.psd1; this is
  the rule they enforce.
- Listings are drawn from the environments decisions 23 and 38 name, and each
  one exists as a `\newminted` alias or a stock lexer in preamble/packages.tex.
  Adding an environment is a decision, recorded in the log.
- Every file in this book is ASCII, with one exception: a `minted:text` listing
  may carry a non-ASCII character when the tool that produced the line wrote it
  and the line is recorded in a research note. Captured output is not ours to
  clean, and altering it would be the worse breach. The exception is enforced by
  `Characters.AllowInCapturedListings` in check-chapter.psd1, which requires
  both halves and forgives no control character, so it cannot reach prose or an
  invented listing. It covers punctuation a tool emitted; it is not a licence to
  paste a curly quote into a listing. See decision 60.
- Prefer a figure wherever a figure carries the point better than prose does.
  One diagram replaces three paragraphs describing an architecture; one plotted
  series replaces a four-row table. A figure is not decoration. It is a second
  tool of derivation, standing beside the code, the layers in the code, and the
  path a query or a request takes through them, rather than illustrating any of
  those after the fact. If a reader would have to hold four moving parts in
  their head to follow a paragraph, draw the four parts instead.
- TikZ figures follow the idiom the existing ones already use: hand-placed
  absolute coordinates rather than a layout engine, `-{Stealth[length=2mm]}`
  arrowheads, `rounded corners=2pt`, node dimensions in mm, and `font=\small`
  with `\scriptsize` for labels. A figure drawn to a different idiom reads as a
  figure borrowed from another book, which is why the existing pictures rather
  than this paragraph are the authority.
- The "Your turn" lab opens with a paragraph of framing, then a numbered list
  whose items begin with a bolded imperative (`\item \textbf{Map the
  owners.}`), and closes by saying what a dull result would mean or by pointing
  forward to the chapter that picks the thread up.
- mosaic-graph is laid out one folder per domain, and every field lives in the
  folder of the domain that owns it, even when it hangs off a type another
  domain declared. `Product` is a Catalog record, but `Product.price` is a
  resolver in `Pricing/Types/`. That is what makes chapter 08's extraction a
  move rather than a rewrite, so it holds even where a shortcut is tempting.
  Dependencies between domains stay acyclic and one-directional: the domain
  that references nobody is the one that can be extracted first.
- Do not enable `EmitCompilerGeneratedFiles` with an output path inside the
  project directory. The SDK compiles the emitted files as sources on the next
  build and the run fails with duplicate definitions. Dump them outside the
  project, or delete them once they have been read.

## Open items

- (resolved 2026-08-09) The composer message chapter 09 could not print now
  prints. `Characters.AllowInCapturedListings` exists, this book sets it to
  `minted:text`, and the enum-drift case is committed in the companion repo like
  the other six. See decision 60. What is worth carrying: the em-dash line in
  research/2026-08-ch09-composition.md section G is load-bearing, because the
  check traces the chapter's listing to it. Re-wrapping that line in the note
  turns the listing back into a finding, and the failure will name the listing
  rather than the note.
- **The satisfiability error names one route out of four.** Catalog has four
  root fields returning `Product` and the unresolvable-path error names only
  `Query.products`. Whether that is the first route the walker tried, the
  shortest, or something else was not investigated; the chapter says only that
  fixing the named path is not evidence the graph is fixed. Chapter 17 walks the
  composer properly and owns the answer.
- **`scalar FieldSet` reaches the client-facing schema** because HotChocolate
  imports it as a named type in its `@link` list and the composer keeps imported
  named types. Harmless, visible to anyone who introspects the router, and
  nobody's documented intent. Chapter 25 should decide whether a production
  graph does anything about it; chapter 28 is where the two stacks are compared
  and it is evidence.
- Chapter 09 leaves these unmeasured, and the research file's section M names an
  owner for each: anything a router does with this config including what it does
  with one composed with the resolvability check off (ch 10), the
  `GRAPHQL_SUBSCRIPTION_PROTOCOL_WS` in the config against a subscription
  chapter 05 exercised over SSE (ch 14), `--split-configs-enabled`,
  `--ignore-external-keys` and `--suppress-warnings` (the second needs
  `@external`, ch 11), composition warnings of any kind since Mosaic produces
  none, composition across more than two subgraphs (ch 12), and whether an
  Apollo-style annotated supergraph SDL can be obtained from wgc at all (ch 28).
- The composer prints some errors more than once: twice for the incompatible
  type case, three times for the uncommitted enum case, identically each time.
  No pattern was established, so chapter 09 says only that a count of blocks is
  not a count of faults. Worth resolving if chapter 17 reads the composer.

- (resolved 2026-08-09) Chapter 08 answered the `[ReferenceResolver]` question,
  and the answer was "only one of them works". See decision 47. The failure is
  silent and leaves a field in the public schema, which is why the chapter spends
  a section on it rather than a sentence.

- **What the chapter 08 audit found, and the one thing it got wrong.** A fresh
  agent reading the chapter cold reported seven defects that survived
  verification: a listing whose project was not in the repository (decision
  55), `[Map]` and composite keys asserted under a "measured" heading when only
  four parameter kinds were run, "byte for byte the same" about two files that
  differ in their comments, a response listing that disclosed two edits and made
  three, "a field on both sides is a composition error" stated without the key
  exception its own two schemas rely on, a lab step whose `--output` path
  resolves against the project directory rather than the repository root, and
  four claims about what the specification requires carrying no citation. All
  seven are fixed. The one finding rejected: the audit called the lab's
  `__typename: "Customer"` outcome inferred rather than measured. It was
  measured, and the response is in section D of the research note; the auditor
  read the note before that section was added.
- **Chapter 08 corrects a defect chapter 04 shipped, and no gate caught it for
  four chapters.** `OrderingService` never called `.Include(o => o.Lines)`, and
  `OrderLine` is a related entity with a shadow key rather than an owned type,
  so `Order.lines` answered `[]` for every order and `Order.total` threw.
  Reproduced at tag `ch07` before anything in chapter 08 was written. The
  service's own doc comment claimed the lines were owned; `OrderConfiguration`
  in the same repository says in as many words that they are not. Chapter 04's
  prose is right about this and only the comment and the missing `Include` were
  wrong, so nothing in chapter 04 needs rewriting. What is worth carrying is
  why it survived: no request in the Postman collection had ever asked an order
  for anything. Chapter 08 found it because `OrderLine.product` is where a
  federated Mosaic hands a key to Catalog. The gate now asks for an order and
  selects `total`.
- Chapter 05's cost numbers for `Product.reviews` (30 flat, 41 at `first: 2`,
  521 at `first: 50`) do not reproduce at tag `ch08` or later, because decision
  51 turned the automatic per-field weights off in both services. The numbers
  stand for the schema that produced them. Chapter 25 owns cost and has to set
  weights deliberately rather than inheriting defaults; when it does, say in
  chapter 25 what changed rather than leaving a reader to rerun chapter 05 and
  find different numbers.
- `verify.sh` needed one fix beyond translation, and it is a Windows trap worth
  remembering: under Git Bash the JSON helper prints CRLF, and a carriage return
  inside a key becomes an illegal control character in a JSON string literal.
  The service answers HC0012 "Invalid JSON document" about a request that looks
  perfectly fine in the log. Both key files are now piped through `tr -d '\r'`.
  Both scripts were run to completion on this machine at tag `ch08`, which is
  the first time `verify.sh` has been executed here rather than only reviewed.
- Chapter 08 leaves these unmeasured, and the research file's section N names an
  owner for each: anything a router does with these two subgraphs (ch 10), the
  supergraph the composer produced (ch 09), `@requires` / `@provides` /
  `@external` / `@override` (ch 11 and 12), whether a reference resolver behind
  a DataLoader is called concurrently for one batch (ch 11), the latency cost of
  the extraction (ch 10), what happens when Catalog is down (ch 24), mutations
  and subscriptions through a federated graph (ch 12 and 14), and whether
  `Query.node` can be given back to a federated graph at all (ch 13).
- Mosaic has no root field that lists customers, so at tag `ch08` the only way
  to obtain a customer key is through a review's author. Both verification
  scripts do exactly that and then walk the authors until one of them has an
  order, because seven of the twelve seeded customers have none. That is a fair
  description of the schema rather than a workaround, but it is fragile: a seed
  change that leaves every reviewing customer orderless would fail the gate for
  the wrong reason. Chapter 19 or 20 should give the gate a deterministic route
  to an order.
- Chapter 07 leaves these unmeasured and its research file's section M names an
  owner for each: DataLoader behind a reference resolver (ch 11), `@requires`
  and `@provides` on the wire (ch 11), `@override` (ch 12), Advanced Request
  Tracing (ch 17 and 23), a subgraph that is down or slow (ch 24), mutations and
  subscriptions through a router (ch 12 and 14), and whether the router's plan
  cache reuses a plan across requests (ch 17).
- Chapter 07's latency table is single-machine, like chapters 03 and 04. Two
  claims are meant to survive: the second subgraph hop costs about what that
  subgraph costs when asked directly, and the router's own fixed cost is larger
  than the extra hop. The router figure is an upper bound, because the container
  reaches the subgraphs across Docker's bridge and the direct rows do not.
- The federated-wire sample composes from committed schema files, so changing a
  subgraph's C\# and recomposing changes nothing. The chapter 07 lab now tells
  the reader to switch `graph.yaml` to `introspection:` before the two exercises
  that depend on it. If that sample grows, consider making introspection the
  committed default and keeping the files only for the drift check.
- `X-WG-Disable-Tracing` was never exercised. Chapter 07 names it and says
  plainly that only the other two query-plan headers were tested with and
  without development mode.

- **Chapter 05 corrects chapter 04's Postman gate, and the correction matters.**
  Chapter 04's assertion named "the projection kept the identifier"
  base64-decodes an id and asserts the decoded text does not contain an all-zero
  `Guid`. At tag `ch04` ids were raw `Guid`s rather than base64, so the decode
  produces binary noise and the test passes whichever value it is given.
  Verified both ways with node. It could never have caught the bug it was
  written for. Fixed at tag `ch05`, where ids really are base64 and the
  assertion checks the prefix and the key bytes. Chapter 04's prose is right
  about the bug and the fix; only its claim about the gate was wrong. If ch 04
  is ever revised, say so there rather than leaving it to ch 05.
- Chapter 04's prose says `[ID]` "has to encode the raw `Guid` into an opaque
  identifier". At tag `ch04` it encoded nothing (decision 40). The projection
  failure that sentence explains is real and follows from the field being
  resolver-backed at all, so only the stated reason is wrong. One sentence to
  tighten on any ch 04 revision.
- Chapter 05's section 5.4, "When the answer is no", is the one section in the
  chapter with no Mosaic code of its own; it was drafted from the documentation
  and then given two measured Mosaic error responses during the audit. It still
  reads more like an argument than the rest of the chapter. If the chapter is
  revised, consider folding it into 5.5 rather than expanding it.
- Chapter 05 leaves these unmeasured, and the research file's section M names an
  owner for each: the WebSocket transport (only SSE was exercised), `[Topic]`
  placeholder formatting, subscriptions with more than one subscriber or across
  a restart, cursor stability when a row is inserted ahead of an open cursor
  (ch 13), and `MaxPageSize` (ch 25).
- The connection on `reviews` is **slower** than the list it replaced: a mean of
  9.2 ms against 6.5 ms for the same 120 reviews, measured paired. The chapter
  prints this because it is the only number that argues against the change. What
  the connection buys is a cost the analyzer can compute: 30 flat for the
  unbounded list, against 41 at `first: 2` and 521 at `first: 50`. If the book is
  re-measured, keep both halves of that.
- `schema export --output` resolves a relative path against the project
  directory, not the working directory, so the README's own command run from the
  repository root fails with a `DirectoryNotFoundException`. Harmless, and worth
  fixing in the README the next time the companion repo is opened.

- (resolved 2026-08-08) Companion repo created, verified and published:
  https://github.com/Giang-Dang/mosaic-graph, tags `ch02` and `ch03`.
  `scripts/verify.ps1` is the gate a tag has to pass; it builds in Release with
  warnings as errors, checks the committed SDL against a fresh export, asserts
  25 products / 120 reviews / 146 lookups, and runs the Postman collection
  through newman. Chapter 03 added two assertions to it: the request pipeline
  is the expected 13 middleware in order, and the request timeline reports 146
  resolvers. The collection is now seven requests and twenty-four assertions.
- (resolved 2026-08-08) "Mosaic" confirmed as the demo name; see decision 24.
- The "Your turn" apparatus has now been used three times (ch 01, 02 and 03, all
  as an unlabelled `\section*`). Ch 03's is a seven-exercise lab in ch 02's
  shape, so the third form the last revisit was waiting for did not appear. It
  still does not need a macro: the heading is one line and nothing
  cross-references a lab. Stop revisiting this until something actually needs to
  `\ref` one.
- Chapter 03 corrects one sentence of chapter 02. Ch 02's Postman section says
  validation runs "against the schema before a single resolver is called" and
  applies that to both the unknown-field 400 and the syntax-error 400. The
  unknown field is validation inside the pipeline; the syntax error is rejected
  by the transport parser and never creates a request at all. Ch 03 states the
  distinction explicitly. If ch 02 is ever revised for line-level prose, tighten
  that sentence rather than leaving the correction to arrive a chapter late.
- Chapter 03 leaves three things unmeasured and says so: which shipped
  validation rules are non-cacheable (`DocumentValidator.HasNonCacheableRules`),
  the single-flight compilation path under a real burst, and anything about
  `RunTask` or execution-task counts. Chapters 16 and 17 own all three. The ch
  03 research file's section O lists them so they do not get asserted from
  memory later.
- The absolute timings in chapter 03 are single-machine numbers from the
  author's box. The claims that are meant to survive are the ratio (validation
  costs roughly three times compilation) and the warning that a cold first
  request measures the runtime warming up rather than the pipeline. If the book
  is ever re-measured on other hardware, keep the ratios and replace the
  milliseconds.
- (resolved 2026-08-09) Chapter 02's three deferred items are settled. `reviews`
  is a connection and errors have a model, both in ch 05; only "nothing is
  authorised" is still outstanding and still belongs to ch 15. Chapter 04's
  addition is settled too: `products` is deprecated in favour of
  `browseProducts` rather than paginated, which keeps decision 35 intact and
  gives ch 05 its one survivable change.
- House style says the prose references a figure before it appears. Chapters 02
  and 03 do not do this for any of their five figures; chapter 04 does for both
  of its. Worth one pass over ch 02 and ch 03 when either is next opened, rather
  than a separate errand.
- (resolved 2026-08-09) Chapter 04 delivered the number: 146 lookups down to 3,
  and 146 statements down to 3. `MosaicDataOptions` and its `LookupDelay` were
  **removed** rather than used. The knob existed so an in-memory lookup could be
  made to cost something; a PostgreSQL round trip costs something on its own, so
  keeping it would have been a way to lie about the measurement rather than a
  way to take one. Chapter 04's lab throttles the container instead, which slows
  the real thing.
- Chapter 04's absolute timings are single-machine numbers, like chapter 03's.
  The claim meant to survive is the ratio, roughly twelve milliseconds against
  roughly five for the same query, measured back to back in one sitting. That
  last part is not a detail: an earlier pass measured the same `ch04-ef` code at
  10-12 ms and a later one at 19-20 ms, purely because the machine was busier.
  Any re-measurement has to do both tags in one session or it says nothing.
- Chapter 04 leaves five things unmeasured and its research file's section J
  names an owner for each: batching under real concurrency and index behaviour
  (ch 24), `MaxBatchSize` splitting, `DataLoaderServiceScope.OriginalScope`, and
  migrations (ch 22, which should say plainly that a real service migrates
  where Mosaic calls `EnsureCreatedAsync`).
- `verify.sh` had never been given chapter 03's pipeline and timeline checks,
  although its own header says changes to one script belong in the other. It was
  brought back to parity in chapter 04 and now also carries the SQL assertion.
  Whatever is added to one gate from here needs adding to both in the same
  commit, because a second gate that silently checks less is worse than no
  second gate.
- The v16 security docs page tells readers to call `AllowIntrospection(false)`
  on the builder, which does not compile against 16.6.0. Chapter 02 says so.
  Re-check before ch 25 (security hardening) in case ChilliCream fixes the page.
- (resolved 2026-08-08) minted builds verified twice: locally on MiKTeX
  (minted v3 needs TEXMF_OUTPUT_DIRECTORY, set in .latexmkrc) and in the one
  CI run that existed before CI was removed. Compile checks now happen in the
  repo's pre-commit hook.
- (resolved 2026-08-08) refs.bib no longer holds the knuth1984 placeholder; it
  was removed once chapter 01's real citations landed.
- Facts in research/2026-08-ch01-scaling-and-federation-history.md must be
  re-verified before chapters 26 and 28 reuse them. That file's section J lists
  fabricated and vendor-biased sources that rank highly in search results;
  read it before researching the landscape chapters.
- Pygments has no GraphQL SDL lexer, so SDL is typeset through Ruby's (decision
  23). If Pygments ships one, switch `graphqlsdl` in preamble/packages.tex over
  to it and drop the workaround comment.
- Chapter 01 came in at 11 pages against a 12-18 estimate. Not padded on
  purpose. If the whole book tracks short of 450 pages, revisit the estimate
  rather than inflating chapters.
- Unused-but-verified sources are parked in the chapter 01 research file's bib
  key table (Artsy's stitching RFC, Shopify's modular-monolith posts, Giroux's
  later essays, Avilla's "One Graph to Rule Them All" piece). Chapters 26 and 28
  should start there rather than re-researching.
