# Chapter 15 - Where Satisfiability Actually Fails

Research note for the sixth chapter of part III: what a resolvability answer
from the composer means, in both directions.

Web sources accessed **2026-09-05**; everything else was measured on this
machine on the same date.

Four things are worth stating before any of it.

**The composer answers per field, not per route.** One unresolvable field
produces one error carrying one path, and that path is an example rather than
an inventory. Six routes into `Session.averageScore` exist in this book's
supergraph and all six fail; the composer names one.

**Which one it names depends on subgraphs that have nothing to do with the
mistake.** Take the Speakers service out of `graph.yaml`, a service that
declares no `Session` at all, and the same defect in the same file is reported
at `query { node { ... on Session { ... } } }` rather than at
`query { searchSessions { edges { node { session { ... } } } } }`. Reverse the
order of the lines in `graph.yaml` and the third reason line names a different
subgraph as the entity ancestor. Taking **Search** out instead does something
worse and is the next paragraph.

**A composition that passes is not proof that a route exists.** With Search out
of the graph, the same broken Ratings document composes cleanly, exit zero,
nothing printed. What buys the silence is a second subgraph declaring
`node(id: ID!): Node`, and the singular field alone does it: the plural
`nodes(ids:): [Node]` does not, and neither does implementing `Node` without
declaring the root field. The subgraph does not even have to have an
implementation of `Node` in it.

**That is the same shareable root field decision 90 already charges the book
for.** Chapter 9 measured what `@shareable` on `Query.node` costs at run time
once two subgraphs own different node types. This is the second bill for it,
and it falls on the composer rather than on the router.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| `wgc` | 0.129.9, `@wundergraph/composition` 0.63.3 |
| Cosmo Router | 0.341.0, go1.26.6 |

**The databases must be deleted first.** The trap the chapter 11 open item
records: `EnsureCreated` seeds an empty database and does nothing to an
existing one, and `rescheduleSession` moves a session's `StartsAt`. Both probe
scripts below delete `conference.db`, `speakers.db`, `ratings.db` and
`search.db` before they start anything.

### The mistake this chapter is built on

One attribute in `src/Ratings/SessionType.cs`:

```csharp
[Key("id", false)]     // was [Key("id")]
```

and the `[ReferenceResolver]` attribute removed with it, because a key that
cannot be entered through has nothing to route to a resolver. Hot Chocolate
then exports `type Session @key(fields: "id", resolvable: false)` and drops
`_entities` and the `_Entity` union out of the Ratings schema entirely, which
is decision 85's measurement arriving from the other side.

It is a plausible mistake rather than a contrived one, and the book is what
teaches it: chapter 9 put `resolvable: false` on the `Speaker` stub in Sessions
and explained it as *this service does not own these rows*. Ratings does not
own `Session` rows either. The difference is that Ratings contributes three
fields to the type, and a contributed field is resolved by sending that
service a representation.

## What was measured

### 1. The four-service graph refuses, and names one route out of six

`graph.yaml` naming sessions, speakers, ratings and search, with the Ratings
document above. Composition fails, exit 1, with three errors - one per
unresolvable field, not one per route:

```
The field "averageScore" is unresolvable at the following path:
 query {
  searchSessions {
   edges {
    node {
     session {
      averageScore <--
     }
    }
   }
  }
 }
This is because:
 - The root type field "Query.searchSessions" is defined in the following subgraph: "search".
 - The field "Session.averageScore" is defined in the following subgraph: "ratings".
 - The entity ancestor "Session" in subgraph "sessions" has no accessible target entities (resolvable @key directives)
in the subgraphs where "Session.averageScore" is defined.
 - The type "Session" is not a descendant of any other entity ancestors that can provide a shared route to access
"averageScore".
```

The same block follows for `ratingCount` and for `feedbackUrl`, identical apart
from the field name.

Three subgraphs appear in one error and none of the three is where the reader
would look first. The path starts in `search`. The entity ancestor named is
`sessions`. The subgraph to edit is `ratings`, and it is named once, on the
second of the four reason lines.

**The routes that also fail and are not named.** Six paths reach
`Session.averageScore` in the composed schema:

| # | Route |
|---|-------|
| 1 | `sessions { nodes { averageScore } }` |
| 2 | `sessions { edges { node { averageScore } } }` |
| 3 | `sessionById(id:) { averageScore }` |
| 4 | `node(id:) { ... on Session { averageScore } }` |
| 5 | `nodes(ids:) { ... on Session { averageScore } }` |
| 6 | `mutation { rescheduleSession { session { averageScore } } }` |

