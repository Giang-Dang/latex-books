# Chapter 10 - The N+1 the Router Creates

Research note for the first chapter of part III: what a reference resolver
costs when the router hands it a list, and what a DataLoader behind one is
worth.

Web sources accessed **2026-08-24**; everything else was measured on this
machine on the same date.

Four things are worth stating before any of it.

**The failure this chapter is about is invisible from outside the service.**
Every other state this book has argued against announced itself: a null where a
name should be, an empty list, an unhandled error, a composition that stops.
This one answers every request correctly. The exported schema is unchanged, the
graph composes, the query plan is the same two fetches, the router sends the
same one HTTP request carrying the same representations, and the client gets
byte-for-byte the same response. The only thing that moves is a number in one
service's own log. That is why `ch10-naive`'s script spends most of its
assertions on what did **not** change.

**The router already does half of what a DataLoader does, and this book did not
know that until now.** It de-duplicates representations before it sends them.
Four sessions with three distinct speakers produce a fetch carrying three
representations, not four, and two sessions sharing a speaker produce one. So
the N in this chapter's N+1 counts distinct entities rather than rows, and the
half the router does not do - collapsing the batch into one query - is exactly
the half that costs statements.

**Decision 69 is wrong and this chapter corrects it.** It records that
`QueryContext<T>` cannot be injected into a reference resolver. It can, in both
services, on the same 16.6.1, and it projects correctly. What is true is a
different and more interesting thing: batching and projection cannot be
combined here, because the selector defaults the key and a batching loader is
keyed on it. The section "The projection that works and cannot be shipped"
below is that, with the stack traces.

**One negative result carries a recommendation.** Neither WunderGraph nor
ChilliCream publishes guidance telling a subgraph author to put a batch loader
behind a reference resolver. Apollo does, in unsigned product documentation.
Under decision 38 that puts the recommendation for this specific stack on my
own judgment, with Apollo's general guidance as corroboration rather than as
instruction.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| GreenDonut | 16.6.1, same monorepo and release date as the above |
| `wgc` (Cosmo CLI) | 0.129.9, `@wundergraph/composition` 0.63.3 |
| Cosmo Router | 0.341.0, the released Windows binary |
| `graphql-go-tools` inside it | v2.16.0, per that release's own `go.mod` |
| Gate | `pwsh verify.ps1`, run on each tag below. All PASS 2026-08-24 |

| Tag | Branch | What it is | Assertions |
|-----|--------|-----------|------------|
| `ch10` | `main` | the finished chapter: a DataLoader behind both entity routes | 342 |
| `ch10-naive` | `ch10-naive` | the Speakers reference resolver querying the context directly, and the proof that nothing else moves (decision 51) | 33 |
| `ch10-hc14` | `hc14` | an unchanged tree; every assertion the chapter added sits behind a flag that is false there | 214 |

**Ports**, unchanged: Sessions 5001, Speakers 5002, Ratings 5003, router 3002.

**Seed**, unchanged and deliberately not touched: four sessions, three distinct
speakers, six ratings across three of the four sessions. Chapter 3 settled the
single-service baseline against this exact seed - five statements naive, two
batched - and changing it would invalidate that comparison, which is the one
this chapter is built on.

Schedule in **seeded** order, which is what the chapter prints and what
`ch10-naive` asserts. `main`'s script runs chapter 4's reschedule before it
reaches the router block, which moves *Paging Without Offsets* to 16:00 and so
past *The Bank That Split Its Graph*; that is why the two scripts assert
different orders for the same request. Same handling as chapter 9.

| # | Title | Speaker | Speaker key |
|---|-------|---------|-------------|
| 1 | Schemas That Outlive Their Authors | Ada Fischer | 1 |
| 2 | Reading a Query Plan | Ada Fischer | 1 |
| 3 | Paging Without Offsets | Bruno Kaminski | 2 |
| 4 | The Bank That Split Its Graph | Chidi Okafor | 3 |

## The numbers this chapter prints

