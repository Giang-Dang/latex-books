# Chapter 17 - Nobody Owns That Field

Research note for the eighth chapter of part III: what the toolchain records
about who owns a type or a field, which is nothing, and what follows from that.

Web sources accessed **2026-09-06**; everything else was measured on this
machine on the same date.

Four things are worth stating before any of it.

**Nothing in the toolchain has a word for an owner.** Not the specification,
not the directive set, not the router execution config. A subgraph entry in
that config carries three properties - an id, a name and a routing url - and
ownership exists in the file only as which datasource is listed as able to
answer a field. The Composite Schemas draft never uses the word, checked by
fetching and searching it directly. Apollo's directive reference lists no
directive recording a team, an owner or a contact; what it does list is
`@composeDirective`, which preserves a directive of your own definition into
the supergraph without reading it. An Apollo technote goes further and shows an
`@owner` directive registered that way, but it is an unsigned vendor page
arguing a technique rather than a reference defining an artifact, so it does
not pass decision 39 and no chapter cites it. The claim the chapter makes is
the one the reference page carries.

**The composer requires consent to share a field and none to take one.** Two
subgraphs declaring the same field are refused unless *every* subgraph
declaring it says `@shareable`, which is exactly what Apollo documents. One
subgraph declaring `@override(from:)` on somebody else's field is accepted at
exit zero with nothing printed, no edit to the other document, and a composed
schema that is byte-for-byte what it was before.

**A change of owner is invisible in the schema a client reads.** Sharing a
field and moving a field both leave `engineConfig.graphqlSchema` identical to
the byte. The only thing that moves is the routing table underneath it. This
is the mirror image of chapter 16, where the schema moved and the composition
said nothing; here the composition says nothing and the schema does not move
either.

**A fourth vendor disagreement, after decisions 73, 88 and 122.**
`HotChocolate.ApolloFederation` 16.6.1 ships `OverrideAttribute` with both a
`From` and a `Label` property and documents Apollo's progressive override in
its own XML comments. `@wundergraph/composition` 0.63.3 has no `label`
argument on `@override` at all and refuses the directive by name. Jens Neuse
of WunderGraph describes progressive override as Apollo's feature and Cosmo's
answer as a different mechanism, which is the reason rather than an oversight.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| `wgc` | 0.129.9, `@wundergraph/composition` 0.63.3 |
| Cosmo Router | 0.341.0, go1.26.6 |
| Baseline before this chapter | `verify.ps1` PASS at 565, tag `ch16` |
| After this chapter | PASS at 607, tag `ch17` |

**The tag is on a branch and `main` has not moved, for the second chapter
running.** Chapter 16's work sits on `ch16-work` with tag `ch16` on it, and
this chapter's sits on `ch17-work` cut from that tag. Moving `main` means
writing in the verification repository's own checkout, which these sessions
have left alone on purpose. Two fast-forwards are now outstanding and both are
raised in this chapter's pull request.

**`wgc` 0.130.1 exists** and this book stays on 0.129.9. The tool printed its
own update banner during the first run of the composition block. Re-pinning is
not a drafting session's call here the way it was in chapter 7: chapters 7, 15,
16 and this one all quote this composer's error text line for line, `verify.ps1`
asserts the version, and a minor bump would have to be re-measured against
every one of them. Recorded as an open item rather than taken.

**The databases must be deleted first**, and an assertion added late in the
script compares against something taken in the same breath rather than against
chapter 3's seed. Both halves of the chapter 11 open item's trap apply here
unchanged.

**Force UTF-8 before reading `wgc` output from anything but an interactive
console**, decision 127's trap. Every capture below was taken with
`[Console]::OutputEncoding` set to UTF-8 and the box `wgc` draws stripped by
codepoint afterwards.

## The composition experiments

Every one of them edits **one** exported document, leaves the other three
exactly as the services export them at tag `ch16`, and composes the four as a
graph. No service is changed, so decision 143 applies and no branch or tag is
needed: the whole failure lives in a file generated into a temp directory. The
driver used while researching is a small Python script, and the assertions that
keep the results honest are in `verify.ps1`.

