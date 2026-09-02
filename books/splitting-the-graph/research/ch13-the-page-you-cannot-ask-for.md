# Chapter 13 research: The Page You Cannot Ask For

Research date: 2026-09-02.

## Question and conclusion

The chapter asks whether a client can filter, order, and paginate the Sessions
connection by rating fields owned by Ratings. It cannot do so through the
existing `sessions` root. Sessions selects and slices that list before the
router has values from Ratings. A later entity fetch can enrich the chosen
sessions, but it cannot replace the list owner's page.

The implemented escape is a fourth Search subgraph. Search owns a complete
denormalized session discovery projection. It filters, orders, applies a stable
Session-id tie-breaker, and slices locally, then returns Session entity keys for
hydration by Sessions. The original `sessions` root, seed, schedule order, and
chapter 11's `1, 1, 2, 3` speaker sequence are unchanged.

## External sources

### Apollo directive reference

URL: https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/directives

This is an unsigned reference artifact, not a recommendation by a named
engineer. It establishes the declared jobs of the relevant directives:

- `@requires` lets a resolver require fields from another subgraph.
- `@provides` says a resolver can provide a normally external field at a
  particular path.
- `@shareable` marks a field that more than one subgraph can resolve.
- `@listSize` supplies demand-control metadata about list sizes.

None declares that a router should re-filter, re-order, or re-page a list after
an entity fetch. That negative conclusion is schema-specific and also measured
against the current graph; it is not a universal claim that federation can
never support a cross-domain search surface.

### Apollo query-plan reference

URL: https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/query-plans

This is also an unsigned reference artifact. Its vocabulary distinguishes the
root fetch from later flatten/entity work. The inference used in the chapter is
that later work operates on the objects already selected by the root fetch. The
local Cosmo plan below supplies the engine-specific evidence.

### Apollo aggregation guide

URL: https://www.apollographql.com/docs/graphos/schema-design/guides/aggregating-data-across-subgraphs

The guide describes an aggregation/search subgraph backed by a denormalized
store. It has no byline, so the chapter does not present it as expert advice or
quote it. It was useful as an orientation source only.

### Concrete defect report

URL: https://github.com/apollographql/federation/issues/2668

The open issue is a concrete report of relational filter/paging trouble across
subgraphs. The reporter is not verified as an Apollo engineer. The chapter does
not use the issue as authority and does not need it for the mechanism claim.

### Version check

URL: https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/versions

The current page listed Federation v2.15 on the research date. No newly listed
directive changes the filter/order/page ownership mechanism used here.

## Empirical verification

Private verification tag: `ch13` at commit `8a5602b`.

The verification repository is local only and must not be named in book prose.
The exact source at the tag built with Hot Chocolate 16.6.1 on `net10.0`,
exported all four schemas, composed with `wgc 0.129.9`, and served through
Cosmo Router 0.341.0.

Command:

```powershell
pwsh -NoProfile -File verify.ps1
```

Result: `PASS` with 422 assertions on the main-equivalent `ch13` state and
`PASS` with 214 assertions on the unchanged Hot Chocolate 14 branch, tagged
`ch13-hc14`.

The exported Search root is:

```graphql
searchSessions(
  after: String
  before: String
  first: Int
  last: Int
  minimumScore: Float
  order: SessionSearchOrder
): SearchSessionsConnection
```

Search owns four documents, including session 4 with a null average and a
rating count of 0. An unfiltered rating-descending request returns averages in
this order: 4.5, 4.0, 3.0, null. Filtering at 4.0 and asking for the first two
returns session 2, then session 1, with no next page.

The generated Search SQL contains:

```sql
WHERE "s"."AverageScore" >= @
ORDER BY "s"."AverageScore" DESC, "s"."SessionId"
LIMIT @
```

For the filtered request, the attributed statement counts are:

- Search: 1
- Sessions: 1 batched entity lookup
- Ratings: 0
- Speakers: 0

The plan is a `Sequence` with two children:

1. `Single`, subgraph `search`, id `3`.
2. `BatchEntity`, subgraph `sessions`, id `0`, waiting for fetch `0`.

This establishes the order that matters: Search decides membership and order;
Sessions only hydrates the already chosen entity keys.

## Alternative checked

A second prototype placed the same projection and root in Ratings. It composed
and produced the same page, SQL shape, two-step plan, and statement counts. A
fourth process is therefore not mechanically required.

The book uses a separate Search subgraph because the projection combines
schedule and rating data and owns a second query domain. Putting it in Ratings
would preserve a count of three services while making Ratings own both rating
writes and cross-domain discovery. The fourth subgraph makes that ownership
change visible. It also makes the cost visible: another process and a projection
whose freshness must be maintained.

## Claims checked false

- The router can fetch a Sessions page, attach Ratings fields, then sort and
  paginate the result. The measured plan contains no such step.
- `@requires` moves a remote rating into the Sessions list resolver before the
  page is cut. It only changes the representation needed by a field resolver.
- `@provides` copies remote data into a service. It describes data the providing
  resolver can already return at that path.
- `@shareable` copies or synchronizes a field. It only declares multiple
  resolvers for data they already possess.
- `@listSize` supplies pagination semantics. It is demand-control metadata.
- The current Ratings database can enumerate every session. It has no row for
  the unrated session 4, so it cannot produce a complete discovery result
  without a separate complete projection.

## Not established

- No production ingestion path is implemented. The chapter uses deterministic
  seed data to isolate the ownership and execution question.
- No claim is made about acceptable indexing lag or consistency guarantees.
  Those depend on product requirements and the update mechanism.
- The experiment does not establish stable pages while the projection changes
  between requests. The id tie-breaker makes a single ordering deterministic;
  it does not create snapshot isolation across requests.
- No timings are reported. The evidence is schema, response, plan, SQL shape,
  and statement counts.

## Cold-audit triage

The cold audit reported 27 findings, and all 27 were accepted.

- The opening rule and final summary exceeded the experiment's scope. Both now
  name the existing `sessions` plan, and the remaining mechanism claims name
  the measured plans for this graph.
- Two printed responses contained fields the verifier did not assert. Five new
  assertions now cover the opening title and score plus the Search titles,
  rating counts, and end cursor. The main-equivalent run is therefore at 422.
- A hypothetical request used arguments that do not exist on `sessions`. It was
  removed and replaced with prose describing the missing API requirement.
- The chapter's scope line, six section labels, subsection label, index entries,
  lowercase references, figure-before-reference order, inline-code macro, and
  first-person-singular voice were corrected. A redundant mid-chapter box was
  removed.
- `launchSettings.json` was a source listing but the listing checker treated
  every JSON block as captured output. The map now opts that block into exact
  JSON comparison without treating response bodies as source. All 23 mapped
  listings match the `ch13` tag.

No audit finding was rejected.
