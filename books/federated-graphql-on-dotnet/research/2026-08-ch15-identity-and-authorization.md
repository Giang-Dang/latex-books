# Chapter 15 - Identity and Authorization Across the Graph

Research for "Identity and Authorization Across the Graph". Tags: `[web]` a
primary source on the web, `[docs]` vendor documentation, `[source]` read out of
a cloned source tree at a release tag, `[measured]` run on this machine.

Decision 32 applies throughout: an internals claim is read out of the source at
a tag, not out of a documentation page.

## Contents

- A. Version baseline
- B. What the graph had, which was nothing
- C. Two families of attribute, and only one of them enforces anything
- D. What the composer does with the federation pair
- E. `@authorize` is dropped and its enum is not
- F. `@policy` composes and enforces nothing
- G. A token at the router
- H. The claim that reaches a subgraph
- I. Pre-fetch field authorization, counted
  - I1. What the setting does not do, measured 2026-08-12
- J. Ownership, and the field that returns anything
- K. A subscription has no identity
  - K1. What the block changes, measured 2026-08-12
- L. The request pipeline gains two middleware
- M. What chapter 15 changed in Mosaic
- N. What the gate asserts
- O. Reproduction recipes
- P. Left unmeasured, and who owns it
- Q. Bibliography keys

## A. Version baseline

Unchanged from chapter 14 except for the two additions.

| Component | Version |
|-----------|---------|
| HotChocolate / HotChocolate.ApolloFederation | 16.6.0, tag `16.6.0`, commit `8fea46e`, cloned at F:/repo/graphql-platform |
| HotChocolate.AspNetCore.Authorization | 16.6.0, added at `ch15` |
| Microsoft.AspNetCore.Authentication.JwtBearer | 10.0.10, added at `ch15`, same band as the EF pin |
| WunderGraph Cosmo Router | 0.337.1, image `ghcr.io/wundergraph/cosmo/router:0.337.1` |
| wgc (Cosmo CLI) | 0.129.7, bundling `@wundergraph/composition` 0.63.2 |
| Apollo Federation specification | v2.15. Apollo's directive reference defines all three of `@authenticated`, `@requiresScopes` and `@policy` and does not state which version introduced each, so this chapter does not either. The v2.5 and v2.6 numbers below are HotChocolate's `[Package(...)]` gates, which is a fact about the library rather than about the specification |
| .NET | 10 (LTS) |

Machine for every `[measured]` line: Windows 11, .NET SDK 10.0.302, PostgreSQL
18-alpine and NATS 2.12-alpine in Docker Desktop on the same box, seven
subgraphs built Release and started with `dotnet run --no-build`, router in a
container reaching the host through `host.docker.internal`.

## B. What the graph had, which was nothing

`[measured]` At tag `ch14`, grepped across the repository: no
`HotChocolate.AspNetCore.Authorization`, no `Microsoft.AspNetCore.Authentication.*`,
no `Microsoft.IdentityModel.*` in `Directory.Packages.props` or in any `.csproj`
under `src/`. `MosaicSubgraphDefaults` references nothing authorization-shaped.
`router/config.yaml` has no `authentication` block and no `headers` block.

Two consequences worth naming, both true of the published graph at `ch14`:

- `Query.ordersByCustomer(customerId: ID!)` hands anybody anybody's order
  history.
- `Customer.email` is on the public storefront, reachable from any product page
  through `Review.author`.
- `Mutation.submitReview` takes `customerId` as an argument and believes it, so
  any client could post a review in any customer's name.

## C. Two families of attribute, and only one of them enforces anything

`[source]` Read at tag `16.6.0`, commit `8fea46e`.

`src/HotChocolate/ApolloFederation/src/ApolloFederation/Types/Directives/`
contains `AuthenticatedAttribute.cs`, `RequiresScopesAttribute.cs` and
`PolicyAttribute.cs`, with their directive types beside them. Version gates read
out of the `[Package(...)]` attributes: `@authenticated` and `@requiresScopes`
are `FederationVersionUrls.Federation25`, `@policy` is `Federation26`.
`FederationVersion.cs` gives `Default = Federation26`, so all three are
available with a bare `AddApolloFederation()`.

`RequiresScopesAttribute` is `public sealed class RequiresScopesAttribute(string[] scopes)`
with `AllowMultiple = true`; `RequiresScopesDescriptorExtensions.AddScopes`
appends one AND-set per application, so two attributes on one field produce an
OR of two AND-sets.

**The finding.** These three emit SDL and enforce nothing. The proof is
structural rather than a grep:
`src/HotChocolate/ApolloFederation/src/ApolloFederation/HotChocolate.ApolloFederation.csproj`
declares exactly one project reference,
`..\..\..\Core\src\Core\HotChocolate.Core.csproj`. `HotChocolate.Authorization`
is a different package, so there is no path from `[RequiresScopes]` to any
authorization handler. Grepping the whole `ApolloFederation` source tree for
`HotChocolate.Authorization`, `IAuthorizationHandler`, `AuthorizeDirective` and
`ApplyPolicy` returns nothing.

`[source]` The other family: `HotChocolate.Authorization.AuthorizeAttribute`
(`src/HotChocolate/Core/src/Authorization/AuthorizeAttribute.cs`) has four
constructors, `Policy`, `Roles` and `Apply` properties, and
`ApplyPolicy` is `BeforeResolver = 0`, `AfterResolver = 1`, `Validation = 2`.
There is no apply-to-descendants option anywhere in that directory.
`AuthorizeDirectiveType.cs` calls `.Internal()`, which sets
`Configuration.IsPublic = false`; `IsPublic` is consulted only when building the
introspection listings, not by the SDL printer, which is why `@authorize` is
invisible to `{ __schema { directives { name } } }` and fully visible in
`_service { sdl }`.

