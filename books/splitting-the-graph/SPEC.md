# SPEC - Splitting the Graph

Source of truth for this book: decisions, approved TOC, and progress. Read it
fully before working on the book; update the progress table before finishing a
working session.

Title: **Splitting the Graph**
Subtitle: *Federated GraphQL with Hot Chocolate and Cosmo on .NET*
Author: Giang Dang

## Status

Settled 2026-08-19 through a seven-round requirements interview. Chapters 1 to
11 are drafted. The verification repo at `F:/repo/splitting-the-graph-graph`
carries a tag per chapter plus one per state the book argues against, with
`verify.ps1` passing on each; the full table is that repo's `README.md`. The
single-service baseline chapter 10 measured against was settled by chapter 3:
**five statements naive, two batched**, for four sessions and three distinct
speakers. Chapter 4 put every entity behind a global node
id, so from `ch04` onward an id in a response is `U2Vzc2lvbjox` and not `1`.
Chapter 5 confirmed decision 31's `graphqlsdl` environment against real
federation SDL: `@key`, `@link`, `FieldSet!`, `repeatable on OBJECT |
INTERFACE` and a `@link` url all tokenize without a single error box.

Chapter 7 ran a composer for the first time and paid the `Query.node` bill
chapter 6 left (decision 74). It also found a refusal nobody had predicted: the
Sessions subgraph, unchanged, does not compose at all, because Hot Chocolate
writes `@cost` and `@listSize` onto fields nobody configured and Cosmo's
composer holds different definitions of both (decision 73). `wgc` was two patch
releases stale and is re-pinned at 0.129.9.

Chapter 8 started the router. It is the book's first long-running process that
is not ours and its first component that arrives as a downloaded binary rather
than a package, and it needed no container: the release ships standalone builds
for seven platform and architecture pairs, which is what keeps decision 23's
containerless example intact. The router serves the one subgraph that exists,
hides exactly `_entities` and `_service` from it, and plans every query as a
sequence holding one fetch. The Cosmo Router is now verified by running it
rather than by reading a release page, and the gateway audit that had been an
open item since chapter 5 was run rather than cited (decision 84).

Chapter 9 split the graph. There are now three services on three databases,
and the two seams are different shapes: Speakers takes a whole type away from
Sessions, which keeps a stub declared `resolvable: false`, and Ratings
contributes three fields to a `Session` it will never own a row of. The first
query answered across two subgraphs costs the same two statements chapter 3
measured inside one process, one in each service, because the DataLoader
behind the reference resolver went with the code. `verify.ps1` is at 328
assertions on `main`.

Two things chapter 9 found are larger than the chapter. `@shareable` on
`Query.node`, which chapter 7 shipped thirty-three lines to apply, is a promise
neither subgraph can keep: with two node types in two services, `node(id:)`
answers correctly only when the query names the type in a fragment (decision
90). And a subgraph that contributes fields to a type it does not own cannot
switch on global object identification at all, while still having to read the
node ids it is handed (decision 86). Both are consequences of decision 67,
which federated this book on the global node id as my judgment rather than on
Apollo's guidance.

Chapter 10 opened part III and found two things bigger than itself. The router
**de-duplicates** representations before it sends them, so the N in this book's
N+1 counts distinct entities rather than rows, and the router has already done
half of what a DataLoader does (decision 95). And decision 69 is wrong: a
`QueryContext<T>` does inject into a reference resolver and does project
(decision 96), which means chapter 6 printed a false claim in prose and in a
code comment, and chapter 10 corrects both. What replaces it is sharper anyway:
the entity route can be batched or projected and not both, because the selector
defaults the key and a batching loader is keyed on it, and the combination is
correct only when the caller happens to ask for the key (decision 97). The
book batches. `verify.ps1` is at 342 assertions on `main`.

Chapter 11 prints two complete C# files and puts neither of them on `main`. The
example was already right, so the chapter's own contribution to `verify.ps1` is
the request that would have caught it if it were not, and both listings live on
branches: the broken one the chapter argues against, and the corrected one it
ends on. Three findings outrank the chapter. The `[DataLoader]` source
generator makes the order failure unreachable, and reinterprets a list-returning
method rather than rejecting it, so the broken listing had to be hand-written
(decision 99). The router checks that an entity answer has as many entries as it
sent and checks nothing else, and cannot do better because it never asks for the
key (decision 100). And this book's seed hides the whole failure: with the
defect deployed, every page printed since chapter 3 still answers correctly,
because the schedule names speakers in ascending order and ascending is the
order the rows come back in (decision 101). `verify.ps1` is at 353 assertions on
`main`.

Chapter 12 put the first guard in the book on a field and found three doors
where it expected one: `node(id:)` reaches the guarded rows for the same reason
`_entities` does, and all three are advertised by introspection. Three findings
outrank the chapter. The correction a reader reaches after the first one is
worse than the mistake, because `[Authorize]` on a reference resolver compiles
clean, emits no directive at all and guards nothing, which `[GraphQLIgnore]` is
the direct cause of (decision 106). A guard on a field is not a guard on a
fetch: the row is read and only the value withheld, at one statement, where a
guard on the type refuses first and costs none (decision 107). And the router's
own `@authenticated` is a filter rather than a gate, enforced after the subgraph
has answered and costing the same statement, so it protects the response and not
the port (decision 109). The graph now needs a bearer token for one column, the
router validates and forwards it, and `verify.ps1` is at 389 assertions on
`main`.

Chapter 13 adds a fourth Search subgraph without changing the Sessions seed,
default sort or paging surface that decision 101 protects. Search owns a
complete denormalized discovery projection, including the unrated session, and
cuts the requested page before Sessions hydrates the chosen entity keys. The
measured request costs one Search statement and one batched Sessions statement;
Ratings and Speakers cost none. `verify.ps1` is at 422 assertions on `main`.

Chapter 14 collects the debt chapters 2, 3, 4, 8, 9 and 12 all forward-referenced
to it. Chapter 4's nullability rule turns out to be necessary and not
sufficient: `Ratings.Query.ratingCount` met it exactly, being a count over a
table that service owns, and stopping that service empties the whole response,
including the half the Sessions service answered correctly at the cost of a
real statement. Behind a router the blast radius is a property of the composed
schema rather than of the service, and the two positions that decide it are a
field contributed to somebody else's type, which costs their whole list, and a
root field, whose only parent is `data`. Five fields give up their exclamation
marks, one of which nobody wrote: `AddGlobalObjectIdentification()` generates
`Query.nodes` as `[Node]!` and it needs a type interceptor to soften, in both
subgraphs that export it. No router setting reaches any of this (decision 121).
The `@semanticNonNull` open item is closed and the TOC line corrected: the
directive is superseded rather than merely unratified, and what Hot Chocolate
ships under its name changes the printed schema and nothing about execution
(decision 122). `verify.ps1` is at 451 assertions on `main`.

Chapter 15 opened on a mistake the book itself taught: chapter 9 explained
`resolvable: false` as *this service does not own these rows*, and the Ratings
service does not own `Session` rows either. Put it on that key and the
four-service graph refuses, once per unresolvable field, naming one route out
of the six that reach it and a subgraph that is on neither the path nor the
fix. Two findings outrank the chapter. **Which route it names is not a property
of the mistake** (decision 127): removing a service that declares no `Session`
changes it, reversing four lines of `graph.yaml` changes the subgraph named as
the entity ancestor, and `wgc`'s fixed 120-column box then elides a word out of
its own sentence. And **the check can be satisfied without finding a route at
all** (decision 128): the same broken document composes silently in the
three-service graph, because a second subgraph declaring the singular
`Query.node` records the entity on the way past and every later route to it is
waved through. That graph then answers HTTP 500 on six routes, sends a root
field at a list position on a seventh, and returns four nulls with no `errors`
key on the eighth. It is the second bill for decision 74's `@shareable`, which
is the collection decision 90 asked this chapter for, and decision 90's second
rejected option turns out to buy the check back (decision 129). `verify.ps1` is
at 493 assertions on `main`.