Adding Search adds two more, through `SessionSearchDocument.session` under
`nodes` and under `edges { node }`, and it is one of those two the composer
printed. Section 4 below sends all six at a running graph and every one of them
fails.

### 2. The reported path moves when subgraphs move

Same Ratings document throughout. Only the set of subgraphs, or the order of
the lines in `graph.yaml`, changes.

| Input | Outcome | Path named |
|-------|---------|------------|
| sessions + ratings | fails | `query { node { ... on Session { ... } } }` |
| sessions + speakers + ratings | **composes** | none |
| sessions + speakers + ratings + search | fails | `query { searchSessions { edges { node { session { ... } } } } }` |
| sessions + search + ratings | fails | `query { node { ... on Session { ... } } }` |
| the four again, lines reversed | fails | same path, different entity ancestor |

Two runs of the same input are byte-identical, so this is not nondeterminism.

**Reversing the order of the subgraph entries** in `graph.yaml` leaves the
printed path alone and changes the third reason line from

```
 - The entity ancestor "Session" in subgraph "sessions" has no accessible target entities (resolvable @key directives)
in the subgraphs where "Session.averageScore" is defined.
```

to

```
 - The entity ancestor "Session" in subgraph "search" has no accessible target entities (resolvable @key directives) …
the subgraphs where "Session.averageScore" is defined.
```

Note the ellipsis, which is `wgc`'s own. The tool draws a fixed 120-column box
and elides whatever does not fit, so the longer name costs the sentence the
word `in`. The composer's own presentation can eat part of its explanation, and
there is no flag that turns the box off: `wgc router compose --help` at 0.129.9
offers `--suppress-warnings`, `--disable-resolvability-validation`,
`--ignore-external-keys` and `--split-configs-enabled`, and no structured
output option.

### 3. The composition that passes and cannot be served

Drop Search from `graph.yaml`, change nothing else, and the same broken Ratings
document composes:

```
Router execution config successfully written to "...router.json".
```

Exit 0. Nothing printed. The config it wrote carries the contradiction openly:

```
  keys:      [{"typeName": "Session", "selectionSet": "id", "disableEntityResolver": true}]
  rootNodes: [{"typeName": "Query", "fieldNames": ["ratingCount"]},
              {"typeName": "Session",
               "fieldNames": ["averageScore", "ratingCount", "feedbackUrl", "id"],
               "externalFieldNames": ["title"]}]
```

Three fields the router is told this subgraph resolves, and beside them a flag
saying the router may not send it an entity.

**What buys the silence, isolated one variant at a time.** The Speakers
document is the only thing that differs between the failing and the passing
three-subgraph run.

| Speakers document | Outcome |
|-------------------|---------|
| as shipped: `node` and `nodes`, `Speaker implements Node` | **composes** |
| `node` and `nodes` removed, `implements Node` kept | fails |
| `node` and `nodes` removed, `implements Node` removed | fails |
| `node` and `nodes` kept, `implements Node` removed | **composes**, with one warning |
| `node` alone | **composes** |
| `nodes` alone | fails |

So it is the singular `node(id: ID!): Node` in a second subgraph that does it.
The plural field, which differs only in returning `[Node]` rather than `Node`,
does not. And the fourth row is the sharpest: with `implements Node` taken off
`Speaker`, that subgraph's `Node` interface has no object implementation at
all, the composer says so in a warning -

```
Subgraph "speakers": The Interface "Node" is used as an output type without at least one Object type implementation
defined in the schema.
```

- and then composes the unresolvable graph anyway.

### 4. What the router does with the config the composer approved

`ch15-falsepass` carries the Ratings change; the three services and the router
are started on the config from section 3. Every route from section 1's table:

| Route | Status | Response |
|-------|--------|----------|
| `sessions { nodes { averageScore } }` | 500 | `{"errors":[{"message":"internal server error"}]}` |
| `sessions { edges { node { averageScore } } }` | 500 | same |
| `sessionById(id: 1) { averageScore }` | 500 | same |
| `node(id:) { ... on Session { averageScore } }` | 500 | same |
| `nodes(ids:) { ... on Session { averageScore } }` | 500 | same |
| `rescheduleSession { session { averageScore } }` | 500 | same |

Six for six. The router's own log gives two different reasons, and both are
worth reading:

```
printOperation planner id: 1: validation failed: external: Cannot query field
"averageScore" on type "Query"., locations: [], path: [query]
```

for routes 1, 2, 3 and 6, and

```
could not resolve a field: internal: nodesResolvableVisitor: could not select
the datasource to resolve Query.node on path query.node
```

