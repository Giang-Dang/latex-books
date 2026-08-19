# SPEC - Splitting the Graph

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Splitting the Graph**
Subtitle: *Federated GraphQL with Hot Chocolate and Cosmo on .NET*
Author: Giang Dang

## Status

Settled 2026-08-19 through a seven-round requirements interview. Chapters 1 and
2 are drafted. The verification repo exists at
`F:/repo/splitting-the-graph-graph` with both branches tagged for chapter 2 and
`verify.ps1` passing on each. Next action: chapter 3, which replaces the
in-memory store with SQLite and EF Core and produces the single-service
statement counts chapter 10 measures against.

**Why this book exists.** It is the second book in this library on federated
GraphQL in .NET, and it exists because the first one,
`federated-graphql-on-dotnet`, failed its reader in three specific ways. Those
three failures are the reason for most of the decisions below, so they are
stated here rather than buried in the log:

1. **Code the reader could not see.** Listings were fragments whose enclosing
   file lived in a companion repo. A reader who had not cloned the repo was
   shown a method and expected to supply the other two hundred lines from
   somewhere. Decisions 15, 16 and 17 exist to make this impossible.
2. **Chapters that circled.** Seventeen chapters of six sections each, with no
   fixed shape and no rule about what came first, so a reader could finish a
   section unable to say what it had claimed. Decisions 13 and 14 exist to make
   this impossible.
3. **Prose that narrated the author's own bug fixes.** Pages spent on wrong
   turns, control runs and corrected measurements, which are lessons about how
   the author works rather than about federated GraphQL. Decisions 19 and 22
   exist to make this impossible.

Each of those three is a design failure with a mechanical fix, not a matter of
writing better sentences. If a drafting session finds itself arguing that an
exception is warranted, the exception is the failure returning.

## Decision log

Settled 2026-08-19. A settled row is re-opened only by recording what changed
and why, in the row.

