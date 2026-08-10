# SPEC - Federated GraphQL on .NET

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Federated GraphQL on .NET**
Subtitle: *Building and running distributed graphs with HotChocolate and
WunderGraph Cosmo*
Author: Giang Dang

## Status

Chapters 01 to 13 drafted (13 on 2026-08-10). The companion repo is public at
https://github.com/Giang-Dang/mosaic-graph, tagged `ch02`, `ch03`, `ch04-ef`,
`ch04`, `ch05`, `ch07`, `ch08`, `ch09`, `ch10`, `ch11`, `ch12` and `ch13`.

**Mosaic is seven services.** `src/Mosaic.Api` does not exist. Catalog owns
`Product` on 5101; Pricing (5102), Inventory (5103) and Reviews (5105) each
contribute fields to it; Accounts (5104) owns `Customer`, which became an entity
at `ch12` because two services reference one; Ordering (5106) owns `Order` and
references `Product` and `Customer` with `resolvable: false` on both. Six
databases on one PostgreSQL container, created by `EnsureCreatedAsync` on first
start. The seventh service, `src/Mosaic.Nodes` on 5107, arrived at `ch13` and is
the only one with no database and no domain: it owns `Query.node` and
`Query.nodes` for the whole graph and declares four two-line stubs to do it.
`src/Mosaic.ServiceDefaults` is the first project in the repo that is not a
service: the request timeline, the two counters, the snake_case convention and
the builder calls that make a subgraph composable. The Cosmo Router in front of
all seven is unchanged from `ch10` and is handed a different execution config.

Getting there: `ch08` extracted Catalog; `ch09` added the composed config as a
committed file and five composition failures on purpose; `ch10` put the router
in front; `ch11` added `Product.shippingCost` with `@requires(fields:
"category")` and `samples/entity-resolution`; `ch12` emptied and deleted the
monolith, added `scripts/override-cases.mjs`, and retired
`mosaic-federation.postman_collection.json` for `mosaic-subgraphs`; `ch13` added
the node service, made `Review` and `Order` entities, fixed a paging cursor
chapter 4 broke, and added `scripts/modeling-cases.mjs` and
`samples/interface-object`.