for routes 4 and 5. The first says what the planner did when it had no entity
route: it built a root-level query against `Query`. The second is the router's
own resolvability check, running at request time, finding what the composer's
did not.

**The other two fields fail differently, and this is the part worth printing.**
The same graph, the same defect, the same subgraph:

`ratingCount`, at HTTP 200:

```json
{"errors":[{"message":"Failed to fetch from Subgraph 'ratings' at Path 'sessions.nodes', Reason: no data or errors in response.","extensions":{"statusCode":200}}],
"data":{"sessions":{"nodes":[{"title":"Schemas That Outlive Their Authors","ratingCount":null}, ...]}}}
```

and its plan:

```json
{"kind":"Single","path":"sessions.nodes","subgraphName":"ratings","subgraphId":"2",
 "fetchId":1,"dependsOnFetchIds":[0],"query":"{\n    ratingCount\n}"}
```

The router sent `{ ratingCount }` - the **root field** - to the Ratings service,
at path `sessions.nodes`. `averageScore` produced a 500 for exactly the reason
this one does not: there is no `Query.averageScore` to fall back to, and there
is a `Query.ratingCount`. A name collision between a root field and a field on
a type is the whole difference between a 500 and a wrong query that runs.

`feedbackUrl`, at HTTP 200, with **no error at all**:

```json
{"data":{"sessions":{"nodes":[{"title":"Schemas That Outlive Their Authors","feedbackUrl":null}, ...]}}}
```

Its plan is a `BatchEntity` fetch carrying an `_entities` query and a
`@requires` fragment for `title`, sent to a subgraph whose exported schema has
no `_entities` field in it. The client gets four nulls and is told nothing.

So one defect, three fields, three failure modes: a 500, a valid query against
the wrong field, and silence. None of them is a composition error, and the
composer approved the graph that produces all three.

### 5. Decision 90's second option, measured

Decision 90 rejected four ways of making `node(id:)` route across a seam, and
recorded that only the first was certain; the other three were rejected on
reasoning. The second was **declare `node` in one subgraph only**, and the
recorded reason for rejecting it was that composition passes and the failure is
identical.

Measured now, and it is not identical. Take `node` and `nodes` out of the
Speakers document, leave everything else as it is:

- the healthy four-service graph still composes, exit 0;
- the broken one fails again, and names `query { node { ... on Session } }`
  rather than the search route.

So that option costs nothing at composition time on a healthy graph and buys
back the check that section 3 shows the shipped arrangement losing. What it
costs at run time was not measured here and is what the open item still wants:
`node(id:)` for a `Speaker` would then have to be planned through the Sessions
subgraph's field, and whether it answers, errors or misroutes is unknown.

### 6. Moving two fields down one file decides whether the bug is found

The mechanism in section 8 predicts that the order root fields are **declared
inside one subgraph document** decides the answer, because the composer
validates root fields in declaration order and the first one it validates is
the one that writes the cache entry. Tested, and it holds.

Take the Sessions document exactly as the service exports it and move `node`
and `nodes` from the top of `type Query` to the bottom of the same type, above
`_service`. Same fields, same types, same directives, same everything else.

| Sessions document | Ratings key | Outcome |
|-------------------|-------------|---------|
| as exported, `node` first | resolvable | composes |
| as exported, `node` first | unresolvable | **composes** |
| `node` moved down four fields | resolvable | composes |
| `node` moved down four fields | unresolvable | **fails**, names `Query.sessions` |

```
The field "averageScore" is unresolvable at the following path:
 query {
  sessions {
   edges {
    node {
     averageScore <--
    }
   }
  }
 }
This is because:
 - The root type field "Query.sessions" is defined in the following subgraph: "sessions".
 - The field "Session.averageScore" is defined in the following subgraph: "ratings".
 ...
```

The healthy control in row three is what makes it a finding rather than a
coincidence: the reordering alone changes nothing.

This was predicted from the source before it was run, which is the reason to
trust the reading in section 8 more than a static read usually deserves.

### 7. A `@requires` that names a guarded field

The other question the open items sent here, because CVE-2025-64172 is exactly
this shape in Apollo's composer: a field using `@requires` was not required to
carry the same access control as the field it depends on.

**Composition, measured on two hand-written documents.** One subgraph declares
`Session.title: String! @authenticated`; a second declares
`feedbackUrl: String @requires(fields: "title")`. `wgc` 0.129.9 composes, exit
0, nothing printed, and writes exactly one rule:

```json
[ { "typeName": "Session", "fieldName": "title",
    "authorizationConfiguration": { "requiresAuthentication": true } } ]
```