| # | Question | Decision |
|---|----------|----------|
| 1 | Why this book | To do what `federated-graphql-on-dotnet` did not: put the whole program on the page, give every chapter a shape, and keep the author's debugging out of the reader's book. The three failures are stated in Status above and are the origin of decisions 13 to 22. |
| 2 | Relationship to `federated-graphql-on-dotnet` | That book is left exactly as it is: not frozen in its own SPEC, not annotated, not deleted. **Nothing is reused** - no prose, no figures, no research notes, no bib entries. Every fact this book prints is re-established from source here. Its `research/` remains a place to look for a starting URL, but a fact only enters this book through this book's own note. |
| 3 | Title and slug | *Splitting the Graph*, subtitle *Federated GraphQL with Hot Chocolate and Cosmo on .NET*, folder `splitting-the-graph`. The other book holds *Federated GraphQL on .NET* and the two must not be confusable in a `books/` listing. |
| 4 | Language | English. Considered and rejected: Vietnamese, and Vietnamese prose with English technical terms. The difficulty being fixed is structural, not lexical. |
| 5 | Spine | Apollo Federation v2 subgraphs built with `HotChocolate.ApolloFederation`, composed with `wgc` and served by the WunderGraph Cosmo Router. |
| 6 | Why not Fusion | Fusion cannot span the two versions this book covers. The Fusion v1 line (Hot Chocolate 13 and 14 era, `fusion compose` CLI, pre-spec directives) ended at 15.1.17 on 2026-06-16, and Fusion 16 is a complete rewrite on the GraphQL Composite Schemas specification, composed with Nitro CLI. They are different products, and a reader on 14 could not follow a Fusion 16 chapter at all. `HotChocolate.ApolloFederation` shipped in the 14 era and still ships in lockstep with 16, which makes Apollo Federation v2 the only subgraph contract reaching both. |
| 7 | Why Cosmo and not Apollo Router | Cosmo Router is Apache-2.0, self-hostable, and speaks Federation v1 and v2, so it composes subgraphs regardless of which Hot Chocolate produced them. Apollo Router Core is Elastic License v2, which forbids offering it as a managed service - an awkward thing to teach in a book about running your own graph. Hive Router was considered and is the strongest alternative; rejected only because a book with no reader-facing repo cannot afford to teach two gateways shallowly. |
| 8 | Versions covered | Hot Chocolate 16 is the spine. Hot Chocolate 14 appears as inline boxed callouts where the API difference changes the reader's code, plus appendix B in full. HC 14 is out of support - the platform's SECURITY.md lists only 16.x and 15.x - and the preface says so plainly: 14 coverage exists to get a reader off 14, not to endorse staying. |
| 9 | Companion repo | **None that a reader ever hears about.** No URL, no tags, no checkout instructions, nothing in the preface. See decision 10 for what exists instead, and decision 15 for what replaces it on the page. |
| 10 | The verification repo | One local repository at `F:/repo/splitting-the-graph-graph`, never pushed and never mentioned in the book. `main` carries the conference example on .NET 10 and Hot Chocolate 16. A long-lived `hc14` branch carries only the files an HC 14 callout quotes, pinned to Hot Chocolate 14.3.1 on `net8.0`, because 14 does not target .NET 10. |
| 11 | HC 14 callouts are compiled | An "On HotChocolate 14" callout may only say what the `hc14` branch compiled. A callout sourced from documentation and never built is the invented-listing failure wearing a version number. Rejected alternatives: documentation-sourced callouts, and prose-only pointers to appendix B. |
| 12 | Shape | Two movements. Parts I and II take a reader from zero to a working three-subgraph federated graph. Part III is problems-first: each chapter opens with a failure a reader will actually meet, reproduces it, explains the mechanism underneath, and fixes it. Part IV covers living with the result. Problems-first suits a book with no repo, because a problem chapter is self-contained by construction: it needs the failure, not everything that came before. |
| 13 | Chapter skeleton | Five beats, same order, every chapter. **(1) The one sentence** - what this chapter establishes, stated first, before anything else; a chapter needing two sentences is two chapters. **(2) Show it** - the thing running, or in Part III the thing failing, with code and output on the page. **(3) Why it does that** - the mechanism; all theory lives here. **(4) Do it properly** - the complete, correct implementation. **(5) Summary box.** |
| 14 | The ordering law | No concept is explained before the reader has seen the behaviour it explains. This is the direct inverse of the first book's habit of theory followed by code the reader could not see, and it is what beat 3 following beat 2 enforces. |
| 15 | Listings are build-along and complete | Every file appears in full the first time it matters. The reader can type the entire system out of the book. No listing is a fragment of something that lives elsewhere, because there is no elsewhere. |
| 16 | How a change to an already-shown file is typeset | The full file again, with changed lines marked by minted's `highlightlines` and a caption naming what moved. For a file too long to reprint, the complete enclosing member - whole class or whole method - with the same highlighting. **Never a unified diff**: three lines of context is the same failure as a fragment, in miniature. |
| 17 | Source appendix | Appendix E carries the final complete source of all three subgraphs. Estimated 25 to 35 pages for a three-service SQLite example. This was rejected earlier in the interview on the assumption of a larger example and reinstated when decision 23 fixed the example's size. |
| 18 | Provenance is not declared | The book makes no statement about how its listings were produced. It does not need to: decision 15 puts the whole program on the page, so a reader who doubts a listing can compile it. Rejected alternatives: a preface contract, and per-listing markers. |
| 19 | Counts yes, timings never | A count - SQL statements issued, `_entities` calls made, round trips taken - is deterministic and reproducible by a reader who typed the code out of the book, and it carries the whole argument of chapter 10. A timing is a property of one machine, cannot be reproduced by any reader, and is the largest single source of the measurement narration decision 22 bans. No milliseconds appear in this book. |
| 20 | Chapter apparatus | No end-of-chapter labs. Each chapter closes with a summary box, which is the single named exception to the Economy line. |
| 21 | Summary box shape | Parts I, II and IV: the chapter's claims as three to five bullets. Part III: a fixed three-line **symptom, cause, fix** - the symptom a reader will search for, the mechanism underneath it, and the change that fixes it. That triple is what a reader flips back to find months later, which is why it is not a restatement. |
| 22 | The book never narrates the author's debugging | A problem earns space if it is a property of federation, Hot Chocolate or Cosmo that a competent reader will meet. It earns none if it is a property of the author's code being wrong. Wrong turns, control runs and corrected measurements go in `research/` and never reach prose. First person is for judgement and choice, never for a debugging log. The one carve-out: a listing shown deliberately broken to demonstrate a failure mode is the reader's problem, not the author's, and stays. |
| 23 | Running example | A conference system: Sessions, Speakers, Ratings. Three subgraphs, SQLite or in-memory, no container, no message broker. Chosen because the cross-seam paging problem is obvious in it rather than contrived - everyone understands sorting sessions by rating, and everyone can see why the service owning sessions cannot do it - and because it resembles nothing in the other book. |
| 24 | The hard cases the book owns | Twelve, established by research on 2026-08-19 and recorded in `research/2026-08-hard-cases.md`. Six mechanical ones take a chapter each: N+1 at the reference resolver; entity representation order; `_entities` bypassing authorization; cross-subgraph filter, sort and paginate; non-null blast radius; satisfiability and `@requires`. Ownership takes a chapter of its own because it is the failure that kills federation projects. Breaking changes and the REST-shaped schema share one. Blame routing and latency share one. The adoption threshold opens the book. |
| 25 | Length | No ceiling, on the book or on any chapter. Recorded as a decision rather than an omission: the author was shown that the other book removed its ceiling at 358 pages with eleven chapters unwritten, and chose this anyway. The four controls that stand in a ceiling's place are decision 13's one-sentence rule, decision 13's skeleton, decision 14's ordering law and decision 22's ban. |
| 26 | Voice | First-person practitioner. First person singular, opinionated where experience warrants it and willing to concede. No contractions in my own voice; they appear only inside quoted material. Sentence length varies. Claims are concrete - a company, a date, a count, a name. Bounded by decision 22: first person for judgement and choice, never for a debugging log. |
| 27 | Economy | Tight, as AGENTS.md sets it. Say it once, no setup paragraph before the paragraph that does the work, one idea per paragraph, every sentence carries a fact, a decision or a consequence. Economy is not sentence length and does not touch decision 26's cadence. One named exception: the decision 20 summary box. |
| 28 | Humanizer skill | `humanizer`. The book is in English, so drafts are judged against the English tone profiles. |
| 29 | Spelling | `en-US`. Enforced by `check-chapter.psd1`. The exemption list starts **empty**; the words that will need it are British spellings appearing inside captured tool output and vendor prose, added one at a time as the gate finds them. |
| 30 | Characters | Strict `Ascii` mode, with the captured-output exception on `minted:text`, because composition errors and router output contain punctuation that is not ours to edit. Both halves are required and no control character is forgiven, so the exception cannot reach prose or an invented listing. |
| 31 | How SDL is typeset | Two environments. Executable GraphQL - queries, mutations, fragments - uses `\begin{minted}{graphql}`. SDL uses `\begin{graphqlsdl}`, defined in `preamble/packages.tex` as minted's Ruby lexer under an honest name. Measured on this machine 2026-08-19: Pygments 2.19.2's `graphql` lexer emits **77 Error tokens** on a nine-line federation SDL snippet using `@key`, `@external`, `extend type` and `!`; the `ruby` lexer emits **0**. A custom Pygments lexer is blocked in practice, because minted v3 needs a per-machine `.latexminted_config` to load one, which breaks a fresh clone and the pre-commit build gate. Revisit if Pygments ships an SDL lexer. |
| 32 | HC 14 callouts on the page | A boxed environment titled "On HotChocolate 14", defined once in `preamble/macros.tex`. A reader on 16 must be able to skip every one of them without losing the thread, and only a visual break makes that possible. It also makes the appendix B cross-reference mechanical rather than hand-written each time. |
| 33 | Figure idiom | Engineering-drawing style: square corners, no fills, single stroke weight, sans-serif labels, black on white. Deliberately unlike the other book's rounded corners and Stealth arrowheads. Biased hard toward sequence and timeline figures over box-and-arrow architecture diagrams, because this book's difficulty is what happens in what order - the router fanning out, `_entities` batching, non-null errors propagating upward - and a box diagram cannot show order. Two recurring visuals are fixed once and reused: the seam between two subgraphs, and the router. |
| 34 | Clients and the dev loop | Nitro appears in Part I only, capped at three screenshots in the whole book, because screenshots are the fastest-rotting content in a technical book. Postman carries the repeatable request sets in Parts II to IV. **Every request is also printed as raw HTTP**, so no page depends on a tool the reader has not installed. |
| 35 | Version pinning | One version table, in appendix A. No chapter names a version anywhere else, so bumping the toolchain is one edit and no chapter can go stale independently of another. Re-verified once before release rather than per chapter. Per-chapter pinning was rejected: it existed in the other book to serve two source-diving chapters, and this book has none. |
| 36 | Research notes | `research/` holds one note per chapter. A note records every external fact with its source URL and access date, every version pinned, every count with the procedure that reproduces it, and **every claim that was checked and found false**, so a later chapter does not re-derive it. |
| 37 | Citations, quotes, index | Citations are `~\autocite{...}`, always with the tilde, so a bracketed number can never start a line. Quoted material uses `\enquote{}` (csquotes), never literal quote characters. The index is maintained while writing, not retrofitted. |
| 38 | What to do when no source passes the Sources bar | State the claim as my own judgment, in first person, and cite nobody. Settled while drafting chapter 1, whose central claim is the adoption threshold: no named engineer has published one, and the only source that gives a threshold at all is a vendor guide bylined "WunderGraph" with no author. The two rejected alternatives are citing the weak source anyway, which launders a vendor's marketing into an authority, and dropping the claim, which would gut the chapter the book opens with. A judgment labelled as judgment is honest and is what decision 26's "opinionated where experience warrants it" is for. This is a precedent, not a one-off: a later chapter in the same position does the same thing and says so. |
| 39 | Whether an unsigned document passes the Sources rule | Yes, when it is the artifact rather than a claim about the artifact. The Sources rule exists to stop a vendor's prose about a company or an outcome being read as evidence, and a byline is what separates evidence from marketing in that case. It does not reach three things chapter 1 cites unsigned: a standards body recording its own working group (the GraphQL Specification Working Group on its Composite Schemas Subcommittee), a specification's publisher defining that specification, and the normative list of what a specification requires of an implementation (Apollo's subgraph specification, which is where chapter 1's four-requirement count comes from). All three can be checked against a running implementation, which is what a byline would otherwise be standing in for, and `research/2026-08-hard-cases.md` already cites unsigned RFC documents on the same basis. Still barred: any unsigned vendor page arguing a result, including one about that vendor's own customers. A chapter relying on this row records the reasoning in its research note rather than leaving it implicit, because an audit reading the chapter cold cannot tell a considered call from an oversight. |
| 40 | Non-ASCII letters in cited authors' names | An accent macro, never the Unicode letter and never a respelling. Decision 30 puts the book in strict `Ascii` mode, so `Philip M\uml{u}ller` is written with the `\uml` wrapper defined in `preamble/macros.tex`; spelling him "Mueller" would misspell a real person, and the raw `\"u` trips the prose gate's quote check, which reads the accent's double quote as a literal quotation mark. The wrapper exists to keep both the name and the gate correct. |
| 41 | Every box in the book wears one skin | `bookbox`, defined once in `preamble/macros.tex` and worn by the decision 32 callout and both decision 21 summary boxes. Settled while drafting chapter 1, which needed the first summary box and found the callout it was built to match rendering wrong: the title was drawn in white on white and invisible, and `attach boxed title to top left` drew its tab but then only the left rule of the box, with no top, right or bottom edge. Both are fixed in the shared skin, so neither can be reintroduced by a chapter copying the old pattern. |
| 42 | A build file printed in full carries its own version pins | Decision 35 says no chapter names a version outside appendix A, and it means prose. A `.csproj` shown complete under decision 15 necessarily carries `Version="..."` on each `PackageReference`, and a reader typing it out needs those numbers. So the rule reads: no chapter states a version in a sentence, and a build file printed as a listing shows what it actually pins. Appendix A stays the one place the table lives, and stays the thing re-verified before release. Settled while drafting chapter 2, which prints the first `.csproj`. |
| 43 | The verification repo's one layout rule | One folder per service under `src/`, and **no project reference between them, ever**: no shared model library, no `Common` project, no linked source file. Where two services need the same shape, each declares its own copy. Chapters 6 and 9 split this graph into subgraphs that would in real life be separate repositories owned by separate teams, and a shared type would make the book demonstrate the opposite of what it says. Recorded here rather than only in the repo's README because the extraction chapters depend on it and the repo is not the source of truth. |
| 44 | Where a chapter's requests go | Sessions on port 5001, Speakers on 5002, Ratings on 5003, each pinned in the service's own `Properties/launchSettings.json` with `launchBrowser` off. `dotnet new web` picks a random port, so a book that prints raw HTTP under decision 34 has to pin one or its addresses are fiction. The launch profile is therefore a file the book prints in full like any other. The router's port is chapter 8's to settle. |
| 45 | Nitro is served from the package, not the CDN | Every service in this book sets `Tool.ServeMode` to the embedded build. Measured 2026-08-19: under the default, `ServeMode.Latest`, a request to the local endpoint comes back with `Server: cloudflare` and a `Last-Modified` later than the assembly's build date, because the IDE is fetched from ChilliCream's CDN and passed through; with `Embedded` the same request is answered by Kestrel from the 17.9 MB copy in the package. A book whose reader must see what the author saw cannot depend on a component that updates itself. What happens with no network was **not** established, so no chapter claims anything about it. |
| 46 | Nitro screenshots | None. Decision 34 caps the book at three and spends none of them in chapter 2, which describes the IDE and prints every request as raw HTTP instead. The budget is unspent, not withdrawn; a later Part I chapter may take it. Recorded so that a future session does not read the absence as an oversight and add one. |
| 47 | What the `hc14` branch carries | Whatever the callouts issued so far actually quote, plus the minimum needed to compile them, and nothing else. Settled by chapter 2, which was the open case. For chapter 2 that happens to be the whole first service, because the callout covers the whole of `Program.cs` and the project file; the branch is not therefore a running port of the book, and from chapter 3 it keeps only what a live callout still quotes. Kept in step with `main` by cherry-picking the shared files rather than by merging, so the two `Program.cs` files can differ permanently. |
| 48 | The chapter's request set lives in `verify.ps1` | Every request a chapter prints, and every response it quotes, is asserted by the verification script before the prose is written. Chapter 2 asserts twelve, including the two the callout's version comparison rests on. This is what makes decision 11's rule enforceable rather than aspirational: a callout that stops being true fails a run instead of ageing quietly on the page. |
| 49 | `xml` joins the listing environments | Added by chapter 2, which prints a `.csproj` in full under decision 15. The project file is a file the reader types, so it is a listing like any other, and `minted{xml}` is the environment that renders it. No other build file format is admitted by this row: a `.json` launch profile uses `json`, which was already on the list. |
| 50 | The listing measure is 73 columns | Measured in the book itself on 2026-08-19 at its own geometry and `\setminted` settings: a 73-column line fits and a 74-column line gains a continuation arrow nobody chose, while the build log stays silent either way. Every C# file the book prints is written to 73. A block that genuinely cannot be, a package identifier or a vendor's own directive description, declares `fontsize=\footnotesize` in its option list, and captured output with no break point anywhere adds `breakanywhere`. Re-measure if the geometry or the mono font changes. |

