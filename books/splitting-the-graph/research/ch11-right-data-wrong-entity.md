# Chapter 11 - Right Data, Wrong Entity

Research note for the second chapter of part III: the positional contract on
`_entities`, and what a graph looks like when a subgraph breaks it.

Web sources accessed **2026-08-24**; everything else was measured on this
machine on the same date.

Five things are worth stating before any of it.

**The contract is stated three times and enforced nowhere.** Apollo's subgraph
specification says the answer must come back in representation order, and says
it twice - once as the contract and once as an instruction inside its own
resolver algorithm. GreenDonut says the same thing one layer down, in the doc
comment on the method a reader overrides. Nothing in the router, nothing in
Hot Chocolate and nothing in the specification checks that the entity at
position *i* is the entity representation *i* named. The router checks the
length of the list and nothing else.

**Hot Chocolate protects you twice, and that is why the broken listing is
hand-written.** The `[DataLoader]` source generator only classifies a method as
a batch loader if it returns a dictionary, and the `CopyResults` it emits walks
the keys and looks each one up, so a dictionary's own ordering cannot reach the
answer. Underneath that, `_entities` fires one indexed task per representation.
Both layers have to be left behind before order can go wrong, and the way out
is `DataLoaderBase`, which is a documented and ordinary thing to reach for when
the store is not a `DbContext`.

**This book's own graph is the lucky case, and the chapter opens on that.**
`sessions` is ordered by start time and the schedule happens to name speakers
1, 2 and 3 in that order, which is the order SQLite returns the rows in. With
the broken loader deployed, every page this book has printed since chapter 3
still answers correctly, at the same statement counts, with a byte-identical
schema and an unchanged query plan. The request that surfaces the defect is
`nodes(ids:)`, because there the client chooses the order of the parent list.

**Half of GreenDonut's contract fails loudly and half fails silently.** The doc
comment asks for two things: a result for every key, and the results in key
order. Breaking the first leaves a slot in the span unwritten and produces
`Unexpected Execution Error` at the position that was never filled. Breaking
the second produces a correct-looking answer forever.

**One negative result.** No bylined engineer at ChilliCream, Apollo or
WunderGraph publishes a warning to subgraph authors about this. What exists is
the specification (usable unsigned under decision 39, as its own publisher),
GreenDonut's doc comment (an artifact, not a claim about one), the router's
source, and one bylined WunderGraph post that describes position-based merging
without discussing a subgraph that misbehaves. Under decision 38 the advice in
this chapter is therefore my judgment, citing the contracts rather than an
authority who has interpreted them.

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
| `ch11` | `main` | unchanged source; the chapter's own assertions | 353 |
| `ch11-misordered` | `ch11-misordered` | the hand-written loader filling the span by row (decision 51) | 39 |
| `ch11-handwritten` | `ch11-handwritten` | the same loader walking the keys; `main`'s script unchanged | 353 |
| `ch11-hc14` | `hc14` | an unchanged tree; both halves sit behind `SpeakerExtracted` | 214 |

**Ports**, unchanged: Sessions 5001, Speakers 5002, Ratings 5003, router 3002.

**Seed**, unchanged: four sessions, three distinct speakers, six ratings across
three of the four sessions. Sessions 1 and 2 are Ada Fischer's (speaker 1),
session 3 is Bruno Kaminski's (2), session 4 is Chidi Okafor's (3). That
mapping is the whole reason the chapter needs `nodes(ids:)` and is recorded
here because a later chapter changing the seed would silently un-break this
chapter's demonstration.

Node ids used throughout, from decision 56's format (type name, colon, key,
base64):

| Value | Node id |
|-------|---------|
| `Session:1` | `U2Vzc2lvbjox` |
| `Session:3` | `U2Vzc2lvbjoz` |
| `Session:4` | `U2Vzc2lvbjo0` |
| `Speaker:1` | `U3BlYWtlcjox` |
| `Speaker:2` | `U3BlYWtlcjoy` |
| `Speaker:3` | `U3BlYWtlcjoz` |
| `Speaker:99` | `U3BlYWtlcjo5OQ==` |

## Sources

### The specification says it twice

