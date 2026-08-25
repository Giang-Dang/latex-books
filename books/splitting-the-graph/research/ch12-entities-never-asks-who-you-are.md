# Chapter 12 - `_entities` Never Asks Who You Are

Research note for the third chapter of part III: what a guard on a root field
guards, and what reaches the same rows without passing it.

Web sources accessed **2026-08-25**; everything else was measured on this
machine on the same date.

Six things are worth stating before any of it.

**The guard has three doors to cover and a root-field attribute covers one.**
`Query.speakers`, `_entities(representations:)` and `node(id:)` are three
fields of `Query` on one service, and all three end at the same rows.
`[Authorize]` on the first refuses the first. The other two answer a caller
carrying nothing, at the statement count they always cost. Nothing has to be
guessed either: introspection lists `_entities` and `_service` as fields of
`Query`, the `_Entity` union names every type the route will return, and
`_service { sdl }` hands an anonymous caller the whole schema.

**The obvious correction is silently inert, and that is the chapter's second
beat.** `[Authorize]` on the reference resolver itself compiles, compiles
without a warning, and produces no directive at all. Hot Chocolate's
authorization is field middleware and needs a field to attach to;
`[GraphQLIgnore]` is what keeps a reference resolver from being published as a
field, which chapter 6 needed and which is still right. A method that is not a
field has no descriptor. The exported schema carries no `@authorize` anywhere,
while `AddAuthorization()` still adds its `ApplyPolicy` enum, so the state
reads as configured.

**What works is guarding the data: the type, or the field.** Both cover all
three doors. This book guards the field, because guarding the type would take
`name` and `bio` with it and break every request chapters 9 to 11 print.

**A field guard is not a fetch guard, and the count says so.** With the guard
on `Speaker.email`, a refused request still costs **one statement** in the
Speakers service: the reference resolver runs, the row is read, and the column
is withheld on the way out. Guarding the whole type refuses before the
resolver runs and costs **none**. That is a real lever and the wrong one here.

**The router's directive is a filter, not a gate.** `[Authenticated]` composes
into one `authorizationConfiguration` on `Speaker.email` and the router
enforces it. Measured with the subgraph guard removed: an unauthenticated
request is refused at the router and **still costs one statement** in
Speakers, because the entity fetch went out, the row was read, and the router
discarded the value. Cosmo documents this. Its opt-in
`enable_pre_fetch_field_authorization` did **not** change it here, and why was
not established.

**One negative on sourcing.** No bylined engineer publishes the
`_entities`-specific claim. Two clear the bar for the general one. Under
decision 38 the mechanism in this chapter is stated as my judgment.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| `HotChocolate.AspNetCore.Authorization` | 16.6.1, **new to the book in this chapter** |
| `Microsoft.AspNetCore.Authentication.JwtBearer` | 10.0.11, new to the book in this chapter |
| `wgc` (Cosmo CLI) | 0.129.9, `@wundergraph/composition` 0.63.3 |
| Cosmo Router | 0.341.0, the released Windows binary |
| Gate | `pwsh verify.ps1`, run on each tag below. All PASS 2026-08-25 |

| Tag | Branch | What it is | Assertions |
|-----|--------|-----------|------------|
| `ch12` | `main` | the guard on the field, the router validating and forwarding | 389 |
| `ch12-rootguard` | `ch12-rootguard` | `[Authorize]` on `Query.speakers` and nothing else (decision 51) | 20 |
| `ch12-inertguard` | `ch12-inertguard` | `[Authorize]` on the reference resolver, emitting nothing (decision 51) | 13 |
| `ch12-routeronly` | `ch12-routeronly` | `[Authenticated]` and no `[Authorize]`: the router filters after the fetch (decision 51) | 17 |
| `ch12-noforward` | `ch12-noforward` | `main`'s C# with the router's `headers` block removed (decision 51) | 17 |
| `ch12-hc14` | `hc14` | an unchanged tree; every new assertion sits behind `EmailGuarded` | 214 |