## Version baseline

Partly verified. Rows marked verified were measured on this machine on the date
shown and the procedure is in the named research note; the rest are still
starting points carried in from the interview. Verify each before drafting the
chapter that depends on it. Decision 35 puts the verified table in appendix A,
and this section is what appendix A is built from.

| Component | Version | Status |
|-----------|---------|--------|
| .NET SDK (`main`) | 10.0.303 | verified 2026-08-19, chapter 2 note |
| .NET runtime (`main`) | 10.0.11, LTS, supported to 2028-11-14 | verified 2026-08-19, chapter 2 note |
| .NET (`hc14` branch) | `net8.0` | verified 2026-08-19: 14.3.1 targets net6.0 to net9.0 and not net10.0 |
| HotChocolate / HotChocolate.ApolloFederation (`main`) | 16.6.1 | verified 2026-08-19, chapter 2 note; the two are on the same version sequence |
| HotChocolate (`hc14` branch) | 14.3.1 | verified 2026-08-19 as the last stable 14.x: no 14.3.2, and 14.4.0 shipped only as prereleases |
| WunderGraph Cosmo Router | unpinned | to verify before chapter 8 |
| `wgc` (Cosmo CLI) | unpinned | to verify before chapter 7 |
| Pygments | 2.19.2 | verified 2026-08-19 on this machine; see decision 31 |

