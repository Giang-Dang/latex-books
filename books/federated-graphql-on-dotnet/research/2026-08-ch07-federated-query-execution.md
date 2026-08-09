# Chapter 07 research - how a federated query actually runs

Research date: 2026-08-09. Every listing in this file was captured from a
running system on the author's machine, or read out of a primary source at a
pinned version. Where the two disagree the capture wins and the disagreement is
recorded in section I.

The chapter's companion code is `samples/federated-wire/` in `mosaic-graph` at
tag `ch07`. Mosaic itself is untouched: it is one service until chapter 8.

## Contents

- A. Version baseline
- B. The sample, and why it is a sample
- C. The subgraph contract, as HotChocolate 16.6.0 implements it
- D. `_service`, and who actually reads it
- E. Composition, only as far as chapter 7 needs it
- F. The query plan
- G. `_entities` and representations
- H. The captured wire
- I. Where docs and behaviour disagree
- J. Measurements
- K. What the gate asserts
- L. Reproduction recipes
- M. Left unmeasured, and who owns it
- N. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; source read at tag `16.6.0`, commit `8fea46e9560c973eba1b9c899937f9a6bb02aaf9`, cloned at F:/repo/graphql-platform |
| WunderGraph Cosmo Router | 0.337.1, released 2026-08-05 | GitHub releases API, filtered to `router@*`, 2026-08-09. Image `ghcr.io/wundergraph/cosmo/router:0.337.1` |
| wgc (Cosmo CLI) | 0.129.7 | npm, pinned exactly in `package.json` beside newman |
| Router execution config | `compatibilityVersion: "1:0.63.2"` | read out of the composed `supergraph.json` |
| Apollo Federation specification | v2.15 (LTS, Jul 2026) | SPEC version baseline, re-checked 2026-08-09 |
| Federation version HotChocolate emits | **v2.6** | measured; see section C |
| .NET SDK | 10.0.302 | `dotnet --version` |

## B. The sample, and why it is a sample

Chapter 7 sits before chapter 8, which is where Mosaic is split for the first
time, and before chapter 10, which is where the router is set up properly. So
the chapter needs a federated graph that already exists and that costs nothing
to explain.

`samples/federated-wire/` is two ASP.NET Core projects and one container:

| Piece | Port | What it owns |
|---|---|---|
| `Mosaic.Sample.Wire.Catalog` | 5201 | `Product @key(fields: "id")` with `title` and `price`; `Query.products`, `Query.productById` |
| `Mosaic.Sample.Wire.Reviews` | 5202 | The same `Product`, same key, one field `reviews`; `Review`, which is not an entity; `Query.reviews` |
| `ghcr.io/wundergraph/cosmo/router:0.337.1` | 3002 | The supergraph |

Three products (ids `1`, `2`, `3`) and three reviews, distributed 2 / 1 / 0. The
zero is deliberate: a product nobody has reviewed is the interesting row on the
wire because the router still asks about it and the answer is `[]`, not a
missing entry.

This is SPEC decision 31 applied: a demo of one mechanism lives in `samples/`
and never in `Mosaic.Api`.

### Both subgraphs log the wire themselves

There is no proxy and no packet capture. Both projects call ASP.NET Core's own
`AddHttpLogging` / `UseHttpLogging` with request and response bodies turned on,
so every listing in the chapter is what the server process received or sent,
read from inside the server.

Two traps, both hit and both fixed in `samples/federated-wire/WireLogging.cs`:

1. A body is only logged when its media type is on `MediaTypeOptions`.
   HotChocolate answers GraphQL over HTTP with
   `application/graphql-response+json`, which ASP.NET Core does not know about,
   so it has to be added by hand along with `application/json`.
2. Headers outside the middleware's default allow-list print as `[Redacted]`,
   **not** omitted. Verified directly: a request carrying
   `graphql-client-name`, `Authorization` and `X-Custom-Thing` logs

   ```
   Authorization: [Redacted]
   graphql-client-name: direct-test
   X-Custom-Thing: [Redacted]
   ```

   with `graphql-client-name` in the clear only because it was added to
   `options.RequestHeaders`. This matters for section H: a header the router did
   not send is absent from the log entirely, and a header it sent but that is
   not allow-listed would appear as `[Redacted]`. The two are distinguishable,
   which is what makes the "the router forwards nothing" claim measurable rather
   than inferred.