**Ports**, unchanged: Sessions 5001, Speakers 5002, Ratings 5003, router 3002.

**Seed**, changed by this chapter. `Speaker` gains a fourth column, `Email`,
seeded `ada@example.test`, `bruno@example.test`, `chidi@example.test` for
speakers 1, 2 and 3. Nothing else about the seed moved, so decision 101's
dependency on speakers 1, 1, 2, 3 in schedule order is untouched and chapter
11's demonstration still demonstrates.

**The token.** HS256 over a fixed development secret,
`splitting-the-graph-development-signing-key-32b`, with `kid` `dev` and fixed
`iat`/`exp` so a run is reproducible. `verify.ps1` mints it with `New-Token`,
and the same secret is in the service's `SigningKey.cs` and the router's
`config.yaml`. That duplication is real and the chapter says so: there is no
shared file between a C# service and a YAML config.

## What was measured

### The three doors, on `ch12-rootguard`

`[Authorize]` on `Query.GetSpeakers`. Requests to `http://localhost:5002/graphql`
carrying no `Authorization` header at all.

The root field, refused before the resolver runs, at **0 statements**:

```json
{"errors":[{"message":"The current user is not authorized to access this resource.","path":["speakers"],"extensions":{"code":"AUTH_NOT_AUTHENTICATED"}}],"data":{"speakers":null}}
```

The entity route, answering in full, at **1 statement**:

```json
{"data":{"_entities":[{"id":"U3BlYWtlcjox","name":"Ada Fischer","email":"ada@example.test"}]}}
```

Three representations, the whole table, still one statement:

```json
{"data":{"_entities":[{"id":"U3BlYWtlcjoz","name":"Chidi Okafor","email":"chidi@example.test"},{"id":"U3BlYWtlcjox","name":"Ada Fischer","email":"ada@example.test"},{"id":"U3BlYWtlcjoy","name":"Bruno Kaminski","email":"bruno@example.test"}]}}
```

`node(id:)`, the third door:

```json
{"data":{"node":{"name":"Ada Fischer","email":"ada@example.test"}}}
```

And the map, free to anybody:

```json
{"data":{"__type":{"fields":[{"name":"node"},{"name":"nodes"},{"name":"speakers"},{"name":"_service"},{"name":"_entities"}]}}}
```

```json
{"data":{"__type":{"kind":"UNION","possibleTypes":[{"name":"Speaker"}]}}}
```

Asserted as a negative on the same branch: the exported document carries no
`@authenticated`. `[Authorize]` is Hot Chocolate's own directive and declares
nothing to the supergraph, so a router in front of this service would have no
rule to enforce either.

### The inert placement, on `ch12-inertguard`

`[Authorize]` on `ResolveSpeakerReferenceAsync`, under the `[GraphQLIgnore]`
that has been on it since chapter 6.

- It compiles. `dotnet build` reports 0 warnings and 0 errors.
- The exported schema contains **zero** occurrences of `@authorize` and no
  `directive @authorize` definition. Counted with a regex over the file.
- The method is not published as a field: no `resolveSpeakerReference` in the
  document. `[GraphQLIgnore]` is working, and that is precisely why the guard
  is not.
- `AddAuthorization()` still writes `enum ApplyPolicy` into the schema, so the
  only visible trace of authorization guards nothing.
- A caller with a token and a caller with none get **byte-identical** answers,
  which is what separates a rule that ran and passed from no rule at all.

The mechanism, stated as a rule: Hot Chocolate's authorization is field
middleware. It attaches to a field descriptor. A reference resolver is not a
field, so there is no descriptor and the attribute is dropped without
complaint.

### The fix, on `main`

`[property: Authorize, Authenticated] string Email`. All three doors refuse
the column and every other field of the same type still answers.