Two things the interview assumed and the measurement corrected. The version is
16.6.1 rather than 16.6.0. And Hot Chocolate 16 targets `net8.0`, `net9.0`,
`net10.0` and `net11.0`, so a reader on .NET 8 can move to 16 without moving
framework, which is a more useful thing for an "On HotChocolate 14" callout to
say than anything about what 14 lacks.

## Table of contents

Approved 2026-08-19. If drafting deviates, update this list in the same
session. Chapter folders in `chapters/` carry the same scope lines.

### Part I - Foundations

1. **Do You Actually Need This?** - what federation costs, the coordination problem it solves, the threshold below which a modular monolith wins, and explicit permission to stop reading
2. **Hot Chocolate from Zero** - the first service, implementation-first types, the schema it produces, and the development loop
3. **Data Without the N+1** - SQLite and EF Core, DataLoader, projections, paging; the single-service version of the problem chapter 10 meets again across a seam
4. **Schema Design That Survives Change** - Relay conventions, abstract types, error design, deprecation, and the first pass at nullability that chapter 14 collects on

### Part II - Federation End to End

5. **The Federation Model** - supergraph and subgraphs, entity ownership, keys, and the Apollo Federation v2 directive tour
6. **Your First Subgraph** - `HotChocolate.ApolloFederation`, `@key`, reference resolvers, and what `_service` and `_entities` expose
7. **Composition** - `wgc router compose`, what a router execution config actually contains, and satisfiability as a graph walk
8. **Enter the Router** - Cosmo Router locally, what it loads and what it serves, and the first query answered across two subgraphs
9. **The Second and Third Subgraph** - the seams, `@external`, `@requires` and `@provides`, and the graph the rest of the book uses