The field used throughout is `Session.abstract`. It is owned by the Sessions
service, it is nullable, and no `@requires` anywhere names it. `Session.title`
was tried first and is useless for this: the Ratings document carries an
`@external` copy of it so that `feedbackUrl` can `@requires` it, so every edit
that touches `title` in Ratings fails on the `@requires` precondition instead
of on the thing being tested. That failure is recorded below because it took
three variants to notice.

### 1. A service puts a field on a type it owns no row of

Ratings declares `flagged: Boolean` on its `Session`.

```
exit 0
Router execution config successfully written to ".../router.json".
```

Nothing else printed. The composed schema gains exactly two lines, the
description and the field:

```
206a207,208
>   """Whether this session was flagged by a moderator."""
>   flagged: Boolean
```

The Ratings datasource's `Session` field list goes from
`averageScore,ratingCount,feedbackUrl,id` to
`flagged,averageScore,ratingCount,feedbackUrl,id`. The Sessions document is
untouched and no run reads it for permission.

### 2. Two services declare the same field, and neither says `@shareable`

Ratings declares `abstract: String` beside the Sessions copy.

```
exit 1
The Object "Session" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "abstract" is defined in the following subgraphs: "sessions", "ratings".
 However, it is not declared "@shareable" in any of them.
```

Doing the same edit in the Search document instead names `"sessions",
"search"` and is otherwise identical. This is the one refusal in the whole
chapter.

### 3. `@shareable` in one document only

Both directions were run, because the asymmetry would have been the finding if
there were one. There is not.

- `@shareable` on the Sessions copy alone: exit 1, and the message becomes
  `The field "abstract" is defined and declared "@shareable" in the following
  subgraph: "sessions".` / `However, it is not declared "@shareable" in the
  following subgraph: "ratings".`
- `@shareable` on the Ratings copy alone: exit 1, the mirror image, naming
  `"ratings"` as the one that declared it.

Which matches Apollo's documented rule exactly: a field marked `@shareable` in
any subgraph must be marked `@shareable` or `@external` in every subgraph that
defines it, or composition fails. This composer enforces what the vendor
documents, which is worth saying plainly after decisions 73, 88, 122 and 126
all recorded the opposite.

### 4. `@shareable` in both

Exit 0, nothing printed. Both datasources now list `abstract`:

```
sessions  http://localhost:5001/graphql   id,speaker,title,abstract,startsAt,durationMinutes
ratings   http://localhost:5003/graphql   abstract,averageScore,ratingCount,feedbackUrl,id
search    http://localhost:5004/graphql   id
```

And `engineConfig.graphqlSchema` is **byte-identical** to the baseline's, 247
lines, `diff` silent. A field with two owners and a field with one look the
same to a client.

The Ratings document has to gain the `@shareable` import and the directive
definition as well as the directive itself; without them the composer refuses
for a different reason. That is what Hot Chocolate emits anyway when the
attribute is applied, so it is the realistic edit rather than a contrivance.

### 5. `@override`, which needs nobody's permission

Ratings declares `abstract: String @override(from: "sessions")`. The Sessions
document is not edited.

```
exit 0
Router execution config successfully written to ".../router.json".
```

The routing table moves and the schema does not:

```
sessions  http://localhost:5001/graphql   id,speaker,title,startsAt,durationMinutes
ratings   http://localhost:5003/graphql   abstract,averageScore,ratingCount,feedbackUrl,id
```

`abstract` has left the Sessions datasource. `engineConfig.graphqlSchema` is
byte-identical to the baseline, 247 lines. Composition never asks whether the
Ratings service can answer the field; the document says it can, and that is the
whole of the check.

### 6. Progressive `@override` is refused by this composer

`@override(from: "sessions", label: "percent(50)")`, with the Ratings document
declaring `directive @override(from: String!, label: String) on
FIELD_DEFINITION` so that the argument is defined where it is used:

```
exit 1
The subgraph "ratings" could not be federated for the following reason:
The 1st instance of the directive "@override" declared on coordinates "Session.abstract" is invalid for the following
reason:
 The definition for "@override" does not define the following argument that is provided: "label".
```

The document *does* define it. The composer substitutes its own definition,
which is the same behaviour decision 122 recorded for
`@semanticNonNull(levels:)` and decision 73 for `@cost(weight:)`. Confirmed by
reading the pinned package rather than by inference:
`npm view @wundergraph/composition@0.63.3 dist.tarball`, extract, and
`dist/directive-definition-data/directive-definition-data.js` carries an
`OVERRIDE_DEFINITION_DATA` whose `argumentDataByName` map holds one entry,
`from`, and whose `requiredArgumentNames` is the set `{from}`. A grep of the
whole extracted package for `label` and `percent` returns nothing related to
`@override`. The v1 constants file carries the comment
`// directive @override(from: String!) on FIELD_DEFINITION`, the same
single-argument shape.

The other side ships it. `HotChocolate.ApolloFederation` 16.6.1 exports
`OverrideAttribute` with `From` and `Label` properties and a two-string
constructor, read out of `HotChocolate.ApolloFederation.xml` beside the
assembly:

> The progressive @override feature enables the gradual, progressive deployment
> of a subgraph with an @override field. As a subgraph developer, you can
> customize the percentage of traffic that the overriding and overridden
> subgraphs each resolve for a field.

So a .NET subgraph author can write the attribute, the schema will carry the
argument, and this composer will refuse the graph.

### 7. `@override` from a subgraph name that does not exist

`@override(from: "session")`, singular, a plausible typo.

```
exit 1
The Object "Session" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "abstract" is defined in the following subgraphs: "sessions", "ratings".
 However, it is not declared "@shareable" in any of them.
```

The message names neither `@override` nor the typo. The directive simply did
not apply, so what is reported is the duplicate-field error from experiment 2.
A reader who has just written an override and gets this back has to work out
for themselves that the two are the same event.

### 8. `@override` of a field nobody else declares any more

The second half of a migration: the `abstract` field is deleted from the
Sessions document and the Ratings copy still says
`@override(from: "sessions")`.

```
exit 0
```

Nothing objects. The directive outlives the thing it referred to and no run
will ever mention it again.

### 9. Two subgraphs overriding the same field

Ratings and Search both declare `abstract: String @override(from: "sessions")`.

```
exit 1
The "@override" directive must only be declared on one single instance of a field. However, an "@override" directive
was declared on more than one instance of the following field: " The field "Session.abstract" declares an @override
directive in the following subgraphs: "ratings", "search".".
```

Which matches Apollo's documented restriction. **The message is malformed**: a
whole sentence is interpolated into a slot that expects a field coordinate, so
it arrives inside quotation marks with a stray leading space and a doubled
full stop. Same family as the elided word chapter 15 recorded in this tool's
120-column box. No chapter prints it.

### 10. `@inaccessible`, and the second schema in the config

Two variants, both exit 0: Ratings marks the shared `abstract` inaccessible,
and Ratings marks its own root field `ratingCount` inaccessible.

In both, `engineConfig.graphqlSchema` **keeps** the field and carries
`@inaccessible` on it. What changes is that a second key appears:

| Config | `graphqlSchema` | `graphqlClientSchema` |
|---|---|---|
| baseline | 247 lines | **absent** |
| `abstract` inaccessible | 249 lines | 240 lines |
| `ratingCount` inaccessible | 249 lines | 240 lines |

`graphqlClientSchema` is not in the baseline config at all. It appears only
when something is hidden, and what it drops is the hidden field, the directive
definitions and the `@authenticated` marker on `Speaker.email`. Cosmo
documents exactly this split for its Contracts feature: the Router Schema keeps
inaccessible fields for query planning, and the Client Schema is what
introspection and clients see.