Next action: chapter 16, the subgraph that broke everyone.

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
| 6 | Why not Fusion | Fusion cannot span the two versions this book covers. The Fusion v1 line (Hot Chocolate 13 and 14 era, pre-spec directives) ended at 15.1.17 on 2026-06-16, and Fusion 16 is a complete rewrite on the GraphQL Composite Schemas specification. They are different products, and a reader on 14 could not follow a Fusion 16 chapter at all. `HotChocolate.ApolloFederation` shipped in the 14 era and still ships in lockstep with 16, which makes it the only *federation subgraph contract* with unbroken releases across both. **Two clauses corrected 2026-08-23** while drafting chapter 5, from primary sources recorded in that chapter's research note. First, "composed with Nitro CLI" was too narrow: Michael Staib's own post on Fusion 16 says it "no longer depends on command-line tools for composition" and describes an Aspire-driven path, so the CLI is one option rather than the mechanism. Second, "the only subgraph contract reaching both" overreached, since the base library trivially reaches both too; the claim that survives is the one about federation tooling specifically, and it is the one chapter 5 prints. The two dates and the version were checked against NuGet registration metadata and both hold exactly. |
| 7 | Why Cosmo and not Apollo Router | Cosmo Router is Apache-2.0, self-hostable, and speaks Federation v1 and v2, so it composes subgraphs regardless of which Hot Chocolate produced them. Apollo Router Core is Elastic License v2, which forbids offering it as a managed service - an awkward thing to teach in a book about running your own graph. Hive Router was considered and is the strongest alternative; rejected only because a book with no reader-facing repo cannot afford to teach two gateways shallowly. **Verified and narrowed 2026-08-23** while drafting chapter 5. The Elastic License clause holds and is quoted in that chapter's research note: Apollo Router's own `LICENSE` carries it, and it forbids providing the software "to third parties as a hosted or managed service". What does **not** hold is the broader form of the claim carried in `research/2026-08-hard-cases.md`, that the Federation 2.x libraries are Elastic as a family. Apollo's `subgraph-js`, the JavaScript counterpart of the package this book uses, is MIT; it is the router, gateway and composition tier that is Elastic. The decision is unchanged, because that tier is exactly the one Cosmo replaces, but the reason has to be stated at the right altitude and no chapter may print the family-wide version. Hive Router was also re-checked: The Guild, MIT, Rust, Federation v2 only. |
| 8 | Versions covered | Hot Chocolate 16 is the spine. Hot Chocolate 14 appears as inline boxed callouts where the API difference changes the reader's code, plus appendix B in full. HC 14 is out of support - the platform's SECURITY.md lists only 16.x and 15.x - and the preface says so plainly: 14 coverage exists to get a reader off 14, not to endorse staying. |
| 9 | Companion repo | **None that a reader ever hears about.** No URL, no tags, no checkout instructions, nothing in the preface. See decision 10 for what exists instead, and decision 15 for what replaces it on the page. |
| 10 | The verification repo | One local repository at `F:/repo/splitting-the-graph-graph`, never pushed and never mentioned in the book. `main` carries the conference example on .NET 10 and Hot Chocolate 16. A long-lived `hc14` branch carries only the files an HC 14 callout quotes, pinned to Hot Chocolate 14.3.1 on `net8.0`, because 14 does not target .NET 10. |
| 11 | HC 14 callouts are compiled | An "On HotChocolate 14" callout may only say what the `hc14` branch compiled. A callout sourced from documentation and never built is the invented-listing failure wearing a version number. Rejected alternatives: documentation-sourced callouts, and prose-only pointers to appendix B. |
| 12 | Shape | Two movements. Parts I and II take a reader from zero to a working three-subgraph federated graph. Part III is problems-first: each chapter opens with a failure a reader will actually meet, reproduces it, explains the mechanism underneath, and fixes it. Part IV covers living with the result. Problems-first suits a book with no repo, because a problem chapter is self-contained by construction: it needs the failure, not everything that came before. |
| 13 | Chapter skeleton | Five beats, same order, every chapter. **(1) The one sentence** - what this chapter establishes, stated first, before anything else; a chapter needing two sentences is two chapters. **(2) Show it** - the thing running, or in Part III the thing failing, with code and output on the page. **(3) Why it does that** - the mechanism; all theory lives here. **(4) Do it properly** - the complete, correct implementation. **(5) Summary box.** |
| 14 | The ordering law | No concept is explained before the reader has seen the behaviour it explains. This is the direct inverse of the first book's habit of theory followed by code the reader could not see, and it is what beat 3 following beat 2 enforces. |
| 15 | Listings are build-along and complete | Every file appears in full the first time it matters. The reader can type the entire system out of the book. No listing is a fragment of something that lives elsewhere, because there is no elsewhere. |
| 16 | How a change to an already-shown file is typeset | The full file again, with changed lines marked by minted's `highlightlines` and a caption naming what moved. For a file too long to reprint, the complete enclosing member - whole class or whole method - with the same highlighting. **Never a unified diff**: three lines of context is the same failure as a fragment, in miniature. |
| 17 | Source appendix | Appendix E carries the final complete source of all four subgraphs. The estimate must be revisited when the appendix is drafted: chapter 13 deliberately amended decision 23's three-service limit. This was rejected earlier in the interview on the assumption of a larger example and reinstated when the running example was still smaller. |
| 18 | Provenance is not declared | The book makes no statement about how its listings were produced. It does not need to: decision 15 puts the whole program on the page, so a reader who doubts a listing can compile it. Rejected alternatives: a preface contract, and per-listing markers. |
| 19 | Counts yes, timings never | A count - SQL statements issued, `_entities` calls made, round trips taken - is deterministic and reproducible by a reader who typed the code out of the book, and it carries the whole argument of chapter 10. A timing is a property of one machine, cannot be reproduced by any reader, and is the largest single source of the measurement narration decision 22 bans. No milliseconds appear in this book. |
| 20 | Chapter apparatus | No end-of-chapter labs. Each chapter closes with a summary box, which is the single named exception to the Economy line. |
| 21 | Summary box shape | Parts I, II and IV: the chapter's claims as three to five bullets. Part III: a fixed three-line **symptom, cause, fix** - the symptom a reader will search for, the mechanism underneath it, and the change that fixes it. That triple is what a reader flips back to find months later, which is why it is not a restatement. |
| 22 | The book never narrates the author's debugging | A problem earns space if it is a property of federation, Hot Chocolate or Cosmo that a competent reader will meet. It earns none if it is a property of the author's code being wrong. Wrong turns, control runs and corrected measurements go in `research/` and never reach prose. First person is for judgement and choice, never for a debugging log. The one carve-out: a listing shown deliberately broken to demonstrate a failure mode is the reader's problem, not the author's, and stays. |
| 23 | Running example | A conference system: Sessions, Speakers, Ratings, and from chapter 13 onward Search. Four subgraphs, SQLite or in-memory, no container, no message broker. The original three were chosen because cross-seam paging is obvious in them rather than contrived. Chapter 13 amends the service count: Search owns the complete denormalized discovery projection needed to filter, order and cut a session page. Keeping that second domain inside Ratings produced the same plan and counts but concealed its ownership. |
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
| 51 | A state the book argues against gets its own tag | Chapter 3 opens on a statement count it then removes, and decision 48 says every number the book prints is asserted by `verify.ps1`. The verification repo cannot hold two states of one file, so the state being argued against gets a branch, a tag and a `verify.ps1` of its own: `ch03-naive`, asserting the five statements the chapter opens with. Nothing is built on such a branch and it ends at its tag. Rejected: leaving the opening number reproducible only by following a recipe in the research note, which is the class of claim this book exists to avoid. Chapter 11 owes a deliberately broken listing and uses the same mechanism. |
| 52 | `verify.ps1` asserts the current state, and tags carry the rest | Settled by chapter 3, which turned `sessions` into a Relay connection and so made chapter 2's printed requests illegal against `main`. The script asserts the example as it now stands, and an earlier chapter's requests stay provable by checking out that chapter's tag. Rejected: keeping every chapter's requests answerable forever, which would freeze the example at chapter 2, and dropping the older assertions, which would leave those listings unproved. Recorded because the alternative reading, that a chapter-2 assertion failing on `main` is a regression, is wrong. |
| 53 | A failure no tagged state produces is described, not quoted | Two things chapter 3 wanted to print and could not: SQLite's refusal to `ORDER BY` a `DateTimeOffset`, and the exception `[UseProjection]` raises on a positional record. Neither can be produced by the corrected code, so under decision 48 neither response may be quoted. Both are stated in prose as facts and recorded verbatim in the research note instead. Narrower than decision 51: a state worth a tag gets one, and a one-off message that no tagged state produces is described rather than quoted. |
| 54 | The chapter counts statements with an interceptor, not EF Core's logger | `StatementLog`, a `DbCommandInterceptor` printing a numbered marker and the command text, is a file the book prints like any other. EF Core's own `LogTo` was rejected twice over: with `CommandExecuted` it prints an elapsed time and decision 19 puts no milliseconds in this book, and with `CommandExecuting` it prefixes each statement with a 113-column line that decision 50's budget cannot take and that carries nothing a reader needs. The interceptor also numbers the statements, which is the currency of chapters 3 and 10. `builder.Logging.AddFilter` silences EF Core's duplicate report; without it every statement is printed twice. |
| 55 | Projection is `QueryContext<T>`, never `[UseProjection]` | `[UseProjection]` builds its projected row with `Expression.New` and member assignment, so it needs a parameterless constructor and settable properties. Decision 23's domain is positional records, so every request against a field wearing the attribute throws `Type 'Session' does not have a default constructor` at run time, not at build and not at schema build. Measured on 16.6.1 and on 14.3.1, so it is a property of the attribute rather than a version to wait out. `QueryContext<T>` with the `System.Linq` `.With()` extension works on records and is what the book uses, at the cost of being unavailable on 14. The ordering rule that comes with it: sort before projecting, because `.With()` rewrites the entity and EF Core cannot then translate an `OrderBy` over the result. |
| 56 | Global object identification is on, and the id format is not a secret | Every entity type carries a `[NodeResolver]`, so `id` exports as `ID!` and the type implements `Node`. Measured 2026-08-21: the value is the type name, a colon and the primary key, base64 encoded, so `U2Vzc2lvbjox` decodes to `Session:1` and nothing else is in the string. The chapter says both halves out loud, because the alternative reading, that an opaque id is unguessable and therefore a control, is the mistake chapter 12 is about. Also recorded: the Relay object identification specification requires global uniqueness and refetchability and never uses the words "opaque" or "base64", checked by searching the fetched document. The book attributes the encoding to convention, not to the specification. |
| 57 | Every id the schema hands back is a node id, errors included | Settled by chapter 4, where the first `SpeakerDoubleBookedError` exposed `speakerId: Int!` and `verify.ps1` failed on chapter 3's assertion that the schema hides that foreign key. The assertion was right. An error type is part of the schema and obeys the same rules the rest of it does, so both exception properties carry `[ID<T>]` and a client can feed what comes back to `node(id:)`. The chapter 3 assertion was narrowed in the same commit, from a whole-file search to a search inside the `Session` type plus a new check that no field anywhere is typed `speakerId: Int`; a check that cannot tell two different fields apart is a check that fails for the wrong reason. |
| 58 | Errors are data, in a union with an interface under it | `AddMutationConventions` plus one `[Error<T>]` per declared failure. The union names every failure that exists today and the generated `Error` interface is what lets tomorrow's arrive without breaking a client that shipped before it. Marc-Andre Giroux argues exactly this pairing in *A Guide to GraphQL Errors*, on his own site and bylined, so the vendor rule does not arise; the chapter cites him. Rejected: the top-level `errors` array for a failure a caller should act on, which arrives as a string with a path and nothing to branch on. Sasha Solomon's post, which Giroux credits as first, could not be fetched from Medium and nothing from it is used. |
| 59 | Nullability is ownership, not caution | A field is non-null only where the value is guaranteed from data this service owns with a constraint behind it. `speaker` stays nullable although chapter 4 could have made it non-null, and the measurement is why: on `ch04-orphan` one session pointing at a missing speaker empties the whole `nodes` list, all four sessions, at HTTP 200 with one error. The rule is not "prefer nullable": a schema with no exclamation marks pushes a null check onto every field of every client forever. Chapter 14 collects on this. |
| 60 | The mutation's overlap test runs in memory, and the book says so in the listing | Decision 23's `StartsAt` goes through chapter 3's value converter, so EF Core cannot translate arithmetic over that column and the first version of `rescheduleSession` answered `Unexpected Execution Error` rather than either declared error. The shipped version loads one speaker's other sessions and tests in C\#, and the comment explaining why is in the printed file rather than in the prose, because a reader typing the listing out needs the reason at the line. |
| 61 | A quotation long enough to display uses `\begin{quote}`, and `\enquote{}` stays for everything else | Decision 37 names `\enquote{}` and chapters 1 to 3 never needed anything else, because they quoted phrases. Chapter 4 quotes four normative passages from two specifications, each two or three sentences, and an inline `\enquote{}` around a passage that long stops reading as a quotation halfway through. A displayed quote carries its `~\autocite{}` on the sentence that introduces it, so the source is still attached to the claim rather than to the block. Rejected: paraphrasing the normative text, which is exactly the thing a reader would want to check word for word. |
| 62 | A chapter may take more than one subject through beats 2 to 4 | Decision 13 fixes the order of the five beats and says nothing about how many subjects a chapter may run through them. Chapter 3's fifth section already restarted at beat 2 for projection and again for paging, and chapter 4 does it three times: identity, errors, nullability. The one-sentence rule in decision 13 is what stops this from becoming three chapters in a trench coat, and chapter 4's one sentence covers all three. Recorded because a cold audit raised it as a possible skeleton violation, and the answer should not have to be re-derived every chapter. |
| 63 | An SDL document printed in full carries its own `@link` version | Decision 42 settled this for a `.csproj` and the reasoning is identical here: decision 35 keeps versions out of *sentences*, and a schema document printed under decision 15 necessarily opens with a `@link` url ending in a version. The version the book prints is **v2.6**, and it is not a preference. Measured 2026-08-23 from the shipped `HotChocolate.ApolloFederation` 16.6.1 assembly: `FederationVersion` runs to `Federation27` and `Default` is `Federation26`, so v2.6 is what a reader's own subgraph emits unless they go looking for a setting. The three-subgraph map composes identically at v2.6 and v2.7, checked with `wgc router compose`. Appendix A stays the one place a version table lives. |
| 64 | Chapter 5 issues no HotChocolate 14 callout, deliberately | Decision 47 says the `hc14` branch carries whatever the live callouts quote, so a chapter that emits none adds nothing to it. Chapter 5 ships no C# and prints no API surface, and the one version difference it met is not its own: the batched speaker lookup reads `IN (@ids1, @ids2, @ids3)` on `main` and `FROM json_each(@__ids_0)` on `hc14`, which is EF Core 9 rather than Hot Chocolate 14, and chapter 3's callout already reports it. Recorded so that the absence reads as a decision rather than as an oversight, which is the same reason decision 46 exists for screenshots. |
| 65 | A composition failure no tagged state produces is described, not quoted | Decision 53 settled this for a *response*, on the reasoning that decision 48 lets the book quote only what `verify.ps1` asserts. Chapter 5 reproduced two composition errors with `wgc` against hand-written SDL in a scratch directory: two subgraphs both declaring `Query.node`, and an entity referenced without a `@key`. Neither is produced by any tagged state of the verification repo, because the repo has one service and no composition step. Both are therefore stated in prose as facts and recorded verbatim in the chapter's research note. Revisit when chapter 7 puts composition into `verify.ps1`, at which point the error text becomes quotable the ordinary way. |
| 66 | A chapter that ships no code still gets a tag | `ch05` is the first tag in the verification repo on an unchanged tree: `git diff ch04..ch05` over `src/` is empty. It exists because decision 48 is about requests rather than about source, and chapter 5 opens on a request nothing asserted before. The tag marks the state its eight assertions were run against. Rejected: skipping the tag, which would leave the chapter's opening listing the only unproved one in the book, and inventing a code change to justify one. |
| 67 | The key this book federates on is the global node id, and that is my judgment rather than Apollo's | Chapter 4 put every entity behind a global node id and chapter 5 argued from it that the book already has its keys. Searched Apollo's documentation for guidance on using a Relay global object identification id as a `@key` and found **none**, including on the entity key design page that would carry it. So decision 38 applies: the claim is stated as my judgment, citing nobody. Recorded because the reasoning is load-bearing for chapters 6 and 9 and an audit reading cold cannot tell a considered call from an oversight. The consequence is decision 68. |
| 68 | A reference resolver decodes its own key, and checks the type name inside it before spending the integer | Measured 2026-08-23. The key arrives at a reference resolver as the undecoded node id **string**, where the node resolver beside it is handed the decoded `int`. `[ID<T>]` on the parameter does not decode it: it yields 0 and the entity answers null with no error at HTTP 200, which reads exactly like a key that matched no row. The decode is `INodeIdSerializer.Parse(id, typeof(int))`, whose second argument is the CLR type of the key and not of the entity. `Parse` returns both the integer and the type name that produced it, and **spending the integer without reading the type name answers with the wrong object**: a `Speaker` node id under a `Session` type name returns the session with that number, correctly typed, at 200, with no error key. Both resolvers therefore compare `nodeId.TypeName` and return null on a mismatch, which is what the specification permits for a representation naming no entity. `ch06-unguarded` proves the failure. This is a different mechanism from chapter 11's, which is about order, and the chapter says so. |
| 69 | `QueryContext<T>` cannot be injected into a reference resolver, so the entity route has no projection | Measured 2026-08-23: it compiles, builds a schema, starts the service, and answers the first `_entities` request with `Unexpected Execution Error` and no exception in any log. So the projection chapter 3 built does not reach the entity route, and the same request for one field costs six columns there against one through `node(id:)`. Both statements are asserted by text rather than by count, because the counts are equal and the columns are the point. Chapter 6 states this and does not work around it; whether it can be worked around is an open item. |
| 70 | The `hc14` branch may carry more than one tag for one chapter | Settled by chapter 6, whose callout has two halves that cannot both be true of one tree: that the attribute idiom compiles and does nothing on 14.3.1, and that a code-first `ObjectType<T>` works. Decision 11 says a callout may only state what the branch compiled, so both states are built and tagged, `ch06-hc14-ignored` and `ch06-hc14`. Rejected: describing one half under decision 65, which would have made the more useful half the unproved one. The same mechanism decisions 51 and 53 set up for `main`, reaching `hc14` for the first time. |
| 71 | A federated entity on 14 leaves the source generator, and the book says so rather than porting the idiom | On 14.3.1 the generator has no mechanism for applying an arbitrary descriptor attribute declared on a type class, so `[Key]` and `[ReferenceResolver]` are never read. Worse than inert: the method `[ReferenceResolver]` names is published as a field despite `[GraphQLIgnore]`, landing on `Speaker` as `resolveSpeakerReference(id: String!): Speaker` with its doc comment as the description. The only route that works is a code-first `ObjectType<Speaker>`, which collides with `[ObjectType<Speaker>]` and so costs the type its place in the generator. The callout states the trade rather than pretending the idiom ports, and appendix B carries the class. |
| 72 | `AddApolloFederation()` pays one shareable bill and not the other, and the chapter prints the contrast | Measured 2026-08-23: the package writes `@shareable` onto all four fields of the generated `PageInfo` type without being asked, and adds it to the `@link` import list. It does not write it onto `Query.node` or `Query.nodes`. Both halves are asserted, because the paragraph rests on the contrast. The reason is where the two features live: paging and federation ship together and `PageInfo` is generated by code that knows federation is loaded, while `node` comes from global object identification, which has never heard of it. This is the concrete form of the debt decision 65's neighbourhood recorded, and chapter 7 pays it. |
| 73 | Cost defaults are off, because the composer rejects what they emit | Measured 2026-08-23. The Sessions subgraph as chapter 6 left it does not compose: Hot Chocolate applies `@cost(weight: "10")` to every field and writes `@listSize` onto the paged one with no configuration at all, and Cosmo's composer holds its own definitions of both, typing `weight` as `Int!` and knowing no `slicingArgumentDefaultValue`. Six weights and one argument rejected over one service, none of the messages about federation. `ModifyCostOptions(o => o.ApplyCostDefaults = false)` is the whole fix; the neighbouring `ApplySlicingArgumentDefaultValue` narrows a directive the composer rejects for another reason and is redundant once the defaults are off, so the book does not set it. **Two consequences recorded rather than buried.** Chapter 3's `MaxPageSize` and `DefaultPageSize` were asserted by reading `@listSize` out of the exported schema and are now asserted behaviourally instead, the default page holding two and a page of eleven being refused; that is firmer ground, not a loosened assertion, and the paging limits themselves are untouched. And the book now ships a schema with no cost weights at all, so what complexity limits a federated subgraph should declare deliberately becomes chapter 20's question rather than a default nobody chose. Which of the two libraries is right about `@cost` was **not** established and no chapter says. |
| 74 | `@shareable` on `Query.node` goes on a type interceptor | Settled by chapter 7, which answers the open item chapters 5 and 6 left with a third option, because both the ones the item named are wrong. `node` and `nodes` are generated by `AddGlobalObjectIdentification()` and declared in no class, so there is no method for `[Shareable]` to sit on. Measured: `[Shareable]` on the `Query` **class** compiles and emits `type Query @shareable`, which clears the collision and also declares `sessions` and `sessionById` shareable, and a second subgraph then claims `sessionById` with no complaint from the composer. An `ObjectTypeExtension` in `Program.cs` does **not** work at all: it declares a second field of the same name and the schema fails to build, first for an uninferrable type and then for `node, nodes` being declared multiple times. `ShareNodeFields`, a `TypeInterceptor` of about thirty lines, reaches exactly the two fields, and that is what the book ships. The trade is stated in the prose: thirty lines to avoid a promise about four fields made in order to keep one about two. |
| 75 | A composition that is meant to fail is an input file in the repo, and its error text is asserted | The revisit decision 65 asked for. Chapter 7 put composition into `verify.ps1`, so a composer error is no longer something only a scratch directory can produce: `graph/` carries three input files, two of which fail on purpose, and the script asserts their messages line for line. A composition that starts passing is as much a regression as one that starts failing. Decision 65's rule stands where it still applies, for an error no input in the repo produces; it no longer applies to anything chapter 7 prints. |
| 76 | A schema no service exports may be composed, and the prose says what it is | Chapter 7 needs a second and a third document to ask the questions one subgraph cannot, and the services that would export them are chapters 9's. Composition reads files, so a hand-written document is a legitimate thing to compose rather than a listing pretending to be a program, and `graph/speakers.graphql` and `graph/ratings-unreachable.graphql` are both printed in full and both introduced as what they are. This does not weaken decision 15: they are complete files a reader types, not fragments, and no prose claims a service produced them. Rejected: composing the Sessions document under two names, which needs no new file and produces a 73-line error naming eight objects, correct and useless. |
| 77 | The book uses Cosmo's word for the second pass, and names Apollo's | Cosmo's composer is `@wundergraph/composition`, which declares no Apollo dependency, and it calls the check **resolvability** everywhere: the flag, the source directory, the error function, the walker classes. Apollo calls the same idea satisfiability and has a `SATISFIABILITY_ERROR`; the Composite Schemas draft has `UNSATISFIABLE_QUERY_PATH`. The book prints what the tool prints and says both words once, because a reader searching for satisfiability after a Cosmo failure will land on documentation for a different composer. Calling the check a **walk** is my framing under decision 38: no source publishes that phrase, and what the sources give is the mechanism, which all three implement as a traversal. The mechanics are cited and the phrase is not. |