### Part III - The Problems

10. **The N+1 the Router Creates** - the router batches representations and a naive reference resolver does not; what a DataLoader behind one is worth
11. **Right Data, Wrong Entity** - `_entities` must answer in representation order, and what silently wrong data looks like when it does not
12. **`_entities` Never Asks Who You Are** - the guard on the root field that the entity route walks straight past
13. **The Page You Cannot Ask For** - filtering, sorting and paginating across a seam; why no directive fixes it, and the dedicated search domain as the escape
14. **One Field Fails and the Response Is Empty** - non-null error propagation, blast radius, designing for partial failure, and `@semanticNonNull`
15. **Where Satisfiability Actually Fails** - reading composition errors, and why the composer blames one route out of four that fail
16. **The Subgraph That Broke Everyone** - breaking changes as the highest availability risk, schema checks as a gate, and the REST-shaped schema nobody uses
17. **Nobody Owns That Field** - ownership, governance, and schema evolution as a social problem wearing an API problem's clothes
18. **Slow, and Nobody Knows Which Subgraph** - trace correlation across the router and three subgraphs, routing a failure to its owner, and caching

### Part IV - Living With It

19. **Testing a Federated Graph** - reference-resolver tests, composition checks as tests, contract tests
20. **Observability, Resilience and Hardening** - OpenTelemetry across the router and subgraphs, timeouts and partial failure, depth and complexity limits, introspection policy

