# SPEC - Federated GraphQL on .NET

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Federated GraphQL on .NET**
Subtitle: *Building and running distributed graphs with HotChocolate and
WunderGraph Cosmo*
Author: Giang Dang

## Status

Chapter 01 drafted (2026-08-08); everything else is scaffold. Next action:
create the companion repo F:/repo/mosaic-graph, which chapter 02 needs before
it can be drafted.

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

## Version baseline

Verified 2026-08-08; details and sources in
research/2026-08-federation-landscape.md. Re-verify before drafting chapters
that depend on them.

| Component | Version |
|-----------|---------|
| HotChocolate / HotChocolate.ApolloFederation | 16.6.0 (2026-08-05) |
| WunderGraph Cosmo (router, wgc CLI) | current as of Aug 2026 - pin exact versions when the companion repo is created |
| ChilliCream Fusion (ch 27) | 16.5 |
| Apollo Federation specification | v2.15 (LTS, Jul 2026) |
| .NET | 10 (LTS) |

## Table of contents

Approved 2026-08-08. If drafting deviates, update this list in the same
session. Chapter folders in chapters/ carry the same scope lines.

### Part I - One Service Done Right

1. **Why One Graph Is Never Enough** - single-schema failure modes, team coupling, where federation fits, the Mosaic storefront, first pass at "do you need this" (ch 26 in full)
2. **HotChocolate, Quickly** - first service on .NET 10; annotation-based vs code-first vs schema-first; Mosaic monolith v1; the Postman dev loop
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
| 02 | not-started | needs companion repo first |
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

- Companion repo F:/repo/mosaic-graph: create when chapter 02 drafting starts.
- Demo retailer name "Mosaic" is provisional; confirm or rename before the
  companion repo is created (rename is a find-and-replace until then).
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