`https://github.com/apollographql/federation/blob/main/docs/source/schema-design/federated-schemas/reference/subgraph-spec.mdx`,
which is the source of
`https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec`.
Fetched from `raw.githubusercontent.com` on `main`, 2026-08-24. Unsigned, and
usable under decision 39: this is a specification's publisher defining that
specification, not a vendor arguing a result.

From "Understanding `Query._entities`", verbatim, and the sentence pair
chapter 10 already cites:

> The `Query._entities` field must return a list of entity objects that
> correspond to the provided representations, in the exact same order. Entries
> in the list can be null if no entity exists for a provided representation.

From "Resolving `Query._entities`", step 2.3 of the algorithm the page gives a
subgraph library, and **new to this chapter**:

> Add the fetched entity object to the array of entity objects. Make sure
> objects are listed in the same order as their corresponding representations.

So the requirement is stated once as a contract on the answer and once as an
instruction to the implementer. Chapter 10 quoted only the first.

**Searched for and not found:** any sentence requiring a subgraph or a router
to check that a returned entity matches the representation it was resolved
from. The page's validation rules are all about the *incoming* representation:
that it carries `__typename`, and that it carries every field in the `@key`
field set. Nothing about the answer beyond order and nullability.

The file's commit history (`api.github.com/repos/apollographql/federation/commits?path=...`)
shows the last change to it on 2025-10-14 and unrelated to this section.

### GreenDonut states the same contract, one layer down

Read out of the shipped assembly rather than off a documentation page:
`~/.nuget/packages/greendonut/16.6.1/lib/net10.0/GreenDonut.xml`, the member
`M:GreenDonut.DataLoaderBase\`2.FetchAsync(...)`. Verbatim:

> A batch loading function which has to be implemented for each individual
> `DataLoader`. For every provided key must be a result returned. Also to be
> mentioned is, the results must be returned in the exact same order the keys
> were provided.

and, on the `results` parameter:

> The resolved values which need to be in the exact same order as the keys were
> provided.

and on the return:

> A list of results which are in the exact same order as the provided keys.

Three statements of it in one doc comment, which is what a reader sees in
IntelliSense the moment they type `override`. This is an artifact rather than a
claim about an artifact, so the byline rule does not arise.

**Not found:** any page on `chillicream.com` documenting `DataLoaderBase` or
`FetchAsync` as an extension point. The docs site covers `BatchDataLoader<TKey,
TValue>` and its `LoadBatchAsync` override under "Manual DataLoader Classes"
and never names the base class's `FetchAsync`. Reported as *not found* rather
than *absent*: an exhaustive search of the site was not possible.

**Also recorded, because it cost time:** ChilliCream has dropped versioned
documentation URLs. `chillicream.com/docs/hotchocolate/v16/...` now redirects to
the unversioned path, and the Hot Chocolate Apollo Federation API reference page
redirects to a 404. Nothing in this chapter rests on a ChilliCream docs page,
which is partly why.

### The router merges by position and checks only the length

`github.com/wundergraph/graphql-go-tools` at tag `v2.16.0`, which is what
`router@0.341.0` pins - confirmed from that release's own `router/go.mod`:

```
github.com/wundergraph/graphql-go-tools/v2 v2.16.0
```

The merge lives in `Loader.mergeResult`, in `v2/pkg/engine/resolve/loader.go`.
**Note the path**: chapter 10 read `loader.go` and `loader_multi_entity.go`
under `v2/pkg/engine/datasource/graphql_datasource/`, and at this version they
are under `v2/pkg/engine/resolve/`. The plain positional merge:

```go
for i := range items {
    items[i], _, err = astjson.MergeValuesWithPath(
        l.jsonArena, items[i], batch[i], res.postProcessing.MergePath...)
```

and the de-duplicated path, which is chapter 10's `batchStats` in use:

```go
for batchIndex, targets := range res.batchStats {
    src := batch[batchIndex]
    for _, target := range targets {
        _, _, mErr := astjson.MergeValuesWithPath(
            l.jsonArena, target, src, res.postProcessing.MergePath...)
```

The one check, in both paths:

```go
if batchCount, itemCount := len(batch), len(items); batchCount != itemCount {
    return l.renderErrorsFailedToFetch(fetchItem, res,
        fmt.Sprintf(invalidBatchItemCount, itemCount, batchCount))
}
```