| 78 | A version string a generated artifact carries may be quoted, and the gate holds it | The third case in the family decisions 42 and 63 opened, and it needed a row because neither of theirs covers it. Decision 35 keeps versions out of sentences so that bumping the toolchain is one edit; decision 42 exempted a `.csproj` printed in full and decision 63 an SDL document's `@link` url, both on the reasoning that a document printed under decision 15 carries its own pins and a reader typing it needs them. Chapter 7 quotes `1:0.63.3` out of the router execution config, in prose rather than in a listing, because the whole point of the paragraph is that this is the only place a config records which composer produced it. What makes that safe is not the carve-out but the gate: `verify.ps1` asserts the string, so upgrading `wgc` fails a run and the chapter is corrected rather than ageing quietly, which is the protection appendix A was giving. The rule reads: a version a chapter states about the toolchain goes in appendix A; a version a chapter reads back out of an artifact it just produced may be quoted, provided the verification script asserts it. |

| 79 | Chapter 8's cross-seam clause moves to chapter 9, and the router arrives over a graph of one | The TOC gave chapter 8 "the first query answered across two subgraphs" and chapter 9 the building of the second subgraph, so the service chapter 8 queried across did not exist until the chapter after it. Settled while closing out chapter 7, which had already assumed this resolution in prose without the TOC catching up. The clause moves to chapter 9 and chapter 8 shows the router over the one subgraph that exists. **The reason is decision 14, not tidiness.** A reader who meets the router and the first seam in one chapter cannot tell which of the two caused what they are looking at; a reader who has already watched a router serve a graph with no seam in it can attribute everything chapter 9 adds to the seam. **Rejected: giving chapter 8 a minimal Speakers subgraph**, which sounds smaller and is not. Such a subgraph either duplicates `Speaker.name` and `bio` while Sessions still owns the rows, which cannot compose without declaring shareable exactly the field chapter 7 closes by teaching the reader never to declare shareable, or it moves the rows properly, which is chapter 9's content arriving inside a chapter about the router and a second full service printed under decision 15. Also rejected: swapping the two chapters, which leaves chapter 8 with two services and no router to show them working through. Chapter 9 becomes the largest chapter in part II and that is accepted; if outlining it finds it is genuinely two chapters, it splits there, which this resolution keeps available and the rejected one would have foreclosed. |

| 80 | The router's port is 3002, which is its own default, and `config.yaml` does not name it | The last piece decision 44 left open. The three services are pinned at 5001 to 5003 in their own `launchSettings.json` because `dotnet new web` picks a port at random and a book printing raw HTTP under decision 34 would otherwise print fiction. The router has no such problem: measured 2026-08-24, it announces `localhost:3002` in its startup log with no configuration present at all, and does so even on the run where it then refuses to start. A `listen_addr` line would therefore be a line that can drift out of step with the log beside it and buys nothing. Rejected: pinning 4000 or 5000 for symmetry with the services, which trades a number the router will tell you for a number you have to remember. |
| 81 | The router arrives as a downloaded binary and no chapter says `docker run` | Decision 23 fixed an example with no container in it, and most published material about this router opens with a container image. Measured 2026-08-24: release `router@0.341.0` ships fourteen assets, standalone binaries for darwin, linux and windows on amd64 and arm64 plus linux 386, each with a published md5 beside it, and the Windows archive holds exactly two files, the binary and its Apache-2.0 license. Every measurement in chapter 8 was taken with the Docker daemon not running, so the claim is proved rather than assumed. The verification repo keeps the binary in a gitignored `tools/` and `verify.ps1` falls back to PATH, because 93 MB of another project's release artifact is not something to commit. |
| 82 | A file the reader writes may carry a version pin the same way a generated one does, and `config.yaml` does not need one | The fourth case in the family decisions 42, 63 and 78 opened, and it resolves the other way, which is why it is worth a row. `config.yaml` has a `version: "1"` key and it is a real key rather than something the router tolerates: measured 2026-08-24, the router validates the file against a JSON schema and refuses to start on an unknown property, naming the schema by url in the refusal, so a key that survives validation is one the schema declares. But that `1` is the config format's version and not a toolchain version, so decision 35 is not engaged at all and appendix A gains no row. Recorded because the previous three rows in this family all went the other way and a later session should not have to re-derive that this one is different. |
| 83 | `dev_mode` ships in the book's `config.yaml`, and the chapter shows the state without it first | The query plan is the chapter's subject and it is an Advanced Request Tracing option, which is one of the five Cosmo Cloud features the router disables when it finds no graph token. Measured 2026-08-24: without `dev_mode` the `X-WG-Include-Query-Plan` header is ignored **in silence**, and the response is byte for byte the response sent without it. No error, no warning, nothing in the log. With `dev_mode` on, the router removes ART from the disabled list and logs that it has done so. So the book ships the switch and section 8.2 prints the config without it, which under decision 51 gets its own branch and tag, `ch08-noplan`, asserting the silence. Rejected: printing the final config once and explaining `dev_mode` before the reader has met the silence, which inverts decision 14. Also rejected: `ENGINE_FORCE_UNAUTHENTICATED_REQUEST_TRACING`, whose own schema description opens "UNSAFE - DO NOT ENABLE IN PRODUCTION"; it is named in the research note and in no chapter. |
| 84 | The gateway audit was run, and no chapter prints a score from it | The open item chapters 5 and 7 carried, closed by running it rather than by citing it. Measured 2026-08-24 against `graphql-hive/federation-gateway-audit` at commit `7956ca1`: Cosmo Router 0.341.0 scores **194 of 199 test cases and 43 of 46 suites**, where the audit publishes 183 and 37 for it. Better, not worse, so the worry that prompted the item does not survive it. No chapter prints either number, for four reasons recorded in full in the chapter 8 note: the harness pins router 0.321.2 as a Linux binary and had to be modified in five places to run 0.341.0 at all; the controlled A/B against 0.321.2 was impossible on this machine; the audit's own repository disagrees with itself, its committed per-gateway results being from an older 189-case run while its README is a 199-case run and its live site lists a gateway its committed data does not; and its maintainer, The Guild, ships the two gateways ranked first and second in it. Decision 7 is unchanged, having chosen Cosmo on license and version coverage and never on a score. |

| 85 | An entity stub carries `resolvable: false`, and the argument is not decoration | The open item chapters 5 and 6 left, closed by chapter 9 writing the first stub. Apollo's own documentation pairs a stub definition with the argument to say the subgraph defines no reference resolver, and measurement agrees with it in three places: the type loses `implements Node`, it drops out of that service's `_Entity` union, and the composer writes `disableEntityResolver: true` beside its key in the router execution config. That flag is what stops the router routing an entity fetch for a `Speaker` to Sessions. **Chapter 5's printed map does not need the edit the open item anticipated.** That map shows the Sessions subgraph's `Speaker` as `@key(fields: "id")` with no argument, and it is drawn as the state before the extraction, which is what chapter 5 was describing; the stub is chapter 9's and chapter 9 prints it. What the item was right about is that the two declarations want opposite answers, and they got them. Also recorded: the flag is advice to the composer and not a guard. Send Sessions a representation naming a `Speaker` on its own port and it answers `Unexpected Execution Error` with a null `data`, because the type is in the schema, advertises a key, and nothing a client can introspect says the key cannot be resolved. Chapter 12 inherits that. |
| 86 | A subgraph that owns no node cannot switch on global object identification, and still has to read node ids | Measured 2026-08-24 while building the Ratings service. `AddGlobalObjectIdentification()` adds `node`, `nodes` and the `Node` interface and then refuses to build: \enquote{There is no object type implementing interface `Node`.} A subgraph contributing fields to a type it does not own has no node of its own, and giving it a `[NodeResolver]` to satisfy the builder would declare that it can answer `node(id:)` for a type it cannot fetch. But the keys it is handed across the seam are still global node ids. `AddDefaultNodeIdSerializer()` registers the serializer alone and is what the book ships; without it the reference resolver is injected a null and the entity route answers `Unexpected Execution Error` with nothing in any log, which is the third distinct cause of that message in this book after decision 69's. **Not established:** whether that serializer produces identical ids to the ones `AddGlobalObjectIdentification()` configures under a non-default `NodeIdSerializerFormat`. It does for this book's types and `verify.ps1` asserts the strings. |
| 87 | `[ID<T>]` on a key property does not decode the key at the entity route either | Decision 68 recorded that `[ID<T>]` **on the parameter** yields 0 rather than decoding. The same is true of the property: declare the key as `[property: ID<Session>] int Id`, take an `int` in the reference resolver, and every key arrives as 0. The service then answers with a session that has no ratings, at HTTP 200, with no error key, which reads exactly like a session nobody rated. The rule that survives both placements is decision 68's: nothing on the entity route decodes a node id for you, and the resolver takes the undecoded string and calls `INodeIdSerializer.Parse` itself. Recorded separately because decision 68 as written covers only the parameter and a reader could reasonably think the property was the fix. |
| 88 | `@provides` is taught and not shipped, and this composer does not enforce its second precondition | Apollo states two preconditions: the provided field must be `@external` where it is provided, and `@shareable` in at least one other subgraph that defines it, \enquote{otherwise a composition error occurs}. Measured 2026-08-24 on `wgc` 0.129.9: `graph/provides-unshared.graphql` meets the first and not the second, and composes. Exit zero, a config written, nothing said. That is the second vendor disagreement in three chapters after decision 73's `@cost`, and it is reported as a disagreement: which side is right was not established and no chapter says. `verify.ps1` asserts that it composes, so a `wgc` that starts enforcing the rule fails a run rather than ageing the chapter quietly. The book ships no `@provides` because the preconditions require a copy of a column in a service that does not own it, which is the duplication chapter 9's first section removes and chapter 17's subject; the chapter says that rather than leaving the absence unexplained. The prose recommends writing the `@shareable` anyway, on the practical ground that the stricter of two rules cannot break you later. **Not established:** what the router does at runtime with such a graph, because no service stands behind that input. |
| 89 | Chapter 9 is one chapter, not two | The open item decision 79 left, closed by outlining and then writing it. It is 30 pages, the longest in part II, and it prints two services in full. It stays one because it makes one argument, which decision 62 already permits across subjects: a seam is a type two services both name, and the two services are the two shapes that takes. Most of the page count is the first service again under another name, and the boilerplate is what a split would have duplicated rather than separated. Rejected: splitting along the seam each service makes, which was the item's own suggested line, because it would put `@external` and `@requires` in a chapter with no `@provides` to contrast them against and would renumber eleven chapters and their labels for a page count the SPEC had already accepted. |
| 90 | Federating on the global node id breaks `node(id:)` across a seam, and the book states it rather than hiding it | Measured 2026-08-24, and the largest consequence chapter 9 found. `@shareable` on `Query.node`, which chapter 7 shipped a type interceptor to apply, says any subgraph declaring the field can resolve it. Neither can: Sessions resolves it for a `Session`, Speakers for a `Speaker`. Three requests disagree with each other. `node(id:)` with a fragment naming the owning type works, because the fragment is what the planner routes on. The same id with a fragment for the other type fails, where chapter 4 established that a well-formed id of the wrong type is harmlessly unmatched in a single service. `nodes` with one id of each type answers 200 with half the list null. Four fixes were considered and all rejected: a node resolver per type per subgraph undoes the split, declaring `node` in one subgraph only leaves the identical failure, returning null instead of throwing trades a loud failure for a silent wrong answer, and `@inaccessible` on both fields costs the reader the whole of chapter 4's refetch story. The graph ships as measured. This is the cost of decision 67, which chose the node id as the key on my judgment because Apollo publishes no guidance, and it is recorded here rather than as a footnote because chapter 15 should collect on it. |
| 91 | Chapter 9 issues no HotChocolate 14 callout, deliberately | The second chapter to do this after decision 64, and the reasoning is decision 71's rather than chapter 5's. On 14.3.1 the source generator never reads an arbitrary descriptor attribute declared on a type class, so `[Key]` and `[ReferenceResolver]` compile and do nothing, and every federation attribute chapter 9 introduces (`[External]`, `[Requires]`, and the second argument of `[Key]`) is inert there for exactly the same reason chapter 6 already recorded and appendix B already carries. A chapter 9 callout would restate chapter 6's: the only route on 14 is a code-first `ObjectType<T>`, which costs the type its place in the generator. What it would add is the code-first spelling of two directives the book uses once each, and buying that means porting two whole services onto a branch decision 47 keeps to what a callout quotes. Rejected on that trade. **The consequence is that `hc14` carries no chapter 9 service and its `graph.yaml` still names one subgraph**, so everything chapter 9 changed in `verify.ps1` is branched on a new `SpeakerExtracted` expectation rather than on `SessionKeyed`, which is about whether `Session` is an entity and is a different question. `ch09-hc14` tags an unchanged tree with a passing script, on the same footing as `ch05` and `ch08` (decision 66). |
| 92 | The spelling gate runs its variant table as well | `Spelling.Variants` on. The preset's own table holds the differences that follow a rule, `-our` against `-or` and the doubled `l`; the variant table holds the leftovers, words like `programme` and `judgement` whose two spellings follow none, which is exactly why the base table cannot generate them. Turned on because a chapter 9 draft carried `programme` once and `judgement` three times through a clean run and a reader with no drafting context found all four. The two directions are not mirror images and the script says why: `program` is correct British English for something a computer runs and `judgment` is standard in British legal writing, so the en-GB direction flags neither. This book is `en-US`, where both are simply wrong. Decision 29 is unchanged: the exemption list stays empty and grows only for a British spelling inside captured tool output or a vendor's own prose. |
| 93 | The index may not name this book's own machinery | `Index.ForbidPattern` set to `\\index\{decision\b`. The printed index is the reader's vocabulary and `SPEC.md` never ships, so an entry naming a numbered row of this decision log would print a term no reader has seen and none can look up. A chapter 9 draft indexed `decision 43` and the machine gate had nothing to say about it, because the entry was terminated correctly and every other index check passed. The pattern carries a word boundary on purpose: an entry about how this book records a decision is a legitimate reader-facing subject and stays silent. |
| 94 | A chapter that adds a service re-prints the shared inputs that name services | Settled by chapter 9's audit, which found `graph.yaml` printed with two subgraphs while the file carried three, so a reader typing the system out of the book ended with a graph that could not answer anything from section 5 onward. Decision 15 already required it and decision 16 already said how; what was missing was a trigger, because a file printed correctly in one section goes stale three sections later without anybody touching it. The trigger is: adding a service to `src/` means re-printing every shared input that names services before the chapter ends. There are two that the book prints, `graph/graph.yaml` and `router/config.yaml`, and chapter 9 re-prints the first with its new entry highlighted under decision 16. No check can find this - the file was right in the repository and stale on the page - so it is a rule rather than a setting, and chapter 13 will need it again if it builds a fourth subgraph. |