Next action: chapter 14, real-time in a federated world. It inherits a
subscription, `onReviewAdded`, that chapter 5 built over SSE against one service
and that nothing has exercised through a router since; decision 43's admission
that it is outside the verification gate; and chapter 9's unanswered question
about `GRAPHQL_SUBSCRIPTION_PROTOCOL_WS` in the composed config. Mutations
through the router are owed here too.

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
| 61 | Chapter 10's TOC line widened | The approved line read "Cosmo Router locally: config, first federated query, reading query plans". Drafting added three things it did not name: what the router costs in milliseconds, which chapter 08 assigned to this chapter and the line never picked up; what a router does with a config composed with the resolvability check off, which chapter 09 owed it; and configuration as a subject in its own right, because two of the settings behave in ways their names do not suggest. The line now names all six sections. Same form as decisions 33, 45 and 58: scope grew in detail, not in ambition. Settled 2026-08-09. |
| 62 | A timing gets a script, not a gate | `scripts/measure-router.mjs` is committed and is deliberately not called by either verification script. Decision 55 says a measurement worth printing is worth committing, and the independent audit found chapter 10 printing a latency table with no harness behind it and no reproduction recipe. But asserting single-machine milliseconds in a gate makes the gate fail on a busier laptop, which teaches nobody anything and trains people to ignore red. So the rule splits: a **behaviour** the chapter prints becomes a case in a `*-cases.mjs` that both gates run, and a **timing** the chapter prints becomes a committed script a reader can run twice, named in the chapter and in the research note. Settled 2026-08-09. |
| 63 | Chapter 11's TOC line widened | The approved line read "DataLoader-backed reference resolvers, representation batching internals, `@requires`/`@provides`, computed fields, boundary nullability". Drafting found two subjects it did not name and both earned sections: how the required value reaches the resolver, which is a compiled setter running after the reference resolver returns and is documented nowhere; and what the composer insists on around `@external`, which is three cases of which the interesting one produces no error at all. The line now names all six sections. Same form as decisions 33, 45, 58 and 61: scope grew in detail, not in ambition. Settled 2026-08-09. |
| 64 | An `@external` field's schema nullability is not its property's | Catalog declares `Product.category` as `ProductCategory!`. Mosaic's `@external` copy was first written nullable, to match the C# property, and the pair composes silently with the client-facing field becoming nullable for every client of the graph: composition merges the two declarations and takes the more permissive side. The copy is now `[External] [GraphQLNonNullType] public ProductCategory? Category { get; set; }`. The schema declaration is a copy of another service's contract and has to match it; the property is not a copy of anything and holds a value that arrives for some representations and not others, where a non-nullable enum would report `FURNITURE` for absent. Committed as the `external-nullability-wins` case, which reads the composed client schema rather than the composer's exit code, because there is no error to read. Settled 2026-08-09. |
| 65 | A field that crosses a subgraph boundary should be nullable | Measured on the sample: one crate out of four holding a widget key Catalog has never heard of takes the whole response to `data: null`, because `name: String!` inside `widgetByKey: Widget!` inside `[Crate!]!` has nowhere to stop. Chapter 8's `OrderLineNode` doc comment claimed a dangling identifier "surfaces as a null product at the router"; `OrderLine.product` is `Product!`, so it does not, and the comment is corrected at `ch11`. Referential integrity across a network is not a thing a schema can assume, so the default at a boundary is nullable and non-null is the exception that needs an argument. Chapter 12 applies this five more times. Settled 2026-08-09. |
| 66 | A count belongs in a gate; a timing does not | Decision 62 sent timings to a committed script because asserting milliseconds makes a gate fail on a busier laptop. Counts are the other half of that split and go the other way: they are the same on every machine, so chapter 11's resolver and statement counts are steps of both verification scripts rather than numbers read off a terminal. The measurement query deliberately stops short of `Product.reviews`, because a resolver runs per review author and `postman/mosaic-federation` submits a review on every pass, so a count that walked the reviews would be true only of a database nothing had written to. That is how the first draft's 144 and 169 turned into 76 and 101: both pairs are correct, and only one of them is correct twice. Settled 2026-08-09. |
| 67 | The monolith is deleted rather than emptied | `src/Mosaic.Api` is gone at `ch12`, not left as a shell with the shared infrastructure in it. The strangler pattern is named after a fig that stands up when its host rots away, and a host that never rots is a second deployment unit nobody owns. What was genuinely shared went to `src/Mosaic.ServiceDefaults`; what was a contract between services was duplicated. The cost is that chapters 2 to 11 refer to a project a reader checking out `ch12` will not find, which is what tags are for. Settled 2026-08-10. |
| 68 | A shared library is allowed, and the test for it is agreement | Decision 48 duplicated `ProductKey` because a shared class turns a wire contract into a build dependency, and chapter 12 duplicates fifteen files on that argument. `Mosaic.ServiceDefaults` is the other side of the same test: the request timeline, the two counters, the snake_case convention and `AddMosaicSubgraph` are things all six should do the same way and nothing any two of them have to agree about. The line is the question "do two services have to agree about this?" - if yes it is a contract and gets copied, if no it is platform and gets shared. Settled 2026-08-10. |
| 69 | Catalog's lookup counter comes back, reversing part of decision 47's chapter | Chapter 8 dropped `ServiceCallCounter` from Catalog on the argument that a single-domain service has nothing to count. True of two services and false of six: a graph where one process reports and five do not answers every question about cost with "somewhere else". All six count now and the counting is in the shared library so the six answers mean the same thing. This does not close chapter 10's open item about unobserved queries - six unrelated timelines are still six unrelated timelines - and chapter 23 still owns the trace that joins them. Settled 2026-08-10. |
| 70 | Decision 65's rule has a boundary of its own, and it is three not five | Decision 65 predicted chapter 12 would make five more fields nullable. Three became nullable, all of them references to an entity another subgraph owns: `Review.author`, `Order.customer`, `OrderLine.product`. Three did not: `Product.price`, `Product.shippingCost` and `Product.availableQuantity`, which are fields a subgraph contributes to an entity the router has already located. The sharper rule: a reference you do not own must be nullable because the router may fail to find the thing; a contribution need not be, because there is no second lookup and the subgraph's answer is authoritative. The test is whether the failure is a missing datum or a broken invariant. Settled 2026-08-10. |
| 71 | Progressive `@override` is described and not exercised | HotChocolate 16.6.0 ships `[Override(from, label)]` and emits the label when a subgraph links federation 2.7; wgc 0.129.7 defines `@override` with one argument and rejects the second with "The definition for `@override` does not define the following argument that is provided: `label`". So the chapter describes the feature from Apollo's documentation, prints the composer's refusal, and does not pretend to have run it. Chapter 28 compares the two stacks and is where an Apollo Router could be pointed at a 2.7 config. Settled 2026-08-10. |
| 72 | Chapter 9's composition messages are pinned to `ch11` and earlier | `scripts/composition-cases.mjs` edited the subgraph named `mosaic`, which does not exist at `ch12`, so the same six mistakes are now made in `pricing` and the composer says different words about three of them. Chapter 9's listings reproduce at tag `ch11` and earlier, which is what a chapter tag is for, and chapter 12 says so. What is worth carrying: a catalogue of composition errors is a fact about a particular set of subgraphs, not about the composer. Settled 2026-08-10. |
| 73 | The resolver count has always measured resolver tasks | Reviews' `_entities` query went from 146 resolvers to 26 at `ch12`, and 120 of the missing ones are authors that are still resolved. `ReviewNode.GetAuthor` has no await in it, so `OperationCompiler.CompileResolver` turns it into a `PureFieldDelegate` that runs inline, and `DiagnosticEvents.ResolveFieldValue` is raised only inside `ResolverTask.Execute` and `BatchResolverTask`. So chapter 3's number counts resolver tasks rather than fields resolved, and always did; nothing before chapter 12 was wrong, because every field on that path used to be asynchronous. Read at tag `16.6.0`, commit `8fea46e`. Settled 2026-08-10. |
| 74 | Chapter 12's TOC line widened | The approved line read "carving Orders/Inventory/Pricing/Accounts/Reviews, `@override` progressive migration, team contracts". Three things were wrong with it by the time the chapter existed. It named "Orders" for a domain the repository calls Ordering and omitted the order the extraction happens in, which turned out to be the first section and the thing the dependency graph decides. It did not name the query plan at six subgraphs, where the `Parallel` node is the chapter's evidence that the seams were cut in the right places. And it did not name boundary nullability, which decision 65 explicitly assigned here and which became a section arguing the rule down from five fields to three. The line now names all six sections. Same form as decisions 33, 45, 58, 61 and 63: scope grew in detail, not in ambition. Settled 2026-08-10. |
| 75 | `Query.node` gets a service of its own | Whoever publishes `node` has to be able to return every globally addressable type, because a resolver can only return a type its own schema declares. That coupling is unavoidable; where it sits is the decision. Putting it in Catalog would make the product service declare `Customer`, `Review` and `Order`, which is the knowledge chapter 12 spent a chapter removing from one process. So `src/Mosaic.Nodes` on 5107 owns the two root fields and nothing else: four `resolvable: false` stubs, no database, no `depends_on`, no `_entities`. Its file listing is a description of the graph rather than of a domain, which is the honest form of the coupling. Measured working for all four types through the router. Settled 2026-08-10. |
| 76 | `Node` and `@key` are different promises, and Mosaic had kept only one for two types | `Node` says a client may hold this identifier and come back; `@key` says another service may hand it to the router and have the thing found. Inside one process both mean "there is a primary key". `Review` and `Order` implemented `Node` with no resolvable key, so no router could fetch either, and a `node` field returning one was impossible. Both became entities at `ch13`, with `[Key("id")]` and a reference resolver on the record behind the DataLoader their node resolvers already used. Ordering published `_entities` for the first time as a result. Settled 2026-08-10. |
| 77 | A domain record gains a parameterless constructor for one caller | `browseProducts` had shipped a broken keyset cursor since chapter 4: the selector is built from the selection set alone, so a client selecting only `title` got a `Product` whose `Id` was default and every cursor on the page carried the same tiebreaker, and page two repeated a row. The fix is `QueryContext.Include(p => p.Id)`, which does not work on a positional record: `ExpressionHelpers.Rewrite` ends in `Expression.MemberInit(Expression.New(typeof(TRoot)), ...)` and `Expression.New(Type)` wants a parameterless constructor, so it throws and the field answers `Unexpected Execution Error` with nothing in the log. `Product` therefore has a constructor whose only caller is an expression tree, and whose doc comment says so. The projection survives: two columns and the key. Settled 2026-08-10. |
| 78 | A fix no schema can see needs a gate step that does not look at the schema | The cursor repair above changes no byte of `schema/catalog.graphql`, so no composition check, schema diff or breaking-change gate could see the defect or the fix. Both verify scripts now ask for a page selecting only `title`, decode the cursor, refuse an all-zero tiebreaker, and refuse a second page that repeats a title from the first. This is the second time this book has met a fault invisible to the SDL; decision 40 was the first, where `[ID]` encoded nothing for four chapters while the schema said `id: ID!` throughout. Settled 2026-08-10. |
| 79 | A gate assertion a later chapter falsifies is updated with its reason, never loosened | Two assertions written earlier became false at `ch13` because the facts changed. `mosaic-router` asserted that `Query.node` is gone from the graph, which chapter 13 undoes on purpose; `mosaic-subgraphs` asserted that Ordering has no `_Entity` union at all, which stopped being true when `Order` became an entity. Both now assert the new fact and carry a comment saying what they used to assert and why it changed, so the diff reads as a recorded change rather than as a weakened test. The second one keeps its original claim intact in sharper form: the union exists and holds `Order`, and neither referenced type is in it. Settled 2026-08-10. |
| 80 | Chapter 13's TOC line widened | The approved line read "cross-subgraph pagination, abstract types across boundaries, shared enums/scalars, global ID design". Four topics became six sections, and two things the line did not name earned their place. Pagination split in two, because the connection that works and the page that cannot exist are different findings with different causes, and the first of them turned up a defect chapter 4 shipped. And "shared enums/scalars" turned out to be two different stories rather than one: an enum is checked and the answer depends on where it is used, a scalar is not checked at all, and putting them in one section would have buried the point that the composer's protection tracks how much structure a type has. The line now names all six sections. Same form as decisions 33, 45, 58, 61, 63 and 74: scope grew in detail, not in ambition. Settled 2026-08-10. |

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
| Microsoft.EntityFrameworkCore.Relational | 10.0.10, added at ch12. `Mosaic.ServiceDefaults` holds the `DbCommandInterceptor` that counts statements, and an interceptor is a relational type: the six services get it from the Npgsql provider and a library with no provider has to name it. |
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
10. **Enter the Router** - Cosmo Router locally: what it loads and what it serves; the storefront query answering across two services for the first time; configuration, its 66 keys and the two whose behaviour surprises; reading a query plan on a real graph; what the router costs in milliseconds; and what it does with a graph composed with the resolvability check off