Every count is asserted by `verify.ps1` at the tag named in the last column.

| Request | Sessions | Speakers | Ratings | Total | Tag |
|---|---|---|---|---|---|
| `sessions { nodes { title speaker { name } } }` | 1 | 1 | 0 | **2** | `ch10` |
| the same, with no loader behind the reference resolver | 1 | 3 | 0 | **4** | `ch10-naive` |
| `+ averageScore ratingCount` | 1 | 1 | 1 | **3** | `ch10` |
| the same, no loader | 1 | 3 | 1 | **5** | `ch10-naive` |
| `sessions(first: 2) { nodes { speaker { name } } }` | 1 | 1 | 0 | 2 | both |

On its own port, with no router involved:

| Request | Statements at `ch10` | at `ch10-naive` |
|---|---|---|
| 3 `Speaker` representations to 5002 | 1 | 3 |
| 3 `Session` representations to 5001 | 1 | 3 |
| the same `Session` id 3 times to 5001 | 1 | 3 |
| 1 representation whose key fails the type-name guard | 0 | 0 |

The `Session` row is the one that moved on `main`. It was 3 from chapter 6 to
chapter 9, because `SessionType`'s reference resolver queried the context
directly and its own comment said chapter 10 would fix it. This is that fix.

**The two in the first row is chapter 3's two, still holding.** Chapter 3
measured this request at five statements naive and two batched inside one
service. Chapter 9 measured it at two across a seam. Chapter 10's job is to say
why the two is not automatic, and the four in the second row is the answer.

### The statements themselves

Batched, at `ch10`:

```sql
SELECT "s"."Id", "s"."Bio", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" IN (@ids1, @ids2, @ids3)
```

Naive, at `ch10-naive`, three times:

```sql
SELECT "s"."Id", "s"."Bio", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" = @key
LIMIT 1
```

Same column list on both, which is the half a DataLoader does not fix. The
Sessions entity route selects all six of its columns either way:

```sql
SELECT "s"."Id", "s"."Abstract", "s"."DurationMinutes", "s"."SpeakerId",
       "s"."StartsAt", "s"."Title"
```

against the node route beside it, asked for the same one field:

```sql
SELECT "s"."Title"
FROM "Sessions" AS "s"
WHERE "s"."Id" = @id
LIMIT 1
```

## The router de-duplicates representations

The finding that reshapes the chapter. Measured by putting a request-logging
middleware in front of the Speakers service, running the graph on a freshly
seeded database, and reading what arrived. The middleware is a scratch patch,
not committed to any branch; it read the buffered request body and appended it
to a file.

Four sessions, three distinct speakers. What the router sent:

```json
{"query":"query($representations: [_Any!]!){_entities(representations: $representations){... on Speaker {__typename name}}}",
 "variables":{"representations":[
   {"__typename":"Speaker","id":"U3BlYWtlcjox"},
   {"__typename":"Speaker","id":"U3BlYWtlcjoy"},
   {"__typename":"Speaker","id":"U3BlYWtlcjoz"}]}}
```

Three, in first-appearance order, for a list of four. `sessions(first: 2)`,
whose two sessions are both Ada Fischer's:

```json
{"variables":{"representations":[{"__typename":"Speaker","id":"U3BlYWtlcjox"}]}}
```

One. And asking for `name bio` rather than `name` changes the selection set and
not the representation list:

```json
{"query":"...{... on Speaker {__typename name bio}}}",
 "variables":{"representations":[
   {"__typename":"Speaker","id":"U3BlYWtlcjox"},
   {"__typename":"Speaker","id":"U3BlYWtlcjoy"},
   {"__typename":"Speaker","id":"U3BlYWtlcjoz"}]}}
```

### What proves it is the router rather than the loader

Important, because the obvious test does not prove it. On `main` a page of
sessions sharing one speaker produces one key in the `WHERE`, and a DataLoader
handed two equal keys would collapse them too, so that observation is
consistent with either explanation.

The proof is the same request at `ch10-naive`, where there is no loader behind
that resolver at all:

- four sessions, three distinct speakers: **3** statements, not 4
- two sessions, one speaker: **1** statement, not 2

With nothing in the subgraph keeping track, the only thing that could have
collapsed the duplicates is the caller. Both counts are asserted at that tag.

The mirror image is asserted there too: send the service the same
representation three times **by hand**, with no router in the path, and it
issues three statements. The de-duplication is a property of the router's
entity fetch, not of `_entities`, and anything else calling that route gets
none of it.

### Corroboration in the router's source

Not the evidence - the measurement is - but it says what the mechanism is.
`graphql-go-tools` v2.16.0 (commit `7ba7777e30f4c45ab38a03ca4574e471edf059cd`,
the version `router@0.341.0`'s `go.mod` pins), in
`v2/pkg/engine/resolve/loader.go`, function `prepareBatchEntityFetch`:

```go
res.tools.keyGen.Reset()
_, _ = res.tools.keyGen.Write(itemInput.Bytes())
itemHash := res.tools.keyGen.Sum64()
if existingIndex, ok := res.tools.batchHashToIndex[itemHash]; ok {
    batchStats[existingIndex] = arena.SliceAppend(res.tools.a, batchStats[existingIndex], items[i])
    continue WithNextItem
}
```

An xxhash64 of the **rendered** representation, and a map from hash to the
position in the batch, with the original item appended to that position's list
so the one answer can be fanned back out. The same pattern appears in
`loader_multi_entity.go`'s `renderEntryRepresentations` for the case where
several entity fetches merge into one upstream request.

Because the hash is over the rendered representation and not over the key
alone, two representations that carry different `@requires` fields would not
collapse even with the same key. **Not measured**, and no chapter says it.

### Whether the representation list has a ceiling

**Not established.** No cap, chunk size or configurable maximum was found in
`loader.go`, `loader_multi_entity.go`, a repo-wide search for a
`MaxRepresentations`-shaped constant, or Cosmo's hardening and cost-control
documentation. Absence of documentation is not a measurement, and this seed
cannot produce a long enough list to find one, so **no chapter claims the list
is unbounded**. What the chapter says instead is the thing that is measured and
is the practically important half: the length is the size of the page the
*owning* service returned, which is a limit the subgraph answering the fetch
does not set and cannot see.

A trap worth recording: Cosmo does ship a feature called query batching, with a
`max_entries_per_batch` defaulting to 100, and it is the first thing a search
for a batch limit surfaces. It batches multiple client operations into one HTTP
request and has nothing to do with entity representations. Do not cite it here.

## Why the resolver runs once per representation

Apollo's subgraph specification defines the field and says two normative things
about the answer and nothing at all about how to produce it.

Signature, verbatim: `_entities(representations: [_Any!]!): [_Entity]!`

> The `Query._entities` field must return a list of entity objects that
> correspond to the provided representations, in the exact same order.

> Entries in the list can be null if no entity exists for a provided
> representation.

Read the whole page and the raw `.mdx`; there is no sentence about sequential
against batched against concurrent resolution. The subgraph is handed a list
and told what the answer must look like, and how it gets there is entirely the
implementer's problem. That silence is the chapter's beat 3.

**A caveat on citing this at a version.** The `@link` url this book prints,
`https://specs.apollo.dev/federation/v2.6`, does not resolve to a frozen v2.6
document: it redirects (302, then two 301s) to Apollo's current, unversioned
subgraph-spec page, which carries no version or date stamp. So a citation to
"the v2.6 spec" is really a citation to Apollo's living documentation as of the
access date. Whether the order-preservation and null wording has changed since
v2.6 was **not** established; no archived copy was diffed. The chapter cites
the page it actually read.

Source of record: the docs page is generated from
`docs/source/schema-design/federated-schemas/reference/subgraph-spec.mdx` in
`apollographql/federation`, last touched by commit `05754da0` (2025-10-14).

## The projection that works and cannot be shipped

Decision 69 says: `QueryContext<T>` cannot be injected into a reference
resolver, so the entity route has no projection, measured 2026-08-23 as
`Unexpected Execution Error` with no exception in any log. Every part of that
except the conclusion turns out to be about a different thing.

### It injects, and it projects

Injected `QueryContext<Speaker>` into `SpeakerType.ResolveSpeakerReferenceAsync`
alongside `SpeakerContext db`, and called `.With(query)`. It is not null, and
the selector it carries is correct:

```
root => new Speaker(default(Int32), root.Name, default(String))
```

```sql
SELECT "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" = @p
LIMIT 1
```

One column where the shipped resolver takes three. The same test on
`SessionType.ResolveSessionReferenceAsync`, which is the exact resolver
decision 69 was measured against, on a tree whose `Program.cs` calls
`AddQueryContext()` exactly as it did at tag `ch06`:

```
root => new Session(default(Int32), root.Title, default(String),
                    default(Int32), default(DateTimeOffset), default(Int32))
```

```sql
SELECT "s"."Title" FROM "Sessions" AS "s" WHERE "s"."Id" = @key LIMIT 1
```

and asking for two fields widens it to `SELECT "s"."Title", "s"."Abstract"`.
Three representations, three statements, each projected, no error anywhere.

**So decision 69's conclusion does not hold at 16.6.1 today.** What produced
the original `Unexpected Execution Error` was not re-derived, and it is not
worth re-deriving: what the book has to state is what is true now, and the
correction goes in the decision row rather than being smoothed over.

### The selection the resolver is handed is `_entities`

Worth recording because it is the thing that makes the projection surprising.
Inside a reference resolver:

```
selection.ResponseName = _entities
selection.Field.Name   = _entities
declaringType          = Query
selection.Type         = [_Entity]!
named type             = _Entity, kind = Union
```

The resolver's own `ISelection` is the **root** field, typed as the entity
union. Hot Chocolate nevertheless builds the `QueryContext`'s selector from the
right inline fragment. So anything reading `ISelection` by hand gets the union;
anything taking the injected `QueryContext` gets what it wanted.

That is why `IDataLoader.Select(ISelection)`, from
`GreenDonut.Data.HotChocolateExecutionDataLoaderExtensions` in
`HotChocolate.Execution.Projections`, is useless here. It compiles, and throws:

```
System.ArgumentException: Type 'Speakers.Speaker' does not have a default
constructor (Parameter 'type')
   at System.Linq.Expressions.Expression.New(Type type)
   at GreenDonut.Data.Internal.ExpressionHelpers.Rewrite[TRoot,TKey](Expression`1 selector)
   at System.Linq.GreenDonutQueryableExtensions.Select[T](IQueryable`1 query,
        Expression`1 keySelector, ISelectorBuilder builder)