### Appendices

- A. **Toolchain and Versions** - setup, and the one version table decision 35 names
- B. **HotChocolate 14, in Full** - the 14-to-16 mapping every callout points at
- C. **Federation Directives Quick Reference**
- D. **Composition Errors, Decoded**
- E. **The Complete Source** - all three subgraphs, final state (decision 17)

## Progress

Status values: not-started / outlined / drafted / reviewed / final.

| Chapter | Status | Notes |
|---------|--------|-------|
| Preface | not-started | Write last. Must carry decision 8's plain statement that HC 14 is out of support. |
| 01 | drafted | No code, as planned. Note at `research/ch01-do-you-actually-need-this.md`. Established the summary box (decisions 20, 21, 41) and the figure idiom (decision 33); `figures/tikz/ch01-one-field.tex` is the idiom specification later figures are matched against. Its threshold is stated as my judgment under decision 38, because no source passed the Sources bar. |
| 02 | drafted | Note at `research/ch02-hot-chocolate-from-zero.md`. Stood up the verification repo, tags `ch02` and `ch02-hc14`, `verify.ps1` PASS on both. Emitted the first callout, which fixed the `hc14` file set (decision 47) and settled decisions 42 to 46. Measured the listing column budget at 73. |
| 03 | not-started | Sets up chapter 10; the counts printed here are the single-service baseline. |
| 04 | not-started | Owes chapter 14 its nullability groundwork. |
| 05 | not-started | First SDL. Confirms decision 31's `graphqlsdl` environment against real federation SDL. |
| 06 | not-started | |
| 07 | not-started | Verify the `wgc` version first. |
| 08 | not-started | Verify the Cosmo Router version first. |
| 09 | not-started | End of the zero-to-hero movement: the graph Part III uses. |
| 10 | not-started | |
| 11 | not-started | Carries a deliberately broken listing under decision 22's carve-out. |
| 12 | not-started | |
| 13 | not-started | **Open item:** may need a fourth subgraph. See Open items. |
| 14 | not-started | |
| 15 | not-started | |
| 16 | not-started | |
| 17 | not-started | No code. Prose and figures only. |
| 18 | not-started | |
| 19 | not-started | |
| 20 | not-started | |
| App A | not-started | Built from the Version baseline section once verified. |
| App B | not-started | Accumulates as chapters 2 to 20 emit callouts; drafted last. |
| App C | not-started | |
| App D | not-started | Accumulates from chapters 7 and 15. |
| App E | not-started | Generated from the `main` branch at the end; never hand-maintained. |