| 95 | The router de-duplicates representations, so N counts distinct entities rather than rows | Measured 2026-08-24 off the wire, with a request-logging middleware in front of the Speakers service. Four sessions naming three distinct speakers produce a `BatchEntity` fetch carrying **three** representations, in first-appearance order, and a page whose two sessions share a speaker produces **one**. Corroborated in the router's own executor, `graphql-go-tools` v2.16.0 (the version `router@0.341.0` pins), which hashes each rendered representation with xxhash64 and appends duplicates to the position already in the batch; and stated in WunderGraph's own words by Jens Neuse, bylined, which is what makes it citable under the Sources rule. **What proves it is the `ch10-naive` tag rather than the measurement on `main`**, because a DataLoader given equal keys collapses them too and both are in play there; with no loader behind that resolver the counts are still three and one. The consequence is that this book's N+1 chapter is about distinct entities, and that the router has already done the de-duplicating half of what a DataLoader does. **Not established:** whether the list has any cap, and whether two representations carrying the same key and different `@requires` fields collapse; the hash is over the whole rendered representation, which suggests not. No chapter claims either. |
| 96 | Decision 69 is wrong: a `QueryContext<T>` does inject into a reference resolver, and does project | Measured 2026-08-24 in both services, on the same 16.6.1, on a tree whose `Program.cs` calls `AddQueryContext()` exactly as it did at tag `ch06`. The selector arrives correctly built from the inline fragment inside `_entities` and narrows the `SELECT` to the fields asked for. Recorded here as a correction rather than smoothed over, because chapter 6 printed the claim in prose and in a code comment a reader types out, and chapter 10 corrects both. What produced the original `Unexpected Execution Error` was **not** re-derived: the book states what is true now. One thing decision 69 turned up that survives and explains the surprise: the `ISelection` a reference resolver is handed is the root `_entities` field, declared on `Query` and typed `[_Entity]!`, so anything reading the selection by hand gets the union while the injected `QueryContext` gets the entity. The consequence is decision 97. **A residual defect is left standing on purpose, and it is the author's call rather than a drafting session's.** Chapter 6 carries the false claim in three places: a paragraph of prose, its summary box, and a comment inside a listing it prints. The prose and the box could be corrected in an afternoon. The comment could not: chapter 6 prints the file as it stands at tag `ch06`, and that comment sits in `src/Sessions/SessionType.cs` from `ch06` through `ch09`, so putting it right in print means amending five historical tags and re-verifying each. Chapter 10 therefore corrects the claim in the text rather than silently, and re-prints the file with the comment fixed under decision 16, which is the mechanism this book already has for a file that changes. Whether to go back and amend chapter 6 as well is open. |
| 97 | The entity route batches or projects, never both, and this book batches | The projection decision 96 found cannot be combined with a batching loader. The selector defaults every property nobody asked for, the key included, so a loader keyed on that property receives rows all carrying zero and `ToDictionary` raises `An item with the same key has already been added. Key: 0`. Measured 2026-08-24, and it **works** when the client happens to select the key, which is worse than failing: correctness conditional on the caller, and invisible in review because the request you test with is the one carrying the id. GreenDonut ships the API for exactly this, a `Select` overload taking a key selector, and all three routes to it fail: the builder overload and the expression overload both throw `Type does not have a default constructor` from `Expression.New`, which is decision 55's wall in a second API and closes the whole selector-builder family to a domain modeled in positional records, and merging a key-preserving expression into a `DefaultSelectorBuilder` by hand silently discards it. So the book takes the batch: the statement count grows with another service's page size and the column count does not. The trade is stated in the chapter rather than hidden, along with when it would go the other way. |
| 98 | Chapter 10 issues no HotChocolate 14 callout, deliberately | The third chapter to do this, after decisions 64 and 91, and the reasoning is its own. Chapter 6's callout already showed a reference resolver on 14 going through a DataLoader and `verify.ps1` already asserts it there at one statement, because the only route that federates a type on 14 is a code-first `ObjectType<T>` and the book's copy of it takes the loader. So a chapter 10 callout would restate a claim the `hc14` branch already carries and already proves. `Session` is not an entity on that branch at all (decision 71), so the one source change this chapter makes has no counterpart there, and every assertion it adds to the shared script sits behind `SessionKeyed` or `SpeakerExtracted`, both false there. `ch10-hc14` tags an unchanged tree with an unchanged 214, on the same footing as `ch05`, `ch08` and `ch09-hc14` (decision 66). |