```

which is **decision 55's wall in a second API**. That decision recorded
`[UseProjection]` as unusable in this book because it builds its projected row
with `Expression.New` and this book's domain is positional records. GreenDonut's
selector rewriting does the same thing and fails the same way.

### Batching and projection together, and why the book ships neither combination

The combination does work mechanically. Loader taking `QueryContext<Speaker>`
and calling `.With(query)`, call site `speakerById.With(query).LoadAsync(...)`:

```sql
SELECT "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" IN (@ids1, @ids2, @ids3)
```

One statement and one column. And then the service answers
`Unexpected Execution Error` three times, because the rows it got back are:

```
Id=0 Name=Ada Fischer, Id=0 Name=Bruno Kaminski, Id=0 Name=Chidi Okafor
```

The selector defaults every property nobody asked for, `Id` included, and the
loader's dictionary is keyed on `Id`. `ToDictionary` throws
`An item with the same key has already been added. Key: 0`.

**And it works when the client asks for the key.** Same code, same request,
adding `id` to the selection set:

```
selector: root => new Speaker(root.Id, root.Name, default(String))
SELECT "s"."Id", "s"."Name" FROM "Speakers" AS "s" WHERE "s"."Id" IN (...)
rows: Id=1 Ada Fischer, Id=2 Bruno Kaminski, Id=3 Chidi Okafor
{"data":{"_entities":[{"id":"U3BlYWtlcjox","name":"Ada Fischer"}, ...]}}
```

A subgraph that is correct only when the caller happens to select the key is
not a subgraph. That is the whole reason the book takes the columns.

### Three ways to keep the key, all of which fail

GreenDonut has an API whose entire purpose is this - a `Select` overload taking
a key selector alongside the projection - and it is unusable on positional
records.

1. **`Select(s => (object)s.Id, ISelectorBuilder)`.** Throws
   `Type 'Speakers.Speaker' does not have a default constructor` from
   `Expression.New`, as above.
2. **`Select(s => (object)s.Id, query.Selector)`**, the sibling overload taking
   an expression rather than a builder. Same exception, same frame: both
   converge on `ExpressionHelpers.Rewrite`.
3. **Merging by hand with `DefaultSelectorBuilder`**: add `query.Selector`, then
   add `s => new Speaker(s.Id, default!, default)`, then `TryCompile<Speaker>()`.
   No exception, and the merge **silently drops the second expression**:

   ```
   merged: root => new Speaker(default(Int32), root.Name, default(String)) {}
   ```

   so the run fails exactly as before, on the duplicate zero key. Why the added
   expression is discarded was **not** established.

**Conclusion, and it is what the chapter says.** The entity route can be
batched, unconditionally, and the book does that. It can be projected, but only
by giving up the batch. It cannot be both without a correctness condition on
the caller. The open item "whether the entity route can be given a projection"
is answered; a narrower one replaces it, about whether a key-preserving
projection can be built at all for a type with no parameterless constructor.

## What survives batching, measured rather than assumed

All four asserted at `ch10` on the Sessions port. They matter because the
chapter is telling a reader to change a resolver, and a fix that quietly breaks
one of these would be worse than the N+1.

- **Order.** Representations `3, 1, 2` come back as *Paging Without Offsets*,
  *Schemas That Outlive Their Authors*, *Reading a Query Plan*. The loader
  returns a dictionary and the engine puts each answer at its representation's
  position. This is the specification's requirement and chapter 11's whole
  subject, so it is asserted rather than assumed.
- **Null for a missing row.** A key matching no row is a null in its own
  position, in the middle of a batch, with no error and at HTTP 200. The
  dictionary a loader returns need not contain every key it was given, and the
  key it leaves out is the entry the specification wants nulled. One statement
  for the whole list.
- **De-duplication, for any caller.** The same id three times costs one
  statement carrying one key, and answers three times.
- **The guard runs first.** A `Speaker` node id under a `Session` type name, in
  the middle of a batch of three, produces a null in that position and a
  `WHERE "s"."Id" IN (@ids1, @ids2)` - two keys for three representations. The
  guard chapter 6 wrote runs per representation and before the batch is
  assembled, so a rejected key never reaches the database at all.

## The third shape: an entity route that cannot have this problem

The Ratings service's reference resolver is not async, takes no `DbContext` and
no loader, and issues no statement:

```csharp
public static Session? ResolveSessionReference(
    string id, string? title, INodeIdSerializer serializer)