## Writing rules (book-specific)

Library-wide defaults are in AGENTS.md; these are this book's additions and
deviations. The machine-checkable half is `check-chapter.psd1` in this folder;
keep the two in step.

- **Voice:** first-person practitioner. First person singular, opinionated
  where experience warrants it and willing to concede. No contractions in my
  own voice; they appear only inside quoted material. Sentence length varies,
  and a short declarative sentence lands the end of a paragraph. Claims are
  concrete - a company, a date, a count, a name - because vague authority is
  the failure this voice exists to avoid. **Bounded:** first person is for
  judgement and choice, never for a debugging log. The book does not narrate
  the author's wrong turns, control runs or corrected measurements. A problem
  earns space only if it is a property of federation, Hot Chocolate or Cosmo
  that a competent reader will meet. See decision 22 for the one carve-out.
- **Economy:** tight. Say it once, no setup paragraph before the paragraph that
  does the work, one idea per paragraph, every sentence carries a fact, a
  decision or a consequence. Economy is not sentence length and does not touch
  the Voice line's cadence. **One named exception:** the end-of-chapter summary
  box, whose shape decision 21 fixes so that it cannot become a restatement.
- **Language and spelling:** English, `en-US`. The exemption list in
  `check-chapter.psd1` starts empty and grows only as the gate finds a real
  case - a British spelling inside captured tool output or a vendor's own
  prose. A spelling exemption is never added to accommodate the author's habit.
  A cited author whose name carries a diacritic keeps it, written with the
  `\uml`-style accent macro from `preamble/macros.tex` rather than the Unicode
  letter, which strict `Ascii` mode forbids, or a respelling, which would
  misspell a real person (decision 40).
- **Humanizer skill:** `humanizer`.
- **Listings:** every C# and SDL listing is build-along and complete. A file
  appears in full the first time it matters. A later change to it is shown as
  the full file again with `highlightlines` marking what moved, or for a long
  file as the complete enclosing member with the same highlighting. **A unified
  diff is never used.** Environments: `minted{csharp}`, `minted{graphql}` for
  executable GraphQL, `graphqlsdl` for SDL (decision 31), plus `text`, `json`,
  `sql`, `yaml` and `xml` (decision 49). Adding an environment is a decision,
  recorded in the log. The book makes no claim about where a listing came from,
  because the reader has the whole program and can compile it.
  A listing wider than the measure wraps on the page and the build log stays
  silent, so a line stays inside 73 columns or the block declares its own
  `fontsize`; see decision 50.
- **Numbers:** counts only. Statement counts, `_entities` call counts, round
  trips. **No timings anywhere**, in prose, tables or figures. A count printed
  in the prose must be reproducible by a reader who typed the code out of the
  book, and the chapter's research note records the procedure.
- **Figures:** engineering-drawing style - square corners, no fills, single
  stroke weight, sans-serif labels, black on white. Biased toward sequence and
  timeline figures over box-and-arrow diagrams, because this book's difficulty
  is what happens in what order. The seam and the router each have one fixed
  visual, defined by the first figure that draws them and reused unchanged
  afterwards. A figure's `tikzpicture` lives in `figures/tikz/` as a bare
  picture; the `figure` environment, caption and label stay at the call site.
  **The idiom specification is `figures/tikz/ch01-one-field.tex`**, the book's
  first figure: stroke weights, arrowhead, dash pattern, label sizes and how a
  timeline is laid out all come from that file rather than from this
  paragraph, in the same way the previous chapter rather than a style note
  specifies the prose.
- **Chapter apparatus:** no labs. Every chapter follows the five beats of
  decision 13 and closes with the summary box of decisions 20 and 21. The
  environments are in `preamble/macros.tex`: `chaptersummary`, holding three to
  five `\item` bullets, for Parts I, II and IV, and `problemsummary`, taking
  the symptom, cause and fix as three mandatory arguments, for Part III. The
  Part III box takes arguments rather than free content so that the triple
  cannot quietly become a restatement.