```json
{"errors":[{"message":"The current user is not authorized to access this resource.","path":["_entities",0,"email"],"extensions":{"code":"AUTH_NOT_AUTHENTICATED"}}],"data":{"_entities":[null]}}
```

Note the shape of that `data`. `email` is `String!`, so refusing it takes the
whole entity down with it: the entry is `null`, not an object with a missing
field. Chapter 14 is what this is a small instance of.

The same request with a token:

```json
{"data":{"_entities":[{"id":"U3BlYWtlcjox","name":"Ada Fischer","email":"ada@example.test"}]}}
```

An unguarded field on the guarded type, no token, still answered:

```json
{"data":{"_entities":[{"id":"U3BlYWtlcjox","name":"Ada Fischer"}]}}
```

**The count.** The refused request costs **1 statement** in Speakers. The
reference resolver ran and the row was read; only the column was withheld.
Measured against the type-level alternative, where the same request costs
**0**, because the whole type is refused before any resolver runs. The book
takes the field guard and pays the statement, because the type guard would
take `name` and `bio` with it.

### The router, on `main`

`config.yaml` gains two blocks. Discovered by probing the router's own JSON
schema, which refuses an unknown property and names the offending path:

- `authentication.jwt.jwks[]` takes **either** `url` **or** the triple
  `secret`, `symmetric_algorithm`, `header_key_id`. The refusal that
  established this reads
  `at '/authentication/jwt/jwks/0': oneOf failed, none matched` followed by
  `missing property 'url'` and
  `missing properties 'secret', 'symmetric_algorithm', 'header_key_id'`.
  `authentication.providers`, which older material uses, is **not** a valid
  key at 0.341.0: `additional properties 'providers' not allowed`.
- `headers.all.request` with `op: propagate`, `named: Authorization`.

Cross-seam, no token. The subgraph refuses, and `Speaker.name` being `String!`
takes the whole speaker with it:

```json
{"errors":[{"message":"Failed to fetch from Subgraph 'speakers' at Path 'sessions.nodes.@.speaker'.","extensions":{"errors":[{"message":"The current user is not authorized to access this resource.","path":["sessions","nodes","@","speaker","email"],"extensions":{"code":"AUTH_NOT_AUTHENTICATED"}}],"serviceName":"speakers","statusCode":200}},{"message":"Cannot return null for non-nullable field 'Query.sessions.nodes.speaker.name'.","path":["sessions","nodes",0,"speaker","name"]}],"data":{"sessions":{"nodes":[{"title":"Schemas That Outlive Their Authors","speaker":null}]}}}
```

(Abbreviated here to one session and one relayed error; the run produces four
of each. The chapter prints the whole thing or a stated excerpt of it.)

The same seam asking only for the public name, no token, unaffected:

```json
{"data":{"sessions":{"nodes":[{"title":"Schemas That Outlive Their Authors","speaker":{"name":"Ada Fischer"}}]}}}
```

With a token, complete. And a token the router cannot verify is the one place
in this book the router answers something other than 200:

```
HTTP 401
{"errors":[{"message":"unauthorized"}]}
```

### The router's directive alone, on `ch12-routeronly`

`[Authenticated]` and no `[Authorize]`. The composer writes exactly one rule:

```json
{"typeName":"Speaker","fieldName":"email","authorizationConfiguration":{"requiresAuthentication":true}}
```

Put `[Authenticated]` on the **type** instead and the composer writes three,
on the fields that *return* the type rather than on the type itself:
`Session.speaker`, `SpeakersConnection.nodes` and `SpeakersEdge.node`. Worth
recording because the shape of the compiled output does not match the shape of
the source annotation, and a reader looking for their type in that file will
not find it.

Unauthenticated, through the router:

```json
{"errors":[{"message":"Unauthorized to load field 'Query.sessions.nodes.speaker.email', Reason: not authenticated.","path":["sessions","nodes",0,"speaker","email"],"extensions":{"code":"UNAUTHORIZED_FIELD_OR_TYPE"}}],"data":{"sessions":{"nodes":[{"title":"Schemas That Outlive Their Authors","speaker":null}]}}}
```