Nothing on `feedbackUrl`. The same holds on the book's real graph with
`Session.Title` guarded in the Sessions service: two rules, `Session.title` and
chapter 12's `Speaker.email`, and none on the field built out of the first.
So this composer does not require it either.

**Run time, on branch `ch15-requiresguard`.** The guard holds anyway:

| Request | Token | Result |
|---------|-------|--------|
| `sessions { nodes { title } }` | none | refused, `AUTH_NOT_AUTHENTICATED` at `sessions.nodes.0.title` |
| `sessions { nodes { title } }` | yes | the titles |
| `sessions { nodes { feedbackUrl } }` | none | refused, at path `sessions.nodes.0.title` |
| `sessions { nodes { feedbackUrl } }` | yes | `https://feedback.example/2026/schemas-that-outlive-their-authors` |
| `node(id:) { ... on Session { feedbackUrl } }` | none | refused, at path `node.title` |

Read the paths. The refusal names `title` on a request that never mentioned it,
because the router has to collect `title` from Sessions before Ratings can be
asked, and the Sessions service refuses that field to a caller with no token.
The protection is the owning subgraph enforcing its own guard on the field the
router fetched. Neither the composer nor the router contributed anything: the
composer wrote no rule for `feedbackUrl`, and under decision 109 the router
enforces only the rules it was given.

**Not measured, and it is the case that would matter:** a graph guarded only at
the router, which is chapter 12's `ch12-routeronly` shape. There the subgraph
refuses nothing, and whether the derived field carries the guarded value
through is unknown.

The branch is an experiment rather than a state the book prints, so it carries
no tag: Sessions gains the two authorization packages, a copy of the Speakers
service's `SigningKey`, the `AddAuthorization()` pair in `Program.cs`, and
`[property: Authorize, Authenticated]` on `Session.Title`.

### 8. Why, read out of the composer

`@wundergraph/composition` 0.63.3, `dist/resolvability-graph/`. The build is not
minified, so function and parameter names survive. Everything here is a static
read, corroborated by section 6's prediction.

**The cache records a node when it is touched, not when it resolves.** For an
unshared root field, `visitEdge` in `root-field-walker.js` waves an entity
through if the map already holds it, under a comment that states the invariant
it does not have:

```js
/* This check prevents infinite loops.
 * The entity is only propagated into this map after it has been assessed for resolvability.
 * Consequently, only a valid node would appear here.
 *  */
if (this.resDataByNodeName.has(edge.node.nodeName)) {
    return { visited: true, areDescendantsResolved: true };
}
```

**A shared root field writes that entry without resolving anything.**
`Query.node` is declared by two subgraphs, so it takes `visitSharedEdge`, which
records the node and walks on. `visitRootFieldEdges` then returns on the first
edge that resolves, which is an OR across subgraphs rather than an AND:

```js
const result = isShared ? this.visitSharedEdge(...) : this.visitEdge(...);
if (result.areDescendantsResolved) {
    return result;
}
```

The Sessions branch fails and leaves `sessions.Session` in the map unresolved;
the Speakers branch succeeds; the field passes. Every later root field that
reaches the same node, `sessions`, `sessionById` and the mutation payload, then
hits the check above and is waved through.

**Case G is vacuous truth.** An abstract node with no implementations resolves
trivially, in all three walkers:

```js
visitSharedAbstractNode({ node, selectionPath }) {
    if (node.headToTailEdges.size < 1) {
        return { visited: true, areDescendantsResolved: true };
    }
```

**One route is reported because `validate()` returns at the first failing root
field**, so the rest of the schema is never walked in that run. And where one
entity is reachable by several paths from the same root field, the reported one
is chosen by `getFirstEntry(entityPaths)`, under the comment
`// Propagate errors for the first encounter only.`

**The subgraph named as the entity ancestor is first-write-wins.**
`subgraphNameByUnresolvablePath` is filled with `getValueOrDefault`, which
writes only when the key is absent, and the siblings are iterated in
subgraph-declaration order. That is why reversing `graph.yaml` in section 2
changed `sessions` to `search`: both copies of `Session` fail on the same
relative path, and the first one iterated puts its name in the sentence. The
path is where the query really is; the subgraph in the reason is not
necessarily on it.

## Sources

- **Apollo, `SATISFIABILITY_ERROR`.** \enquote{Subgraphs can be merged, but the
  resulting supergraph API would have queries that cannot be satisfied by those
  subgraphs.}
  `https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/errors`,
  accessed 2026-09-05, unsigned. Chapter 7 already cites this. **The page shows
  no example error text**, checked directly today, so no comparison of the two
  composers' message shapes is made anywhere in this chapter.