## D. What the composer does with the federation pair

`[measured]` `wgc` 0.129.7 against Mosaic's eight committed schemas.

The composed config gains `engineConfig.fieldConfigurations[].authorizationConfiguration`:

```json
{
  "typeName": "Query",
  "fieldName": "customerById",
  "authorizationConfiguration": {
    "requiresAuthentication": true,
    "requiredOrScopes": [{"requiredAndScopes": ["customers:read"]}]
  }
}
```

Four fields carry one at `ch15`: `Query.customerById`,
`Query.ordersByCustomer`, `Mutation.submitReview` and `Customer.email`.

**A scope implies a token.** `Query.customerById` and `Query.ordersByCustomer`
carry only `@requiresScopes` in their subgraph schemas, and the composer sets
`requiresAuthentication: true` on both anyway. Asserted as the
`a-scope-implies-a-token` case, which adds `@requiresScopes` to
`Query.productById` in Catalog, a field with no `@authenticated` anywhere near
it, and reads both members back.

**Both survive into the client-facing schema, retyped.** The subgraph publishes
`directive @requiresScopes(scopes: [[String!]!]!)`, because HotChocolate
declares a `Scope` scalar and then overrides the argument with
`[GraphQLType("[[String!]!]!")]` on `RequiresScopesDirective.Scopes`. The
composed client schema declares:

```
directive @requiresScopes(scopes: [[openfed__Scope!]!]!) on ENUM | FIELD_DEFINITION | INTERFACE | OBJECT | SCALAR
directive @authenticated on ENUM | FIELD_DEFINITION | INTERFACE | OBJECT | SCALAR
scalar openfed__Scope
```

Three spellings of one argument: Apollo's specification says
`federation__Scope`, HotChocolate emits `String`, the published graph says
`openfed__Scope`. The composer substitutes its own and declares the scalar, so
the document is self-consistent; nothing warns about the substitution.

`scalar openfed__Scope` joins `scalar FieldSet` as a type in Mosaic's published
schema that nobody chose to publish. Chapter 25's open item already carries the
first.

## E. `@authorize` is dropped and its enum is not

`[measured]` The committed `schema/accounts.graphql` at `ch15` carries:

```
type Query {
  customerById(id: ID!): Customer
    @authorize(policy: "CustomersRead")
    @requiresScopes(scopes: [["customers:read"]])
  ...
}

type Customer implements Node @key(fields: "id") {
  id: ID!
  displayName: String!
  email: String! @authenticated @authorize
}
```

and its full `directive @authorize(policy: String, roles: [String!], apply: ApplyPolicy! = BEFORE_RESOLVER) repeatable on OBJECT | FIELD_DEFINITION`
definition, plus the `ApplyPolicy` enum the argument refers to.

After composition the client-facing schema contains **no** `@authorize` - zero
occurrences of the string - and does contain:

```
"""Defines when a policy shall be executed."""
enum ApplyPolicy {
  """Before the resolver was executed."""
  BEFORE_RESOLVER
  """After the resolver was executed."""
  AFTER_RESOLVER
  """The policy is applied in the validation step before the execution."""
  VALIDATION
}
```

referenced by nothing. Anyone who introspects Mosaic's router is told about the
resolver execution phases of one subgraph's server library.

Asserted both ways as the `authorize-is-dropped-and-takes-nothing-with-it`
case: removing every `@authorize` usage and both definitions from the three
subgraphs that carry them produces an identical authorization table and a client
schema with no `ApplyPolicy` in it. That is how we know where the enum came
from.

## F. `@policy` composes and enforces nothing

`[measured]` Add `@policy(policies: [["stock:read"]])` to
`Product.availableQuantity` in Inventory, with the `@link` import and the
directive definition HotChocolate would print, and compose. wgc 0.129.7 exits 0
and prints only its success line. The composed config has **no**
`authorizationConfiguration` for `Product.availableQuantity` at all - not an
empty one, not a warning - and the client schema carries no `@policy`.

`[source]` The reason:
`@wundergraph/composition@0.63.2`'s
`composition/src/directive-definition-data/directive-definition-data.ts`
defines `AUTHENTICATED_DEFINITION_DATA` and `REQUIRES_SCOPES_DEFINITION_DATA`
and has no `@policy` entry of any kind. `router/core/authorizer.go` at tag
`router@0.337.1` enforces `@authenticated` and `@requiresScopes` and mentions no
policy.

So: a directive the Apollo specification defines at federation v2.6, which
HotChocolate ships an attribute for, is accepted by this composer and silently
discarded. This is chapter 14's `@defer` finding in a worse place, because
`@defer` only costs you a loading state.

Asserted as the `policy-composes-and-enforces-nothing` case.

## G. A token at the router

`[measured]` The symmetric branch of `authentication.jwt.jwks` requires
`header_key_id`. Without it the router will not start:

```
Could not load config: errors while loading config files: router config validation error for /etc/mosaic-router/config.yaml: jsonschema validation failed with 'https://raw.githubusercontent.com/wundergraph/cosmo/main/router/pkg/config/config.schema.json#'
- at '/authentication/jwt/jwks/0': oneOf failed, none matched
  - at '/authentication/jwt/jwks/0': validation failed
    - at '/authentication/jwt/jwks/0': missing property 'url'
    - at '/authentication/jwt/jwks/0': not failed
  - at '/authentication/jwt/jwks/0': missing property 'header_key_id'
```