- **HotChocolate 14:** an "On HotChocolate 14" callout uses the boxed
  environment in `preamble/macros.tex`, may only state what the `hc14` branch
  compiled, and points at appendix B. A reader on 16 must be able to skip every
  callout without losing the thread.
- **Companion code:** none that a reader hears about. The verification repo is
  local at `F:/repo/splitting-the-graph-graph`, never pushed and never named in
  the book. `verify.ps1` builds all three subgraphs, runs `wgc router compose`,
  starts the router, sends the book's canonical requests and asserts the counts
  the book prints. It runs on `main` and on `hc14`. No chapter is drafted until
  both print PASS. If a chapter legitimately changes a number the script
  asserts, update the script and say so in the commit message; **never loosen
  an assertion to make a run pass.**
- **Research:** one note per chapter under `research/`. A note records every
  external fact with its source URL and access date, every version pinned,
  every count with the procedure that reproduces it, and every claim that was
  checked and found false.
- **Sources:** a number that fixes a fact in time needs a source or the claim
  is written without it. Vendor-published sources are usable only when they
  quote a named engineer at the company being described, and the prose says
  whose blog it was. A name is not a source: an identifier in a source tree is
  evidence that somebody once meant something by it and nothing more. A
  standards body's record of its own working group is not vendor prose and
  passes unsigned (decision 39); a vendor's unsigned post does not. **When no
  source passes the bar, the claim is stated as my judgment, in first person,
  citing nobody** (decision 38). Citing the weak source anyway is the failure
  this rule exists to prevent, and quietly dropping the claim is how a chapter
  loses its argument to a sourcing gap.
- Citations are `~\autocite{...}`, always with the tilde. Quoted material uses
  `\enquote{}`, never literal quote characters.
- Chapter numbers in prose are `chapter~\ref{ch:...}`, never a literal number.
- The index is maintained while writing, not retrofitted.

## Open items

An unresolved question, and the condition that unblocks it.

- **Chapter 13 may need a fourth subgraph.** Decision 23 fixed the example at
  three, and the accepted answer to cross-seam filtering, sorting and paging is
  a dedicated search domain with its own index. Whether that domain is built as
  a fourth service or described without being built decides how much of
  decision 23 survives. Unblocked by outlining chapter 13.
- **Cosmo Router and `wgc` versions are unpinned.** Unblocked by running the
  toolchain, which chapters 7 and 8 require anyway.
- **Whether the Nitro IDE works with no network at all.** Decision 45 pins the
  embedded serve mode and gives reproducibility as the reason, which is
  measured. The stronger reason, that the default cannot work offline, is
  **not**: setting `HTTP_PROXY` and `HTTPS_PROXY` to a dead port did not change
  the behaviour, which shows .NET ignored those variables on this machine
  rather than showing anything about the fetch. No chapter claims it meanwhile.
  Unblocked by a genuinely disconnected run, or by a documented setting that
  forces the fetch to fail.
- **Whether `[QueryType]` classes are required to be `partial`.** The
  get-started documentation says they must be. Measured 2026-08-19 on both
  16.6.1 and 14.3.1: a non-partial class compiles, the generator picks it up,
  and the field reaches the schema. Chapter 2 makes no claim either way and
  its `Query` is not partial. Unblocked by finding the generator feature the
  requirement is actually about, at which point it is a sentence in chapter 2
  and possibly a change to `Query.cs`.
- **Whether Pygments gains an SDL lexer.** Decision 31 is a workaround with a
  measured justification, not a preference. Unblocked by a Pygments release
  whose `graphql` lexer handles type definitions, `!` and directives; at that
  point `graphqlsdl` is redefined in one place and nothing else changes.
- **Whether any public account exists of a team abandoning federation.**
  Chapter 1 says outright that I looked and found none, so if one surfaces the
  chapter has a claim to correct rather than merely a citation to add. The
  strongest lead is a GraphQLConf 2026 talk, *Shifting Instagram Development
  Towards Monolith Server Via Federated Schema*, whose existence is confirmed
  from the conference's own schedule but whose content is not: no abstract,
  recording or slides could be found, and nothing from it is used. Unblocked by
  a recording or transcript of that talk appearing. Details in
  `research/ch01-do-you-actually-need-this.md`.