### The router runs in a container, the subgraphs do not

`docker-compose.yml` gains a `wire-router` service behind the compose profile
`wire`, with `extra_hosts: host.docker.internal:host-gateway`, and the routing
URLs in `graph.yaml` name `host.docker.internal`. This costs the router one
NAT hop the subgraphs do not pay, and section J says so where it quotes a
number.

## C. The subgraph contract, as HotChocolate 16.6.0 implements it

`AddApolloFederation()` is the whole registration. Read at
`src/HotChocolate/ApolloFederation/src/ApolloFederation/Extensions/ApolloFederationRequestExecutorBuilderExtensions.cs`:

```csharp
public static IRequestExecutorBuilder AddApolloFederation(
    this IRequestExecutorBuilder builder,
    FederationVersion version = FederationVersion.Default)
```

### The default is v2.6, and the specification is at v2.15

`FederationVersion.cs`, same tag:

```csharp
public enum FederationVersion
{
    Unknown = 0,
    Federation10 = 1_0,
    Federation20 = 2_0,
    // ...
    Federation26 = 2_6,
    Federation27 = 2_7,
    // default to latest-1
    Default = Federation26,
    Latest = Federation27
}
```

So the highest version HotChocolate 16.6.0 can emit is 2.7, the default is 2.6,
and the specification is at 2.15. Measured in the published SDL:

```
schema
  @link(
    url: "https://specs.apollo.dev/federation/v2.6"
    import: ["@key", "@tag", "FieldSet"]
  ) {
  query: Query
}
```

`[source]` for the enum, `[measured]` for the emitted link. This is not a
defect: the directives chapter 6 covers are all v2.0-v2.3 vintage, and the
composer accepts a v2.6 subgraph without comment. It does mean a subgraph that
needs something newer than 2.7 cannot ask HotChocolate for it.

### Entities are attributes on the runtime type

`[Key("id")]` on the class, `[ReferenceResolver]` on a static method in it. From
`KeyAttribute.cs`, the v2 signature is
`@key(fields: FieldSet!, resolvable: Boolean = true) repeatable on OBJECT | INTERFACE`.
The reference resolver's parameter names are what unpack the representation:
a parameter called `id` receives the representation's `id`. `[Map("a.b")]`
exists for nested key fields.

This is the annotation-based style HotChocolate's own certification schema uses
(`test/ApolloFederation.Tests/CertificationSchema/AnnotationBased/Types/Product.cs`).
Whether `[ReferenceResolver]` composes with the source generator's
`[ObjectType<T>]` partial-class style, which is Mosaic's house style under SPEC
decision 28, was **not** tested here. Chapter 8 owns that question and has to
answer it before Catalog is extracted.

### A type nothing returns is not in the schema

The first version of the Reviews subgraph published no `Product` at all, no
`_entities` field, and a `@link` import list without `@key`. Nothing was wrong
with the C#; no root field returns `Product`, so HotChocolate never reached it.
The fix is one line in `Program.cs`:

```csharp
builder.AddGraphQL()
    .AddApolloFederation()
    .AddWireReviews()
    .AddType<Product>();
```

The failure mode is quiet. The service starts, answers its own queries, and
publishes a schema that composes - into a supergraph where `Product` has no
`reviews`. `[measured]` What it published, in full:

```graphql
schema
  @link(
    url: "https://specs.apollo.dev/federation/v2.6"
    import: ["@tag", "FieldSet"]
  ) {
  query: Query
}

type Query {
  reviews: [Review!]!
  _service: _Service!
}

type Review { id: ID!  rating: Int!  body: String! }
type _Service { sdl: String! }
scalar FieldSet
scalar _Any
directive @link(url: String!, import: [String!]) repeatable on SCHEMA
```

No `Product`, no `_entities`, no `_Entity`, and `@key` absent from the import
list. That artefact no longer exists in the repository, which is why it is
recorded here.