The container exits 1. That is the sharp contrast with chapter 14's wgc
finding: the router's config loader validates against a JSON Schema with
`additionalProperties: false` and names the exact JSON pointer, where
`router compose` accepted a misspelled key and shrugged.

`[measured]` The key id is required to start and is **not** required of a token.
A token minted with no `kid` header (`node scripts/mint-token.mjs --no-kid`) is
accepted by the router and answers `{"data":{"customerById":{"displayName":"Lars Andersen"}}}`.

`[measured]` Nothing is logged. Started with the `authentication` block, the
router's startup output is byte-comparable to a run without it: grepping the
whole log for `auth`, `jwt` and `jwk`, case-insensitively, matches nothing. The
only ways to tell are behavioural - a bad token gets 401, a good one gets an
`X-Authenticated-By: jwks` response header.

`[measured]` An expired token, over HTTP:

```
HTTP/1.1 401 Unauthorized
{"errors":[{"message":"unauthorized"}]}
```

`ClockSkew = TimeSpan.Zero` in `MosaicSecurityDefaults` is what makes a
one-second token expire in one second rather than in five minutes.

## H. The claim that reaches a subgraph

Chapter 7 measured that the router forwards no client header. The smallest
change is:

```yaml
headers:
  all:
    request:
      - op: propagate
        named: Authorization
```

`[measured]` With a recording proxy on 5104 and Accounts moved to 5114, the
request the router makes on a subscription's entity fetch carries the token
correctly formed:

```
POST /graphql
authorization: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im1vc2FpYy1kZXYifQ..."
body: {"variables":{"representations":[{"__typename":"Customer","id":"Q3VzdG9tZXI6AAAAwAAAAECAAAAAAAAADg=="}]},"query":"query($representations: [_Any!]!){_entities(re
```

`[docs]` The block has exactly two operations, `propagate` and `set`. Confirmed
twice: the documentation page lists only those two, and `router/pkg/config/config.go`
at tag `router@0.337.1` declares `HeaderRuleOperationPropagate` and
`HeaderRuleOperationSet` and no others. There is no remove.

`[docs]` WunderGraph documents the other arrangement - do not forward the token,
`set` a header derived from a claim with
`expression: "request.auth.isAuthenticated ? request.auth.claims.sub : ''"`.
Mosaic forwards the token instead, because all seven services listen on a host
port and a header a subgraph trusts is a header anybody can send it.

`[measured]` **On a probe, not on Mosaic.** One `headers.all.request` propagate
rule moves a header on an ordinary HTTP subgraph fetch and on the WebSocket
upgrade the router makes for a subscription; there is no separate
WebSocket-specific header block for it. Measured with a purpose-built
single-subgraph service that echoes the headers it received, composed with wgc
0.129.7 and put behind a router on a spare port, asked once over HTTP and once
over a `graphql-transport-ws` connection whose upgrade request carried
`X-Test-Header`. Both arrived. Mosaic cannot show this, because by the end of
this chapter no subscription it serves carries a token at all, so the chapter
says the measurement was made on a probe.

## I. Pre-fetch field authorization, counted

`[measured]` `authorization.enable_pre_fetch_field_authorization`, default
false. An anonymous request for `Query.customerById`, counted as
`Mosaic.RequestTimeline` lines in the Accounts console either side:

| setting | Accounts requests | what the client gets |
|---|---|---|
| off (the default) | 1 | the router's refusal **and** the subgraph's, nested under `serviceName: accounts` |
| on | 0 | the router's refusal alone |

Off, the response carries both layers:

```json
{"errors":[{"message":"Failed to fetch from Subgraph 'accounts'.","extensions":{"errors":[{"message":"The current user is not authorized to access this resource.","path":["customerById"],"extensions":{"code":"AUTH_NOT_AUTHENTICATED"}}],"serviceName":"accounts","statusCode":200}},{"message":"Unauthorized to load field 'Query.customerById', Reason: not authenticated.","path":["customerById"],"extensions":{"code":"UNAUTHORIZED_FIELD_OR_TYPE"}}],"data":{"customerById":null}}
```

On:

```json
{"errors":[{"message":"Unauthorized to load field 'Query.customerById', Reason: not authenticated.","path":["customerById"],"extensions":{"code":"UNAUTHORIZED_FIELD_OR_TYPE"}}],"data":{"customerById":null}}
```

Mosaic turns it on. The saving is not the round trip; it is that data a caller
may not see stops being loaded into a process on their behalf.

Both rows are gated, and they had to be gated differently because they are
visible in different places. The `on` row is a count and is a step of both
verification scripts, which read the Accounts console either side of one refused
request and require the delta to be zero. The `off` row cannot be counted from a
gate without reconfiguring and restarting the router mid-run, so it is asserted
on the response instead: `pre-fetch-authorization-skips-the-fetch` in
`scripts/router-cases.mjs` starts two routers differing only in that setting and
requires the nested `serviceName: accounts` refusal, carrying HotChocolate's own
`AUTH_NOT_AUTHENTICATED` code, to be present in one reply and absent from the
other. The code rather than the service name, because a subgraph that is simply
down also produces an error naming accounts.

`[measured]` A token missing the scope gets the scope named back:

```json
{"errors":[{"message":"Unauthorized to load field 'Query.customerById', Reason: missing required scopes.","path":["customerById"],"extensions":{"code":"UNAUTHORIZED_FIELD_OR_TYPE"}}],"data":{"customerById":null},"extensions":{"authorization":{"missingScopes":[{"coordinate":{"typeName":"Query","fieldName":"customerById"},"required":[["customers:read"]]}],"actualScopes":["reviews:write"]}}}
```

### I1. What the setting does not do, measured 2026-08-12

The table above is a **root field** being refused, and a root field is a whole
fetch. Re-measured against a guarded field hanging off an entity the caller is
also entitled to read, and the setting does much less:

`[measured]` Anonymous, through the router, counting `Mosaic.RequestTimeline`
lines in the Accounts container either side of each request. The path is
`browseProducts -> reviews -> author`, so reaching `Customer` is an entity fetch
from Reviews to Accounts:

| selection on `author` | pre-fetch on | pre-fetch off | who refused, on |
|---|---|---|---|
| `email` | 0 | 1 | the router |
| `id email` | 0 | not run | the router |
| `displayName email` | **1** | 1 | **Accounts** |
| `displayName` (control) | 1 | 1 | nobody, the field is public |
| `customerById { email }` (root field) | 0 | 1 | the router |

The `pre-fetch off` column is the control, added 2026-08-12 after an audit
pointed out that every entity-level run had been made with the setting on, so
attributing the zero to the setting was inference rather than measurement. It is
not: with the setting off every selection costs Accounts one request, including
the guarded field on its own, and the router still refuses that field after the
fetch. Turning the setting on buys back exactly one of the three. Measured by
editing `router/config.yaml`, `docker compose up -d --force-recreate
mosaic-router`, running the same four requests, and putting the file back.

`[measured]` The same pair inside a subscription on `onReviewAdded`, on the
shipped configuration only: `author { email }` costs Accounts 0 and the router
refuses; `author { displayName email }` costs 1 and Accounts refuses. The
subscriptions were **not** re-run with the setting off, so the control column
above is an HTTP measurement and nothing here claims otherwise.

The capture behind the chapter's control listing, `author { email }` inside a
subscription on the shipped configuration:

```json
{"errors":[{"message":"Unauthorized to load field 'Subscription.onReviewAdded.author.email', Reason: not authenticated.","path":["onReviewAdded","author","email"],"extensions":{"code":"UNAUTHORIZED_FIELD_OR_TYPE"}}],"data":{"onReviewAdded":{"id":"UmV2aWV3OojznwFCcah+j2s8Y2FXU5Q=","author":null}}}
```

So the rule is one rule, and it is not about the transport:
`enable_pre_fetch_field_authorization` removes a fetch it can remove
**entirely**, and does not prune a guarded field out of a fetch that has to
happen anyway for a permitted field on the same entity.

**What a count cannot show.** That a fetch happened, it shows. Why the router
kept it, it does not: whether the authorization check is applied per fetch node
or per field is a question about the planner, and under decision 32 that is read
out of the source at a tag rather than inferred from two data points. Not done
here; chapter 17 owns the router's planner and this belongs in its row. What is
not inference is that the guarded field travelled inside the kept fetch, because
Accounts' own error names the path down to `author.email` and a subgraph cannot
refuse a field nobody sent it.

The router's refusal, for the selections it can remove:

```
Unauthorized to load field
'Query.browseProducts.nodes.reviews.nodes.author.email',
Reason: not authenticated.
```

with `"code": "UNAUTHORIZED_FIELD_OR_TYPE"`. And the subgraph's, for the ones it
cannot, nested under the router's fetch error with `serviceName: accounts` and
`"code": "AUTH_NOT_AUTHENTICATED"`.

**This corrects section K.** That section originally read the subscription case
as a subscription property, on the strength of the payload contrast: the
subscription reply carried Accounts' refusal and the HTTP reply for
`Query.customerById` carried the router's. Both observations were real and the
inference from them was wrong, because the two requests differed in the
selection shape as well as the transport. Section K now states the general rule
and the control that establishes it.

**A dead end worth recording so nobody re-walks it.** An early probe of the
mixed selection inside a subscription showed *neither* refusal in the payload,
only the non-null violation on `displayName`, and reproduced three times.
Counting requests at Accounts settled it: Accounts is called and does refuse, in
every arrangement tried, with and without a preceding public subscription on the
same product. The payload's error list was the unreliable observation, not the
behaviour. This is the same lesson as the em dash in chapter 9's composition
note, one level up: read the thing that is definitionally the evidence, which
here is the subgraph's own request log, rather than the thing that reports on it.

**Gate status: gated, in two places.**

The three `pre-fetch on` rows the chapter prints are a step in both verification
scripts, `entity-level authorization`, sitting immediately after the root-field
step. It sends the three selections, reads the Accounts console either side of
each, and requires 1, 0 and 1 exactly, plus the refusal strings: the router's
coordinate on the guarded-alone row, `serviceName: accounts` and
`AUTH_NOT_AUTHENTICATED` with **no** `Unauthorized to load field` on the mixed
row, and the `author.displayName` non-null violation as the tell that the mixed
selection really was mixed. The control runs first, because a product with no
reviews would make every row count zero and the step would pass by measuring
nothing.