**This qualifies chapter 16's reading**, which called
`engineConfig.graphqlSchema` the schema a client reads. For this book's graph
it is, because nothing in it is inaccessible and the second key is absent. The
general statement is that `graphqlSchema` is what the router plans against and
`graphqlClientSchema`, where present, is what a client is shown. Chapter 16's
diff is over the right document for its own graph; the sentence around it is
narrower than it sounds. Not corrected in chapter 16, because the claim it
makes about its own five lines is true and the qualification belongs where the
mechanism is explained.

### 11. What a subgraph is, in the config

```json
{ "id": "2", "name": "ratings", "routingUrl": "http://localhost:5003/graphql" }
```

Three properties. No team, no contact, no repository, no owner. The
`datasourceConfigurations` entry beside it carries `keys` and `requires` and
the two node lists, all of which are about routing.

## The runtime half

One served graph, on the config from experiment 5. The four services behind the
router are the ones on `main`, unmodified, because only the composer's input
differs. The Ratings service's real schema has no `abstract` on `Session`; its
*document*, as edited, says it does.

The point is not that a document can lie. It is that `@override` is a claim and
composition takes the claim on trust, so the first thing that ever checks it is
a request.

The request is the page query this book has printed since chapter 3 with one
field added, `{ sessions(first: 10) { nodes { title abstract } } }`, and this
is the whole answer as captured, HTTP 200:

```json
{"errors":[{"message":"Failed to fetch from Subgraph 'ratings' at Path 'sessions.nodes'.","extensions":{"errors":[{"message":"The field `abstract` does not exist on the type `Session`.","locations":[{"line":1,"column":107}],"extensions":{"code":"DOWNSTREAM_SERVICE_ERROR"}}],"serviceName":"ratings","statusCode":200}}],"data":{"sessions":{"nodes":[{"title":"Schemas That Outlive Their Authors","abstract":null},{"title":"Reading a Query Plan","abstract":null},{"title":"The Bank That Split Its Graph","abstract":null},{"title":"Paging Without Offsets","abstract":null}]}}}
```

The chapter prints the `errors` half only, with `locations` and the `data` key
left out, and says on the page that it did.

**The title order in that capture is not the seed's**, and this is the chapter
11 open item's trap from the inside for the second chapter running. Chapter
4's `rescheduleSession` block runs earlier in the same script and moves a
session, so `The Bank That Split Its Graph` is third here and fourth in the
capture chapter 16 prints from a run that reaches the router earlier. Nothing
about the chapter's claim depends on the order, so the assertion sorts the
titles and the prose does not state one.

## Sources