| 99 | The order contract cannot be broken through the `[DataLoader]` source generator, so chapter 11's broken listing is hand-written | Measured 2026-08-24. The generator classifies a method as a batch loader only if it returns a dictionary shape, and the `CopyResults` it emits walks the **keys** and calls `TryGetValue` on each, so the returned collection's own ordering never reaches the answer. Under that, `_entities` resolves one indexed task per representation. Both layers have to be left behind before order can go wrong. **Also measured, and recorded because it looked like the obvious middle road:** a `[DataLoader]` method returning `Task<IReadOnlyList<Speaker>>` is **not rejected**. The generator silently reinterprets it as a cache loader whose key is the whole `IReadOnlyList<int>` and whose value is the whole list, and the call site then fails to compile with two `CS0266` errors about converting `object` to `Speaker`, neither of which mentions batching. The mistake is caught, by the type checker rather than by a diagnostic that knows what you meant. The consequence for the chapter is that the deliberately broken listing is a hand-written `DataLoaderBase<int, Speaker>`, and the motive for writing one is stated in the prose rather than assumed: a store that is not a `DbContext` hands back a list. |
| 100 | The router validates the length of an `_entities` answer and nothing else | Read at `graphql-go-tools` v2.16.0, which `router@0.341.0` pins, in `Loader.mergeResult`. **Note the path moved**: chapter 10 read `loader.go` and `loader_multi_entity.go` under `v2/pkg/engine/datasource/graphql_datasource/` and at this version they are under `v2/pkg/engine/resolve/`. The merge pairs `batch[i]` with `items[i]`, and where decision 95's de-duplication applies it merges `batch[batchIndex]` into every target that hashed to that position. One check precedes both loops, that the two counts are equal, failing with `invalidBatchItemCount`. Nothing reads `__typename` or a key field off the returned object; `astjson.MergeValuesWithPath` is a generic deep merge with no identity logic, and the one `__typename` test in the file inspects the **parent** before the request is sent. So a short or long answer is refused and a same-length reordered answer is undetectable. **The router cannot do better**: the entity fetch does not select the key, because asking for a key the router already holds would be a column nobody wanted on every entity fetch in every graph. **Not reproduced:** the length check firing. Hot Chocolate always answers one entry per representation, so no state of the verification repo produces a short or long array, and under decisions 53 and 65 chapter 11 describes the behaviour and quotes no message. |
| 101 | The order failure is invisible in this book's graph, and that is the chapter rather than a caveat | Measured 2026-08-24 on `ch11-misordered`. With the defect deployed, every request the book has printed since chapter 3 still answers correctly, at unchanged statement counts, with byte-identical exported schemas, a composing graph and an unchanged query plan. The reason is the seed: sessions in schedule order name speakers 1, 1, 2 and 3, the router de-duplicates to `[1, 2, 3]`, and SQLite returns those rows ascending, so the two lists agree. **That is a property of the data.** No paging request in this graph can surface the defect, because `sessions` sorts by `StartsAt` in the resolver and takes no sort argument, and Relay's `last:` still returns its window forwards. `nodes(ids:)` is the only root field where the client chooses the order, and two **aliased** `node(id:)` calls are immune because the planner makes them two `Entity` fetches of one representation each rather than one `BatchEntity`. Recorded as a decision because a later chapter changing the seed, the default sort or the paging surface would silently un-break chapter 11's demonstration and nothing would fail. |
| 102 | GreenDonut's two clauses fail differently, and chapter 11 is built on the asymmetry | `DataLoaderBase.FetchAsync` carries the contract in its own doc comment, read out of the shipped 16.6.1 assembly: \enquote{For every provided key must be a result returned. Also to be mentioned is, the results must be returned in the exact same order the keys were provided.} Measured 2026-08-24: breaking the first leaves a slot in the span unwritten, and an unresolved `Result` becomes `Unexpected Execution Error` at that position, which is the **fourth** distinct cause of that message in this book after the stub advertising an unresolvable key (decision 85), the Ratings service without its serializer (decision 86), and the dictionary with a duplicate key that chapter 10 closed on (decision 97). Those three are the ones chapter 10 prints; decision 69's original is not among them, because decision 96 records that it was never re-derived. Breaking the second costs nothing and says nothing. The chapter prints both, because which half of a contract fails loudly is what decides whether anyone finds out. Also recorded: de-duplication and decision 68's type-name guard both survive the defect, living in `DataLoaderBase` above `FetchAsync` and in the reference resolver respectively, so a narrow defect is not a safe one. |
| 103 | Chapter 11 issues no HotChocolate 14 callout, deliberately | The fourth chapter to do this, after decisions 64, 91 and 98. Everything chapter 11 is about lives in GreenDonut rather than in Hot Chocolate: `DataLoaderBase<TKey, TValue>`, its `FetchAsync` and the doc comment stating the order contract are the same API on both versions, so a callout would report no difference. The chapter's demonstration needs more than that, though, and cannot have it: the failure is visible only across a seam, and `hc14` has one subgraph (decision 91), `Session` is not an entity there at all (decision 71), and the Speakers service does not exist on that branch. Building one to host a deliberately broken loader would put a second full service on a branch decision 47 keeps to what a callout quotes, to demonstrate a defect in a library that does not differ between the versions. `ch11-hc14` tags an unchanged tree with an unchanged 214, on the same footing as `ch05`, `ch08`, `ch09-hc14` and `ch10-hc14` (decision 66). |
| 104 | A second correct implementation gets a tag, on the same reasoning a wrong one does | Chapter 11 prints the corrected hand-written loader as its beat 4, and decision 48 says every listing the book prints is run before it is typeset. `ch11-handwritten` is therefore the first tag in this repository that is neither `main` nor a state the book argues against: an alternative implementation, verified by running `main`'s own `verify.ps1` against it unchanged and unloosened, 353 assertions PASS, the same 353 that pass against the source-generated loader. That equivalence is the chapter's claim, so running the whole script is the proof rather than a spot check. Rejected: describing the corrected loop under decision 65, which would have left the chapter's only constructive listing the unproved one. **One edit both hand-written branches carry:** the override names its list parameter `ids` rather than the base class's `keys`, because EF Core names SQL parameters after the closed-over variable and the book's other two loaders print `@ids1`. A reader typing the file from an IDE's `override` completion gets `keys` and sees `@keys1`; that difference is real, harmless, and recorded here rather than in the prose. |
| 105 | Authorization goes on the data, and the guarded thing in this book is one column rather than a type | Settled by chapter 12. Measured 2026-08-25 on 16.6.1: `[Authorize]` on a field of `Query` guards that field and nothing else, and `_entities` and `node(id:)` reach the same rows with no credentials at all, at the statement count they always cost. The attribute works on the **type** and on the **field**, and both cover all three routes. The book guards the field, `Speaker.Email`, written `[property: Authorize, Authenticated]` because a positional record's undecorated attribute lands on the constructor parameter where Hot Chocolate never looks. **The reason is scope rather than security.** Guarding the `Speaker` type would refuse `name` and `bio` too, which would put a bearer token into every request this book prints from chapter 9 onward, for the rest of its length, to demonstrate a mechanism one column shows just as well. `Speaker` is a public program entry with one private column in it, and the graph should say so. A book whose whole type was confidential would guard the type and the chapter says so. |
| 106 | `[Authorize]` on a reference resolver compiles, emits nothing and guards nothing | Measured 2026-08-25 and the sharpest thing chapter 12 found, because it is the correction a reader reaches on the second try. Hot Chocolate's authorization is field middleware and needs a field descriptor; `[GraphQLIgnore]`, which chapter 6 put on that method so it would not be published as a field of `Speaker`, is exactly what denies it one. The two attributes sit on adjacent lines wanting opposite things and neither the compiler nor the schema builder says a word: 0 warnings, and **zero** occurrences of `@authorize` in the exported document, with no directive definition either. `AddAuthorization()` still writes its `ApplyPolicy` enum, so the state reads as configured. Proved by a caller with a token and a caller with none getting byte-identical answers, which is what separates a rule that ran and passed from no rule. `ch12-inertguard` carries it. This is what ChilliCream issue 6546 reported in September 2023 against 13.5.1; it is still open, the pull request Michael Staib linked in December 2023 (6769) was closed unmerged, and the behaviour still holds for **that placement only**. The issue never tried the type or the field. |
| 107 | A field guard costs the row; only a type guard refuses before the resolver | Measured 2026-08-25 and recorded because the obvious reading of decision 105 is wrong. With the guard on `Speaker.email`, a refused request costs **one statement** in Speakers: the reference resolver runs, the row is read with every column on it, and field middleware withholds the value on the way out. The same request against a type-level `[Authorize]` costs **zero**, refused before any resolver runs, exactly as the root-field guard in `ch12-rootguard` costs zero. So the two placements are a real trade rather than a matter of taste, and the chapter prints both numbers. Not established: whether a field guard can be made to refuse before the fetch. |
| 108 | The router must be told two separate things, and neither is a default | Settled by chapter 12. **It does not forward headers.** WunderGraph documents the default as no headers forwarded, and the consequence is not a weaker graph but a broken field: with the guard shipped and no `headers` block, a caller whose token the router verified is refused by the subgraph as unauthenticated, and an anonymous caller is refused **identically**, so nothing in the response points at a header rather than at a policy. `ch12-noforward` carries it. Narrower than it first looks, and the run corrected the first draft of that script: the refusal follows the guarded column and not the seam, so a cross-seam request that never names a guarded field answers completely, which is why a missing block survives a smoke test. **And it needs a way to verify a token.** `authentication.jwt.jwks[]` takes either a `url` or the triple `secret`, `symmetric_algorithm`, `header_key_id`, established by probing the router's own JSON schema, which refuses an unknown property and names the path. `authentication.providers`, which older material uses, is not a valid key at 0.341.0. A token the router cannot verify is answered **401** and reaches no subgraph, the first time in this book the router refuses anything outright rather than answering 200 with the problem in the envelope. |
| 109 | `@authenticated` is a filter on the answer, not a gate on the fetch, and the book ships it anyway | `HotChocolate.ApolloFederation` 16.6.1 publishes `AuthenticatedAttribute`, `RequiresScopesAttribute` and `PolicyAttribute`, read out of the shipped assembly; a search-engine summary claiming the name `ApolloAuthenticated` is wrong and is recorded here so nobody re-derives it. `[Authenticated]` emits `@authenticated`, adds it to the `@link` import list unasked, and **composes cleanly**, which is worth recording after decision 73's `@cost`: `wgc` carries Hot Chocolate's own `@authorize` through untouched as well. The composer compiles the federation directive into one `authorizationConfiguration` on `Speaker.email`; put it on a **type** and it writes one rule per field that *returns* the type instead, so `@authenticated` on `Speaker` produces rules on `Session.speaker`, `SpeakersConnection.nodes` and `SpeakersEdge.node` and none naming `Speaker`. **The router enforces it after the subgraph has answered.** Measured on `ch12-routeronly` with the subgraph guard removed: an unauthenticated request is refused at the router and still costs **one statement** in Speakers, and the same service hands the column to anyone on port 5002 with a token or without one. WunderGraph documents the order plainly and Apollo describes the same shape for its own router. The book ships both attributes and says which one means it. |
| 110 | Turning authorization on adds a type to the supergraph | `AddAuthorization()` puts an `ApplyPolicy` enum into the subgraph schema because it is the argument type of the `@authorize` directive the registration declares, the composer carries it up, and the router serves it to clients. The named-type count the router serves goes from 23 to **24**, and the list of types the router adds over the Sessions subgraph gains `ApplyPolicy`. Chapters 8 and 9 print 21 and 23 and stay provable at their own tags under decision 52. Recorded rather than buried because it is a reader-visible consequence of a line nobody thinks of as schema design, in the same family as decision 72's `@shareable` on `PageInfo`. Not established: whether `@inaccessible` or a type interceptor could keep it out. |
| 111 | Chapter 12 issues no HotChocolate 14 callout, deliberately | The fifth chapter to do this, after decisions 64, 91, 98 and 103. There is no Speakers service on `hc14` to guard a field of (decision 91), so there is nothing there to put an attribute on and nothing to measure. Standing one up would put a second full service on a branch decision 47 keeps to what a callout quotes. Every assertion the chapter adds therefore sits behind a new `EmailGuarded` flag which is false on that branch, and `ch12-hc14` tags an unchanged tree with an unchanged 214, on the same footing as `ch05`, `ch08`, `ch09-hc14`, `ch10-hc14` and `ch11-hc14` (decision 66). |
| 112 | A cited author's acute accent gets a macro, the same as decision 40's diaeresis | Chapter 12 cites Tom Houl\acu{e} at Grafbase, and decision 40 settled the reasoning one letter along: strict `Ascii` mode forbids the Unicode letter, respelling him would misspell a real person, and a bare `\'` in a chapter file is an apostrophe as far as the prose gate's quote check is concerned. `\acu` joins `\uml` in `preamble/macros.tex`. Recorded rather than left as a silent edit because the two macros are a family and the next accent should join it rather than starting a third pattern. |
| 113 | The verification repo proves the page and the code are one text, because nothing else does | Settled by chapter 12's audit, which found two listings drifted from the files they claim to be: one carried a `using` directive the file does not have, and one abbreviated a five-line doc comment to one. The book compiled clean and the prose gate passed. `verify.ps1` proves the code runs, which is a different claim from the one decisions 15 and 48 make to the reader. `check-listings.ps1` beside it now compares every whole-file listing the book prints against this repository at the tag it came from, and it lives there rather than in `scripts/check-chapter.ps1` because the map from a listing to a tag is this book's and decision 18 keeps that provenance off the page deliberately. The map is maintained by hand: **a chapter that prints a file adds a row when it is drafted**, and a chapter is not finished until that script passes. It reads `csharp`, `yaml` and `xml` as source by default. A mapped row can name another language, as chapter 13's `launchSettings.json` now does; this preserves the distinction between a JSON source file and an unmapped JSON response. `graphql` remains a request rather than a source file. |
| 114 | The list owner owns membership, order, cursor and slice | Settled by chapter 13. In the existing `sessions` plan, Sessions fetches and slices first and Ratings receives only representations for the selected rows. A later entity fetch can hydrate those rows but has no plan operation that admits an unseen row, reorders the list and creates replacement cursors. This is a claim about the measured schema and router plan, not a universal limit on federated search surfaces. |
| 115 | Search is a fourth subgraph, not a second domain hidden in Ratings | Both designs were built. Co-locating the complete projection in Ratings and putting it in a fourth Search service compose to the same two-step plan and cost the same two statements. Search wins because the projection combines schedule and rating data and owns discovery semantics separate from rating writes. The extra process is an honest cost, so decision 23 is amended rather than preserved cosmetically. |
| 116 | A search projection is complete before it is current | Search carries one row per Session, including the unrated session with a null average and count zero. Grouping Ratings alone would omit it. Every order ends with `SessionId` for a deterministic tie-breaker. Neither fact promises cross-request snapshot stability, and the book names ingestion lag and cursor movement as unimplemented product concerns rather than federation behavior. |
| 117 | Chapter 13 preserves the original Sessions surface byte for byte | The new behavior lives behind `searchSessions`. `Sessions.Query.GetSessions`, its start-time ordering, the four-row seed and the original paging arguments do not move, because decision 101's broken-loader demonstration depends on the resulting `1, 1, 2, 3` speaker sequence. Cross-seam sorting is added rather than retrofitted onto that root. |
| 118 | Chapter 13 issues no HotChocolate 14 callout | The accepted mechanism is an additional Search service, and decision 47 keeps `hc14` to code a callout quotes. There is no version-specific claim to make: the list-ownership mechanism is established on the current four-service graph. `ch13-hc14` therefore tags the unchanged branch and its unchanged 214 assertions, on the same footing as chapters 9 through 12 when their new service behavior was outside that branch. |
| 119 | Decision 59's rule is necessary and not sufficient, and this is the federated half | Chapter 4 said a field is non-null where the value is guaranteed from data you own, in the same process, with a constraint behind it. `Ratings.Query.ratingCount` met that exactly, being a `COUNT` over a table its own service owns, and it is the field that empties the response. What decision 59 could not see is that after composition the field's *position* is written by other teams, so the rule gains a second test: **and the position it occupies in the composed schema is one you are willing to empty when your service is down.** Measured 2026-09-05 at the canonical four-session page, with Ratings stopped: a non-null field contributed to a type another service owns costs that service's whole list, four sessions for one field, while the Sessions service still spends its one statement reading them; a non-null **root** field costs the entire `data` entry, taking a healthy service's answer in the same response with it. Those are the only two sizes, and the second is the chapter. Five fields move (`Ratings.Query.ratingCount`, `Ratings.Session.ratingCount`, `Ratings.Session.feedbackUrl`, `Search.SessionSearchDocument.session`, `Query.nodes`) and everything a service owns outright stays non-null, because a schema with no exclamation marks is the failure decision 59 already rejected. Recorded as an amendment rather than a replacement: decision 59 is still right about one service. |
| 120 | The one non-null root field nobody wrote, and the interceptor that reaches it | `AddGlobalObjectIdentification()` generates `Query.node` as `Node` and `Query.nodes` as `[Node]!`, and the difference decides whether a dead subgraph costs a field or the response. **The nullable item type protects nothing**, measured 2026-09-05: the router plans one batched step per owning subgraph and fails the whole field when one is unreachable, so a mixed `nodes(ids:)` naming one live and one stopped service answers `data: null` with no path and no index, while the singular `node(id:)` hitting the identical failure answers `{"node": null}`. Neither field is declared in any class, which is the wall decision 74 hit for `@shareable`, and the answer is the same hook: `ObjectFieldConfiguration.Type` is settable, so `NullableNodesField` rewrites it with `TypeReference.Parse("[Node]", TypeContext.Output)`. **Both subgraphs that export the field carry a copy**, because the field is shareable and two subgraphs declaring it with different types have not declared the same field. Not established: whether the registration offers an option that does this without an interceptor; none was found and the search was not exhaustive. |
| 121 | The router's error configuration cannot reach a stopped subgraph | Measured 2026-09-05. `subgraph_error_propagation` is real at router 0.341.0 and its key set was confirmed against the running binary by decision 83's refusal-as-probe method. It changes nothing in chapter 14: `wrapped` and `pass-through` answer **byte for byte identically** for both the list request and the root field while Ratings is stopped. The block reshapes errors a *responding* subgraph returns inside its own body, and a service that is not listening never produces one, so `Failed to fetch from Subgraph 'x'` is fixed router behavior. Proved by contrast against chapter 12's guarded field, which a running service refuses: there the two modes differ exactly as documented, wrapped nesting the original under `extensions.errors` and pass-through surfacing it with its own `path` and `AUTH_NOT_AUTHENTICATED` code. The consequence the chapter states: the amount of a response one outage destroys is decided by the schema, and there is no operational lever for it. Two internal contradictions in the router's own artifacts are recorded in the research note and printed nowhere, because neither was isolated behaviorally: the config schema and the documentation page disagree on the default of `omit_locations`, and `statusCode` appeared under a minimal config that never set `propagate_status_codes`. |
| 122 | `@semanticNonNull` is described, not shipped, and the TOC line was wrong about what it is | The open item chapter 4 opened, closed by measuring and by reading the repositories rather than the documentation. **The directive is superseded, not merely unratified.** Specification PR 1065 is open, never merged, never closed, and was labelled stale on 2026-03-19 at stage RFC 0; the GraphQL Nullability Working Group archived itself on 2026-02-05 and its closing note records that the work landed on PR 1163, `onError`, at stage RFC 1 and discussed two days before this chapter was drafted. Neither name appears in the September 2025 edition or the current working draft. **What Hot Chocolate 16.6.1 ships under the directive's name is an export-time rewrite**, `schema export --semantic-non-null`, which strips `!` from query-side output fields and applies the directive, leaves the mutation root field and every argument type untouched, and changes nothing about execution. It composes at `wgc` 0.129.9 and reaches the schema the router serves, and the composer substitutes its own stricter definition of the directive's `levels` argument for the one the subgraph declared, which is the **third** vendor disagreement in this book after decisions 73 and 88. The runtime half is `ErrorHandlingMode`, read off an `onError` request property, which is an implementation of the unmerged PR 1163 shipped ahead of it, and which replaced a v15 schema-level option that was removed. The book ships neither, because both live inside one service and every request in it since chapter 8 goes to a router written in Go. |
| 123 | A version may be named in a sentence when the sentence is about that version | Decision 35 reads that no chapter names a version outside appendix A, and its reason is that bumping the toolchain should be one edit. Chapters 7 and 12 already print `14.3.1` and `16.6.1` in prose, and chapter 14 does it twice more, so the rule as written has been diverged from three times and is better narrowed than quietly broken again. The narrowing: a version a chapter states **about the toolchain** goes in appendix A, and a version a chapter names **as the subject of the claim** may be written in the sentence, because the claim is that these two versions differ and a sentence that will not say which is not making it. This is the same shape as decisions 42, 63, 78 and 82, which carved out a build file's pins, an SDL document's `@link`, a version an artifact records about itself, and a config format's own version. What is still barred is naming a version as a way of pinning the toolchain, which is what appendix A is re-verified for. |
| 124 | Chapter 14 issues a HotChocolate 14 callout, the first since chapter 8 | The five chapters before it declined one (decisions 64, 91, 98, 103, 111, 118), each because the thing being taught did not exist on that branch or did not differ there. Chapter 14 is the opposite case and the difference is small enough to state exactly: the propagation rule is the specification's and is identical on both versions, and the fields the chapter softens belong to services `hc14` does not carry, so the only version-specific claim is that `schema export --semantic-non-null` does not exist on 14.3.1. Decision 11 wants that compiled rather than read off a release note, so `verify.ps1` runs both halves: the flag is in the help text on 16.6.1 and absent on 14.3.1, where passing it anyway is refused by name. `ch14-hc14` tags an unchanged tree at 216 assertions, up from 214 by exactly that pair. |
| 125 | Chapter 9's printed half-down response is trimmed, and chapter 14 corrects it in its own text | Found by chapter 14's cold audit, which noticed that chapter 9 prints one error for a request chapter 14 says produces five. It resolves against chapter 9. Measured at tag `ch09` itself, in a throwaway worktree built and composed from that tag's own three services: **five** errors, with a byte-identical `data` half. `Speaker.name` is `String!` and the router has no speaker to put a name on, so each of the four rows raises its own propagation error before stopping at the nullable `speaker`. So the listing was trimmed to its first error when it was written rather than overtaken by a later chapter. **Why nothing caught it:** `check-listings.ps1` compares whole-file *source* listings against the repository and says nothing about a printed response, and no assertion in `verify.ps1` read an errors array for length. Both gaps are now closed for this request. Chapter 14 states the corrected count in its first section rather than repeating the claim, which is the same move decision 96 made when chapter 10 found a chapter 6 claim false. Whether to amend chapter 9's own page is open. |
| 126 | A shareable field typed two ways composes, and the composer takes the permissive one | Chapter 14 drafted the claim that softening `Query.nodes` in Sessions alone would leave the composer with two answers, the audit flagged it as unmeasured, and running it proved it wrong. Measured 2026-09-05 at `wgc` 0.129.9: the half-softened graph composes, exit zero, nothing printed, and `engineConfig.graphqlSchema` carries `[Node]` rather than `[Node]!`. Handed two types for one shareable field this composer takes the more permissive rather than refusing the pair. That is the **third** time this composer has accepted what a reader would expect it to stop, after decision 73's `@cost` and decision 88's `@provides`, and it is why a prediction of composer strictness is never safe by analogy in this book. The book still softens both subgraphs, for two reasons the chapter states: a graph that is correct only because a composer was lenient breaks on the release where it stops being, and a half-softened Speakers subgraph tells anyone reading its own schema a different story from the supergraph. `verify.ps1` generates both inputs into the temp directory and asserts both halves, rather than committing a copy of another service's exported schema into `graph/`, which decision 75 keeps for what `wgc` reads and which would go stale the first time that service changed. |


| 127 | The resolvability check answers per field, names one route, and the route it names is not a property of the mistake | Measured 2026-09-05 on `wgc` 0.129.9. One unresolvable field produces one error carrying one path; three contributed fields produce three errors, not one per failing route. Six routes reach `Session.averageScore` in this book's supergraph (`sessions.nodes`, `sessions.edges.node`, `sessionById`, `node`, `nodes`, and the `rescheduleSession` payload), eight once Search's two are counted, and all of them fail identically. **Which one is printed moves with the rest of the graph.** The four-service graph names `searchSessions.edges.node.session`; drop Search and the same defect is reported at `Query.node`, which is the error chapter 7 printed. Reverse the four subgraph entries in `graph.yaml` and the printed path holds while the third reason line names `search` where it named `sessions`, because both services declare a `Session` that cannot reach ratings and the composer names whichever it visited first. `wgc`'s own fixed 120-column box then elides the word `in` out of that sentence, and the command offers no structured output to read instead. Two runs of one input are byte-identical, so this is sensitivity rather than nondeterminism. **The scope line and chapter 7's forward reference both said four**; both are corrected in this session, chapter 7's to a count-free sentence rather than to a new number, because the number was never measured and a forward reference does not need one. |
| 128 | A composition that passes is not proof that a route exists, and a shareable `node` is what defeats the check | The finding that outranks chapter 15. Measured 2026-09-05: the same broken Ratings document that fails in the four-service graph **composes at exit zero, silently**, in the three-service graph chapter 9 finished with. The config it writes carries both halves openly, `disableEntityResolver: true` beside three fields the router is told that service resolves. Isolated one variant at a time, what buys the silence is a second subgraph declaring the singular `node(id: ID!): Node`: the plural `nodes` returning `[Node]` does not, implementing `Node` without declaring the field does not, and declaring the field while `Speaker` implements nothing at all **does**, with the composer warning that the interface has no implementation and then composing anyway. Read out of `@wundergraph/composition` 0.63.3: the walk records an entity when it is *visited* rather than when it resolves, under a code comment asserting the opposite; a shared root field is an OR across subgraphs, so Speakers answering for `Speaker` passes the field while `Session` stays in the record unresolved; and every later root field reaching it is skipped. That reading predicted that moving `node` and `nodes` to the bottom of `type Query` in the Sessions document would make the same graph fail, and it does, naming `Query.sessions`, with the healthy control still composing. **At run time the approved graph produces three different failures from one defect**: `averageScore` answers HTTP 500 on all six routes, the first 500 in this book; `ratingCount` answers 200 while the router sends `{ ratingCount }`, the root field, at path `sessions.nodes`, because a root field of that name exists to fall back to; and `feedbackUrl` answers 200 with four nulls and **no `errors` key**, because `@requires` makes the router plan a `BatchEntity` fetch against a service whose schema has no `_entities`. `ch15-falsepass` carries it. **Not established:** whether abstract return types in general do this rather than `Node` specifically, and whether anyone has reported it upstream; neither is claimed. |
| 129 | Decision 90's second rejected option is not neutral, and it buys the check back | Chapter 9 rejected four ways of making `node(id:)` route across a seam and recorded that only the first was certain. The second, declare `node` in one subgraph only, was rejected on the reasoning that composition would pass and the failure would be identical. Measured 2026-09-05: take `node` and `nodes` out of the Speakers document and the healthy four-service graph still composes at exit zero, while the broken one fails again and names `Query.node`. So the option costs nothing at composition time and removes exactly the condition decision 128 turns on. **The runtime half was not measured** and the chapter says so: with one subgraph declaring the field, a `node(id:)` for a speaker must be planned through the Sessions subgraph's copy and what happens then is unknown. The chapter recommends trying it before sharing the field, as my judgment under decision 38, and states the untested half rather than rounding it off. |
| 130 | Chapter 15 issues no HotChocolate 14 callout, deliberately | The sixth chapter to decline one, after decisions 64, 91, 98, 103, 111 and 118, and the reasoning is decision 71's. Everything this chapter measures needs two subgraphs both declaring `Query.node` and a third contributing fields to a type it does not own. On `hc14` there is one subgraph, `Session` is not an entity at all, and the composer never reaches the resolvability pass for that input because the merge fails first, which decision 65's neighbourhood already recorded and `ch07-hc14` already asserts. A callout would restate that. `ch15-hc14` should tag an unchanged tree at 216, on the same footing as `ch05`, `ch08` and the four that followed (decision 66), and **it has not been run or tagged yet**: the `hc14` branch is checked out in a leftover worktree from the chapter 13 session, at `.claude/worktrees/stg-graph-ch13-hc14`, which this session did not modify because it is another session's working state. What is established without the run is that the chapter 15 block cannot execute there at all: it is gated on `SearchDomain` and `NullableAcrossSeam`, both false on that branch. Recorded here rather than left as a silent gap, because a progress row claiming a PASS that nobody ran is the thing this book's verification discipline exists to prevent. |
| 131 | This composer does not require a `@requires` dependency to carry the same access control, and what protects the graph is the subgraph | Measured 2026-09-05, and the reason the open item pointing chapter 15 at CVE-2025-64172 is now narrower rather than open. That advisory is `@apollo/composition` not requiring a field using `@requires` to carry the access control of the field it depends on. `wgc` 0.129.9 does not require it either: a graph whose `Session.title` is `@authenticated` and whose `feedbackUrl` is `@requires(fields: "title")` composes at exit zero and the composer writes one `authorizationConfiguration`, on `title`, and none on `feedbackUrl`. On the book's own graph with `Session.Title` guarded, the same holds: two rules, `Session.title` and chapter 12's `Speaker.email`, and none on the field built out of the first. **At run time the guard holds anyway**, and not because of anything composition or the router did: the refusal arrives with its path naming `title` on a request that never mentioned it, because the router must collect `title` from Sessions before Ratings can be asked and the Sessions service refuses that field to an anonymous caller. Under decision 109 the router enforces only the rules it is given, and it was given none. **Not measured, and it is the case that matters:** a graph guarded only at the router, chapter 12's `ch12-routeronly` shape, where no subgraph refuses anything. Searched four ways for any published advisory against `@wundergraph/composition` or `wundergraph/cosmo` and found none on any subject, which is an absence of advisories rather than of defects. None of this reaches chapter 15's prose: the chapter's one sentence is about what a resolvability answer means, and a transitive-authorization finding is chapter 12's subject arriving in the wrong chapter. `verify.ps1` asserts the composition half; `ch15-requiresguard` is an experiment branch and carries no tag. |