The counting lives in the verify scripts rather than in `scripts/auth-run.mjs`,
and an earlier draft of this note said the opposite. `auth-run.mjs` cannot do
it: it is handed three URLs and nothing else, imports no `node:fs`, and under
the gate the subgraphs are `dotnet run` children writing to a temp path only the
verify script knows. It never counted anything.

The `pre-fetch off` column needs two routers rather than two requests, so it is
a case: `guarded-field-beside-a-permitted-one` in `scripts/router-cases.mjs`,
the sixth. It starts two routers differing only in that setting and asserts that
the guarded field alone reaches Accounts on one and not the other, while the
mixed selection reaches it on both. It asserts on `AUTH_NOT_AUTHENTICATED`
rather than the service name alone, because a subgraph that is simply down also
produces an error naming accounts.

## J. Ownership, and the field that returns anything

`[measured]` Guarding `Query.ordersByCustomer` alone. Same token, same order,
one second apart:

```
### node() on another customer's order, before the reference resolver was guarded
{"data":{"node":{"__typename":"Order","id":"T3JkZXI6AAAA0AAAAECAAAAAAAAAAw==","total":{"amount":356.00,"currency":"EUR"},"placedAt":"2026-02-18T11:05:00Z"}}}

### and the query field beside it, same token, same order owner
{"errors":[{"message":"Failed to fetch from Subgraph 'ordering'.","extensions":{"errors":[{"message":"You may only read your own orders.","path":["ordersByCustomer"],"extensions":{"code":"AUTH_NOT_AUTHORIZED"}}],"serviceName":"ordering","statusCode":200}}],"data":null}
```

`Query.node` lives in `Mosaic.Nodes`, which decodes the identifier, returns a
two-line stub, and lets the router fetch the rest from Ordering through
`_entities` - a path that has never heard of `ordersByCustomer`.

`[measured]` A second leak, before `Mosaic.Nodes` was guarded: an **anonymous**
`node(id: <an order>) { id __typename }` answered with the identifier and the
type name, because both are carried by the argument and no subgraph was called
at all.

Both are closed at `ch15`, in two different places because neither could do the
other's job:

- `Mosaic.Nodes.Ordering.Types.OrderNode.ResolveOrder` returns null unless the
  caller is authenticated. It knows the type, because the type name is inside
  the identifier. It can never know whose order it is: no database, no
  `_entities`, and the record is two lines.
- `Mosaic.Ordering.Model.Order.ResolveReferenceAsync` returns null unless the
  caller is the customer on the row. Only this one has the row.

`[measured]` After both: a forbidden order and an order that does not exist
answer identically, so nothing can be enumerated.

```
### node() on a real order belonging to somebody else
{"errors":[{"message":"Cannot return null for non-nullable field 'Query.node.total'.","path":["node","total"]}],"data":{"node":null}}

### node() on an order that does not exist, same shape of request
{"errors":[{"message":"Cannot return null for non-nullable field 'Query.node.total'.","path":["node","total"]}],"data":{"node":null}}
```

`[measured]` Anonymous, after the Nodes guard: `{"data":{"node":null}}`.

## K. A subscription has no identity

Four measurements, in the order they were made, because the first conclusion was
wrong and the record of that matters. The fourth was added 2026-08-12 and
supersedes the reading the other three were written up under; section I1 has it.

**A WebSocket client cannot send a header.** The `WebSocket` constructor takes a
url and a subprotocol list, in browsers and in node. So the `headers` block of
section H, which moves the token so neatly on an HTTP fetch, is moving a header
a subscribing client cannot set.

**Cosmo's answer, and what it costs.** `websocket.authentication.from_initial_payload`
reads the token out of the `connection_init` payload.
`[source]` `router/pkg/authentication/initial_payload_authenticator.go` at tag
`router@0.337.1` requires the `Bearer` prefix (`headerValuePrefixes`, defaulting
to `Bearer`), and `router/core/websocket.go` line 431 writes the value verbatim
onto the subgraph request when `export_token` is on.

`[measured]` Turning that block on answers `401 unauthorized` to **every
anonymous HTTP request**, on a router whose `require_authentication` is false.
Isolated by adding and removing that block and nothing else:

```
anonymous, no websocket block:   HTTP 200 {"data":{"__typename":"Query"}}
anonymous, with websocket block: HTTP 401 {"errors":[{"message":"unauthorized"}]}
```

Committed as the `websocket-auth-closes-the-public-graph` case in
`scripts/router-cases.mjs`. Mosaic therefore does **not** ship the block; it is
in `router/config.yaml` as a comment with this measurement beside it.

**What was measured while it was on**, and cannot now be asserted by a gate,
because it only appears in a configuration that breaks the graph: the router
validated the token, exported it correctly to Accounts (the capture in section
H is from that run), and still refused an `@authenticated` field inside the
subscription payload as `not authenticated`, on every event, with a token valid
for an hour. A control with `enable_pre_fetch_field_authorization` off behaved
identically, so the setting is not the cause.

**What the shipped configuration does.** Every subscription Mosaic serves is
anonymous, and the interesting half is where the refusal comes from:

```json
{"errors":[{"message":"Failed to fetch from Subgraph 'accounts' at Path 'onReviewAdded.author'.","extensions":{"errors":[{"message":"The current user is not authorized to access this resource.","path":["onReviewAdded","author","email"],"extensions":{"code":"AUTH_NOT_AUTHENTICATED"}}],"serviceName":"accounts","statusCode":200}},{"message":"Cannot return null for non-nullable field 'Subscription.onReviewAdded.author.displayName'.","path":["onReviewAdded","author","displayName"]}],"data":{"onReviewAdded":{"id":"UmV2aWV3OvXwnwFsO+d5vD3awsWCD1M=","rating":4,"author":null}}}
```