```

It builds a `Session` out of the representation it was handed. Chapter 9
measured `feedbackUrl` at zero statements in Ratings for that reason. So the
three services in this graph carry the three possible answers to the chapter's
question - one route that batches, one that did not and now does, and one with
nothing to batch - and the third is worth naming so a reader does not add a
loader to a resolver that touches no table.

Note that `averageScore` and `ratingCount` are ordinary field resolvers on that
entity rather than the reference resolver, and both call `LoadAsync` on the same
key. Four sessions, two fields, eight loads, one statement. That is the
request-scoped cache rather than the batch.

## Sourcing, and one negative result that carries a recommendation

**Who publishes the recommendation.** Apollo does, twice, in unsigned product
documentation:

> A particular reference resolver might be called many times to resolve a
> single query. It's crucial that reference resolvers account for "N+1" issues
> (typically via data loaders).

> The solution for the N+1 problem - whether for federated or monolithic graphs
> - is the DataLoader pattern.

with a JavaScript sample putting the loader inside `__resolveReference`, and a
generalisation that Apollo recommends using one "in every resolver, even those
that aren't for entities or don't return a list".

**Who does not.** WunderGraph publishes no subgraph-author-facing guidance of
this kind, and structurally would not: its architecture puts de-duplication and
batching in the router, which is what the source read above confirms. And
ChilliCream, the vendor of the library this book actually uses, currently
publishes **nothing at all** about `HotChocolate.ApolloFederation`'s reference
resolver, let alone about pairing one with a DataLoader.

So: the recommendation for this stack is my judgment under decision 38, with
Apollo's general guidance cited as corroboration rather than as instruction for
Hot Chocolate and Cosmo.

**The one named-engineer source on this subject.** Jens Neuse, CEO and
co-founder of WunderGraph, writing under his own byline on the company blog,
on the N+1 at entity resolution:

> Federation makes batching simpler because the well known `_entities` field to
> fetch "Entities" supports a list of representations as input [...] fetching
> entities by their keys allows you to batch requests by default.

and, of the router's own algorithm:

> If there are duplicate representations, we will deduplicate them before
> building the variables object

which is the same behaviour measured above, described by the vendor that wrote
it. The post also argues **against** the DataLoader pattern, on the ground that
sibling fields all joining one batch and blocking on it multiplies concurrency
cost per nesting level, and offers a breadth-first alternative. Those
performance claims are the author's own benchmarks and are **not** independently
reproduced here; the book uses the post for the two statements above and not for
the numbers.

Checked and rejected as sources: Christopher Gustafson (Volvo Car Mobility, on
Medium) and Sam Fung (ITNEXT), both named authors writing usefully on this exact
subject, neither an engineer at a vendor of anything in this stack. No post by a
named Apollo, ChilliCream, Netflix, GitHub or Expedia engineer on
`_entities`-route batching was found.

**A correction to how this book would have described DataLoader's origin.** The
`graphql/dataloader` README (v2.2.3) credits the pattern to Nicholas Schrock at
Facebook in 2010, not to Lee Byron, who is the repository's primary maintainer
and first-listed contributor. Anything this book says about where the idea came
from has to follow the README rather than the maintainer list. What the README
does say about the mechanism:

> DataLoader will coalesce all individual loads which occur within a single
> frame of execution (a single tick of the event loop) and then call your batch
> function with all requested keys.

> Subsequent calls to `.load()` with the same key will result in that key not
> appearing in the keys provided to your batch function.

Hot Chocolate's own documentation states the dispatch trigger differently, and
the difference matters for a .NET reader: "The dispatch trigger is 'no more
ready work', not a fixed schedule and not one dispatch per level of the query."

## Things checked and found false, or not established

- **False:** that `QueryContext<T>` cannot be injected into a reference
  resolver (decision 69). It can, in both services, and it projects. The row is
  corrected in the SPEC rather than left standing.
- **False:** that the router sends one representation per row of the parent
  list. It de-duplicates first.
- **False:** that a page whose sessions share a speaker proves the router
  de-duplicated. On `main` a loader would produce the same observation; only the
  loader-free tag separates the two.
- **Not established:** whether the representation list has any cap, chunk size
  or configurable maximum. Nothing in the router's source or documentation, and
  this seed is too small to find one by measurement. No chapter claims it is
  unbounded.
- **Not established:** why `DefaultSelectorBuilder` silently discards an
  expression added after the one Hot Chocolate built.
- **Not established:** whether a key-preserving projection can be built at all
  for a type with no parameterless constructor. Three shapes were tried; two
  throw on `Expression.New` and one is a silent no-op.
- **Not established:** what produced decision 69's original
  `Unexpected Execution Error`. Not re-derived, because the book states what is
  true now.
- **Not established:** whether two representations carrying different
  `@requires` fields but the same key collapse. The hash is over the rendered
  representation, which suggests not; not measured, and no chapter says.
- **Not established:** whether the wording the current Apollo docs page carries
  about order and nulls is the wording Federation v2.6 carried. The `@link` url
  does not resolve to a frozen document and no archived copy was diffed.
- **Not re-examined:** whether Hot Chocolate resolves sibling entity
  representations concurrently. The naive branch ran three lookups against a
  context per request without incident, which shows nothing about a longer list.
  The open item from chapter 3 stands, and no chapter claims anything about
  resolver concurrency.

## What the audit found, and what was done about it

A read-only agent with no drafting context read the chapter cold against this
note, the companion repo, the SPEC and chapter 9. Nineteen findings, of which
sixteen were fixed and three rejected. Recorded here because a rejection nobody
writes down is how a draft launders itself past its own reviewer.

### The ones that were outright wrong in the draft

- **A verification-repo tag name reached the prose.** Section 4 wrote
  `ch06-unguarded` on the page. Decisions 9 and 10 say the repo is never
  mentioned, and this was the only tag name in ten drafted chapters. Cut.
- **`highlightlines` marked three unchanged lines and missed all three changed
  ones.** The reprinted `SessionType.cs` member highlighted the serializer
  parameter, `return null` and a closing brace, and left the new loader
  parameter and the new body unmarked. Decision 16 wants the changed lines.
  Corrected to `{2-8,14,29,30}`.
- **An index range was opened and never closed.** `N+1!at the entity route|(`
  in section 1, with no `|)` anywhere. Closed at the end of section 5.
- **`generalises` in an `en-US` book.** Decision 29. The gate cannot see it:
  the en-US table carries `initialis/organis/analys/authoris` and neither it
  nor the variants table has a general `-ise` row.
- **Chapter 9 was credited with a decision chapter 6 made.** The draft said
  chapter 9 put the DataLoader behind that reference resolver "without stopping
  to argue for it". Chapter 6 put it there and argued for it on the page, and
  measured it at `3 Speaker representations -> 1 statement`
  (`06/04-what-the-entity-route-costs.tex`). Chapter 9 only moved the file.
- **The naive resolver was called the same shape as the node resolver above
  it.** It is not: that one goes through the loader, which is exactly what
  makes it fine. Replaced.
- **Take one line out of one file** understated the change, which is a
  parameter and the body under it.
- **The chapter opener misattributed its own failure.** It said the failure
  section 1 opens on is one the book has been shipping since chapter 6. Section
  1 opens on the Speakers resolver with its loader removed, a state the book
  never shipped; the shipped debt is the Sessions entity route, which is
  section 4's. Rewritten.
- **Jens Neuse was called the company's founder.** He is CEO and co-founder,
  which is what this note and the bib entry both say.
- **An Apollo quotation silently dropped its internal quotation marks** around
  `"N+1"` and elided `It's`. Restored with a nested `\enquote`.