| 132 | A change the book argues against and does not ship may be stated in prose, because a fragment is what decision 16 forbids and prose is not a listing | Raised by chapter 15's cold audit, which read the chapter changing one attribute in `src/Ratings/SessionType.cs` and never reprinting the file, and called it decision 16's fragment rule. The finding is rejected and the reasoning is recorded rather than left to be re-derived. Decision 15 is about **listings**: a file appears in full the first time it matters, and decision 16 forbids showing a later change as anything smaller than the whole file or the complete enclosing member, because three lines of context is a fragment wearing a diff's clothes. Chapter 15 prints no listing of that file at all. It says, in a sentence, to put `resolvable: false` on the key and take the reference resolver off with it, which is complete: there is nothing a reader could type wrongly from it, and the enclosing member here is the whole 108-line class, reprinted to mark one attribute in a state the reader is being told not to adopt. Chapter 11 is not the counter-example it looks like: there the broken listing **was** the chapter's subject and a reader had to read it line by line, where here the subject is the composer's message and the C\# is its cause in one line. The rule this settles: a file the book has already printed, changed into a state the book argues against and never ships, may be described in prose provided the description is complete enough to reproduce and a tag carries the state; printing part of it stays forbidden. `ch15-falsepass` is the tag. |

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
| HotChocolate.Data.EntityFramework (`main`) | 16.6.1 | verified 2026-08-19, chapter 3 note; same version sequence as the rest of the family |
| Microsoft.EntityFrameworkCore.Sqlite (`main`) | 10.0.11 | verified 2026-08-19, chapter 3 note; 10.x targets `net10.0` only |
| Microsoft.EntityFrameworkCore.Sqlite (`hc14` branch) | 9.0.19 | verified 2026-08-19, chapter 3 note: the latest 9.x, chosen because EF Core 10 cannot run on `net8.0` |
| `@wundergraph/composition` | 0.63.3 | verified 2026-08-23, chapter 7 note. Never installed directly: it is inside `wgc`, and the router execution config stamps it as `compatibilityVersion: 1:0.63.3` |
| `HotChocolate.ApolloFederation` (`main`) | 16.6.1 | verified 2026-08-23, chapter 5 note; models Federation up to v2.7 and defaults to v2.6, read out of the shipped assembly. Added to `Sessions.csproj` by chapter 6, and still the newest stable on that date, though a `16.6.2-p.6` prerelease exists above it |
| `HotChocolate.ApolloFederation` (`hc14`) | 14.3.1 | verified 2026-08-23, chapter 6 note. Restores and runs, and its `[Key]` and `[ReferenceResolver]` attributes are never read by the 14 source generator; see decision 71 |
| Apollo Federation, as the subgraphs declare it | v2.6 | verified 2026-08-23, chapter 5 note; the `@link` url the package emits with nothing pinned. Decision 63 |
| WunderGraph Cosmo Router | 0.341.0 | verified 2026-08-24, chapter 8 note, **by running it**: `router -version` reports 0.341.0 on go1.26.6, built 2026-08-18, matching the release's own timestamp. Still the newest stable on that date. The Windows archive's md5 matches the one published beside it, and the Apache-2.0 license was read out of the archive rather than out of the repository. `verify.ps1` asserts the version |
| `wgc` (Cosmo CLI) | 0.129.9 | verified 2026-08-23, chapter 7 note. Re-pinned from 0.129.7, which was two patch releases stale by then; every chapter 7 measurement is on 0.129.9 and `verify.ps1` asserts the version rather than accepting what is installed, because the chapter quotes the tool's error text |
| `HotChocolate.AspNetCore.Authorization` (`main`) | 16.6.1 | verified 2026-08-25, chapter 12 note. Added to `Speakers.csproj` by chapter 12; same version sequence as the rest of the family, published the same day as `HotChocolate.ApolloFederation` 16.6.1 |
| `Microsoft.AspNetCore.Authentication.JwtBearer` (`main`) | 10.0.11 | verified 2026-08-25, chapter 12 note. Added to `Speakers.csproj` by chapter 12; follows the framework rather than Hot Chocolate, so it matches the EF Core row above rather than the 16.6.1 rows |
| Pygments | 2.19.2 | verified 2026-08-19 on this machine; see decision 31 |
| Go, as the router reports it | go1.26.6 | verified 2026-08-24, chapter 8 note. Not a thing this book installs: it is what the router binary was built with, and it is in the table because `router -version` prints it and a reader will see it |

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

5. **The Federation Model** - supergraph and subgraphs, entity ownership, keys, the Apollo Federation v2 directive tour, and why this book builds on that specification rather than on the Composite Schemas draft
6. **Your First Subgraph** - `HotChocolate.ApolloFederation`, `@key`, reference resolvers, and what `_service` and `_entities` expose
7. **Composition** - `wgc router compose`, the two directives that stop it before federation does, what a router execution config actually contains, and resolvability as a walk over the graph
8. **Enter the Router** - Cosmo Router locally, what it loads and what it serves, the subgraph still on its own port behind it, and a query plan with no seam in it yet
9. **The Second and Third Subgraph** - the seams, `@external`, `@requires` and `@provides`, the first query answered across two subgraphs, what a shareable `node` costs once two subgraphs own different node types, and the graph the rest of the book uses

### Part III - The Problems

10. **The N+1 the Router Creates** - the router de-duplicates and batches representations and a naive reference resolver does not; what a DataLoader behind one is worth, and why it cannot also project. **Updated 2026-08-24 while drafting**, from a line that said only that the router batches: it does both, and which half it does not do is the chapter's argument (decision 95). The projection clause is decisions 96 and 97, which correct decision 69.
11. **Right Data, Wrong Entity** - `_entities` must answer in representation order, and what silently wrong data looks like when it does not. **Confirmed 2026-08-24 while drafting**, with one clause added rather than changed: the chapter is equally about why nothing catches it, because the router validates only the length of the answer (decision 100) and this book's own seed makes the failure invisible on every page it prints (decision 101).
12. **`_entities` Never Asks Who You Are** - the guard on the root field that the entity route walks straight past. **Confirmed 2026-08-25 while drafting**, with two clauses added rather than changed: there are three doors and not two, because `node(id:)` reaches the same rows for the same reason, and the correction a reader reaches next is worse than the mistake, because `[Authorize]` on the reference resolver emits no directive at all (decision 106). The fix half of the chapter is the router's, which has to be told separately to verify a token and to forward it (decision 108).
13. **The Page You Cannot Ask For** - filtering, sorting and paginating across a seam; why no directive fixes it, and the dedicated search domain as the escape
14. **One Field Fails and the Response Is Empty** - non-null error propagation, blast radius, designing for partial failure, and what became of `@semanticNonNull`. **Corrected 2026-09-05 while drafting**, which is what the open item on that directive asked for. The scope line assumed a directive a reader could adopt; it is an unratified RFC that has been superseded by a different proposal, and what Hot Chocolate ships under the name rewrites the exported schema without changing execution. The chapter says what it now is and watches the proposal that replaced it (decision 122). Two clauses added rather than changed: the blast radius has exactly two sizes and the larger one costs the whole response (decision 119), and no router setting reaches it (decision 121).
15. **Where Satisfiability Actually Fails** - reading composition errors, and why the composer names one route out of the several that fail. **Corrected 2026-09-05 while drafting.** The scope line said four; this book's graph offers six routes to a contributed field and eight once Search is in, and the count was a guess made before the chapter was measured. Chapter 7's forward reference carried the same number and is corrected in the same session (decision 127). Two clauses added rather than changed: which route is named moves with subgraphs that have nothing to do with the mistake and with the order of the lines in `graph.yaml` (decision 127), and the check can be satisfied without finding a route at all, by a shareable root field returning an interface (decision 128), which is the second bill for decision 74's `@shareable` on `Query.node` and the collection decision 90 asked chapter 15 for.
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
- E. **The Complete Source** - all four subgraphs, final state (decision 17)

## Progress

Status values: not-started / outlined / drafted / reviewed / final.