`serviceName: accounts`, code `AUTH_NOT_AUTHENTICATED`, and **no**
`Unauthorized to load field` anywhere in it. The entity fetch went out and
Accounts refused it, so a graph that had declared `@authenticated` and trusted
the router to enforce it would have served that email to an anonymous
subscriber.

**The first reading of this was wrong, and section I1 has the correction.** It
said here that the router refuses the field itself over HTTP and does not inside
a subscription, which made this a subscription finding. It is not. The
subscription reply above and the HTTP reply it was compared against differed in
their selection sets as well as their transports, and the selection set is what
decides: the router refuses a guarded field when doing so lets it drop the whole
subgraph fetch, and stands aside when the fetch has to happen anyway for a
permitted field on the same entity. Measured both ways over both transports in
section I1, by counting requests at Accounts rather than by reading payloads.

`[measured]` The control on the same connection, same token, one field apart:

```
selection "displayName" -> {"data":{"onReviewAdded":{"id":"UmV2aWV3Ov3wnwHwcG17ipzLTBy6ZZs=","author":{"displayName":"Marta Ibanez"}}}}
selection "displayName email" -> {"errors":[{"message":"Unauthorized to load field 'Subscription.onReviewAdded.author.email', Reason: not authenticated.","path":["onReviewAdded","author","email"],"extensions":{"code":"UNAUTHORIZED_FIELD_OR_TYPE"}}],"data":{"onReviewAdded":{"id":"UmV2aWV3Ov3wnwFsh8twk5ieH8W2+Xo=","author":null}}}
```

**That control pair disagreed with section I1, and section K1 resolves it.** It
was captured with the websocket block on and its second line has the *router*
refusing `displayName email`, where section I1 has *Accounts* refusing the same
selection on the shipped configuration. Both are correct. The block changes the
answer, and K1 has the measurement.

### K1. What the block changes, measured 2026-08-12

Measured on a second router rather than by editing `router/config.yaml`: the
shipped stack kept 3002 and a container running that whole file plus the block
took 3102, so the two configurations were available in one sitting and nothing
in the repository was edited. The provoking `submitReview` went through 3002,
because Reviews publishes `onReviewAdded` to every subscribed router.

Counting `Mosaic.RequestTimeline` at Accounts either side of each event, with a
valid token in `connection_init`:

| subscription selection | config | Accounts | who refused |
|---|---|---|---|
| `author { email }` | shipped | 0 | the router |
| `author { email }` | plus the block | 0 | the router |
| `author { displayName email }` | shipped | 1 | Accounts |
| `author { displayName email }` | plus the block | **1** | **the router** |

Same counts, different layer on the last pair, twice each. What that combination
says is that the fetch went out either way, because `displayName` has to come
from somewhere, and that under the block it went out **without** the address in
it: the router pruned the guarded field out of a fetch it still made, then
discarded the whole customer anyway because `email` is `String!`. Under the
shipped configuration the address travels inside the fetch and Accounts refuses
it.

So the router is capable of the pruning that section I1 says it does not do. On
the configuration Mosaic runs, it does not do it.

`[measured]` The block-on payload for the mixed selection, which is why the
desk argument for "mislabelled" was wrong:

```json
{"errors":[{"message":"Unauthorized to load field 'Subscription.onReviewAdded.author.email', Reason: not authenticated.","path":["onReviewAdded","author","email"],"extensions":{"code":"UNAUTHORIZED_FIELD_OR_TYPE"}}],"data":{"onReviewAdded":{"id":"UmV2aWV3OmP0nwFQl/B6tTKlBIQBNNU=","author":null}}}
```

The desk argument was that this carries no `Cannot return null for non-nullable
field ... author.displayName`, where the shipped mixed capture does, so it must
really have been an `email`-only reply. The absence has a better explanation:
the fetch succeeded, so there was no subgraph error to attach, and the refused
non-null `email` nulled the `Customer` while `Review.author` being nullable
stopped the propagation there. Recorded because the inference was reasonable and
wrong, and only counting requests distinguished the two stories.

**Causation is not claimed, and the reason is itself a measurement.**
`[measured]` With the block on, a `connection_init` carrying no token is refused
outright:

```
[{"message":"invalid JWT token in initial payload: JWT token is not a string"}]
```

So there is no such thing as an anonymous subscription on that router. The two
configurations differ in the block **and** in whether the connection has any
identity, and no experiment available here varies one without the other. This is
a fourth consequence of the block, on top of closing anonymous HTTP.

Not gated, for the reason the chapter gives: reproducing any of it needs the
configuration that answers `401` to every anonymous request, and a gate that
requires a broken graph is not a gate.

**One nullability consequence, worth its own sentence.** Refusing one field on
an entity takes the whole entity out. `Customer.email` is `String!`, so a
refusal nulls it, which nulls the `Customer`, which leaves `author` null - and
`author.displayName` was requested and is non-null, so the client gets a
non-null violation naming a field it was perfectly entitled to. Decision 65's
rule about boundary nullability meets authorization here and the two interact.

## L. The request pipeline gains two middleware

`[measured]` Chapter 3 counted thirteen. A service that calls
`AddMosaicAuthorization()` assembles fifteen, and the two do not go on the end:

```
                       catalog / pricing / inventory / nodes     accounts / reviews / ordering
 1  InstrumentationMiddleware                                    InstrumentationMiddleware
 2  ExceptionMiddleware                                          ExceptionMiddleware
 3  TimeoutMiddleware                                            TimeoutMiddleware
 4  DocumentCacheMiddleware                                      DocumentCacheMiddleware
 5  DocumentParserMiddleware                                     DocumentParserMiddleware
 6  DocumentValidationMiddleware                                 HotChocolate.Authorization.Pipeline.PrepareAuthorization
 7  CostAnalyzerMiddleware                                       DocumentValidationMiddleware
 8  OperationCacheMiddleware                                     HotChocolate.Authorization.Pipeline.AuthorizeRequest
 9  OperationResolverMiddleware                                  CostAnalyzerMiddleware
10  SkipWarmupExecutionMiddleware                                OperationCacheMiddleware
11  OperationVariableCoercionMiddleware                          OperationResolverMiddleware
12  ConcurrencyGateMiddleware                                    SkipWarmupExecutionMiddleware
13  OperationExecutionMiddleware                                 OperationVariableCoercionMiddleware
14                                                               ConcurrencyGateMiddleware
15                                                               OperationExecutionMiddleware
```

One in front of validation and one behind it, which is what lets
`[Authorize(apply: ApplyPolicy.Validation)]` refuse a whole request before any
resolver runs. Chapter 3's thirteen is still correct for the service that
chapter measured.

`[measured]` The two apply modes, on a probe:

- `BeforeResolver` (the default): HTTP 200, the field's own error with a `path`,
  `data` null through non-null propagation, code `AUTH_NOT_AUTHENTICATED` for a
  caller with no token and `AUTH_NOT_AUTHORIZED` for one who is signed in and
  lacks the policy.
- `Validation`: HTTP 401, no `path`, and no `data` key at all.

## M. What chapter 15 changed in Mosaic

- `Directory.Packages.props`: `HotChocolate.AspNetCore.Authorization` and
  `Microsoft.AspNetCore.Authentication.JwtBearer` 10.0.10.
- `src/Mosaic.ServiceDefaults/Security/`: `MosaicTokens.cs` (issuer, audience,
  scope names, policy names) and `MosaicSecurityDefaults.cs`
  (`AddMosaicSecurity`, `AddMosaicAuthorization`, `UseMosaicSecurity`,
  `HasScope`, `SubjectOrNull`).
- Four of the seven services authenticate: Accounts, Reviews, Ordering and
  Nodes. Three of those four also authorize; Nodes does not, because every rule
  it could state is about a type rather than a row.
- `Customer.email` gains `[Authenticated]` and `[Authorize]`.
  `Query.customerById` gains `[RequiresScopes]` and `[Authorize(policy)]`.
  `Query.ordersByCustomer` gains both plus an ownership check.
  `Mutation.submitReview` gains `[Authenticated]`, `[Authorize(policy)]` and an
  ownership check.
- `Order.ResolveReferenceAsync` gains the instance check;
  `Mosaic.Nodes`'s `OrderNode.ResolveOrder` gains the type check.
- Two more copies of the key decode, in Ordering and Reviews, both reading a
  token's `sub` rather than a representation. Seventh and eighth in the
  repository.
- `router/config.yaml`: `authentication.jwt.jwks`, an `authorization` block with
  pre-fetch on, a `headers` block, and the commented `websocket` block with its
  measurement.
- `scripts/mint-token.mjs`, `scripts/auth-cases.mjs`, `scripts/auth-run.mjs`, a
  fourth case in `scripts/router-cases.mjs`, `postman/mosaic-auth`.
- `docker-compose.yml`: `MOSAIC_JWT_SECRET` on four services and the router.

## N. What the gate asserts

Both `verify.ps1` and `verify.sh`, in the same commit, per this book's rule.

- `scripts/auth-cases.mjs`: five composition cases.
- The pre-fetch count: an anonymous request for a guarded field costs Accounts
  zero requests.
- `scripts/auth-run.mjs`: fifteen runtime checks.
- The `entity-level authorization` step: the three selections section 15.6
  prints, counted at Accounts, requiring 1, 0 and 1 exactly along with which
  layer refused each.
- `scripts/router-cases.mjs`: three new cases, the websocket block closing the
  public graph, the pre-fetch setting deciding whether a refused root field is
  fetched first, and `guarded-field-beside-a-permitted-one` for the
  `pre-fetch off` column. Six in the file now, three of them chapter 10's.
- `postman/mosaic-auth`: the same field asked four ways.
- The pipeline assertion is now two exact lists rather than one, selected per
  subgraph.
- Three existing steps mint tokens: the Accounts `_entities` query selecting
  `email`, the walk over `ordersByCustomer`, and the `node(Order)` step.
- `scripts/subscription-run.mjs` mints a token per write.

Still not gated, and section K1 says why it cannot be: everything about the
websocket block, because reproducing any of it needs the configuration that
answers `401` to every anonymous request.

## O. Reproduction recipes