```go
invalidBatchItemCount = "returned entities count does not match the count of " +
    "representation variables in the entities request. Expected %d, got %d"
```

So a **short or long** answer is refused with a named error, and a **same-length
reordered** answer is merged without comment. `astjson.MergeValuesWithPath`
(module `github.com/wundergraph/astjson`) is a generic deep merge with no
identity logic. The one `__typename` check in the file,
`isItemAllowedByTypename` under `selectItemsForPath`, reads the *parent*
object's type name to decide whether a fetch applies to it, before the request
is sent; it is never applied to a returned entity.

**Consequence for the chapter:** the de-duplication chapter 10 found makes this
worse rather than better. One wrong answer at a batch position is fanned out to
every parent that hashed to it.

**Not reproduced:** the length check firing. Hot Chocolate always answers with
exactly one entry per representation - see the unwritten-slot result below,
which is still a list of three - so no state of this repository produces a
short or long array. Under decisions 53 and 65 the chapter therefore states the
behaviour and does not quote a message.

### Who publishes advice about this, and who does not

- **Apollo's "Entities" guidance page**, covering `__resolveReference`:
  unsigned, and silent on ordering and on mismatch. Not usable and would carry
  nothing if it were.
- **Jens Neuse, "Dataloader 3.0: A new algorithm to solve the N+1 Problem"**,
  `wundergraph.com/blog/dataloader_3_0_breadth_first_data_loading`, published
  2023-09-29. Byline confirmed from the page's own JSON-LD author block: Jens
  Neuse, CEO and co-founder. This is the post chapter 10 already cites for
  de-duplication, and it passes the vendor rule. It says of the merge:

  > The merge algorithm is pretty simple. Based on the position of the product
  > in the list, we merge the stock info from the `_entities` response into the
  > product object.

  and, about the router's own bookkeeping for nested lists:

  > It's possible that we have lists of unequal length within a list of items,
  > so we would screw up the order if we didn't keep track of the child indexes.

  **Do not overstate this.** It describes WunderGraph's merge design in 2023 and
  the router's own index-keeping. It is not a warning to subgraph authors about
  violating the order contract, and the chapter must not present it as one. What
  it corroborates is that the merge is positional, which the source already
  shows.
- **Not found:** any bylined ChilliCream or Apollo engineer writing about
  `_entities` ordering. Recorded so a later chapter does not go looking again.
- **Context only, not cited:** `github.com/dgraph-io/dgraph/issues/8120`, filed
  by user `JLaferri` in 2022: "the data returned in `_entities` is not in the
  same order as the objects in my `representations` input. This causes the data
  to mismatch with the ID when using Dgraph as a subgraph." Evidence that the
  failure happens in the wild, about a subgraph this book does not cover. Not
  used in prose.

## Measurements

### You cannot reach this through the source generator

**Checked and found false:** that a `[DataLoader]` method can return a list and
be treated as a batch loader.

Changed `SpeakerDataLoader.GetSpeakerByIdAsync` to return
`Task<IReadOnlyList<Speaker>>` with `ToListAsync`. The generator does **not**
reject it. It reinterprets the method as a single-key cache loader whose key is
the whole `IReadOnlyList<int>` and whose value is the whole list, and emits:

```csharp
public interface ISpeakerByIdDataLoader
    : global::GreenDonut.IDataLoader<
        global::System.Collections.Generic.IReadOnlyList<int>,
        global::System.Collections.Generic.IReadOnlyList<global::Speakers.Speaker>>
```

with a `FetchAsync` that loops over keys calling the method once per key. The
call site then fails to compile, twice:

```
SpeakerType.cs(21,12): error CS0266: Cannot implicitly convert type 'object'
    to 'Speakers.Speaker'.
SpeakerType.cs(44,16): error CS0266: Cannot implicitly convert type 'object'
    to 'Speakers.Speaker'.
```

So the mistake is caught, but by the type checker at the call site rather than
by a diagnostic naming the real problem. Emit the generated sources to see it:

```
dotnet build -p:EmitCompilerGeneratedFiles=true \
    -p:CompilerGeneratedFilesOutputPath=<dir>
```

### What the generator writes, and why it is safe

From `src/gen/.../GreenDonutDataLoader.735550c.g.cs` in the repository, the
Sessions service's generated loader:

```csharp
private void CopyResults(
    IReadOnlyList<int> keys,
    Span<Result<Speaker?>> results,
    Dictionary<int, Speaker> resultMap)
{
    for (var i = 0; i < keys.Count; i++)
    {
        var key = keys[i];
        if (resultMap.TryGetValue(key, out var value))
        {
            results[i] = Result<Speaker?>.Resolve(value);
        }
        else
        {
            results[i] = Result<Speaker?>.Resolve(default(Speaker));
        }
    }
}
```

(namespaces stripped for reading; the generated file writes every one out in
full). It walks the **keys** and looks each one up. A dictionary has no order
and none is needed. The `else` branch is what turns a key with no row into the
null the specification asks for, which chapter 10 already relied on.

### The broken loader, and the four shapes

`ch11-misordered`. The full file is printed in the chapter; the loop that
matters is:

```csharp
var rows = await db.Speakers
    .Where(s => ids.Contains(s.Id))
    .ToListAsync(ct);

for (var i = 0; i < rows.Count; i++)
{
    results.Span[i] = Result<Speaker?>.Resolve(rows[i]);
}
```

Measured directly against the Speakers service on 5002, no router involved,
asking for `id` alongside `name` so that the answer carries its own evidence:

```
query E($r: [_Any!]!) {
  _entities(representations: $r) { ... on Speaker { id name } }
}
```

| Representations | Answer | Statements |
|-----------------|--------|-----------|
| `Speaker:1, Speaker:2, Speaker:3` | Ada, Bruno, Chidi - correct | 1 |
| `Speaker:3, Speaker:1, Speaker:2` | Ada, Bruno, Chidi - **wrong in all three positions**, and each entry carries an `id` its representation did not name | 1 |
| `Speaker:3, Speaker:1` | Ada, Chidi - **swapped** | 1 |
| `Speaker:1, Speaker:99, Speaker:2` | Ada, Bruno, null, **plus** `"Unexpected Execution Error"` on the entity route, HTTP 200 | 1 |
| `Speaker:1` three times | Ada three times - correct, one key in the `WHERE` | 1 |
| `Speaker:1, Session:1, Speaker:2` | Ada, null, Bruno - correct, two keys in the `WHERE` | 1 |

The statement is the same statement main issues, at the same count:

```sql
SELECT "s"."Id", "s"."Bio", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" IN (@ids1, @ids2, @ids3)
```

Three things in that table are worth keeping.

**The error's path is not stable, and the chapter therefore states neither
half of it.** Found while checking an audit finding. Measured 2026-08-24 over
twenty runs, five each across four key orders, with two selection sets:

| Key order | Runs giving `_entities.2` | Runs giving `_entities` |
|-----------|---------------------------|-------------------------|
| 1, 99, 2 (selection `id name`) | 5 | 0 |
| 1, 99, 2 (selection `__typename id name`) | 5 | 0 |
| 99, 1, 2 | 4 | 1 |
| 1, 2, 99 | 5 | 0 |

The `data` half was byte-identical in all twenty: `Ada Fischer, Bruno Kaminski,
null`. So the index is usually there and cannot be relied on, and **why** was
not established. An earlier draft of the chapter printed a response carrying
`"path":["_entities",2]` and `verify.ps1` on `ch11-misordered` asserted it;
both are corrected. The script now asserts the first path segment only, and the
chapter prints the `data` half and says in prose that an error arrives beside
it on the entity route. Reproduce with
`scratchpad/probe-path.ps1`-style loop: same request, five times, reading
`errors[0].path`.

**Nothing reaches the service's own output.** Also found by the audit, which
noticed that a draft claimed this error "appears in a log" while chapters 6 and
9 had already measured the opposite for the same message. Re-measured
2026-08-24 with stdout and stderr captured to separate files: while answering
the request above, stdout carries only StatementLog's four lines for the one
statement and stderr carries nothing at all. No exception, no stack trace, no
warning. `verify.ps1` on `ch11-misordered` asserts it. The chapter's claim is
therefore that the failure is loud **in the response** and silent everywhere
else, which is a narrower and truer thing than the draft said.