### Part III - Decomposition in Practice

11. **Entity Resolution Done Right** - what `_entities` does with a list of representations, and what a DataLoader behind a reference resolver is worth; `@requires` and computed fields on the real graph, in the plan and on the wire; how the required value actually reaches the resolver; what the composer insists on around `@external`; `@provides`, what it saves and what it hides; nullability at the boundary
12. **Strangling the Monolith** - the order the dependency graph dictates, and carving Pricing/Inventory/Accounts/Reviews/Ordering out until the monolith is deleted; what a subgraph costs to make beyond its domain code; what gets copied and what gets shared, as team contracts; `@override`, its four failure modes and the progressive form this stack cannot compose; the query plan at six subgraphs and what the split actually cost; nullability at the boundary, and the checks that stop being possible
13. **Hard Modeling Problems** - the connection that works because it never crosses a seam, and what a keyset cursor is; the page you cannot ask for, why no directive fixes it, and how far `@requires` really stretches; giving a federated graph its `node` field back, and what a service that owns nothing costs; interfaces and unions across subgraphs, and `@interfaceObject`; the enum whose merge depends on where it is used; and value types and scalars, where the composer stops checking
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
| 10 | drafted | 2026-08-09. 18 pages (155--172), 6 numbered sections plus the lab, ~7,500 words, 2 TikZ figures, 51 index entries, 2 citations, 38 listings. Sources in research/2026-08-ch10-enter-the-router.md. Companion tag `ch10`; neither service changed by a line, and the tag adds the router as a compose service, `router/config.yaml`, a third Postman collection, `scripts/router-cases.mjs` and `scripts/measure-router.mjs`. Both gates pass, 33 steps. The chapter's spine is that the graph finally answers and the process in front of it is configured rather than written. Headline findings: a value in `config.yaml` beats the environment variable that sets it, measured both ways, and the router says so on the second line of its own startup log; `localhost` in a routing URL reaches the host from inside a container because `localhost_fallback_inside_docker` defaults to true, with the control showing the same query failing when it is off; the planner lifts literal arguments into variables, so `first: 3` and `first: 7` produce identical plans while a properly declared variable produces a different one; and a config composed with `--disable-resolvability-validation` starts silently, serves everything inside one subgraph, and answers HTTP 500 `internal server error` at plan time to anything that crosses, with the real cause in the log naming the wrong type. Router overhead measured at roughly 2 to 3 ms across seven passes; the two-hop and one-hop figures are not distinguishable and the chapter says so. Also records that chapter 03's instrumentation stayed in `Mosaic.Api` at the extraction, so half of every federated query is unobserved. TOC line widened in the same session (decision 61) and a new decision 62 on timings. Audited by a fresh agent, which found the latency table and the reload timings had no committed harness; both now have one. Not yet reviewed for line-level prose. |
| 11 | drafted | 2026-08-09. 18 pages (173--190), 6 numbered sections plus the lab, ~8,000 words, 2 TikZ figures, 55 index entries, 4 citations, 40 listings. Sources in research/2026-08-ch11-entity-resolution.md. Companion tag `ch11`, the first since `ch08` to change Mosaic: `Product.shippingCost` carries `@requires(fields: "category")` against an `@external` copy of Catalog's field, and `samples/entity-resolution` is two subgraphs built to be watched. Both gates pass, 38 steps. The chapter's spine is one field that cannot be answered without the other service, followed end to end. Headline findings: `_entities` calls a reference resolver once per representation and starts all of them before awaiting any, which is what makes one DataLoader batch, and the naive version of the same resolver runs strictly in sequence because its tasks complete synchronously; the required value never reaches the resolver as a parameter but is written onto the returned entity by a compiled setter that, for object types, ignores `@external` entirely and will let a representation overwrite a field the subgraph owns; a nullable `@external` copy silently weakens the field for every client with no composition error (decision 64); `@provides` saves a round trip, serves whatever the promising subgraph stored, and hides a dangling reference while doing it; and one unresolvable key through a non-null chain takes the whole response to `data: null` (decision 65). Answers two flags chapter 09 left open: `--suppress-warnings` does not touch an orphaned `@external`, which is an error, and `--ignore-external-keys` composes byte-identically because Mosaic's key is not external. TOC line widened (decision 63) and three more decisions recorded. Audited by a fresh agent, which found 26 defects including a printed cost table with no harness behind it; all fixed, and the fix moved the numbers (decision 66). Not yet reviewed for line-level prose. |
| 12 | drafted | 2026-08-10. 16 pages (191--206), 6 numbered sections plus the lab, ~7,700 words, 2 TikZ figures, 45 index entries, 38 listings, 1 new citation. Sources in research/2026-08-ch12-strangling-the-monolith.md. Companion tag `ch12`, the biggest change to the repo since it was created: `src/Mosaic.Api` is deleted, five services take its place on 5102 to 5106 with a database each, and `src/Mosaic.ServiceDefaults` is the first project there that is not a service. Both gates pass; verify.ps1 is 43 steps and verify.sh was brought to parity in the same commit. The chapter's spine is that the monolith is emptied and then deleted, and that the split moved work without adding any database work. Headline findings: progressive `@override` is rejected by wgc 0.129.7 although HotChocolate emits it (decision 71); the book's first composition warning, which finally gives `--suppress-warnings` something to do and composes a byte-identical config; a misspelled `from:` reports as a shareability error naming neither `@override` nor the misspelling; three of the six subgraphs have no root field and need an explicit `AddQueryType()`, whose failure never mentions federation; the storefront costs four statements across four services and cost four before, three of them counted and one invisible; and Reviews' resolver count fell from 146 to 26 because a pure resolver never reaches the diagnostic event the count comes from (decision 73). Decision 65's five predicted nullability changes turned out to be three, with an argument for the other two (decision 70). TOC line widened in the same session (decision 74): the approved line named a domain "Orders" that the repository calls Ordering, and did not name the extraction order, the six-subgraph query plan or boundary nullability, which are three of the six sections. Adopted from an interrupted earlier session that had done the research, the companion tag and the prose but no gates: this session ran the build, both gate scripts and the independent audit against that draft. Audited by a fresh agent, which found 30 defects; 28 were fixed, 2 rejected on the record (see open items). The expensive ones were a quotation attributed to chapter 10 that chapter 10 does not contain, ten hardcoded chapter numbers in prose where chapters 01 to 11 have none between them, and a lab exercise predicting the opposite of what the router does. Not yet reviewed for line-level prose. |
| 13 | drafted | 2026-08-10. 16 pages (207--222), 6 numbered sections plus the lab, ~7,700 words, 2 TikZ figures, 48 index entries, 59 listings, no new citations. Sources in research/2026-08-ch13-hard-modeling-problems.md. Companion tag `ch13`: `src/Mosaic.Nodes` is a seventh subgraph with no database (decision 75), `Review` and `Order` became entities (decision 76), `browseProducts` got its cursor tiebreaker back (decisions 77 and 78), and there are two new artefacts, `scripts/modeling-cases.mjs` with sixteen cases and `samples/interface-object`. Both gates pass; verify.ps1 is 98 steps. The chapter's spine is that the four problems it inherited are all decisions that were free in one process, and that two of the four compose without a word from the composer. Headline findings: an enum used only as an input is silently intersected across subgraphs, so a value one service accepts disappears from the graph, while the same enum in output position is unioned; two subgraphs declaring `Query.node` with `@shareable` composes and puts both in the routing table, which measures decision 50's assertion for the first time; a `@shareable` value type whose copies differ in nullability composes and takes the weaker side, which is decision 64's rule sighted a second time; a scalar whose two `@specifiedBy` urls disagree composes with no message and both urls are dropped; and an entity interface with one implementation missing its key crashes the composer with a stack trace rather than producing an error. The chapter also fixes a defect chapter 4 shipped: `browseProducts` built keyset cursors from a projected entity whose key was not projected, so a page selecting only `title` repeated a row, and through the router any query touching another subgraph hides it. Chapter 5's cursor-stability open item is closed with a measurement. TOC line widened (decision 80). Audited by a fresh agent, which found 30 defects; all 30 were acted on and none rejected, which is the first chapter where that has happened. The expensive ones: a composer listing carried over from a scratch probe whose subgraph names no longer exist, and a paragraph explaining a truncation that the real output does not have; two listings measured on synthetic pairs and committed nowhere, one of which turned out to be true of Mosaic itself and is now argued from the real graph; the chapter's answer to chapter 11's two `@requires` questions resting on runs nobody could repeat, now two more cases; no version pinned anywhere in seven files, against an explicit writing rule the other eleven chapters follow; and no Postman step in a chapter whose tag ships a seven-request collection. Not yet reviewed for line-level prose. |
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