- **The Composite Schemas Specification, Validate Satisfiability.** Chapter 7
  cites it for the stack algorithm and nothing here changes that. What was
  checked today and found: the document defines a per-path predicate and says
  nothing about how many failing paths an implementation reports or which one,
  and its error entries carry path-tuple notation rather than message text.
  Draft at `https://graphql.github.io/composite-schemas-spec/draft`, stage 0,
  accessed 2026-09-05.
- **`apollographql/federation` issue 1067, Node query support in federated
  apollo server.** Opened 2021-10-08, **still open**, 11 comments, confirmed
  through the GitHub API on 2026-09-05. This is the thread decision 90's
  \enquote{Apollo publishes no guidance} was missing: no normative guidance
  exists, and the question has been open for five years.
- **`--disable-resolvability-validation` and the documentation.** The flag is in
  `wgc router compose --help` on the pinned 0.129.9, checked today, and it was
  run against this chapter's own four-service input rather than inherited from
  chapter 7's: all three errors go, exit 0, and a config is written.
  `verify.ps1` asserts that. It is no
  longer on the `wgc router compose` reference page, which chapter 7 cited it
  from on 2026-08-23 and which now lists exactly `-i/--input`, `-o/--out`,
  `--suppress-warnings` and `--split-configs-enabled`, and never uses the word
  resolvability; re-fetched and grepped on 2026-09-05. It is documented on the
  `wgc subgraph publish` page instead. The tool is what
  this book follows, so nothing chapter 7 printed becomes wrong; recorded so
  that a later session does not read the missing page as the flag being gone.
- **`InterfaceObjectAttribute` ships and is undocumented.** Read out of
  `HotChocolate.ApolloFederation` 16.6.1's own assembly today:
  `InterfaceObjectAttribute` and `InterfaceObjectDirective` are both in the
  metadata, along with the directive name `interfaceObject`. ChilliCream's
  federation API page 404s. Recorded for the open item that says
  `@interfaceObject` was never investigated; **whether it does anything for
  this book's problem was not measured** and no chapter says.
- **CVE-2025-64530 and CVE-2025-64172**, both published 2025-11-13 against
  `@apollo/composition`. The first is access-control directives not inherited
  from interface types to their implementations; the second is them not being
  enforced on fields reached transitively through `@requires` or
  `@fromContext`. Section 7 is the second one, tested against this book's
  composer. Searched for any advisory against `@wundergraph/composition` or
  `wundergraph/cosmo` through the GitHub advisory API, the REST advisories
  endpoint, OSV and the repository's own advisory list: **none, on any
  subject**. That is an absence of advisories rather than an absence of defects.

## Not established

- **Whether `node` is special or abstract return types in general are.** Only
  `Node` was tried, because it is the only interface this book's graph has at
  a root field. A union, or a second interface, was not tested. Section 8's
  reading says the vacuous-truth rule is general to abstract nodes, which is a
  reason to expect it and not a measurement of it.
- **What `node(id:)` does at run time with `node` declared in one subgraph
  only.** Section 5 measured composition and not the request.
- **Whether Apollo's composer reports one path or several** for the same
  input. Nothing here was run against `@apollo/composition`; this book composes
  with Cosmo's and says so, and the vendor's published error reference carries
  no example message to compare shapes against.
- **Whether a graph guarded only at the router leaks a `@requires` dependency.**
  Section 7's runtime result depends on the owning subgraph refusing the field.
  Chapter 12's `ch12-routeronly` is the shape where nothing does.
- **Whether `@interfaceObject` changes anything here.** The attribute ships at
  16.6.1 and was not applied to anything.
- **Whether this is reported upstream.** No search was made for an existing
  issue against `@wundergraph/composition` describing section 3, and none is
  claimed either way.

## Checked and found false

- **That the four-service graph reports every failing route.** It reports one
  path per unresolvable field. Three fields, three errors, six failing routes
  each.
- **That a passing composition means the router has a plan.** Section 4.
- **That the reported path is a property of the mistake.** It is a property of
  the mistake and of the rest of `graph.yaml`, including the order its lines are
  written in, and of the order root fields are declared inside one subgraph's
  own document (section 6).
- **That the subgraph named in the reason lines is on the reported path.** In
  the four-service case it is not, and section 8 says why.
- **That a `@requires` naming a guarded field is refused by composition.** It
  composes, and no rule is written for the requiring field (section 7). The
  guard that holds is the subgraph's own.