### What the federation package adds to the schema

Measured, from the exported SDL of the catalog subgraph:

```graphql
type Query {
  products: [Product!]!
  productById(id: ID!): Product
  _service: _Service!
  _entities(representations: [_Any!]!): [_Entity]!
}

type _Service { sdl: String! }
union _Entity = Product
scalar FieldSet
scalar _Any
directive @key(fields: FieldSet!, resolvable: Boolean = true) repeatable on
  | OBJECT
  | INTERFACE
directive @link(url: String!, import: [String!]) repeatable on SCHEMA
```

`_entities` appears only when at least one type carries `@key`: the reviews
subgraph, before `AddType<Product>()`, had `_service` and no `_entities`.
`_Entity` is a union of exactly the keyed types.

## D. `_service`, and who actually reads it

`Query._service { sdl }` returns the subgraph's schema as text. The Apollo
subgraph specification requires it and says the string "must include all uses of
all federation-specific directives, such as `@key`"; for Federation 2 it adds
that `sdl` may also include the spec's own additions.

### The router never calls it

Measured. With a static execution config the router asks the subgraphs nothing
at start-up: start both subgraphs, start the router, wait for
`Server initialized and ready to serve requests`, then `grep -c '_service'` over
both subgraph consoles. Returns `0` and `0`. The router's schema was baked into
`supergraph.json` at compose time.

Do **not** run the Postman collection first, which an earlier version of this
note said to do. Two of its requests send `{ _service { sdl } }` to the
subgraphs directly, so the count afterwards is 2 and 2 and says nothing about
the router. Re-measured cleanly 2026-08-09; the conclusion is unchanged and the
procedure was not reproducible as first written.

### The composer does call it, when told to

Also measured. With `introspection:` instead of `schema: file:` in `graph.yaml`,
`wgc router compose` sends exactly this, `User-Agent: node`:

```
{"query":"\n  {\n    _service{\n      sdl\n    }\n  }\n","variables":{}}
```

So `_service` is the composer's field, not the router's. That is the sentence
worth printing, because "the router introspects the subgraphs" is the common
mental model and it is wrong for a statically configured router.

The committed `schema/samples/wire-catalog.graphql` and `wire-reviews.graphql`
are what `_service { sdl }` returns, and the verification gate re-fetches and
compares them on every run.

## E. Composition, only as far as chapter 7 needs it

Chapter 9 owns composition. Chapter 7 needs one command and one output file.

```
npx wgc router compose -i samples/federated-wire/graph.yaml \
                       -o samples/federated-wire/supergraph.json
```

The docs are explicit that this "does not interact with the control plane and
completely runs locally". No account, no token, no registry. Input shape,
verbatim from the CLI reference:

```yaml
version: 1
subgraphs:
  - name: <subgraph-name>
    routing_url: <graphql-endpoint>
    schema:
      file: <path-to-schema-file>
```

The output is a *router execution config*, not a supergraph SDL. Top level,
measured:

```
engineConfig: object(5)
  defaultFlushInterval: "500"
  datasourceConfigurations: array(2)
  fieldConfigurations: array(1)
  graphqlSchema: str      # the supergraph API schema, as text
  stringStorage: object(2)
version: "00000000-0000-0000-0000-000000000000"
subgraphs: array(2)
featureFlagConfigs: object(0)
compatibilityVersion: "1:0.63.2"
```

7,960 bytes for two subgraphs. The all-zero `version` is what a locally composed
config gets; the router logs it as `config_version`.

### Running the router with no account

`docker-compose.yml`, profile `wire`:

```
EXECUTION_CONFIG_FILE_PATH: /etc/wire/supergraph.json
DEV_MODE: "true"
LISTEN_ADDR: 0.0.0.0:3002
```

No `GRAPH_API_TOKEN`. The docs say it "can be empty when providing a static
router configuration ... but will disable the default telemetry stack", and the
router says the same thing on start-up, measured:

```
WARN core/router.go:464 No graph token provided. The following Cosmo Cloud
features are disabled. Not recommended for Production.
{"features": ["Schema Usage Tracking", "Persistent operations",
              "Cosmo Cloud Tracing", "Cosmo Cloud Metrics"]}
WARN core/router.go:536 Development mode enabled. This should only be used for
testing purposes
INFO core/router.go:1722 Static execution config provided. Polling and watching
is disabled. Updating execution config is only possible by restarting the router
```

`DEV_MODE` is not decoration here: the docs describe it as enabling "pretty log
output and allows to use Advanced Request Tracing (ART) without further security
protection", and the query-plan header of section F is part of ART.

## F. The query plan

Two headers, both needing `DEV_MODE`:

- `X-WG-Include-Query-Plan: true` puts the plan in `extensions.queryPlan`.
- `X-WG-Skip-Loader: true` stops the router executing it, so `data` comes back
  `null` and the subgraphs are never called.
- `X-WG-Disable-Tracing: true` keeps a plan request out of router tracing.

### The plan for the chapter's query

Query: `{ products { title price reviews { rating body } } }`. Captured whole:

```json
{
  "version": "1",
  "kind": "Sequence",
  "children": [
    {
      "kind": "Single",
      "fetch": {
        "kind": "Single",
        "subgraphName": "catalog",
        "subgraphId": "0",
        "fetchId": 0,
        "query": "{\n    products {\n        title\n        price\n        __typename\n        id\n    }\n}"
      }
    },
    {
      "kind": "Single",
      "fetch": {
        "kind": "BatchEntity",
        "path": "products",
        "subgraphName": "reviews",
        "subgraphId": "1",
        "fetchId": 1,
        "dependsOnFetchIds": [0],
        "representations": [
          {
            "kind": "@key",
            "typeName": "Product",
            "fragment": "fragment Key on Product {\n    __typename\n    id\n}"
          }
        ],
        "query": "query($representations: [_Any!]!){\n    _entities(representations: $representations){\n        ... on Product {\n            __typename\n            reviews {\n                rating\n                body\n            }\n        }\n    }\n}",
        "dependencies": [
          {
            "coordinate": { "typeName": "Product", "fieldName": "reviews" },
            "isUserRequested": true,
            "dependsOn": [
              {
                "fetchId": 0,
                "subgraph": "catalog",
                "coordinate": { "typeName": "Product", "fieldName": "id" },
                "isKey": true,
                "isRequires": false
              }
            ]
          }
        ]
      }
    }
  ],
  "normalizedQuery": "{products {title price reviews {rating body}}}"
}
```

Field names worth naming in prose: `kind` (`Sequence`, `Single`,
`BatchEntity`), `fetchId`, `dependsOnFetchIds`, `representations[].fragment`,
and the `dependencies` array, which is the plan explaining *why* it needs what
it fetches: `Product.reviews` was user-requested and depends on `Product.id`
from fetch 0, `isKey: true`.

### The plan proves why `__typename` and `id` appear

Same root field, no cross-boundary selection:
`{ products { title price } }` plans to

```json
{ "kind": "Single", "subgraphName": "catalog", "fetchId": 0,
  "query": "{\n    products {\n        title\n        price\n    }\n}" }
```

one child, no `__typename`, no `id`. The extra fields in the first plan are a
dependency, not a habit. `[measured]`

The full capture of that one, for the record:

```json
{
  "version": "1",
  "kind": "Sequence",
  "children": [
    { "kind": "Single",
      "fetch": { "kind": "Single", "subgraphName": "catalog", "subgraphId": "0",
                 "fetchId": 0,
                 "query": "{\n    products {\n        title\n        price\n    }\n}" } }
  ],
  "normalizedQuery": "{products {title price}}"
}
```

And the mirror image, `{ products { reviews { rating } } }`, where the client
asks Catalog for nothing at all:

```
Single      catalog -> "{\n    products {\n        __typename\n        id\n    }\n}"
BatchEntity reviews -> "query($representations: [_Any!]!){_entities(...){... on Product {__typename reviews {rating}}}}"
```

Catalog is still called, and called for nothing but the key. `[measured]`

### `Parallel` exists, and this is what earns one

`{ products { title } reviews { rating } }`, two root fields owed to different
subgraphs and to each other nothing:

```json
{
  "version": "1",
  "kind": "Sequence",
  "children": [
    { "kind": "Parallel",
      "children": [
        { "kind": "Single",
          "fetch": { "kind": "Single", "subgraphName": "catalog", "subgraphId": "0",
                     "fetchId": 0, "query": "{\n    products {\n        title\n    }\n}" } },
        { "kind": "Single",
          "fetch": { "kind": "Single", "subgraphName": "reviews", "subgraphId": "1",
                     "fetchId": 1, "query": "{\n    reviews {\n        rating\n    }\n}" } }
      ] }
  ],
  "normalizedQuery": "{products {title} reviews {rating}}"
}
```

Neither fetch carries `dependsOnFetchIds`. `[measured]` Captured because the
first draft of the chapter asserted that a `Parallel` node exists without ever
having seen one.

## G. `_entities` and representations

Specification, quoted from the Apollo subgraph spec:

```graphql
extend type Query {
  _entities(representations: [_Any!]!): [_Entity]!
}
scalar _Any
union _Entity
```

A representation must carry `__typename` and every field of the `@key` fieldset.
The reply is positional: answer *n* belongs to representation *n*.

### Measured: it answers for things that do not exist

There is no product `9`. Sent by hand to the reviews subgraph:

```json
{"representations":[{"__typename":"Product","id":"9"}]}
```

```json
{"data":{"_entities":[{"id":"9","reviews":[]}]}}
```

No error. The reference resolver takes a key and builds an object from it; it
has no way to ask Catalog whether the product is real and does not try. This is
chapter 6's ownership claim - the extending subgraph is not the authority on
existence - showing up on the wire.

### Measured: an unresolvable `__typename` is a bad error

`Review` carries no `@key`, so it is not in `_Entity` and has no reference
resolver:

```json
{"representations":[{"__typename":"Review","id":"r1"}]}
```

```json
{"errors":[{"message":"Unexpected Execution Error","path":["_entities"]}],"data":null}
```

HTTP 200, `data: null`, and a message that says nothing. The throw is
`ThrowHelper.EntityResolver_NoResolverFound()` in `EntitiesResolver.ResolveAsync`
`[source]`; what reaches the client is the masked form. Worth printing because
it is what a reader will actually see the first time they get a `@key` wrong.

### How the resolver runs the batch

`EntitiesResolver.ResolveAsync`, read at 16.6.0 `[source]`: it clones the
resolver context per representation, starts every one as a task, and awaits them
afterwards, so the representations in one call are resolved concurrently rather
than in sequence. A failure in one is reported at path `_entities[n]` and
becomes a `null` in that slot rather than failing the whole list.

## H. The captured wire

One federated query, `{ products { title price reviews { rating body } } }`,
sent to the router. Both subgraph consoles, trimmed to the HTTP logging lines.

### Catalog received

```
Method: POST
PathBase:
Path: /graphql
Accept: application/json
Host: host.docker.internal:5201
User-Agent: Go-http-client/1.1
Accept-Encoding: gzip,deflate
Content-Type: application/json
traceparent: 00-14c8c3610596717bc4c5d5d57ec4c99a-b1ecebfd8985308e-01
Content-Length: 50

RequestBody: {"query":"{products {title price __typename id}}"}

ResponseBody: {"data":{"products":[{"title":"Oak dining table","price":749.00,"__typename":"Product","id":"1"},{"title":"Linen armchair","price":429.00,"__typename":"Product","id":"2"},{"title":"Brass floor lamp","price":189.00,"__typename":"Product","id":"3"}]}}
```

### Reviews received

```
traceparent: 00-14c8c3610596717bc4c5d5d57ec4c99a-ad519fea48de7013-01
Content-Length: 278

RequestBody: {"variables":{"representations":[{"__typename":"Product","id":"1"},{"__typename":"Product","id":"2"},{"__typename":"Product","id":"3"}]},"query":"query($representations: [_Any!]!){_entities(representations: $representations){... on Product {__typename reviews {rating body}}}}"}

ResponseBody: {"data":{"_entities":[{"__typename":"Product","reviews":[{"rating":5,"body":"Survived a house move."},{"rating":3,"body":"Arrived with a chipped leg."}]},{"__typename":"Product","reviews":[{"rating":4,"body":"Firmer than it looks."}]},{"__typename":"Product","reviews":[]}]}}
```