**The fourth row is the loud half of the contract.** Two rows came back for
three keys, so `results.Span[2]` was never written, and an unwritten `Result`
is an execution error rather than the null the specification wants. This is the
**fourth** distinct cause of `Unexpected Execution Error` in this book, after
the three chapter 10 names in its own prose: the stub advertising a key it
cannot resolve, the Ratings service without its serializer registration, and
the dictionary with a duplicate key in it. Decision 69's original is **not** one
of them, because decision 96 records that it was never re-derived; do not put it
back into the list when editing this chapter. The message never says which.

**The fifth and sixth rows are what the branch did not break.** De-duplication
lives in `DataLoaderBase` above `FetchAsync`, and chapter 6's type-name guard
lives in the reference resolver, so neither is in the code that was replaced.
The chapter says this: the defect is narrow, and narrowness is not safety.

**The parameter name is a deliberate edit.** The override's list parameter is
`keys` on the base class, and EF Core names the SQL parameters after the
closed-over variable, so the statement read `@keys1` in the first draft. Both
hand-written branches rename the parameter to `ids`, which makes the printed
statement comparable with every other loader in the book. Recorded because a
reader typing the listing from an IDE's `override` completion will get `keys`
and see `@keys1`, and that difference is real and harmless.

### Through the router: the coincidence, and the query that breaks it

`ch11-misordered`, whole graph up, router on 3002.

**Correct, with the defect deployed:**

| Request | Answer |
|---------|--------|
| `{ sessions(first: 10) { nodes { title speaker { name } } } }` | Ada, Ada, Bruno, Chidi - correct, 1 statement in each of two services |
| `{ sessions { nodes { title speaker { name } } } }` (the default page of two) | Ada, Ada - correct |

The reason is the seed. Sessions in schedule order name speakers 1, 1, 2, 3;
the router de-duplicates to `[1, 2, 3]`; SQLite returns rows in rowid order
`[1, 2, 3]`; the two lists agree. **This is a property of the data, not of the
code**, and it is why the chapter says this graph is the lucky case.

**Wrong, same deployment.** The literal form, which is what the chapter prints
and what `verify.ps1` sends. A variables document was tried and reverted: it
keeps the operation inside the book's 73-column budget, and it costs the
chapter's opening request its body, because every other raw HTTP block in this
book carries the body in the same block. The literal body is 108 columns and
the chapter pays for that with `fontsize` and `breakanywhere` on that one
block, which is what decision 50 provides for.

```
{ nodes(ids: ["U2Vzc2lvbjo0","U2Vzc2lvbjox"])
  { ... on Session { title speaker { name } } } }
```

| Session | Speaker it should carry | Speaker it carries |
|---------|------------------------|--------------------|
| The Bank That Split Its Graph | Chidi Okafor | **Ada Fischer** |
| Schemas That Outlive Their Authors | Ada Fischer | **Chidi Okafor** |

HTTP 200, no error key, one statement in the Speakers service. Representations
are `[Speaker:3, Speaker:1]`, rows come back `[1, 3]`.

And with three, where the middle entry is a fixed point of the reversal:

```
{ nodes(ids: ["U2Vzc2lvbjo0","U2Vzc2lvbjoz","U2Vzc2lvbjox"]) ... }
```

answers Ada, Bruno, Chidi where it should answer Chidi, Bruno, Ada. **The
middle one is right.** Two wrong answers either side of a correct one is worse
than three wrong ones, and the chapter says so.

**Why `nodes(ids:)` and not a page.** The parent list has to be one the client
ordered. `sessions` is ordered by `StartsAt` in the resolver and takes no sort
argument, so no paging request this graph offers can produce a non-ascending
speaker list. `nodes(ids:)` is the only root field where the caller chooses.

The `last:` half of that was measured rather than assumed, on 2026-08-24 against
the Sessions service on 5001, because the chapter states it:

| Request | Titles, in the order returned |
|---------|-------------------------------|
| `sessions(first: 10)` | Schemas That Outlive Their Authors, Reading a Query Plan, Paging Without Offsets, The Bank That Split Its Graph |
| `sessions(last: 3)` | Reading a Query Plan, Paging Without Offsets, The Bank That Split Its Graph |
| `sessions(last: 2)` | Paging Without Offsets, The Bank That Split Its Graph |