No subgraph error is relayed, because no subgraph objected. And the Speakers
service issued **1 statement** answering it, the same one an authorized
request costs. The row was read and the value thrown away at the router.

Asked directly on port 5002, with a token or without one, the same service
hands the column over:

```json
{"data":{"_entities":[{"id":"U3BlYWtlcjox","name":"Ada Fischer","email":"ada@example.test"}]}}
```

### The missing forward, on `ch12-noforward`

`main`'s C#, `config.yaml` without the `headers` block. A caller whose token
the router verified is refused by the subgraph as unauthenticated, and an
anonymous caller is refused **identically** - byte-identical `data`, the same
first error message. Nothing in the response suggests a header rather than a
policy.

Within a failing request the damage is wider than the column: `Speaker.name`
is `String!`, so the whole entity goes and the non-null error reports once per
session, four times over four sessions, while all four titles arrive.

Across requests it is narrower than I first wrote, and the run corrected me.
The refusal follows the guarded column and not the seam. Ask the same seam for
a speaker's public `name` and the entity fetch never selects `email`, so
nothing objects and the answer is complete. Only a request that reaches for
the guarded field fails. That is why a missing `headers` block survives a
smoke test.

## What the audit changed

A cold read found nine things and seven of them were real. Recorded here
because two are corrections to what this note said before it.

- **Two responses were printed abridged and not marked as excerpts.** This
  note itself said "the chapter prints the whole thing or a stated excerpt of
  it" and the chapter printed neither. Both now print in full: four sessions,
  four non-null errors, and three relayed subgraph refusals rather than one.
  The three-against-four is worth knowing rather than tidying: the subgraph
  counts distinct speakers because the router de-duplicates representations
  (decision 95), and the non-null errors count sessions.
- **Four files the chapter changes were never printed.** `Speakers.csproj`,
  `SigningKey.cs`, `Program.cs` and `SpeakerData.cs`. A reader typing the
  system out of the book had no packages, no key, no authentication wiring and
  no seeded addresses, which is decision 15 and the first of the three
  failures the Status section says this book exists to fix. All four are now
  printed in full.
- **No printed request carried a token**, so the authorized half of every
  measurement was unreproducible. The chapter now prints one raw HTTP request
  with the bearer token on it, and `verify.ps1` asserts that `New-Token`
  produces exactly the string on the page.
- **An ordering claim was never measured.** `config.yaml` and this chapter
  said a token with no `kid` is rejected *before* the signature is checked.
  What was measured is that the router's config schema requires
  `header_key_id`; the order cannot be observed from outside the process. The
  claim is gone from the config comment, from `New-Token`'s comment and from
  the prose. **The four branch scripts were generated from `main`'s helper
  block before that fix and still carry the earlier wording in `New-Token`.**
  Recorded rather than silently left: they are internal, the book prints none
  of them, and re-running four gates to correct a comment was not worth it.
- **Two error paths and the `ApplyPolicy` enum were quoted without being
  asserted.** `verify.ps1` now asserts the path out of `node(id:)` and out of
  the root field, and the eight lines of the enum.
- **The summary box claimed more than the measurement.** It said both gateways
  authorize after the subgraph answers. That was measured for Cosmo; for
  Apollo it is one documentation sentence about a router this book does not
  run. The box now says which is which.
- **Rejected, with the evidence.** The audit read `highlightlines={10-16}` on
  the first `Speaker.cs` listing as marking three unchanged lines. It does
  not: chapter 9 printed that record as a single line,
  `public sealed record Speaker(int Id, string Name, string? Bio);`, so every
  line of the five-line form is new on the page. Checked at
  `chapters/09-the-second-and-third-subgraph/02-the-service-that-owns-the-speakers.tex`.