- **The summary box carried a universal the prose had already been narrowed
  away from**, that Hot Chocolate does what any engine does.

### The finding that changed the most prose

**Five verbatim captures came from states that exist on no branch and no tag**,
and two request bodies came from a scratch middleware nothing asserts. Decision
48 says the book quotes what `verify.ps1` asserts; decisions 53 and 65 say a
failure no tagged state produces is described rather than quoted; and chapter 6
declined to print this exact class of output for that reason.

The draft had section 5 printing the projected `SELECT`s, both selector
expressions, the duplicate-key message and the `Expression.New` stack frames,
and section 2 printing the two `_entities` bodies. All of it came from
scratch-patched services built to answer decisions 96 and 97 and thrown away.

Fixed by describing rather than quoting, which is the route decision 53 already
established, in both sections. Everything is still stated as fact and the
verbatim text is all above in this note. The alternative was three more
branches and tags under decision 51, one per scratch state, which is
disproportionate for evidence that supports two decision rows rather than a
listing the reader types.

### Rejected, with the evidence

- **That the naive listing should carry the enclosing member's doc comment**
  (decision 16, "complete enclosing member"). Two reasons it stays as printed.
  Chapter 9 sets the precedent both ways and prints `GetFeedbackUrl` and
  `GetTitle` as attribute-plus-signature-plus-body with no doc comment. And the
  member at `ch10-naive` carries a comment saying `main goes through a
  DataLoader here instead`, which names a branch of the verification repo;
  printing the member complete would put repo-internal language on the page and
  break decisions 9 and 10, which is the finding above. The omission is
  deliberate and this is where it is written down.