### What the client got back

The router's own response body, unmodified. Note `749.00`, not `749.0`: an
earlier capture was piped through `python -m json.tool`, which reparses the
number and drops the trailing zero. Anything printed in the book has to come
from the raw body.

```
{"data":{"products":[{"title":"Oak dining table","price":749.00,"reviews":[{"rating":5,"body":"Survived a house move."},{"rating":3,"body":"Arrived with a chipped leg."}]},{"title":"Linen armchair","price":429.00,"reviews":[{"rating":4,"body":"Firmer than it looks."}]},{"title":"Brass floor lamp","price":189.00,"reviews":[]}]}}
```

### Things to say about those blocks, all of them measured

1. **The plan is sent as a document, not as anything proprietary.** Both bodies
   are ordinary `POST /graphql` with a `query` and, for the second, `variables`.
   A subgraph needs no router-specific code to be talked to.
2. **The representations travel in a variable**, not inlined in the document.
   That is what lets the router reuse one compiled document for any batch size.
3. **One call for three products.** Three separate calls would produce the same
   answer; the gate in `verify.ps1` fails if that changes, because the batching
   claim is the chapter's.
4. **`traceparent` is the same trace, different spans.** Trace id
   `14c8c3610596717bc4c5d5d57ec4c99a` on both, span ids `b1ecebfd8985308e` and
   `ad519fea48de7013`. The router generates them; W3C trace context is how a
   federated request stays one request in a tracing tool. Chapter 23 owns this.
5. **Nothing else of the client's request survives.** See below.

### The router forwards no client headers, measured two ways

The same three headers, `graphql-client-name: chapter-07`,
`Authorization: Bearer not-a-real-token` and `X-Custom-Thing: hello`, sent twice.
Straight to the catalog subgraph:

```
Authorization: [Redacted]
Content-Type: application/json
graphql-client-name: chapter-07
X-Custom-Thing: [Redacted]
```

Through the router, the subgraph logged no line for any of the three: not
`[Redacted]`, absent. The allow-list behaviour in section B is what makes that
distinguishable.

The Cosmo docs agree: "By default, no headers are forwarded for security
reasons." Turning one on is a router config rule:

```yaml
headers:
  all:
    request:
      - op: "propagate"
        named: X-Test-Header
```

Chapter 15 owns what to do about `Authorization`.

### Content negotiation

The router sends `Accept: application/json`, so HotChocolate answers
`application/json; charset=utf-8` rather than
`application/graphql-response+json`. Chapter 18 owns the negotiation rules.

## I. Where docs and behaviour disagree

1. **HotChocolate's own `_Service` description is stale.** The description
   string it ships, in full, exactly as it appears in every schema the package
   generates:

   ```
   This type provides a field named sdl: String! which exposes the SDL of the
   service's schema. This SDL (schema definition language) is a printed version of
   the service's schema including the annotations of federation directives. This
   SDL does not include the additions of the federation spec.
   ```

   Measured, `_service { sdl }` returns `_service`,
   `_entities`, `_Any`, `_Entity`, `FieldSet`, `@key` and `@link` along with
   everything else. The behaviour is legal - the Apollo spec permits it for
   Federation 2 and only forbids it for Federation 1 - so the string is
   describing a v1 rule on a v2 schema. Print the description and the output
   next to each other; it is a two-line demonstration of why the compiler beats
   the docs.
2. **`schema export` and `_service { sdl }` agree here, and only one of them is
   the contract.** Byte-identical for both subgraphs at this version. The
   verification gate asserts the `_service` one, because that is what a composer
   reads and the equality is not promised anywhere.
3. **The Cosmo query-plan documentation does not document the plan's shape.**
   The page names `X-WG-Include-Query-Plan`, `X-WG-Skip-Loader` and
   `X-WG-Disable-Tracing` and shows the Studio playground; the field names in
   section F came out of the router, not the page.

## J. Measurements

