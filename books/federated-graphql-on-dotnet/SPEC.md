# SPEC - Federated GraphQL on .NET

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Federated GraphQL on .NET**
Subtitle: *Building and running distributed graphs with HotChocolate and
WunderGraph Cosmo*
Author: Giang Dang

## Status

Chapters 01 and 02 drafted (2026-08-08). The companion repo exists, is public
at https://github.com/Giang-Dang/mosaic-graph, and is tagged `ch02`. Next
action: chapter 03, which walks the request lifecycle against that same
service; nothing blocks it.

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
| 12 | Voice | First-person practitioner; humanizer bar (library defaults in CLAUDE.md) |
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

## Version baseline

Verified 2026-08-08; details and sources in
research/2026-08-federation-landscape.md. Re-verify before drafting chapters
that depend on them.

| Component | Version |
|-----------|---------|
| HotChocolate / HotChocolate.ApolloFederation | 16.6.0 (2026-08-05). Ships net8.0, net9.0, net10.0 and net11.0 assets; "targets .NET 8+" understates it. Re-confirmed from the nuspec 2026-08-08. |
| HotChocolate.Templates | 16.6.0. Note the id: `ChilliCream.HotChocolate.Templates` does not exist. |
| WunderGraph Cosmo (router, wgc CLI) | current as of Aug 2026 - pin exact versions when the companion repo is created |
| ChilliCream Fusion (ch 27) | 16.5 |
| Apollo Federation specification | v2.15 (LTS, Jul 2026) |
| .NET | 10 (LTS) |

## Table of contents

Approved 2026-08-08. If drafting deviates, update this list in the same
session. Chapter folders in chapters/ carry the same scope lines.

### Part I - One Service Done Right

1. **Why One Graph Is Never Enough** - single-schema failure modes, team coupling, where federation fits, the Mosaic storefront, first pass at "do you need this" (ch 26 in full)
2. **HotChocolate, Quickly** - first service on .NET 10; implementation-first vs code-first (and what happened to schema-first); Mosaic monolith v1; the Postman dev loop
3. **The Life of a Request** - parsing, validation, operation compilation, resolvers, middleware; first source-guided walk
4. **Data Without the N+1** - EF Core, DataLoader usage and batching internals, projections/filtering/sorting/pagination
5. **Schema Design That Survives Change** - abstract types, Relay conventions, error design, deprecation, single-service subscriptions

### Part II - Thinking in Entities

6. **The Federation Model** - supergraph/subgraphs, entity ownership, the Apollo Federation v2 directive tour, composition rules conceptually
7. **How a Federated Query Actually Runs** - query plans, representations, `_entities`/`_service`, exact router-subgraph HTTP traffic, captured in Postman
8. **The First Cut: Extracting Catalog** - HotChocolate.ApolloFederation, reference resolvers, extending foreign entities; testing a naked subgraph in Postman before any router exists
9. **Composition** - satisfiability, reading composition errors, `wgc router compose` (router-only), supergraph anatomy
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
| 03 | not-started | |
| 04 | not-started | |
| 05 | not-started | |
| 06 | not-started | |
| 07 | not-started | |
| 08 | not-started | |
| 09 | not-started | |
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

Library-wide defaults are in CLAUDE.md; these are this book's additions.

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

## Open items

- (resolved 2026-08-08) Companion repo created, verified and published:
  https://github.com/Giang-Dang/mosaic-graph, tag `ch02`. `scripts/verify.ps1`
  is the gate a tag has to pass; it builds in Release with warnings as errors,
  checks the committed SDL against a fresh export, asserts 25 products / 120
  reviews / 146 lookups, and runs the Postman collection through newman.
- (resolved 2026-08-08) "Mosaic" confirmed as the demo name; see decision 24.
- The "Your turn" apparatus has now been used twice (ch 01 unlabelled
  `\section*`, ch 02 the same). It still does not need a macro: the heading is
  one line and the two labs differ in shape, ch 01 being a no-code audit and
  ch 02 a six-exercise lab against a repo tag. Revisit if a third form appears
  or if the labs ever need to be cross-referenced.
- Chapter 02 leaves three things deliberately unfixed, each promised to a named
  chapter: `reviews` is a plain list (ch 05 makes it a connection), errors are
  bare exceptions (ch 05 designs an error model), and nothing is authorised
  (ch 15). If any of those chapters moves, ch 02's closing section needs
  updating with it.
- Chapter 04 inherits a hard number: 146 lookups on the catalog-with-reviews
  query, down to 3 with DataLoaders. Measured latency for that query at tag
  `ch02` was a 3 ms mean over ten warmed-up runs; ch 02 quotes it with "I timed"
  framing, and the reproduction is in the ch 02 research file. `MosaicDataOptions.LookupDelay` ships at zero so
  ch 04 can make a lookup cost something before Postgres enters the story.
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
