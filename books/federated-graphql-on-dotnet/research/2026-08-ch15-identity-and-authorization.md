# Chapter 15 research - identity and authorization across the graph

Research date: 2026-08-11. Every number and every listing in this file was
captured from a running graph, or read out of a primary source at a pinned
version. Internals claims about HotChocolate are read from
`ChilliCream/graphql-platform` at tag `16.6.0`, commit `8fea46e`; claims about
the router and the composer are read from `wundergraph/cosmo` at tag
`router@0.337.1`, commit `2f50ab88b985810645ceb8504e1bed0208d5d9f4`, and from
`@wundergraph/composition` 0.63.2 under `node_modules/` in the companion repo
(decision 32).

The chapter's companion code is `mosaic-graph` at tag `ch15`. What is new:
`src/Mosaic.ServiceDefaults/Auth/MosaicJwtDefaults.cs` and the two lines in
`UseMosaicServiceDefaults` that order the authentication pair; `[Authorize]` on
`Query.customerById` and `[RequiresScopes]` on `Customer.email`, which are the
two halves of this chapter's argument sitting in one service; an
`authentication`, an `authorization` and a `headers` block in
`router/config.yaml`; `scripts/mint-token.mjs`; and `scripts/auth-cases.mjs`.

## Contents

- A. Version baseline
- B. What the chapter inherited
- C. Two authorizations that do not know about each other
- D. What each one puts in the published schema
- E. What the composer does with all three directives
- F. Where authorization lands in the execution config
- G. A token the router will accept
- H. The four answers, measured
- I. The header nobody forwards
- J. The two toggles
- K. The zeroed type name
- L. What chapter 15 changed in Mosaic
- M. What the gates assert
- N. Reproduction recipes
- O. Left unmeasured, and who owns it
- P. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; unchanged since chapter 8 |
| HotChocolate.AspNetCore.Authorization | 16.6.0 | added this chapter, pinned to `$(HotChocolateVersion)` |
| Microsoft.AspNetCore.Authentication.JwtBearer | 10.0.10 | added this chapter |
| graphql-platform source | tag `16.6.0`, commit `8fea46e` | `git log --oneline -1` in the clone |
| WunderGraph Cosmo Router | 0.337.1 | the running process logs `"service_version": "0.337.1"` |
| cosmo source | tag `router@0.337.1`, commit `2f50ab8` | `git rev-parse HEAD` in the clone |
| wgc | 0.129.7 | `npx wgc --version` |
| @wundergraph/composition | 0.63.2 | `node_modules/@wundergraph/composition/package.json` |
| .NET SDK | 10.0.302 | `dotnet --version` against the repo's `global.json` |
| graphql-go-tools (router's engine) | v2.14.2 | `router -version` |

## B. What the chapter inherited

Three things, all of them recorded before this chapter started.

- **Nothing in Mosaic was authorised at all.** Owed since chapter 2, and named
  in chapter 15's Progress row.
- **Authorising `Query.node`**, from chapter 13's research note section Q: one
  field that can return anything in the graph is one field that has to be
  authorised for anything in the graph.
- **Two threads from chapter 14**: authorising a subscription, where a
  connection outlives the token that opened it; and `initialPayload`, which the
  router sends as `"extensions":{"initialPayload":{}}` in its `subscribe` frame
  and which chapter 14 recorded as the obvious route for a claim, empty there
  because nothing authenticated.

## C. Two authorizations that do not know about each other

This is the chapter's spine and it is a fact about HotChocolate 16.6.0 rather
than about federation.

`[Authorize]` comes from `HotChocolate.Authorization`, in the
`HotChocolate.AspNetCore.Authorization` package once ASP.NET Core is involved.
Its constructors and properties are in
`src/HotChocolate/Core/src/Authorization/AuthorizeAttribute.cs`: an empty
constructor, one taking a policy name, one taking a policy and an
`ApplyPolicy`, and one taking an `ApplyPolicy` alone; properties `Policy`,
`Roles` and `Apply`, the last defaulting to `ApplyPolicy.BeforeResolver`. It is
evaluated inside the process, by ASP.NET Core, against the principal that
process authenticated.

`[Authenticated]`, `[RequiresScopes]` and `[Policy]` come from
`HotChocolate.ApolloFederation`, in
`src/HotChocolate/ApolloFederation/src/ApolloFederation/Types/Directives/`.
They are `DescriptorAttribute`s whose entire effect is on the schema the
service publishes. Nothing in this process reads them.

Neither package references the other for this purpose. Searching the
authorization package for the federation directive names turns up only the
English word "authenticated" in `DefaultAuthorizationHandler.cs`. So a subgraph
author who writes `[Authorize]` gets enforcement here and no directive for a
router; one who writes `[RequiresScopes]` gets a directive for a router and no
enforcement here. **Nothing derives either from the other, and nothing warns
when only one is present.**

One detail worth having, because it is in no documentation:
`RequiresScopesAttribute` takes a flat `string[]` while the directive takes
`[[Scope!]!]!`. The attribute is declared `AllowMultiple = true`. So one
attribute is one AND-group and a second attribute beside it is the OR. Read
from `RequiresScopesAttribute.cs` lines 31-45.

## D. What each one puts in the published schema

Measured by exporting each subgraph's schema before and after the change:

```
dotnet run --project src/Mosaic.Accounts -c Release --no-build \
  --no-launch-profile -- schema export --output /tmp/accounts.graphql
diff schema/accounts.graphql /tmp/accounts.graphql
```

Four changes, and the second and fourth are the ones that matter.

1. The `@link` import list gained `"@requiresScopes"`. HotChocolate adds it
   itself; nothing in Mosaic asked for it.
2. `email: String!` became
   `email: String! @requiresScopes(scopes: [["read:pii"]])`, and the schema
   gained a `directive @requiresScopes(scopes: [[String!]!]!)` declaration.
   Note `String`, not `openfed__Scope`: the composer renames it later.
3. `customerById(id: ID!): Customer` became
   `customerById(id: ID!): Customer @authorize`, and the schema gained a
   `directive @authorize(policy: String, roles: [String!], apply: ApplyPolicy! = BEFORE_RESOLVER) repeatable on OBJECT | FIELD_DEFINITION`.
   **This corrects a claim I was given during research and half believed.**
   `AuthorizeDirectiveType.cs:26` does call `.Internal()`, and the reasonable
   conclusion is that the directive stays out of what the service publishes. It
   does not. `schema export` prints it, and `_service { sdl }` is what a
   composer reads.
4. **`enum ApplyPolicy` appeared in all seven schemas**, including the six that
   use no authorization attribute anywhere. It arrives with `.AddAuthorization()`
   in `AddMosaicSubgraph`, which every service calls. It is the enum type of
   `@authorize`'s `apply` argument, and it is now a type of Mosaic's graph.

## E. What the composer does with all three directives

`@authenticated` and `@requiresScopes` are the only two authorization
directives `@wundergraph/composition` 0.63.2 knows.
`node_modules/@wundergraph/composition/dist/utils/string-constants.js:192`:

```
exports.AUTHORIZATION_DIRECTIVES = new Set([exports.AUTHENTICATED, exports.REQUIRES_SCOPES]);
```

Measured against the real Mosaic schemas, by `scripts/auth-cases.mjs`:

- Both compose on a root field, on a field of an entity a non-owning subgraph
  contributes to, on an object type, and on an `extend type`.
- Both compose **whether or not the subgraph's `@link` imports them**. This is
  not general leniency: `@totallyMadeUpDirective` on the same field fails with
  `The directive "@totallyMadeUpDirective" declared on coordinates "Product.price" is not defined in the schema.`
  The composer registers the two unconditionally and consults no import list.
- `@policy` fails with `is not defined in the schema`, with or without an
  `@link` import naming it. HotChocolate ships `[Policy]` and emits the
  directive; this stack cannot compose it, and `authorizer.go` has no
  policy-evaluation path at all. **A reader must not be told `@policy` is an
  option here.**
- `@authorize` composes, and the composer **silently drops it**: it appears
  nowhere in the composed client schema and produces no message.
- `enum ApplyPolicy` does **not** get dropped. It reaches the composed client
  schema, so it is introspectable by every client of the graph. Same family as
  the `scalar FieldSet` note chapter 25 inherited: nobody's intent, visible to
  everyone.
- `scopes: []` and `scopes: [[]]` compose with no error and no warning, and the
  directive vanishes from the client schema entirely, as if never written. A
  typo removes the protection silently.
- A flat `scopes: ["read:pii"]`, one nesting level short, does not produce a
  validation error. It throws out of the composer with a raw Node stack inside
  the generic "please upgrade / open an issue" box:
  `TypeError: scopes.values is not iterable` at
  `NormalizationFactory.extractRequiredScopes`. Same class as chapter 13's
  entity-interface crash.
- Omitting the argument does give a proper message:
  `The definition for "@requiresScopes" defines the following 1 required argument: "scopes". However, no arguments are defined on this instance.`

## F. Where authorization lands in the execution config

Three places, and the first contradicts what chapter 9 established for
everything else.

Chapter 9's decision 56 found that a Cosmo execution config splits into a clean
client schema plus a routing table, carrying no `join__` directives at all.
That does not extend to these two. Composed against the baseline, the client
schema gained:

```
directive @requiresScopes(scopes: [[openfed__Scope!]!]!) on ENUM | FIELD_DEFINITION | INTERFACE | OBJECT | SCALAR

scalar openfed__Scope
```

and, on the field itself,
`email: String! @requiresScopes(scopes: [["read:pii"]])`. The scope type is
renamed from `String` to `openfed__Scope` on the way through.

The second place is the per-subgraph normalised SDL in `stringStorage`, content
addressed the way chapter 9 described.

The third is a structured block, `engineConfig.fieldConfigurations`, beside
`argumentsConfiguration` rather than inside the routing table:

```json
{
  "typeName": "Customer",
  "fieldName": "email",
  "authorizationConfiguration": {
    "requiresAuthentication": true,
    "requiredOrScopes": [ { "requiredAndScopes": [ "read:pii" ] } ],
    "requiredOrScopesByOr": [ { "requiredAndScopes": [ "read:pii" ] } ]
  }
}
```

**`requiredOrScopesByOr` is dead code.** When two subgraphs each attach
`@requiresScopes` with a different scope to one shared field, the two arrays
stop agreeing: `requiredOrScopes` becomes one AND-group holding both scopes,
and `requiredOrScopesByOr` becomes two OR-ed groups. They encode different
rules. `router/core/authorizer.go:256-262` reads `RequiredOrScopes` and nothing
else, and `grep -rn "RequiredOrScopesByOr" router/ --include=*.go` finds the
name only in the generated protobuf accessor. So the enforced rule is the
strict one, and the field whose name reads like the natural choice for an
"OR of ANDs" scheme is never consulted. Verified twice: by composing the case,
and by reading the router at the pinned tag.

## G. A token the router will accept

Two things cost real time here and neither is documented where it would help.

**The symmetric jwks entry needs three keys, not two.** The router validates
`config.yaml` against its own JSON schema, whose `jwks` items carry a `oneOf`:
the `url` branch forbids `secret`, `symmetric_algorithm` and `header_key_id`;
the secret branch **requires all three** and forbids `algorithms`,
`refresh_interval` and `refresh_unknown_kid`. Writing only `secret` and
`symmetric_algorithm` refuses to start:

```
- at '/authentication/jwt/jwks/0': oneOf failed, none matched
  - at '/authentication/jwt/jwks/0': validation failed
    - at '/authentication/jwt/jwks/0': missing property 'url'
    - at '/authentication/jwt/jwks/0': not failed
  - at '/authentication/jwt/jwks/0': missing property 'header_key_id'
```

`header_key_id` is the `kid` the router expects in the token's own header, so
`scripts/mint-token.mjs` writes `"kid": "mosaic-dev"` into the JOSE header.

**The router expands `$VAR` and `${VAR}`, not `{{.Env.VAR}}`.**
`pkg/config/config.go:1625` is `configYamlData := os.ExpandEnv(string(configFileBytes))`,
and Go's `os.ExpandEnv` knows the shell forms only. A `{{.Env.MOSAIC_JWT_SECRET}}`
is a perfectly good string as far as the file's schema is concerned, so the
router starts, takes the twenty-six literal characters as its signing key, and
answers `unauthorized` with HTTP 401 to every genuine token. Nothing in the log
names the cause. The one trace is a startup line from
`authentication/jwks_token_decoder.go:154`:

```
Using a short secret for JWKs may lead to weak security. Consider using a longer secret.
```

which is advice about key strength, fires only because that literal is under
the 32 characters the check uses, and would not appear at all had the template
string been longer. Confirmed the diagnosis rather than guessed it: signing a
token with the literal string `{{.Env.MOSAIC_JWT_SECRET}}` and sending it made
the graph answer. This is the same shape as chapter 14's decision 83, where
wgc's documented spelling of a key composes silently to the wrong thing.

The secret is used as raw bytes: `jwks_token_decoder.go` calls
`jwkset.NewJWKFromKey([]byte(c.Secret), jwkOptions)`, so an HMAC over the
UTF-8 of the string is what `mint-token.mjs` has to produce, and does.

## H. The four answers, measured

One query, four callers, against the running graph:

```
{ products { title reviews { edges { node { author { displayName email } } } } } }
```

| Caller | HTTP | Shape of the answer |
|---|---|---|
| No token | 200 | one error per protected field instance, `UNAUTHORIZED_FIELD_OR_TYPE`, reason `not authenticated`; `author` null, the rest of the response intact |
| Token with `read:pii` | 200 | nothing refused, `email` present |
| Token, no `scope` claim | 200 | same shape as anonymous, reason `missing required scopes` |
| Expired token | 401 | one error, `{"errors":[{"message":"unauthorized"}]}`, `data` absent |

The first error verbatim, anonymous:

```
Unauthorized to load field 'Query.products.reviews.edges.node.author.email', Reason: not authenticated.
```

and with a scopeless token, the same coordinate with
`Reason: missing required scopes.`

**"Nothing refused" is not "no errors", and the difference is a gate run.**
Measured on a freshly seeded database the scoped query answers with no errors
at all. Measured at the end of a full `verify` pass it answers with exactly
one, because step 7 of that pass submits a review against a customer key that
was never seeded, and a query that walks every author in the catalogue reaches
it. The author resolves to null and the response carries an error that no token
could have removed. Both gates therefore assert that no error carries
`UNAUTHORIZED_FIELD_OR_TYPE`, which is the fact the step exists to check, and
not that the response has no `errors` key. Decision 66 met the same trap from
the other side in chapter 12 and stopped a resolver count short of
`Product.reviews`; this is the same lesson, and the first draft of this chapter
walked straight into it because the reproduction recipe in section N starts the
graph and asks the four questions without ever running the collection that
plants the review.

Two things are worth pulling out of that table.

**A denied field takes its parent with it.** `email` is `String!`, so nulling
it propagates to `author`. `Review.author` is nullable - decision 70 made it so,
because a reference to an entity another subgraph owns may fail to resolve - and
that is where the null stops. Had chapter 12 argued the other way, one denied
`email` would have taken the whole response to `data: null`. Boundary
nullability turns out to be an authorization decision as well as a resolution
one, which is decision 65's rule arriving somewhere nobody aimed it.

**The expired token fails at a different door.** It is rejected before planning,
by `access_controller.go`, with an HTTP status and a lowercase message. The
other two are field decisions inside the response, with HTTP 200. A client that
treats "unauthorized" as one condition will get this wrong.

## I. The header nobody forwards

The sharpest measurement in the chapter, and the one that makes section C
concrete.

`Query.customerById` carries `[Authorize]`. Asked through the router by a
caller holding a valid token:

```json
{"errors":[{"message":"Failed to fetch from Subgraph 'accounts'.","extensions":{"errors":[{"message":"The current user is not authorized to access this resource.","path":["customerById"],"extensions":{"code":"AUTH_NOT_AUTHENTICATED"}}],"serviceName":"accounts","statusCode":200}}],"data":{"customerById":null}}
```

Identical to the answer an anonymous caller gets. The reason is chapter 7's
finding in a more expensive setting: the router forwards no client headers by
default, so Accounts saw no token and had no principal. Asked directly on 5104
with no token at all, Accounts gives the same error, which is the proof that
the router's caller made no difference.

Adding one rule to `router/config.yaml`:

```yaml
headers:
  all:
    request:
      - op: propagate
        named: Authorization
```

and the same request answers `{"data":{"customerById":{"displayName":"Lars Andersen"}}}`,
while an anonymous one still fails. Both measured after a router restart.

The cost of that rule is not zero and the chapter says so: every subgraph now
receives the caller's identity and can act on claims the graph never declared,
and nothing composes or checks that.

## J. The two toggles

`authorization` has three keys and all three default to false
(`pkg/config/config.go:716-723`, `envDefault:"false"` on each). Mosaic ships
the first two false and measures both positions.

**`reject_operation_if_unauthorized: true`**, with a scopeless token:

```json
{"errors":[{"message":"Unauthorized"}],"data":null,"extensions":{"authorization":{"missingScopes":[{"coordinate":{"typeName":"\0\0\0\0\0\0\0\0","fieldName":"email"},"required":[["read:pii"]]}],"actualScopes":[]}}}
```


The `typeName` in that line is eight NUL bytes on the wire. They are written
here, and in the chapter, as `\0` eight times, because a NUL is a control
character and this book's character policy forgives a control character
nowhere, captured or not: decision 60's exemption covers punctuation a tool
emitted and says explicitly that a control character is never forgiven. Section
K records what the real bytes are, and the chapter's prose states the
substitution, so no listing claims to be something it is not.

HTTP 200, not 401. The whole operation fails, and an `extensions.authorization`
block appears naming what was missing and what the caller had. Note the capital
`Unauthorized` here against the lowercase `unauthorized` of the 401 path: two
spellings from two code paths.

**`require_authentication: true`**, anonymous, asking only for product titles:

```
HTTP 401
{"errors":[{"message":"unauthorized"}]}
```

Rejected before planning. This is the switch that turns a public graph into an
internal one, and it is why Mosaic leaves it false: a storefront that demands a
token before it will list a product cannot serve a browser.

## K. The zeroed type name

In the block above, `coordinate.typeName` is eight NUL bytes where `Customer`
belongs. `fieldName` is correct. Reproduced three times out of three, byte for
byte, and `Customer` is eight characters long, so the length is right and the
content is not.

The router does not build that coordinate. `AuthorizeObjectField`
(`core/authorizer.go:105`) receives a `resolve.GraphCoordinate` from the
execution engine, `graphql-go-tools/v2 v2.14.2`, and `addMissingScopes`
(`core/authorizer.go:171`) records it as given. I did not trace it into the
engine, so where the zeroing happens is unverified; that it reaches a client is
measured.

One consequence is worth naming because it is not obvious: `addMissingScopes`
deduplicates by comparing `TypeName` and `FieldName`. With every `TypeName`
zeroed, two protected fields of the same name on different types would be
reported once.

## L. What chapter 15 changed in Mosaic

- `src/Mosaic.ServiceDefaults/Auth/MosaicJwtDefaults.cs`: `AddMosaicJwtAuthentication`,
  with `MapInboundClaims = false` so `sub` arrives as `sub` rather than as a
  WS-Federation URI, and `ClockSkew = TimeSpan.Zero` so an expiry test that
  runs in seconds cannot pass by accident.
- `UseMosaicServiceDefaults` gained `UseAuthentication()` then
  `UseAuthorization()`, in that order and in one place, because reversing them
  fails closed and reads as a policy bug.
- `AddMosaicSubgraph` gained `.AddAuthorization()`. Without it `[Authorize]`
  compiles, the schema builds, and every field carrying it answers to anybody.
- All seven `Program.cs` call `AddMosaicJwtAuthentication`.
- Accounts: `[Authorize]` on `Query.customerById`, `[RequiresScopes(["read:pii"])]`
  on `Customer.Email`.
- `router/config.yaml`: `authentication`, `authorization` and `headers` blocks.
- `docker-compose.yml`: `MOSAIC_JWT_SECRET` reaches the router.
- `scripts/mint-token.mjs` and `scripts/auth-cases.mjs`.
- All seven `schema/*.graphql` regenerated; `federation/supergraph.json`
  recomposed.

## M. What the gates assert

`scripts/auth-cases.mjs` runs in both verification scripts and carries the
composer behaviours of section E, so a wgc release that changes any of them
fails the gate rather than making this chapter quietly wrong.

The runtime half is asserted in both verify scripts: the four answers of
section H, and the before-and-after of section I.

Section J's two toggles are measured by restarting the router with a changed
config, which is a thing a reader does and not a thing a gate should do; they
are recorded here with the exact edit rather than asserted.

## N. Reproduction recipes

```bash
cd mosaic-graph
export MOSAIC_JWT_SECRET=dev-secret-not-for-anything-real-0123456789

# the graph
docker compose up -d --wait mosaic-db mosaic-nats
for s in Catalog:5101 Pricing:5102 Inventory:5103 Accounts:5104 \
         Reviews:5105 Ordering:5106 Nodes:5107; do
  ASPNETCORE_URLS="http://localhost:${s#*:}" \
    dotnet run --project src/Mosaic.${s%:*} -c Release --no-launch-profile &
done
docker compose up -d --wait mosaic-router

# section H
Q='{"query":"{ products { title reviews { edges { node { author { displayName email } } } } } }"}'
curl -s -X POST http://localhost:3002/graphql -H 'content-type: application/json' -d "$Q"
curl -s -X POST http://localhost:3002/graphql -H 'content-type: application/json' \
  -H "authorization: Bearer $(node scripts/mint-token.mjs --scope 'read:pii')" -d "$Q"
curl -s -X POST http://localhost:3002/graphql -H 'content-type: application/json' \
  -H "authorization: Bearer $(node scripts/mint-token.mjs)" -d "$Q"
curl -s -X POST http://localhost:3002/graphql -H 'content-type: application/json' \
  -H "authorization: Bearer $(node scripts/mint-token.mjs --expires-in -60)" -d "$Q"

# section I: comment out the headers block, restart the router, repeat
# section J: flip one key, docker compose up -d --force-recreate mosaic-router
# section E
node scripts/auth-cases.mjs
```

The `{{.Env....}}` finding of section G reproduces by writing that form into
`authentication.jwt.jwks[0].secret`, restarting, and signing a token with the
literal twenty-six characters.

## O. Left unmeasured, and who owns it

- **Authorising a subscription**, and `initialPayload`. Chapter 14 handed both
  here and this chapter did not take them: a connection that outlives its token
  is a resilience question as much as an authorization one, and the router's
  behaviour when a token expires mid-subscription was not provoked. Chapter 24,
  or a revision of this one.
- **Authorising `Query.node`.** Chapter 13 named it and this chapter describes
  the risk without resolving it. The field is unprotected at tag `ch15`.
  Deciding whether the node service refuses types or the router refuses fields
  needs a rule the composer can express, and `@requiresScopes` on a field
  returning an interface is not obviously it. Chapter 17 reads the composer.
- **Where the eight NUL bytes come from.** Section K measures the symptom and
  names the two router functions that pass the value through. The engine,
  `graphql-go-tools/v2 v2.14.2`, was not read. Unblocked by reading it, or by
  a release that changes the output.
- **Whether the zeroed length always equals the real type name's length.**
  One observation, one type name. A second protected field on a
  differently-named type would settle it.
- **`@authenticated` on a type**, which one probe suggested marks fields whose
  *return type* is the annotated type rather than that type's own fields.
  Measured once on a scratch harness, not committed, so decision 55 keeps it
  out of the chapter. Chapter 17.
- **Roles and policies.** `[Authorize]` takes a policy name and a role list and
  Mosaic uses neither. A real graph writes policies; what this chapter needed
  was the smallest thing that shows the split.
- **Schema contracts**, Cosmo's `@tag`-driven route to a public and an internal
  view of one graph. It is a control-plane feature and needs the platform
  chapter 21 stands up.
- **`enable_pre_fetch_field_authorization`**, the third `authorization` key,
  untouched. It moves the decision to before the subgraph fetch, which changes
  what a subgraph is asked for rather than what a client sees. Chapter 24.

## P. Bibliography keys

No new citations. Every claim in this chapter is measured on this machine or
read out of a pinned source tree. The federation specification version in the
SPEC baseline is unchanged, and the three directives this chapter describes are
exercised rather than quoted.

One source was checked and rejected: a search result asserting that federation
v2.9 removes `INTERFACE` from the locations of `@authenticated` and
`@requiresScopes`. `apollographql.com` and `specs.apollo.dev` are both
unreachable from this machine, and the newest tagged Apollo composition source
that could be read, `@apollo/federation-internals@2.14.3`, still lists
`INTERFACE` for both and registers one spec version each. The claim is not in
the chapter.