Single machine, one sitting, warm. 50 requests each after 5 warm-up requests,
`curl -w '%{time_total}'`. The router is in a container reaching the subgraphs
through `host.docker.internal`; the direct rows are host-to-host and pay no such
hop, which is why the gap in the last column is an upper bound on router
overhead rather than a measurement of it.

| What | min | median | p90 | max |
|---|---|---|---|---|
| Router, federated (2 subgraph fetches) | 4.14 | **4.69** | 5.84 | 24.14 |
| Router, catalog only (1 subgraph fetch) | 2.87 | **3.27** | 3.82 | 20.77 |
| Catalog direct | 0.70 | **0.81** | 0.96 | 1.43 |
| Reviews `_entities` direct, 3 representations | 0.78 | **0.92** | 1.07 | 21.12 |

All figures in milliseconds.

Two claims that should survive re-measurement on other hardware, as ratios:

- **The second subgraph hop costs about 1.4 ms here**, 4.69 against 3.27. That
  is close to what the reviews subgraph costs when asked directly (0.92), which
  is the expected result: the second fetch is a serial dependency, so its cost
  adds rather than overlaps.
- **The router costs more than the second hop does.** 3.27 against 0.81 for the
  same single-subgraph answer: roughly 2.5 ms of planning, normalisation, HTTP
  and container networking, against 1.4 ms for a whole extra service. The
  interesting number in a federated graph is not usually the fan-out.

The maxima are noise: three of the four rows show one outlier around 20 ms,
which is the machine and not the graph. Quote medians.

## K. What the gate asserts

`scripts/verify.ps1` and `scripts/verify.sh` gained a section 9, and both were
run to PASS on 2026-08-09.

1. `wgc router compose` succeeds against the two committed schemas.
2. Both subgraphs start and answer.
3. What each publishes through `_service { sdl }` equals the committed
   `schema/samples/wire-<name>.graphql`, compared as normalised text.
4. The router starts and answers `/health`.
5. `postman/federated-wire.postman_collection.json` passes: 9 requests, 37
   assertions.
6. The catalog log contains, exactly,
   `{"query":"{products {title price __typename id}}"}`, and the reviews log
   contains the full representations body of section H.

5 and 6 are the same claim from two ends: the collection reads the router's
account of its own plan, and 6 reads what the subgraphs received.

### A PowerShell trap worth remembering

The first version of check 6 used `-notlike "*$Expected*"`. The catalog string
passed and the reviews string failed, because `-like` reads the `[` and `]` of
the JSON array as a wildcard character class. `.Contains()` in PowerShell,
`grep -qF` in bash. The bug is invisible until a pattern happens to contain
brackets, which is exactly how it survives review.

## L. Reproduction recipes

Everything below is run from the root of `mosaic-graph` at tag `ch07`.

**The whole thing:** `pwsh scripts/verify.ps1` or `bash scripts/verify.sh`.
`-SkipWire` / `MOSAIC_SKIP_WIRE=1` leaves out this chapter's section.

**By hand:**

```
dotnet run --project samples/federated-wire/Mosaic.Sample.Wire.Catalog
dotnet run --project samples/federated-wire/Mosaic.Sample.Wire.Reviews
npx wgc router compose -i samples/federated-wire/graph.yaml \
                       -o samples/federated-wire/supergraph.json
docker compose --profile wire up -d wire-router
```

**A query plan without executing it:**

```
curl -s http://localhost:3002/graphql \
  -H 'Content-Type: application/json' \
  -H 'X-WG-Include-Query-Plan: true' \
  -H 'X-WG-Skip-Loader: true' \
  -d '{"query":"{ products { title price reviews { rating body } } }"}'
```

**What the composer reads:**

```
curl -s http://localhost:5201/graphql -H 'Content-Type: application/json' \
  -d '{"query":"{ _service { sdl } }"}'
```

**Proving the router calls no subgraph at start-up:** start both subgraphs,
start the router, then `grep -c '_service'` over each subgraph's console output.
Both are 0. Do this before sending anything, and in particular before running
the Postman collection, two of whose requests ask the subgraphs for `_service`
themselves.