- **Rejected, with the evidence.** The audit flagged the router introspection
  capture in section 3 as untraced. It is chapter 8's claim re-shown rather
  than a chapter 12 measurement, and `verify.ps1` asserts the relation it
  rests on, that `_entities` and `_service` are the two fields the router
  hides. Left as it is.

## Checked and found false

Recorded so that a later chapter does not re-derive them.

- **That `[Authorize]` does not work on the entity route at all in 16.6.1.**
  This is what ChilliCream issue 6546 reports, and it is true only of the
  placement the issue tried. On the type and on the field the guard runs and
  the entity route is refused. The book ships the field.
- **That the composer would reject `@authorize` the way it rejected `@cost`
  (decision 73).** It does not. `wgc router compose` exits 0 with Hot
  Chocolate's `@authorize` and its `ApplyPolicy` enum in the document, and
  carries both into the supergraph.
- **That `enable_pre_fetch_field_authorization: true` stops the subgraph
  fetch.** The Cosmo documentation's wording implies it. Measured on 0.341.0
  with the subgraph guard removed, it did not: the statement count was 1 with
  the flag off and 1 with it on. It is not inert - turning it on added a
  `UNAUTHORIZED_FIELD_OR_TYPE` error to a request that previously carried only
  a relayed subgraph failure - but it did not prevent the read. Why was not
  established and no chapter claims anything about the flag.
- **That the attribute is named `ApolloAuthenticated`.** A search-engine
  summary said so. The types in `HotChocolate.ApolloFederation` 16.6.1 are
  `AuthenticatedAttribute`, `RequiresScopesAttribute` and `PolicyAttribute`,
  read out of the shipped assembly.
- **That removing the router's `headers` block breaks every cross-seam
  field.** It breaks every request that names a guarded field. A cross-seam
  request that does not name one is unaffected. The first draft of
  `ch12-noforward`'s script asserted the wrong thing and the run failed it.
- **That guarding the field costs nothing.** It costs the row. Only guarding
  the type refuses before the resolver runs.

## Sources

| Claim | Source | Byline | Accessed |
|---|---|---|---|
| Only the router should query subgraphs directly, and `Query._entities` is why | Apollo, *Graph Security*, `apollographql.com/docs/graphos/platform/security/overview` | unsigned; passes as the specification's publisher describing its own artifact (decision 39) | 2026-08-25 |
| The subgraph specification never uses the words authorization or authentication | Apollo, *Federation Subgraph Specification*, `apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec` | unsigned, same basis | 2026-08-25 |
| `@authenticated` and `@requiresScopes` arrive in Federation v2.5, `@policy` in v2.6 | Apollo, *Federation version support* | unsigned, same basis | 2026-08-25 |
| The router fetches a protected `@key` field and declines to return it | Apollo, *Authorization in the GraphOS Router* | unsigned, same basis | 2026-08-25 |
| Fields protected by `@authenticated` are authorized after the subgraph fetch and filtered out of the response | WunderGraph Cosmo, *Authentication and Authorization* | unsigned, same basis | 2026-08-25 |
| By default no headers are forwarded to subgraphs | WunderGraph Cosmo, *Subgraph Request Header Operations* | unsigned, same basis | 2026-08-25 |
| Subgraphs should only be accessible from the router | Apollo blog, *Securing Apollo Federation Subgraphs* | **David Walter**, named | 2026-08-25 |
| Authorization must be enforced locally within each subgraph; attackers could bypass by hitting subgraph endpoints directly | Grafbase blog, *Security considerations in GraphQL Federation* | **Tom Houl\'e**, named, Lead Software Engineer at Grafbase | 2026-08-25 |
| The reference resolver is not a field, so field middleware does not reach it | ChilliCream issue 6546 comment thread | **darren-clark**, a user rather than a ChilliCream engineer; used as corroboration of a mechanism measured here, not as authority | 2026-08-25 |