| Chapter | Status | Notes |
|---------|--------|-------|
| Preface | not-started | Write last. Must carry decision 8's plain statement that HC 14 is out of support. |
| 01 | drafted | No code, as planned. Note at `research/ch01-do-you-actually-need-this.md`. Established the summary box (decisions 20, 21, 41) and the figure idiom (decision 33); `figures/tikz/ch01-one-field.tex` is the idiom specification later figures are matched against. Its threshold is stated as my judgment under decision 38, because no source passed the Sources bar. |
| 02 | drafted | Note at `research/ch02-hot-chocolate-from-zero.md`. Stood up the verification repo, tags `ch02` and `ch02-hc14`, `verify.ps1` PASS on both. Emitted the first callout, which fixed the `hc14` file set (decision 47) and settled decisions 42 to 46. Measured the listing column budget at 73. |
| 03 | drafted | Note at `research/ch03-data-without-the-n-plus-1.md`. Four tags, `verify.ps1` PASS on each: `ch03` (main), `ch03-naive` and `ch03-starved` (the two states the chapter argues against, decision 51), `ch03-hc14`. The single-service baseline chapter 10 measures against is **5 statements naive, 2 batched**, for four sessions and three distinct speakers. Settled decisions 51 to 55. Turned `sessions` into a Relay connection, the first change to break an earlier chapter's printed requests. |
| 04 | drafted | Note at `research/ch04-schema-design-that-survives-change.md`. Three tags, `verify.ps1` PASS on each: `ch04` (main, 96 assertions), `ch04-orphan` (the non-null state the chapter argues against, decision 51), `ch04-hc14` (the same 96 assertions from the same script). Global object identification on both types, `sessionById` deprecated, and the book's first mutation, whose conventions generate the first union and the second interface. The nullability groundwork chapter 14 collects on is section 4.5. Settled decisions 56 to 62. The audit's findings and the two it raised that were rejected are recorded at the end of the research note. |
| 05 | drafted | Note at `research/ch05-the-federation-model.md`. No C#: `git diff ch04..ch05` over `src/` is empty, and `ch05` is the book's first tag on an unchanged tree (decision 66). `verify.ps1` gained eight assertions for the request the chapter opens on and prints, 104 total, PASS on `main` and `hc14`. Confirmed decision 31's `graphqlsdl` environment against real federation SDL, which was this chapter's stated job. Paid chapter 1's debt on why Apollo Federation v2 rather than the Composite Schemas draft, and corrected two factual clauses in decisions 6 and 7 in the process. Settled decisions 63 to 66. |
| 06 | drafted | Note at `research/ch06-your-first-subgraph.md`. Four tags, `verify.ps1` PASS on each: `ch06` (main, 148 assertions), `ch06-unguarded` (9, the reference resolver that does not read the type name inside the key), `ch06-hc14-ignored` (125, the attribute idiom compiling and doing nothing on 14.3.1) and `ch06-hc14` (128, the code-first route that works there). The book's first federation C#, and its first version difference that is not a difference in output but in whether the code works at all. Settled decisions 67 to 72. |
| 07 | drafted | Note at `research/ch07-composition.md`. Five tags, `verify.ps1` PASS on each: `ch07` (main, 195 assertions), `ch07-costly` (14, chapter 6's subgraph unchanged, which does not compose), `ch07-unshared` (12, the cost fix in and the shareable fix out), `ch07-typelevel` (12, the one-line fix and the ownership check it switches off) and `ch07-hc14` (174). The book's first non-.NET tool, its first artifact defined only by a protobuf, and its first failure caused by two vendors disagreeing rather than by anybody's mistake. Paid the `Query.node` bill and re-pinned `wgc` to 0.129.9. Settled decisions 73 to 78. The audit found fifteen things worth fixing, including two claims the research note itself had marked as not established; they are listed in the pull request. |
| 08 | drafted | Note at `research/ch08-enter-the-router.md`. Three tags, `verify.ps1` PASS on each: `ch08` (main, 241 assertions), `ch08-noplan` (12, the config that serves the graph and hides the query plan, decision 51) and `ch08-hc14` (214). The book's first long-running process that is not ours, and its first component that is a downloaded binary rather than a package. `git diff ch07..ch08` over `src/` is empty, so this is the second tag on an unchanged tree after `ch05` (decision 66). Settled decisions 80 to 84, and closed the two open items on the router version and the gateway audit. |
| 09 | drafted | Note at `research/ch09-the-second-and-third-subgraph.md`. Three tags, `verify.ps1` PASS on each: `ch09` (main, 328 assertions), `ch09-hc14` (214, an unchanged tree with the shared script branched so it still passes) and `ch09-noserializer` (20, the Ratings service without `AddDefaultNodeIdSerializer()`, which builds, starts and answers its own root field while the entity route alone fails in silence, decision 51). The graph becomes three services on three databases. Speaker leaves Sessions for a stub with `resolvable: false`; Speakers owns the rows; Ratings contributes three fields to a type it does not own, one of them behind `@requires`. The first query answered across two subgraphs costs the two statements chapter 3 measured inside one process. Settled decisions 85 to 91, and closed four open items. The retro added three more: decisions 92 and 93 turn on two new gate checks this chapter's audit argued for, and 94 is the rule no check can enforce. 30 pages, the longest in part II, and one chapter (decision 89). |
| 10 | drafted | Note at `research/ch10-the-n-plus-1-the-router-creates.md`. Three tags, `verify.ps1` PASS on each: `ch10` (main, 342 assertions), `ch10-naive` (33, the Speakers reference resolver with the DataLoader taken out from behind it, decision 51) and `ch10-hc14` (214, an unchanged tree). The first chapter of part III. Its one source change is a DataLoader behind the Sessions reference resolver, which is the debt chapter 6 left in a comment. Two findings are larger than the chapter: the router de-duplicates representations before it sends them (decision 95), and decision 69 is wrong, which decision 96 records and corrects. Settled decisions 95 to 98, closed one open item and narrowed two. 10 pages, the shortest chapter since 5, and it stayed short because the audit moved seven verbatim captures out of the prose: they came from scratch states no tag produces, which decisions 48, 53 and 65 do not allow the book to quote. That triage is recorded at the end of the note. |
| 11 | drafted | Note at `research/ch11-right-data-wrong-entity.md`. Four tags, `verify.ps1` PASS on each: `ch11` (main, 353 assertions, unchanged source), `ch11-misordered` (40, the hand-written loader filling the results span by row rather than by key, decision 51), `ch11-handwritten` (353, the corrected hand-written loader run against main's own script, decision 104) and `ch11-hc14` (214, an unchanged tree). The chapter changes no line of the example, because the example was already right; what it adds is the request that would have caught the defect. Carries the deliberately broken listing the TOC owed, under decision 22's carve-out. Three findings are larger than the chapter: the source generator makes this failure unreachable and reinterprets a list return rather than rejecting it (decision 99), the router validates the length of an entity answer and nothing else (decision 100), and this book's seed hides the failure completely, so the chapter is about why every page still looked right (decision 101). Settled decisions 99 to 104 and opened four open items. 12 pages. |
| 12 | drafted | Note at `research/ch12-entities-never-asks-who-you-are.md`. Six tags, `verify.ps1` PASS on each: `ch12` (main, 389 assertions), `ch12-rootguard` (20, `[Authorize]` on `Query.speakers` and nothing else), `ch12-inertguard` (13, the same attribute on the reference resolver, emitting no directive at all), `ch12-routeronly` (17, the federation directive with no subgraph guard behind it), `ch12-noforward` (17, main's C# with the router's `headers` block removed) and `ch12-hc14` (214, an unchanged tree). The book's first authorization, its first bearer token, and the first request in it that the router answers with something other than 200. `Speaker` gains one guarded column rather than a guarded type, which is what keeps every request chapters 9 to 11 print answerable without a credential (decision 105). Three findings outrank the chapter: the correction a reader reaches next is inert and silent (decision 106), a field guard costs the row while a type guard costs nothing (decision 107), and the router's own directive filters the answer after the subgraph has already read it (decision 109). Settled decisions 105 to 113 and opened five open items. The audit found nine things, seven of them real; the two rejected are recorded with their evidence at the end of the note. Four of the seven were files the chapter changed and never printed, which is decision 15 and the first of the three failures this book exists to fix, so decision 113 puts a check behind it. 16 pages, four of them the files the audit added. |
| 13 | drafted | Note at `research/ch13-the-page-you-cannot-ask-for.md`. Tags `ch13` (main-equivalent, 422 assertions) and `ch13-hc14` (unchanged, 214), `verify.ps1` PASS on both. Search becomes the fourth subgraph and owns a complete discovery projection, including the unrated session. A filtered rating-descending page costs one Search statement and one batched Sessions statement; Ratings and Speakers cost none. The plan is Search `Single` followed by Sessions `BatchEntity`. The original Sessions root and seed remain unchanged under decision 117. Settled decisions 114 to 118 and closed the fourth-subgraph open item. `check-listings.ps1` matches all 23 mapped listings. 11 pages. |
| 14 | drafted | Note at `research/ch14-one-field-fails-response-is-empty.md`. Three tags, `verify.ps1` PASS on each: `ch14` (main, 451 assertions), `ch14-nonnull` (449, the state the chapter argues against, decision 51) and `ch14-hc14` (216, an unchanged tree). Five fields lose their exclamation marks, and the graph degrades instead of emptying. Three findings outrank the chapter: chapter 4's rule is necessary and not sufficient once a router is in the middle (decision 119), the one non-null root field nobody wrote is generated by `AddGlobalObjectIdentification()` and its nullable item type protects nothing (decision 120), and `subgraph_error_propagation` cannot reach a stopped subgraph at all (decision 121). Settled decisions 119 to 126, closed the `@semanticNonNull` open item and opened six. The audit found nine things and two of them outrank their sections: chapter 9 prints a trimmed response (decision 125), and a claim this chapter made about the composer was wrong in the composer's favour (decision 126). The book's first HotChocolate 14 callout since chapter 8, and it is about a command-line flag rather than about the graph. 15 pages. |
| 15 | drafted | Note at `research/ch15-where-satisfiability-actually-fails.md`. Two tags, `verify.ps1` PASS on each: `ch15` (main, 493 assertions, unchanged source) and `ch15-falsepass` (32, the state the chapter argues against, decision 51, with its own script, because a three-subgraph graph and a config of its own is more than a flag in the shared one could carry). **`ch15-hc14` is outstanding** and decision 130 says why: that branch is checked out in a leftover worktree from the chapter 13 session and this one did not touch it. The chapter's assertions are gated off there, so the expected result is an unchanged 216. The chapter changes no line of the example; what it adds is the block of compositions that proves what a resolvability answer means in both directions, every input generated into the temp directory on decision 126's reasoning rather than committed to `graph/`. Two findings outrank the chapter: which route the composer names is decided by subgraphs and by file order that have nothing to do with the mistake (decision 127), and the check can be satisfied without finding a route at all, by the shareable `Query.node` chapter 7 shipped (decision 128), which the router then meets as a 500, a valid query against the wrong field, and silence. Settled decisions 127 to 132, closed the transitive access-control half of one open item, half-closed decision 90's second option, and opened two. Corrected the TOC line's route count and chapter 7's forward reference, both of which said four. The audit found twenty-six things and twenty-five of them were real: two were a Search-for-Speakers swap already caught in drafting, two were captures trimmed without saying so, which is decision 125's defect arriving in a new chapter, and the rest ran from a rounded line count to four bolded paragraph openers that appear nowhere else in the book. The one rejected is decision 132, recorded with its reasoning rather than dismissed. 11 pages. |
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
- **Language and spelling:** English, `en-US`, with the gate's variant table on
  as well as its preset (decision 92): the preset covers the differences that
  follow a rule and the variant table covers the ones that do not, which is
  where `programme` and `judgement` live. The exemption list in
  `check-chapter.psd1` starts empty and grows only as the gate finds a real
  case - a British spelling inside captured tool output or a vendor's own
  prose. A spelling exemption is never added to accommodate the author's habit.
  A cited author whose name carries a diacritic keeps it, written with an
  accent macro from `preamble/macros.tex` rather than the Unicode letter,
  which strict `Ascii` mode forbids, or a respelling, which would misspell a
  real person (decision 40). There are two, `\uml` for a diaeresis and `\acu`
  for an acute, and a name needing a third accent adds it to that family
  rather than writing the accent raw: a bare `\"` or `\'` in a chapter file is
  a quote character as far as the prose gate is concerned (decision 112).
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
  the book. `verify.ps1` builds all four subgraphs on `main`, runs `wgc router compose`,
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
- The index is maintained while writing, not retrofitted, and it is the
  **reader's** vocabulary rather than the book's own. A term a reader has never
  met cannot be looked up, so nothing internal to how this book is made is
  indexed: no decision number, no tag name, no research note. The gate enforces
  the case that actually happened (decision 93) and the rule is wider than the
  pattern.
- **A chapter that adds a service re-prints the shared inputs that name
  services** before it ends, under decision 16's full-file-again rule. Decision
  94: a file printed correctly in one section goes stale three sections later
  with nobody touching it, and no check can see that.

## Open items

An unresolved question, and the condition that unblocks it.

- **What `RegisterDbContextFactory<T>()` actually buys.** Chapter 3 calls it
  and says in the prose that it cannot tell the reader what it changes.
  Removing it leaves the exported schema, every response and every statement
  count in the chapter identical, because `AddDbContextFactory<T>()` already
  registers the context as a scoped service. The plausible answer is that it
  governs which context instance a resolver is handed, which only matters if
  resolvers run concurrently, and that is the next item. Unblocked by a test
  that observes two resolvers holding different context instances, at which
  point the chapter gains a sentence.
- **Whether Hot Chocolate ever resolves sibling list-item resolvers
  concurrently.** A `DbContext` is not thread-safe, so this decides whether
  chapter 3's naive resolver was ever at risk of anything worse than being
  expensive. Four sessions with an artificial delay executed strictly one at a
  time, which shows nothing about a longer list or a different execution
  strategy. **No chapter claims anything about resolver concurrency
  meanwhile**, and chapter 3 criticises the naive resolver for its statement
  count alone. Unblocked by a run that observes genuine overlap, or by
  ChilliCream documenting the execution strategy.
- **Whether `totalCount` on a connection costs a second statement.** Chapter 3
  prints no query that asks for it, so it was not measured. It matters the
  first time a chapter does, because decision 19 makes statement counts the
  book's only numbers. Unblocked by measuring it, which is a one-line change
  to a query.
- **Whether `[UseConnection]` can be made to work.** Chapter 3 tried it first,
  and it compiled, exported `sessions` as an ordinary list, and leaked its
  `PagingArguments` parameter into the schema as a required argument.
  `AddPagingArguments()` fixed the leak and the field still did not become a
  connection. `[UsePaging]` was substituted and worked immediately, so the
  question was abandoned rather than answered and **the book says nothing about
  `[UseConnection]`**. Unblocked by finding the registration or return type it
  wants, at which point decision 55's neighbourhood is worth re-reading.
- **Whether a key-preserving projection can be built for a type with no
  parameterless constructor.** This is what is left of the entity-route
  projection item chapter 6 opened, which chapter 10 closed: the route can be
  projected (decision 96) and cannot be projected and batched at once, because
  the selector defaults the key (decision 97). The narrower question is whether
  any shape survives both. Three were tried and recorded in the chapter 10 note:
  two throw `Expression.New` on a positional record, and merging into a
  `DefaultSelectorBuilder` by hand raises nothing and **silently discards the
  added expression**, which was not explained either. Unblocked by finding a
  shape that compiles, keeps the key and narrows the SELECT, at which point
  decisions 55 and 97 are both worth re-reading. A book whose domain was classes
  with settable properties would not have this problem at all, and that is worth
  saying in whichever chapter picks this up.
- **Whether `@link(as:)` is unsupported by `HotChocolate.ApolloFederation` or
  merely unemitted.** Measured 2026-08-23: the `@link` definition the package
  writes into an exported schema has neither `as` nor `for`, and types `import`
  as `[String!]` rather than the specification's `link__Import`. That is what
  the package *prints*; whether the runtime would honour an `as` written by
  hand was not tested. Chapter 5 says only what was measured, that the
  namespacing is not available there. Unblocked by writing a schema that uses
  it and seeing what happens, which matters only if a chapter ever needs two
  specifications' directives under one name.
- **Two Apollo documentation pages disagree with each other about `@tag` and
  `@context`.** The subgraph specification page and the directives reference
  give different locations for `@tag` (one includes `SCHEMA`, the other does
  not) and disagree about whether `@context` is `repeatable`. Recorded in the
  chapter 5 note. No chapter rests on either, and appendix C will have to,
  which is where this gets settled. Unblocked by checking both against a
  composer that accepts each form.
- **The specification chapter 5 declines to build on is being renamed.** The
  Composite Schemas working group's summary of its 2026-08-06 meeting records
  the final name as the GraphQL Federation Specification, and records that it
  extends Apollo Federation rather than replacing it. The rename has not
  reached the published document, which still calls itself the Composite
  Schemas Spec. Chapter 5 says both halves and attaches the source's own
  auto-generation disclaimer to it. Unblocked by the rename landing in the
  specification, at which point chapter 1's and chapter 5's wording both move
  in one edit.
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
- **Whether to amend chapter 9's printed half-down response.** Decision 125
  records that it prints one error where the graph answers five, measured at
  its own tag, so the listing was trimmed when it was written. Chapter 14
  corrects the count in its own first section, which is what decision 96 did in
  the same position, and `verify.ps1` now asserts count and paths so it cannot
  drift again. What is open is the page itself: replacing that listing means
  re-typesetting a response in a chapter three parts back, and the correction
  is already in print one chapter later. My inclination is to fix it, because
  it is one listing rather than five historical tags, which is what made
  decision 96's equivalent expensive. Unblocked by deciding, not by measuring.
- **Whether anything else the book prints as a response is trimmed.**
  Decision 125's defect survived two gates because neither looks at a printed
  response body: `check-listings.ps1` compares whole-file source listings, and
  `scripts/check-chapter.ps1`'s verbatim family only fires when the prose calls
  a listing a capture, which chapter 9's does not. Every JSON block in the book
  is a candidate and nobody has swept them. Unblocked by extending
  `check-listings.ps1` to map response blocks to a request in `verify.ps1` the
  way it already maps source blocks to a tag, which is a real piece of work and
  is the natural place for it, since the map from a listing to its provenance
  is already that script's job.
- **Whether the two vendors' `@semanticNonNull(levels:)` disagreement matters.**
  Closed the larger item this came out of: decision 122 settles what the
  directive is and chapter 14 prints it. What is left is narrower and is the
  third vendor disagreement in the book after decisions 73 and 88. Hot
  Chocolate's rewritten document declares `levels: [Int!]`, a nullable list;
  the composed schema `wgc` 0.129.9 produces declares `levels: [Int!]!`,
  substituting a definition of its own rather than carrying through the one it
  was handed. Both compose and the directive reaches the schema the router
  serves, so nothing fails. Which side drifted was not established and no
  chapter says. Unblocked by finding the normative definition, which is
  appendix C's territory, in the same place decision 88's `@provides` question
  already waits.
- **What the router does with a semantic-non-null supergraph at run time.**
  The composition was measured and no service was ever served from it: the
  four schemas were copied to a scratch directory, one replaced with the
  rewritten form, and `wgc` run on the copies. Whether the router honours the
  directive, ignores it, or reports it to a client is unknown, and chapter 14
  claims only what it measured. Unblocked by exporting the real Sessions schema
  that way and starting the graph on it, which is cheap and was out of the
  chapter's scope because the book ships neither mechanism (decision 122).
- **Whether `ErrorHandlingMode` survives the router.** `onError` is a property
  of a request a client sends to a Hot Chocolate server, and every request in
  this book since chapter 8 goes to a router written in Go which forwards a
  query rather than a client's envelope. The enum was read out of the shipped
  assembly and never exercised. This is the question that decides whether the
  trade decision 119 accepts can be bought back, so it is worth more than its
  size. Unblocked by sending `onError` to the router and seeing whether
  anything reaches a subgraph, and then by whether WunderGraph documents a
  position on the proposal.
- **Whether `AddGlobalObjectIdentification()` can produce a nullable `nodes`
  without an interceptor.** Decision 120 ships a type interceptor because no
  option was found, and the search was not exhaustive. It matters only for
  tidiness, and it matters a little for chapter 20, which will be looking at
  what a subgraph should declare. Unblocked by reading the registration's own
  options surface.
- **Whether `nodes` can be made to batch.** Chapter 4 measured it: two ids cost
  two statements even when both are sessions, because the field resolves each
  id on its own. A node resolver that goes through a DataLoader gets batching
  anyway, which is why `SpeakerType`'s does and `SessionType`'s does not. The
  chapter states the count and does not claim the plural field cannot be made
  to batch, because that was not established. **Half of this is now answered and
  the answer is no.** The item used to be unblocked by finding whether a node
  resolver taking a `QueryContext` can be routed through a loader without losing
  the projection; chapter 10 measured that it cannot, for any type in this book,
  because the projection defaults the key and a loader is keyed on it
  (decision 97). So `nodes` can be made to batch or to project and the open
  question is only whether the plural field can be made to batch **at all**,
  which is a question about how that field resolves its list rather than about
  projection. Unblocked by measuring `nodes` against a node resolver that goes
  through a loader and no `QueryContext`, which is what `SpeakerType`'s already
  does.
- **Which of Hot Chocolate and Cosmo is right about `@cost(weight:)`.** Hot
  Chocolate emits `weight: String!`, Cosmo's composer demands `Int!`, and
  decision 73 turns the defaults off rather than adjudicating. The
  cost-analysis specification that governs the directive was not read while
  drafting chapter 7. Unblocked by reading it, at which point the chapter can
  name the side that drifted instead of reporting a disagreement, and chapter 20
  inherits a better-founded position on what to declare.
- **What complexity limits a federated subgraph should declare.** Decision 73
  leaves the book's schema with no `@cost` weights at all, which is fine for
  composing and is not a position on cost analysis. Chapter 20's scope line
  already names depth and complexity limits. Unblocked by outlining chapter 20,
  which has to say what a subgraph behind a router should set and whether the
  router or the subgraph is the place to enforce it.
- **Whether `@shareable` has to be imported in the `@link` list to be
  honoured.** Chapter 5's note recorded that adding the directive in both
  subgraphs **and** importing it in both lists composes, which tests the
  conjunction and establishes neither half. Measured 2026-08-23 on `wgc`
  0.129.9: removing it from the import list and leaving it on the fields still
  composes, so this composer does not require the import. Whether the
  specification requires it was not established and Cosmo's leniency is not
  evidence, so no chapter claims anything either way; the book's own documents
  import it because that is what Hot Chocolate emits. Unblocked by finding the
  normative statement, which is appendix C's territory.
- **Whether `ROUTER_CONFIG_PATH` or `EXECUTION_CONFIG_FILE_PATH` is the current
  field.** Both exist in the router's source at tag `router@0.341.0` and both
  start and serve the graph on this machine, measured 2026-08-24. No fetched
  documentation page reconciles them. One piece of indirect evidence turned up
  while running the gateway audit: that harness's committed config uses
  `router_config_path` and starts the router with no flag at all, which 0.341.0
  refuses, so what demonstrably changed is that the router no longer auto-loads
  a bare `config.yaml`. Chapter 8 names only the structured
  `execution_config.file.path` form and claims nothing about the other.
  Unblocked by WunderGraph documenting a deprecation, or by one of the two
  disappearing from a release.
- **What the router's normalization is for.** Measured 2026-08-24: the router
  rewrites literal arguments into variables before forwarding an operation, so
  `node(id: "U3BlYWtlcjox")` reaches the subgraph as `query($a: ID!)`, and
  `normalizedQuery` in the plan is its record of that. Whether it is for the
  subgraph's plan cache, the router's own, or something else was not
  established. Chapter 8 states the behaviour and gives no reason for it.
  Unblocked by reading `graphql-go-tools`, which is where the planner lives and
  which the router names in its own `-version` output.
- **Whether the two `provides-*` audit suites still fail at router 0.341.0.**
  What the three failing suites have in common was settled while drafting
  chapter 9 by reading their source: `provides-on-interface` and
  `provides-on-union` are both `@provides` on an abstract type, and
  `complex-entity-call` is about compound and nested `@key` field sets and
  contains no `@provides` at all. So nothing this book's example does is in the
  territory either failure covers, and chapter 9 says so. What is **not**
  settled is whether they still fail. Two merged upstream pull requests suggest
  the abstract-type handling was fixed before 0.341.0: `wundergraph/cosmo`
  #3043, shipped in router 0.326.3, and #3026, shipped in
  `@wundergraph/composition` 0.63.0, below the 0.63.3 this book pins. That is in
  tension with decision 84's local run, which recorded both suites failing at
  0.341.0. Unblocked by re-running the audit, which was out of chapter 9's
  scope. No chapter prints any of it.
- **Whether the two node id serializers agree under a non-default format.**
  Decision 86 has the Ratings service registering
  `AddDefaultNodeIdSerializer()` because it cannot call
  `AddGlobalObjectIdentification()`. The ids round-trip across all three
  services and `verify.ps1` asserts the strings, so they agree at the default.
  `NodeIdSerializerOptions` and `NodeIdSerializerFormat` were not explored, and
  a book pinning a non-default format would have to check that the service
  which cannot configure the feature still produces what the two that can do.
  No chapter claims anything about it. Unblocked by setting a non-default format
  in one service and seeing whether the seam survives.
- **What the router does with a `@provides` whose preconditions are unmet.**
  Decision 88 measured that this composer accepts one where Apollo's
  documentation says composition should fail. What happens at run time was not
  measured, because the input that demonstrates it is a hand-written document
  with no service behind it (decision 76). Unblocked by standing a fourth
  service behind that document, which is a real cost for a question no chapter
  currently asks.
- **Whether anything can make `node(id:)` route correctly across a seam.**
  Decision 90 rejected four approaches, and only the first of them is certain:
  a node resolver per type per subgraph is impossible because the rows are not
  there. The other three were rejected on reasoning rather than measurement,
  and `@interfaceObject` was not investigated at all, because this book's
  example has no federated interface. **The second is now measured at
  composition and is decision 129**: declaring `node` in one subgraph only
  composes the healthy graph unchanged and restores the check decision 128
  loses, so it was rejected on a reason that is half wrong. What is left of it
  is the runtime half, which chapter 15 states it did not test: with one
  subgraph declaring the field, a `node(id:)` for a speaker has to be planned
  through the Sessions subgraph's copy, and whether that answers, errors or
  reaches the wrong service is unknown. That is now the most valuable
  measurement in this neighbourhood, because a chapter has recommended the
  arrangement on the strength of the other half. Also recorded while looking:
  `InterfaceObjectAttribute` and `InterfaceObjectDirective` **do ship** in
  `HotChocolate.ApolloFederation` 16.6.1, read out of the assembly on
  2026-09-05, while ChilliCream's federation API page 404s; whether the
  directive does anything for this problem was not tried and no chapter says.
  Part of the same question: **why the planner picks Sessions** for a bare `node(id:)` when
  both subgraphs declare the field was not established either. The chapter says
  so in the prose rather than guessing, and whether it is file order, subgraph
  id or something in `graphql-go-tools` decides whether the failure is stable
  or depends on how `graph.yaml` happens to be written.
- **Whether the router caps the number of representations in one entity
  fetch.** Decision 95 established that the router de-duplicates them and says
  nothing about a ceiling, because none was found: not in `loader.go` or
  `loader_multi_entity.go` at the pinned commit, not in a repo-wide search for a
  maximum-representations constant, and not in Cosmo's hardening or cost-control
  documentation. Absence of documentation is not a measurement, and this book's
  seed of four sessions cannot produce a list long enough to find one, so
  **chapter 10 does not claim the list is unbounded**; it claims the thing it
  measured, that the length is the owning service's page size. Unblocked by a
  seed large enough to test, or by WunderGraph documenting a limit. A trap for
  whoever picks this up: Cosmo's `max_entries_per_batch` is a client-operation
  batching setting and has nothing to do with entity representations.
- **Whether two representations with the same key and different `@requires`
  fields collapse.** The router hashes the whole rendered representation rather
  than the key inside it (decision 95), which suggests they do not, but the
  graph has one `@requires` field and no query produces the case. Chapter 10
  states the hashing and declines the inference. Unblocked by a second requiring
  field on the same type, which chapter 13 may need anyway.
- **Why the error path on an unwritten `Result` slot sometimes drops the
  index.** Found while checking a chapter 11 audit finding, and it changed both
  the chapter and the script. Measured 2026-08-24 over twenty runs, five each
  across four key orders: nineteen answered `_entities.2`, naming the position
  that was never filled, and one answered `_entities` alone, with the `data`
  half byte-identical every time. So the index is real, usual, and not
  something to assert. `verify.ps1` on `ch11-misordered` now checks the first
  path segment only, and chapter 11 prints the `data` half and states in prose
  that the index is not dependable. Unblocked by reading how Hot Chocolate
  attributes an unresolved `Result` to a list item, which decides whether this
  is a race, a property of the key order, or something else. A later chapter
  that wants to print a path from the entity route should settle this first.
- **Whether the router's length check can be provoked from a Hot Chocolate
  subgraph.** Decision 100 read the check in the router's source and chapter 11
  describes it rather than quoting it, because no state of the verification repo
  produces a short or long `_entities` array: Hot Chocolate answers one entry per
  representation always, and even the unwritten-slot failure decision 102 records
  still returns a list of the right length carrying a null. Unblocked by a
  subgraph that is not Hot Chocolate, or by something in front of one that
  truncates the array, neither of which is worth a fourth service. Until then the
  error text stays under decisions 53 and 65.
- **Whether SQLite guarantees the row order chapter 11 relies on.** Every run
  returned rows in rowid order for an `IN` list, and the chapter deliberately
  claims something weaker: that the order is the store's choice rather than the
  caller's. Nobody read SQLite's documentation on result ordering without an
  `ORDER BY`, because no claim in the chapter needs it. Unblocked by reading it,
  and worth doing only if a later chapter wants to state what SQLite does rather
  than what a store in general may do.
- **Whether a chapter after 11 will move the seed or the default sort.**
  Decision 101 depends on four sessions naming speakers 1, 1, 2 and 3 in schedule
  order, on `sessions` sorting by `StartsAt` with no sort argument, and on the
  paging surface offering no way to reverse a window. Chapter 13's cross-seam
  sorting is the chapter most likely to change one of those, and if it does,
  chapter 11's demonstration quietly stops demonstrating: `ch11-misordered` would
  start failing a request the book prints as correct. Nothing checks this across
  chapters. Unblocked by outlining chapter 13, which should read decision 101
  before it touches the ordering of anything. **Chapters 13 and 14 both left it
  alone**, and chapter 14 found the trap that hides underneath it: the four
  databases are gitignored, `EnsureCreated` seeds an empty one and does nothing
  to an existing one, and chapter 4's `rescheduleSession` moves a session's
  `StartsAt`. `verify.ps1` deletes all four before every run and is therefore
  safe; a standalone harness that forgets to answers the schedule as speakers
  `1, 1, 3, 2` and looks entirely reproducible doing it. Chapter 14's first
  measurement pass was wrong that way and was caught by comparing against this
  row. Anything measuring outside `verify.ps1` deletes the databases first.
- **Why the router's pre-fetch field authorization did not stop the fetch.**
  `enable_pre_fetch_field_authorization` exists at router 0.341.0, defaults to
  false, is accepted by the config schema, and its documentation says it
  authorizes an operation's protected fields before any subgraph fetch runs.
  Measured 2026-08-25 on `ch12-routeronly`: with it on, the Speakers service
  still issued one statement answering a request the router then refused. It is
  not inert, because the error set on a neighboring request changed when it was
  set, but it did not prevent the read. Chapter 12 states the measurement and
  claims nothing about the switch. Unblocked by reading the router's own
  authorization path, or by WunderGraph documenting what the option covers.
- **Whether a field guard can be made to refuse before the fetch.** Decision 107
  measured the trade: a guard on `Speaker.email` costs the row and a guard on
  the `Speaker` type costs nothing, because field middleware runs after the
  resolver and type middleware runs before it. Whether anything gives the
  precision of the first at the cost of the second was not explored, and it
  matters for a type whose row is expensive rather than merely private.
  Unblocked by finding a mechanism that refuses a single field before its
  entity is fetched, at which point decision 107's trade is worth restating.
- **Whether `@requiresScopes` and `@policy` behave the way `@authenticated`
  does.** `RequiresScopesAttribute` and `PolicyAttribute` ship in
  `HotChocolate.ApolloFederation` 16.6.1 beside `AuthenticatedAttribute` and
  neither was applied to anything. Decision 109's finding, that the router
  filters after the fetch, was measured for `@authenticated` alone, and Apollo's
  own documentation notes that `@policy` needs a router plugin to evaluate it at
  all. No chapter claims anything about either. Unblocked by putting one on a
  field and measuring the same two things: what the composer writes, and what
  the statement count is for a refused request. Chapter 20's complexity-limit
  question is the likely place.
- **Whether `ApplyPolicy` can be kept out of the supergraph.** Decision 110
  records that `AddAuthorization()` puts the enum in the subgraph schema, the
  composer carries it up, and the router serves it, taking the named type count
  from 23 to 24. Whether `@inaccessible` on it, or a type interceptor of the
  kind decision 74 already ships for `Query.node`, could hide it from clients
  was not tried. Unblocked by trying one, and worth doing only if a chapter
  decides a public schema should not describe its own authorization machinery.
- **Whether `@wundergraph/composition` has ever had the access-control bugs
  Apollo's composer had.** Two CVEs published 2025-11-13, CVE-2025-64530 and
  CVE-2025-64172, are both in `@apollo/composition`: access-control directives
  not enforced across interface implementations, and not propagated across
  `@requires`. The second is close enough in shape to matter here, because this
  book's graph has a `@requires` field. This book composes with
  `@wundergraph/composition` 0.63.3, a different implementation. Checked and
  found empty on 2026-08-25: `gh api repos/wundergraph/cosmo/security-advisories`
  returns nothing, so there are no published advisories for that repository.
  That is an absence of advisories rather than an absence of the defect.
  Re-checked four ways on 2026-09-05, through the GitHub advisory GraphQL API,
  the REST advisories endpoint, OSV and the repository's own list, and still
  empty. **The transitive case is now tested and is decision 131**, so what is
  left of this item is one case and it is the dangerous one: the composer
  writes no rule for a field a `@requires` builds out of a guarded one, and what
  stopped the value escaping in the measured graph was the owning subgraph
  refusing the field the router had asked for. A graph guarded only at the
  router, chapter 12's `ch12-routeronly` shape, has no subgraph doing that.
  Unblocked by putting a router-only `@authenticated` on a field that another
  subgraph names in a `@requires` and sending the derived field with no token.
  Worth doing before chapter 20, which is where hardening is argued.
- **Whether the check decision 128 defeats is defeated by abstract return
  types in general, or by `Node` in particular.** Six variants of the Speakers
  document were run and the behaviour is stable, but every one of them used
  `Node`, because it is the only interface this graph puts at a root field. The
  reading of the composer says the rule is general to any abstract node with no
  implementations, which is a reason to expect it rather than a measurement of
  it, and no chapter claims it. Unblocked by putting a second interface, or a
  union, at a root field in two subgraphs and breaking a key behind it.
- **Whether anyone has reported decision 128 upstream.** No search was made,
  and the chapter claims nothing either way. It matters because a defect that
  is known and fixed in a later `@wundergraph/composition` changes what
  chapter 15 should tell a reader to do, and because reporting it is the
  obvious thing to do with a finding of that shape. Unblocked by searching the
  `wundergraph/cosmo` issue tracker for the resolvability walk and the visited
  record, and by re-running the six variants against a newer composer.
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