```
# the graph
docker compose up -d --wait mosaic-db mosaic-nats
dotnet build -c Release
#   then seven services, ASPNETCORE_URLS=http://localhost:510N,
#   MOSAIC_RESET_DATABASE=1, MOSAIC_JWT_SECRET=$(node scripts/mint-token.mjs --secret)
docker compose up -d mosaic-router

# a token
node scripts/mint-token.mjs --customer <customer global id>
node scripts/mint-token.mjs --customer <id> --scopes "reviews:write"
node scripts/mint-token.mjs --customer <id> --ttl 1        # G, the 401
node scripts/mint-token.mjs --no-kid --customer <id>       # G, accepted anyway

# D, E, F: composition
node scripts/auth-cases.mjs
node scripts/auth-cases.mjs --print baseline
node scripts/auth-cases.mjs --print policy-composes-and-enforces-nothing

# G: the router refusing to start
#   delete header_key_id from router/config.yaml, then
docker compose up -d --force-recreate mosaic-router && docker compose logs mosaic-router

# I, J, K: the running graph
node scripts/auth-run.mjs

# K: the block that closes the public graph
node scripts/router-cases.mjs --print websocket-auth-closes-the-public-graph

# I1: who refuses, and what it costs the subgraph.
#   Both gates run this as the `entity-level authorization` step, so the fastest
#   route is scripts/verify.ps1. By hand, count the Accounts request lines
#   either side of each request; the selection on `author` is the only thing
#   that changes between them.
#
#   Where those lines are depends on how Accounts was started, and the two
#   differ: under docker compose it is a container, and under either verify
#   script it is a `dotnet run` child writing to a temp file the script names.
docker logs mosaic-graph-mosaic-accounts-1 | grep -c Mosaic.RequestTimeline
#   { browseProducts(first:1){ nodes { reviews(first:1){ nodes {
#       author { email } } } } } }                      -> 0 requests, router refuses
#   { browseProducts(first:1){ nodes { reviews(first:1){ nodes {
#       author { displayName email } } } } } }          -> 1 request, Accounts refuses
#   and the same two selections under
#   `subscription { onReviewAdded(productId: "...") { id author { ... } } }`,
#   provoking one event per run with a review from a customer who has not
#   reviewed that product, give the same 0 and 1.

# I1, the other column, and K1's pair
node scripts/router-cases.mjs --print guarded-field-beside-a-permitted-one
#   K1 needs a second router rather than an edit to router/config.yaml: run the
#   shipped stack, then start one more container on 3102 with that whole file
#   plus the commented websocket block uncommented, mounting
#   federation/supergraph.json, passing the real MOSAIC_JWT_SECRET (a different
#   secret makes Accounts reject and looks like the other outcome), and
#   subscribe to 3102 while submitting the provoking review through 3002.

# H: the capture at the Accounts boundary
#   Accounts on 5114, a recording proxy on 5104, then any query selecting email.

# L: the pipeline
#   read the "Request pipeline: N middleware" line in any service's console.
```

Section J's before-and-after was produced by removing the ownership check from
`Order.ResolveReferenceAsync`, rebuilding Ordering alone, and asking for the
same order twice. The after state is what the gate asserts; the before state is
reproduced by deleting three lines.

## P. Left unmeasured, and who owns it

- **A real JWKS endpoint.** Only the symmetric branch was exercised. The url
  form is two lines in `router/config.yaml` and nothing else in the repository
  changes, but nothing here proves that. Chapter 21 owns the platform.
- **`authentication.jwt.jwks[].allowed_use`.** Present in the router's Go
  struct at `router@0.337.1` and in none of its documentation. Nobody knows what
  it gates. Chapter 21 or 25.
- **`authorization.require_authentication: true`**, and
  `reject_operation_if_unauthorized: true`. Both left at their defaults and
  written out; neither was run. Chapter 25 owns hardening and should take the
  second one, which changes a partial answer into no answer.
- **The claim-derived header arrangement.** WunderGraph's documented
  recommendation - `set` a header from `request.auth.claims.sub` rather than
  propagating the token - was read and not run, because Mosaic deliberately does
  the other thing. Chapter 21, where a deployment gets a network boundary.
- **`@authenticated` inside a subscription, once Cosmo fixes the block that
  closes the public graph.** The finding in section K's third measurement cannot
  be put in a gate today, because reproducing it needs a configuration that
  401s every anonymous request. When the first bug is fixed the second becomes
  assertable. Chapter 25, or here again at a later release.
- **Roles.** `[Authorize]` takes a `Roles` array and Mosaic uses policies only.
  Nothing was measured about how roles interact with the federation directives,
  which have no equivalent. Chapter 25.
- **A token that expires mid-subscription.** Unmeasurable here for the same
  reason as above: a subscription this graph serves has no token to expire. The
  source reading in `router/core/websocket.go` says validation happens once per
  connection and `HandleMessage` never re-authenticates, so the behaviour is
  predictable and it is not measured. Chapter 24 owns long-lived connections.
- **Introspection under authentication.** `authentication.ignore_introspection`
  exists and was not touched. Chapter 25.

## Q. Bibliography keys

- `cosmodocs2026auth` - WunderGraph, "Authentication and Authorization",
  cosmo-docs, urldate 2026-08-11. Vendor documentation, cited for the
  configuration surface and for the sentence about not forwarding
  authentication headers by default.
- `cosmodocs2026headers` - WunderGraph, "Subgraph Request Header Operations",
  cosmo-docs, urldate 2026-08-11. Cited for the claim-derived header pattern
  Mosaic does not use.
- `apollo2026authdirectives` - Apollo GraphQL, "Federated Schema Directives"
  / authorization reference, urldate 2026-08-11. Cited for the signatures of
  `@authenticated`, `@requiresScopes` and `@policy` and for the DNF semantics of
  the scopes argument.

Reused:

- `cosmodocs2026compose` - chapter 14's, cited again for the composer input.