| Claim | Source | Byline | Accessed |
|---|---|---|---|
| A field `@shareable` in one subgraph must be `@shareable` or `@external` in every subgraph defining it, or composition fails; and resolvers for a shared field must behave identically or queries return inconsistent results | Apollo, *Value Types in Apollo Federation*, `apollographql.com/docs/graphos/schema-design/federated-schemas/sharing-types` | unsigned; admitted under decision 39 as the vendor's reference for its own directive | 2026-09-06 |
| It is the developer's responsibility to make shared field definitions resolve identically, and failure returns different data indeterminately | WunderGraph, *@shareable*, `cosmo-docs.wundergraph.com/federation/directives/shareable` | unsigned; same footing | 2026-09-06 |
| `@override` moves responsibility for a field to the declaring subgraph, and only one subgraph may override a given field | Apollo, federation directives reference | unsigned; same footing | 2026-09-06 |
| Progressive override is Apollo's feature, using `@override` with a `label` argument, and Cosmo's answer is a different mechanism | Jens Neuse, CEO and co-founder, WunderGraph, *Announcing Graph Feature Flags for GraphQL Federation*, published 2024-07-04, edited 2026-07-27 | **bylined**, and the prose names him | 2026-09-06 |
| `@override` indicates a field is now resolved by this subgraph instead of another that also defines it; only one subgraph may override a given field; `label` is an optional second argument; `@composeDirective(name: String!) repeatable on SCHEMA` preserves a custom directive into the supergraph; and the page lists no directive recording a team or owner | Apollo, federation directives reference, `apollographql.com/docs/graphos/schema-design/federated-schemas/reference/directives` | unsigned; the same page chapters 7 and 9 already cite, re-fetched | 2026-09-06 |
| `@tag` marks what a contract removes, the composed schema adds `@inaccessible` to it, and the Router Schema keeps such fields for planning while the Client Schema does not | WunderGraph, *Schema Contracts*, `cosmo-docs.wundergraph.com/studio/schema-contracts` | unsigned; same footing | 2026-09-06 |
| `@tag` says whether a type or field is included in or excluded from a contract schema, `@inaccessible` removes it from the source variant's API schema and every contract schema, and the instructions need an Org Admin or Graph Admin role | Apollo, *Create a Contract*, `apollographql.com/docs/graphos/platform/schema-management/delivery/contracts/create` | unsigned; same footing | 2026-09-06 |
| A proposal is a collection of changes to a federated graph reviewed before it ships; composition errors, breaking changes, operation impact, lint and pruning all run against one automatically; a non-interactive run needs a `COSMO_API_KEY` with write access | WunderGraph, *Proposals*, `cosmo-docs.wundergraph.com/concepts/proposals` | unsigned; same footing | 2026-09-06 |
| Roles are scoped at organization, namespace, federated graph and subgraph, and the subgraph roles are admin, publisher, checker and viewer; the word owner appears nowhere | WunderGraph, *Group Rules*, `cosmo-docs.wundergraph.com/studio/groups/group-rules` | unsigned; same footing | 2026-09-06 |
| Three core entities of one federated graph, each owned by a separate engineering team; and the owner of an index depending on other teams' data is in the position of not being able to resolve its errors independently | Alex Hutter, Falguni Jhaveri and Senthil Sayeebaba, *How Netflix Content Engineering makes a federated graph searchable*, Netflix TechBlog, 2022-04-12 | **bylined**, three named engineers at the company described | 2026-09-06 |
| Teams end up creating the same type as another team, which conflicts after integration in the federated gateway, and developers do not notice until the gateway | Isha Talegaonkar, Walmart Global Tech, *Schema governance approaches for GraphQL*, 2022-08-11 | **bylined**, named engineer at the company described | 2026-09-06 |

Verbatim, the four passages the chapter quotes or leans on:

> If a type or field is marked `@shareable` in any subgraph, it must be marked
> either `@shareable` or `@external` in every subgraph that defines it.
> Otherwise, composition fails.

> However, it is the developer's responsibility to ensure that any such field
> definitions always resolve identically, regardless of which subgraph is
> ultimately resolving the field. Failure to make each resolver identical would
> cause different data to be returned indeterminately.

> As an example, let's examine three core entities of the graph, each owned by
> separate engineering teams: Movie [...] Production [...] Talent

> The owner of the index is often required to follow up with other domain teams
> regarding errors in related entities and be in the unenviable position of not
> being able to do much to resolve the issues independently.

> Teams may end up creating the same *Type* as another team, which can lead to
> conflicts after integration in the federated gateway.

> Developers go through the entire Software Development Life Cycle (SDLC)
> before noticing the collisions (such as usage of the same *Types*) at the
> gateway.

> Apollo has a related feature called "Progressive Overrides", which allows you
> to annotate a field with the `@override` directive and an additional `label`
> argument to gradually move ownership of a field from one Subgraph to another.

> With Cosmo's Graph Feature Flags, we can achieve the same result by creating
> a Feature Subgraph that includes the `@override` directive, and enabling the
> Feature Flag for a subset of traffic.

From the Apollo federation directives reference, the three passages the chapter
quotes or states:

> Indicates that an object field is now resolved by this subgraph instead of
> another subgraph where it's also defined.

> Only one subgraph can `@override` any given field. If multiple subgraphs
> attempt to `@override` the same field, a composition error occurs.

> Indicates to composition that all uses of a particular custom type system
> directive in the subgraph schema should be preserved in the supergraph schema

with the signature `directive @composeDirective(name: String!) repeatable on
SCHEMA`, and `@override` given as `directive @override(from: String!) on
FIELD_DEFINITION` with `label` listed beside `from` as an optional argument
supporting `percent(<percent-value>)`. Read on the same page: **there is no
directive on it recording a team, an owner or a contact.**