- **The composer crashes rather than erroring on one modelling mistake.** An
  entity interface whose interface carries `@key` and one of whose
  implementations does not makes `@wundergraph/composition` 0.63.2 throw out of
  `handleEntityInterfaces` with a stack trace and a "please open an issue" box.
  It is committed as a case in `scripts/modeling-cases.mjs`, asserted by the
  crash message, so a release that turns it into a proper error fails the gate
  rather than making chapter 13 quietly wrong. Worth reporting upstream; nobody
  has.
- **Chapter 13 leaves these unmeasured, and the research note's section Q names
  an owner for each**: a router pointed at an `@interfaceObject` graph whose
  owning interface has no `@key`, which composes and was never run (ch 17); two
  subgraphs both contributing to the same interface (ch 17); whether an
  implementation added after the contributing subgraph was deployed really does
  get the field for free, which follows from the composition rules and was not
  run (ch 22); whether the plan cache keys on the `node` field's argument (ch
  17); what `node` costs in milliseconds against a typed root field, which
  decision 62 keeps out of the gate and no committed script measures (ch 24);
  `Query.nodes` with a list long enough to matter (ch 24); authorisation on a
  single field that can return anything in the graph (ch 15); and a cursor whose
  sort key is not unique, which the seed data has no case of, so the
  tiebreaker's job was read out of the code rather than out of a collision
  (ch 24 or a seed change).