- **That the missing-row test prints a response with no request** (decision 34).
  Half accepted: the prose now names the three keys it sent rather than adding
  a fourth near-identical JSON block, which is what decision 27's economy line
  wants. The request shape is the one printed two subsections earlier.
- **That `I asserted all four rather than assuming them` narrates the author's
  process** (decision 22). Reworded rather than cut, because the sentence is
  load-bearing: it tells a reader that these four properties are checked by the
  gate rather than reasoned about, which is the difference between this book's
  claims and a blog post's. It now says the properties are not safe to assume
  and says why, without narrating who asserted what.

### Voice findings, all accepted

Four `\textbf{}` run-in headers in section 4, a construct used nowhere else in
the ten drafted chapters, against chapter 9 writing the same enumeration as
plain prose: rewritten as prose (humanizer 15 and 16). A structural announcement
in the chapter opener, against tone-chapter's lecture-opener rule and the SPEC
economy line: cut. A superlative self-assessment plus signpost opening section
2: cut. And the same declining-to-say move four times in twelve pages, where
chapter 9 uses it twice in thirty: two of the four rewritten.

## Sources

| What | URL | Accessed |
|------|-----|----------|
| Apollo Federation subgraph specification | `https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec` | 2026-08-24 |
| Apollo, entities introduction | `https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/entities/intro` | 2026-08-24 |
| Apollo, handling the N+1 problem | `https://www.apollographql.com/docs/graphos/schema-design/guides/handling-n-plus-one` | 2026-08-24 |
| Jens Neuse, breadth-first data loading | `https://wundergraph.com/blog/dataloader_3_0_breadth_first_data_loading` | 2026-08-24 |
| `graphql-go-tools` v2.16.0, `loader.go` | `https://github.com/wundergraph/graphql-go-tools/blob/7ba7777e30f4c45ab38a03ca4574e471edf059cd/v2/pkg/engine/resolve/loader.go` | 2026-08-24 |
| `graphql-go-tools` v2.16.0, `loader_multi_entity.go` | `https://github.com/wundergraph/graphql-go-tools/blob/7ba7777e30f4c45ab38a03ca4574e471edf059cd/v2/pkg/engine/resolve/loader_multi_entity.go` | 2026-08-24 |
| `graphql/dataloader` README, v2.2.3 | `https://github.com/graphql/dataloader` | 2026-08-24 |
| Hot Chocolate DataLoader documentation, source form | `https://github.com/ChilliCream/graphql-platform/blob/main/website/content/docs/hotchocolate/fetching-data/batching/dataloader.md` | 2026-08-24 |
| `HotChocolate.ApolloFederation` on NuGet, 16.6.1 | `https://www.nuget.org/packages/HotChocolate.ApolloFederation` | 2026-08-24 |

Two notes on the last two rows. ChilliCream's versioned documentation URLs are
**gone**: everything under `chillicream.com/docs/hotchocolate/v16/` returns 404
since the site dropped version-prefixed paths, so the citation is to the
markdown source in the repository and any older `v16`-prefixed url in this
book's earlier notes is now dead. And that documentation tree contains no page
about `HotChocolate.ApolloFederation` at all; the only "reference resolver" hit
in it is about Fusion consuming *other* people's federation subgraphs, which is
a different product doing the opposite job. Everything in this note about the
C# surface comes from the shipped assemblies, the compiler and the running
services.