**The quotable Apollo sentence**, verbatim: \enquote{If this field is exposed
publicly, any client can circumvent internal resolver logic and fetch any
entity data by mimicking the router.} And beside it: \enquote{As a best
practice for supergraphs, only the router should query individual subgraphs
directly.}

**Barred.** An InstaTunnel blog post carries the single most quotable sentence
found for this chapter's thesis, naming `_entities` directly as an
unauthenticated data access mechanism. It is bylined \enquote{InstaTunnel
Team}, a company name rather than a person, so it fails the Sources rule and
nothing from it is used. Recorded so a later session does not rediscover it
and mistake it for citable.

**Decision 38 applies.** Two sources clear the bar for the general claim that
a subgraph must enforce its own authorization. **None** clears it for the
`_entities`-specific mechanism. The chapter states that mechanism as my
judgment, citing the specification for what the route is and the measurements
above for what it does.

### ChilliCream issue 6546, in full enough to be fair

*Support authorization on Apollo Federation `_entities` query*, opened
2023-09-20 by `jeffclary`, **still open** on 2026-08-25, 13 comments. Read
with `gh issue view 6546 --repo ChilliCream/graphql-platform --comments`.

- `darren-clark`, 2023-10-11, on the mechanism: \enquote{no field resolver
  level extensions function for entities, which kind of makes some sense since
  the resolver itself is not a field (the field is `_entities`)}. That matches
  what was measured here exactly.
- **Michael Staib**, ChilliCream's founder and a named engineer at the company
  being described, 2023-11-17: \enquote{We will have a look at this next
  week.. I will include it in the next patch release.} On 2023-12-16 he linked
  pull request 6769.
- **Pull request 6769 was closed without being merged.** Checked with
  `gh pr view 6769`: title *WIP: Apollo Federation V2 merge*, author
  `AntonC9018`, state CLOSED, `mergedAt` null. So the fix that comment pointed
  at never landed, which is consistent with the placement still being inert on
  16.6.1.

That last point needs care in prose. A three-year-old statement of intent is
not a claim about today, and quoting it as though it were would be unfair to a
named person. What the chapter may say is what is checkable: the issue is
open, the linked pull request was closed unmerged, and the behaviour still
holds for that placement. It does not hold for the type or the field, which
the issue never tried.

### Advisories

Checked and empty. `gh api repos/wundergraph/cosmo/security-advisories`
returns `[]`, so there are no published security advisories for the Cosmo
repository. Recorded as a checked negative rather than an unchecked absence.

Two real CVEs exist in the neighbourhood and **neither applies to this book's
composer**: CVE-2025-64530 and CVE-2025-64172, both published 2025-11-13,
both in `@apollo/composition`. The second is about access-control directives
not propagating across `@requires`, which is close enough in shape to be worth
knowing. This book composes with `@wundergraph/composition` 0.63.3, a
different implementation, and whether it has the same class of defect was not
established. No chapter claims anything about either.

## Not established

Carried into the SPEC's open items.

- **Why `enable_pre_fetch_field_authorization` did not stop the fetch.** The
  flag exists at 0.341.0, defaults false, is accepted by the config schema,
  and changed the error set without changing the statement count.
- **Whether `@requiresScopes` and `@policy` behave the same way.** Only
  `@authenticated` was exercised. `RequiresScopesAttribute` and
  `PolicyAttribute` are in the assembly and neither was applied to anything.
- **Whether the two node id serializers, the `@authorize` directive and a
  non-default `NodeIdSerializerFormat` interact.** Not touched; unchanged from
  chapter 9's open item.
- **What the `hc14` branch would do with any of this.** The Speakers service
  does not exist there (decision 91), so nothing was built or measured.
- **Whether `ApplyPolicy` can be kept out of the supergraph.** It arrives
  because `AddAuthorization()` registers the directive, and the composer
  carries it up. Whether `@inaccessible` or a type interceptor could hide it
  from clients was not tried.