- **`node` is a single field that returns anything in the graph, and nothing
  authorises it.** Chapter 15 owns this and should treat it as a named risk
  rather than as another field to decorate: one coarse rule on `Query.node`
  either blocks identifiers a client is entitled to or admits ones it is not,
  and the type is only known after the identifier is decoded. Worth deciding
  whether the node service should refuse types rather than the router refusing
  fields.
- **The composer can be made to run out of memory, and it reports that as a
  disagreement.** During a full `verify.ps1` run with seven .NET services and
  PostgreSQL up, one `modeling-cases.mjs` case exited non-zero having printed
  nothing at all, and the script reported it as "expected these schemas to
  compose" with an empty "what wgc actually said". The same case passed five
  times standalone. The script now retries once when the output is completely
  empty and, if it happens twice, says plainly that wgc never reported on the
  schemas. Worth carrying: a gate that cannot tell "the tool disagrees" from
  "the tool did not run" will eventually send somebody to look at the wrong
  thing.
- **Line endings bit a case script, and this is the second time they have bitten
  this repository.** `dotnet run -- schema export` writes CRLF on Windows, and
  every case script matches multi-line literals written with `\n`, so
  re-exporting a schema on this platform makes five cases fail with "matched 0
  times" until the next commit normalises the file back. `modeling-cases.mjs`
  normalises on read and says why; `composition-cases.mjs` and
  `override-cases.mjs` do not and have the same latent fault. The chapter 8 open
  item records the first sighting, a carriage return inside a JSON key under Git
  Bash. Worth fixing in the two older scripts the next time either is opened.