**The composition error the lab produces:** point `graph.yaml` at the running
subgraphs with `introspection:` blocks, change Reviews' `[Key("id")]` to
`[Key("productId")]`, rebuild and restart it, then recompose. The subgraph
starts and publishes `type Product @key(fields: "productId")` quite happily; the
composer refuses:

```
The subgraph "reviews" could not be federated for the following reason:
The 1st instance of the directive "@key" declared on coordinates "Product" is
invalid for the following reason:
 The following field set is invalid:
  "productId"
 This is because of the selection set corresponding to the field coordinates
 "Product.productId".
 The type "Product" does not define a field named "productId".
```

`[measured]` This is why the lab's version of that exercise tells the reader to
switch to introspection first: with the committed `schema: file:` form, a change
to the C# never reaches the composer and the exercise silently does nothing.

**The latency table:** the loop in section J is 5 warm-up requests then 50
timed ones per row with `curl -o /dev/null -w '%{time_total}'`, all four rows in
one sitting. Doing the rows in separate sittings says nothing: chapter 4's
research file records the same lesson after the same machine measured one tag at
10-12 ms and later at 19-20 ms.

## M. Left unmeasured, and who owns it

- **`[ReferenceResolver]` with `[ObjectType<T>]`.** Mosaic's house style is the
  source generator's partial-class form (decision 28); the sample uses
  attributes on the runtime type. Chapter 8 has to establish which of the two
  works before Catalog is extracted, and to say so if the answer is only one.
- **DataLoader behind a reference resolver.** The sample's reference resolvers
  are dictionary lookups, so nothing here says what an `_entities` call with 3
  representations costs a database. Chapter 11.
- **`@requires`, `@provides`, `@override` on the wire.** The plan's
  `dependencies` array has an `isRequires` flag this chapter never sees set.
  Chapter 11 for the first two, chapter 12 for the third.
- **Advanced Request Tracing.** `X-WG-Trace: true` returns 6,414 bytes of trace
  for this query. Named in passing, not printed. Chapters 17 and 23.
- **A subgraph that is down, slow, or partially failing.** Chapter 24.
- **Mutations and subscriptions through a router.** Chapters 12 and 14.
- **`--split-configs-enabled`, feature flags, and everything else `wgc router
  compose` can do.** Chapter 9 and chapter 21.
- **Whether the plan for the same query is cached across requests.** The router
  has a plan cache; nothing here measured it. Chapter 17.

## N. Bibliography keys

New entries needed in `refs.bib` for this chapter:

| Key | Source | Used for |
|---|---|---|
| `apollo2026subgraphspec` | Apollo Federation Subgraph Specification, apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec, urldate 2026-08-09 | `_service`, `_entities`, `_Any`, `_Entity`, the representation validation rules |
| `cosmo2026routercompose` | WunderGraph Cosmo CLI reference, `wgc router compose`, cosmo-docs.wundergraph.com/cli/router/compose, urldate 2026-08-09 | "does not interact with the control plane and completely runs locally"; the input file shape |
| `cosmo2026queryplan` | WunderGraph Cosmo, Query Plan, cosmo-docs.wundergraph.com/router/query-plan, urldate 2026-08-09 | the three `X-WG-*` headers |
| `cosmo2026routerconfig` | WunderGraph Cosmo, Router Configuration, cosmo-docs.wundergraph.com/router/configuration, urldate 2026-08-09 | `GRAPH_API_TOKEN` optional with a static config; what `DEV_MODE` enables |
| `cosmo2026headers` | WunderGraph Cosmo, Subgraph Request Headers Operations, cosmo-docs.wundergraph.com/router/proxy-capabilities/request-headers-operations, urldate 2026-08-09 | "By default, no headers are forwarded for security reasons"; the `op: propagate` rule |

Already in `refs.bib` from chapter 6 and reusable here: `apollo2026entities`,
`apollo2026federationspec`, `apollo2026compositionrules`.

All five new entries are vendor documentation of the vendor's own product,
describing what the product does rather than how it compares to a competitor.
The SPEC rule about naming an engineer applies to vendor *claims*; a CLI
reference is not one. Nothing in this chapter cites a vendor blog post.