From `HotChocolate.ApolloFederation.xml` beside the 16.6.1 assembly, the
`OverrideAttribute` summary carries the link the chapter says it does:

> See <see href =
> "https://www.apollographql.com/docs/federation/entities-advanced/#incremental-migration-with-progressive-override">Apollo
> documentation</see> for additional details.

**The Composite Schemas draft was fetched and searched directly** rather than
taken from the research pass: neither `owner` nor `ownership` occurs anywhere
in it. An earlier draft of the chapter also named *contributed by*, *defined
in* and *resolved by* as the draft's vocabulary for the same relationship;
that could not be confirmed from the document, so the sentence is gone and
only the absence is claimed.

## The governance tooling both vendors sell, and what it needs

Same wall chapter 16 met, and measured the same way rather than assumed.
`wgc contract create` and `wgc proposal create` both refuse with
`Organization slug is not set. Please run wgc auth login to set the
organization slug.`, which is the identical refusal chapter 16 recorded for
`wgc subgraph check`. Under decision 147 no chapter prints that, and the
chapter describes both features from the vendor's own reference pages instead.

Cosmo's RBAC page documents roles at four levels - organization, namespace,
graph and subgraph - assignable through groups, which is the closest thing
either vendor has to recording who is responsible for a subgraph. It is access
control rather than ownership metadata: it says who may publish, not whose type
it is. Its own roadmap section names limiting subgraph access to specific
federated graphs as not yet available.

## Checked and found false, or not established

- **That `wgc` supports progressive `@override`.** A search summary claimed a
  `label` argument arriving in "Cosmo Router v0.95.0 or later and wgc CLI
  v0.58.0 or later". No Cosmo documentation page says it;
  `cosmo-docs.wundergraph.com/federation/directives/override` 404s, and the
  directives index describes `@override` with no label argument and no version
  numbers. The pinned package has one argument. The claim is false for 0.63.3.
- **That Netflix runs a schema working group that reviews new entities and
  fields, and tags fields experimental or deprecated.** A search summary
  attributed this to the Netflix post cited above. The full text of that post
  contains none of the words *working group*, *experimental* or *deprecated*.
  Nothing of the kind is used, and no separately sourced version of the claim
  was found.
- **How the router chooses which subgraph answers a shareable field.** Neither
  vendor documents a selection rule and none was measured here. The book has
  said something adjacent since chapter 9: with `Query.node` shareable in two
  subgraphs, which one is asked decides the answer, and decision 90 records
  three requests disagreeing. Why the planner picks the one it picks is still
  the open item chapter 15 left. No chapter claims a rule.
- **Whether the four services would still answer correctly if the Ratings
  service actually implemented `abstract`.** Not built, because it needs a
  service change and this chapter deliberately changes no service.
- **Whether Apollo's GraphOS has subgraph-level roles the way Cosmo's RBAC
  does.** Searched and not established either way. No chapter says.
- **Whether a published account exists of a team arguing about who owns a
  field in a federated graph.** Searched across Netflix, Expedia, Zalando,
  Shopify, GitHub, Coinbase, Booking.com, Instacart, Wayfair, Atlassian and
  Intuit engineering blogs and the GraphQLConf schedules, and the nearest
  matches are the two bylined posts above: Walmart's is about type-name
  collision and the linter built to prevent it, and Netflix's is about an index
  owner unable to fix errors in another team's data. Neither is a dispute over
  a field. Two leads were not run down: an Apollo-hosted post quoting Leah
  Hurwich Adler of Wayfair, which is a vendor page about a customer and needs
  the named engineer's own words checked, and Martijn Walraven's GraphQLConf
  2025 talk *Namespacing Is the Next Frontier of GraphQL Federation*, for which
  no recording or transcript could be found. So decision 38 applies to the
  chapter's central claim, which is stated as my judgment citing nobody, on the
  same footing as chapter 1's threshold and chapter 16's availability risk.