- **The audit found twenty-six defects in chapter 11 and the expensive one was
  a table.** Four numbers were printed as measured with nothing in the repo
  that could produce them again, which is the same defect the chapter 10 audit
  found in that chapter's latency table and the second time this has happened.
  Fixing it changed the numbers, because the reproduction the gate performs is
  not the one done by hand: the storefront query walks `Product.reviews`, a
  resolver runs per review author, and the Postman collection that runs earlier
  in the gate submits a review. See decision 66. What is worth carrying: a
  measurement is not reproducible until something reproduces it, and the act of
  making it reproducible is what finds out whether it was right.
- **Two of the chapter's own claims about HotChocolate's source were wrong on
  the first pass**, and both survived my reading of the file: the error path in
  `EntitiesResolver` is two branches rather than one `try`, and the overload
  that checks `@external` is an overload of `TryAddExternalSetter` rather than
  of `BuildFiller`, and sits above it rather than below. Reading a file is not
  the same as reading it while writing a sentence about it. Both are corrected
  in the chapter and in the research note.
- **`--ignore-external-keys` is answered as far as Mosaic can answer it.**
  Composing the committed pair with the flag produces a byte-identical file,
  because Mosaic's `@external` field is not part of a key. A schema in the
  federation v1 style, where key fields carry `@external`, is what would
  exercise it, and appendix C is where that style is described.