So `last:` selects from the end and still hands the window back forwards, which
is what the Relay convention says and what this connection does. `last: 3` names
speakers 1, 2 and 3, still ascending, so it is immune for the same reason every
other page is.

**The plan, confirming it is one fetch and not two.** For `nodes(ids:)` the
plan is a `Sequence` whose second step is a single `BatchEntity` against
`speakers` at path `nodes.@.speaker`, carrying both representations. Two
**aliased** `node(id:)` calls plan differently - a `Parallel` of two `Entity`
fetches carrying one representation each - and are therefore immune, which was
measured and is why the chapter uses `nodes` and not aliases:

```
{ a: node(id: "U2Vzc2lvbjoz") { ... on Session { title speaker { name } } }
  b: node(id: "U2Vzc2lvbjox") { ... on Session { title speaker { name } } } }
```

answers correctly on `ch11-misordered`, at two statements in each service. A
batch of one cannot be out of order.

**The fetch does not ask for the key.** The plan's entity fetch is:

```
query($representations: [_Any!]!) {
  _entities(representations: $representations) {
    ... on Speaker { __typename name }
  }
}
```

`id` is in the representation and not in the selection set, so the answer the
router receives carries no evidence of which speaker it is. A client asking the
service directly can ask for `id` and see the mismatch immediately; the router
never does.

### Everything the defect does not reach

All asserted on `ch11-misordered`:

- The exported schema of each of the three services is **byte for byte** the
  schema `main` exports.
- The graph composes, with no message.
- The query plan for the book's page is the same `Sequence` of two, the same
  `BatchEntity` against `speakers`, at the same path
  `sessions.nodes.@.speaker`.
- The statement counts do not move: one in the Sessions service, one in the
  Speakers service, none in Ratings.
- The response to every request printed before this chapter is unchanged.

### The corrected hand-written loader

`ch11-handwritten`. One loop different:

```csharp
var rows = await db.Speakers
    .Where(s => ids.Contains(s.Id))
    .ToDictionaryAsync(s => s.Id, ct);

for (var i = 0; i < ids.Count; i++)
{
    results.Span[i] = Result<Speaker?>.Resolve(
        rows.GetValueOrDefault(ids[i]));
}
```

`main`'s own `verify.ps1` runs against this branch unchanged and unloosened:
**353 assertions, PASS**, the same 353 that pass against the source-generated
loader. That is the strongest statement available that the two are equivalent,
and it is why the branch exists rather than being described.

`GetValueOrDefault` is what makes the missing-key case a null instead of an
exception, which is the `else` branch of the generated `CopyResults` written
another way.

## What the chapter states as judgment

Under decision 38, because no source passes the bar:

- **Assert the round trip.** Ask a subgraph's entity route for the key
  alongside the fields, and check that entry *i* carries the key
  representation *i* named. No source recommends this; it is the only check
  available that does not depend on the shape of the data, and it is what
  `verify.ps1` now does on `main` and on `ch11-misordered` in mirror image.
- **Prefer the source generator.** A dictionary cannot be out of order, so a
  loader that returns one cannot make this mistake. This is a stronger reason
  to use `[DataLoader]` than convenience, and nobody publishes it.
- **A passing smoke test proves nothing here.** The request that would catch it
  is the one whose parent list is not in key order, and no default page is.

## Open questions this chapter did not settle

- **Whether the router's length check can be provoked from a Hot Chocolate
  subgraph.** It cannot from any state of this repository, because
  `_entities` always answers with one entry per representation. Unblocked by a
  subgraph that is not Hot Chocolate, or by a proxy that truncates the array,
  neither of which is worth a fourth service.
- **Whether SQLite's row order for an `IN` list is guaranteed.** Every run
  here returned rowid order, and the chapter does not claim it is guaranteed;
  it claims the weaker and sufficient thing, that the order is the store's
  choice and not the caller's. Unblocked by reading SQLite's documentation on
  result ordering without `ORDER BY`, which was not done because no claim in
  the chapter needs it.
- **Whether `@requires` fields change the fan-out of a wrong answer.** Chapter
  10 left open whether two representations with the same key and different
  `@requires` fields collapse. If they do not, a misordered answer is
  distributed differently again. The graph has one requiring field and no query
  produces the case.