- **What the chapter 12 audit found, and the two things it got wrong.** A fresh
  agent reported 30 defects. The three worth carrying: the chapter twice put
  `\enquote{half of every federated query is unobserved}` in chapter 10's mouth,
  and those are the SPEC open item's words rather than chapter 10's, which say
  "unmeasured" and say it differently - quoting a planning document back as
  though it were the book is a failure mode no gate can see, because the
  `\enquote{}` is well formed and the sentence is true. Ten hardcoded chapter
  numbers in prose, in a book whose other eleven chapters contain none between
  them, which suggests the house-style rule is easy to forget precisely when a
  chapter refers back a lot. And a lab exercise that predicted a `Parallel` node
  losing a child and staying, where the router deletes the node: written from
  the plan in the research note rather than from a run, which is the same
  root cause as the chapter 10 and 11 audits found in their printed tables, now
  in a lab instead. The two findings rejected: the lab's "four services, four
  statements" was called unmeasured and is correct, now measured and recorded in
  the research note's section J.1 (catalog 1, pricing 1, reviews 1, accounts 1,
  with inventory and ordering silent); and the "second time a number answered a
  different question" claim was called a possible third, but decisions 59 and 66
  are wrong counts rather than numbers answering a different question, which is
  a distinct failure and the sentence stands.
- **Chapter 12 leaves these unmeasured, and the research file's section P names
  an owner for each**: what a router does with a graph in which a key field was
  overridden, which the composer permits and which strips the field from the
  owner's routing table (ch 17); progressive `@override` against a router that
  implements it, which this stack cannot reach because composition refuses first
  (ch 28); the latency cost of two services becoming six, which
  `scripts/measure-router.mjs` was updated for and deliberately not run, because
  its hand-assembled row is sequential where the router's three entity fetches
  are parallel (ch 24); mutations through the router, which are still exercised
  against the Reviews subgraph directly (ch 14); `onReviewAdded` through the
  router (ch 14); and whether six services need six databases rather than six
  schemas in one, which is asserted as policy and was not compared (ch 21 or
  26).
- **The Postman collection was replaced rather than patched, for the second
  time.** Decision 54 retired the single-service collection at `ch08` because
  most of its requests asked a port that had moved. `mosaic-federation` went the
  same way at `ch12` for the same reason, and `mosaic-subgraphs` replaces it with
  fourteen requests across all six services. Worth noticing as a pattern: a
  collection outlives roughly two extractions before its URLs are more wrong
  than right, and patching one is slower than rewriting it.
- **`scripts/measure-router.mjs` now compares four sequential calls against four
  fetches the router makes in parallel**, and that comparison flatters the
  router. It was honest at two services where the two calls really were
  sequential on both sides. Anybody re-running it should either parallelise the
  hand-assembled row or stop treating the difference as router overhead.
- (mostly resolved 2026-08-10) **Chapter 11 left these unmeasured, and the
  research note's section N named an owner for each**: nested and multi-subgraph
  `@requires` field sets (ch 13), `@override` (ch 12), `@provides` where the copy
  is a real cache with an invalidation story (ch 24), whether the plan cache keys
  on any of the representation machinery (ch 17), `@interfaceObject` (ch 13),
  shared enums as a subject rather than as a composition case (ch 13), two
  overlapping `_entities` requests under load (ch 24), and what a subgraph should
  do about a representation that can set its own fields (ch 25). **Chapter 13
  answered its three.** A nested field set composes, and so does one naming
  fields from two other subgraphs, with the three fields landing in three
  services in the routing table; what `@requires` cannot do is help choose which
  entities a page contains, because it runs after the router has located them.
  `@interfaceObject` got a sample and a router. And the enum question turned out
  to have three answers rather than one, depending on where the enum is used.
  Chapter 12 answered `@override`; the other four are still open.
- (resolved 2026-08-09) **Chapter 10 answered the question chapter 09 refused
  to guess at.** A router handed a config composed with
  `--disable-resolvability-validation` starts with no warning, serves every
  query that stays inside one subgraph, and answers HTTP 500 `internal server
  error` to anything that crosses. It fails at plan time, in under a
  millisecond, with `X-WG-Skip-Loader` set, so no subgraph is called. The
  router's log carries the cause and it names the wrong type: `Cannot query
  field "price" on type "Query"`, because the planner is describing a document
  it wrote rather than the one the client sent. Committed as the
  `resolvability-off` case. Chapter 09's other owed question, the subscription
  protocol in the config, is still chapter 14's.
- (resolved 2026-08-09) **The latency cost of chapter 08's extraction, which
  chapter 08 assigned to chapter 10.** Roughly 2 to 3 ms of router overhead on
  this machine across seven passes, against a hand-assembled two-call baseline
  rather than against the monolith, which no longer exists to measure.
  `scripts/measure-router.mjs` reproduces it. Two things not to carry forward:
  these are upper bounds, because the router crosses Docker's bridge and the
  direct rows do not; and the difference between one-hop and two-hop overhead
  is smaller than the run-to-run spread, so there is no finding there.
- **Chapter 09 and an early draft of chapter 10 both overclaimed the same
  thing.** Chapter 09 closes by saying the router will answer across a boundary
  "for the first time anything in this book will have answered one across a
  boundary without me assembling the answer by hand". Chapter 07's sample
  router did it first, on `samples/federated-wire`. Chapter 10 now says "the
  first answer about Mosaic"; chapter 09's sentence is unchanged and is one
  clause to tighten whenever that chapter is next opened. The audit caught it
  in chapter 10 and only then in chapter 09, which is the usual direction.
- **(half resolved 2026-08-10) Half of every federated query was unobserved, and
  nothing announced it.** Chapter 03 built the request timeline, the resolver
  count and the lookup counter inside `Mosaic.Api`; chapter 08's extraction left
  all three there, so `Mosaic.Catalog` reported nothing about any request.
  Chapter 12 moved all three into `Mosaic.ServiceDefaults` and all six services
  report now, which turned "half of every query" into a measured number: it was
  one statement out of four, and the interesting part is that nobody could have
  said which. That is the registration half. The other half is untouched and is
  the one chapter 23 owns: six services each reporting their own timeline is six
  unrelated timelines, and nothing in a response says which of them belong to
  the same federated query. Do not read chapter 12's change as closing this.
- **The router's execution-config watcher reads the file's modification time,
  not its content.** Rewriting a byte-identical config reloads the graph;
  restoring an older-stamped copy over a newer one does not reload at all. That
  second half bit while writing `scripts/measure-router.mjs`, whose restore
  path used `copyFileSync`, which carries the source's mtime across on Windows.
  The script writes bytes now and says why. Worth remembering anywhere a
  deployment copies a config into place rather than writing it.
- Chapter 10 leaves these unmeasured, and the research file's section L names
  an owner for each: the router's plan cache and whether it keys on the
  normalised document (ch 17), mutations and subscriptions through the router
  (ch 12 and 14), `subgraph_extension_propagation` (ch 23), a subgraph that is
  down, slow or erroring beyond one accidental data point (ch 24), header
  forwarding and the `headers` block (ch 15), the Prometheus endpoint (ch 23),
  `overrides.subgraphs.routing_url` (ch 21 or 22), and the 61 of 66 top-level
  configuration keys nothing in this chapter touches.

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
- (mostly resolved 2026-08-10) Chapter 09 left these unmeasured, and the
  research file's section M named an owner for each: anything a router does with
  this config including what it does with one composed with the resolvability
  check off (ch 10, done), the `GRAPHQL_SUBSCRIPTION_PROTOCOL_WS` in the config
  against a subscription chapter 05 exercised over SSE (ch 14),
  `--split-configs-enabled`, `--ignore-external-keys` and `--suppress-warnings`,
  composition warnings of any kind since Mosaic produces none, composition
  across more than two subgraphs, and whether an Apollo-style annotated
  supergraph SDL can be obtained from wgc at all (ch 28). Chapter 11 answered two
  flags: `--suppress-warnings` changes nothing about an orphaned `@external`,
  which is an error rather than a warning, and `--ignore-external-keys` composes
  byte-identically because Mosaic's key field is not the external one. **Chapter
  12 answered the other two.** Six subgraphs compose, first time, with no edit
  to any schema, and the messages the six composition cases produce changed in
  three of the six because they now name a different subgraph (decision 72).
  And Mosaic finally produces a warning: `@override` naming a subgraph that is
  not in the graph, exit code 0, config written, and `--suppress-warnings`
  silences it while composing a byte-identical file. Only
  `--split-configs-enabled` is still untouched.
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
  `Query.node` can be given back to a federated graph at all (ch 13, answered:
  yes, at the price of a service that declares every addressable type and owns
  no data, and of two types having to become entities first).
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
  (ch 13, answered), and `MaxPageSize` (ch 25). **The cursor question is
  closed.** HotChocolate 16's connections are keyset paged, so a review inserted
  a second before the row a cursor points at neither repeats nor skips anything
  on the next page, where the same data by `offset 2 limit 2` repeats the row
  page one already returned. The price of the stable view is that the inserted
  row is invisible to that client until it starts again from page one. Chapter
  13's research note section D records the insert and both results.
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
