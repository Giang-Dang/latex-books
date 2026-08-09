# Chapter 10 research - enter the router

Research date: 2026-08-09. Every number and every listing in this file was
captured from a running router on the author's machine, or read out of a
primary source at a pinned version. Where the two disagree the running tool
wins and the disagreement is recorded in section I.

The chapter's companion code is `mosaic-graph` at tag `ch10`. Neither service
changes: chapter 10 adds a process in front of them and two files that
configure it.

## Contents

- A. Version baseline
- B. What the router needs to start
- C. The query that stopped working
- D. The plan on a real graph
- E. Configuring it
- F. The config chapter 9 could not test
- G. What the router exposes, and what it does not
- H. Measurements
- I. Where docs and behaviour disagree
- J. What the gate asserts
- K. Reproduction recipes
- L. Left unmeasured, and who owns it
- M. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| WunderGraph Cosmo Router | 0.337.1 | `ghcr.io/wundergraph/cosmo/router:0.337.1`, pinned in `docker-compose.yml`; the container reports `service_version` on every log line |
| Latest router release on 2026-08-09 | 0.337.1, published 2026-08-05T11:59:10Z as `router@0.337.1`; 0.337.0 was 2026-07-31 | GitHub releases API for `wundergraph/cosmo`, filtered to `router@` tags. Still the newest, so the SPEC baseline needed no change |
| wgc (Cosmo CLI) | 0.129.7 | pinned exactly in `package.json`; unchanged from chapter 9 |
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; unchanged since chapter 8 |
| node | 24.15.0 | `node --version` |
| Docker | 29.6.2 | `docker --version` |

The router's configuration schema was read at the matching tag rather than from
the docs site:
`https://raw.githubusercontent.com/wundergraph/cosmo/router%400.337.1/router/pkg/config/config.schema.json`,
236,602 bytes. Everything in section E about defaults, deprecations and key
names comes from that file. [source]

## B. What the router needs to start

Three things, and one of them is optional.

1. A router execution config. `federation/supergraph.json`, composed in chapter
   9 and committed.
2. Somewhere to listen.
3. Optionally a `config.yaml`. Without one the router is configured entirely by
   environment variables, which is what chapter 7's `wire-router` does.

**It contacts no subgraph at startup.** Measured properly on the second pass,
after the audit pointed out that the first one had only ever started the router
with both services already up. Both subgraphs stopped, then
`docker compose up -d mosaic-router`:

```
/health        200  body=OK
/health/ready  200  body=OK
/health/live   200  body=OK
```

and a query at that point:

```
HTTP 200
{"errors":[{"message":"Failed to fetch from Subgraph 'catalog'."}],"data":null}
```

So the router starts against nothing, reports itself ready, and only discovers
the subgraphs are gone when a request needs one. There is nothing for
`depends_on` to wait for, and `docker-compose.yml` gives `mosaic-router` none.

**No account, no registry, no token.** It says so itself, as a warning:

```
WARN core/router.go:464 No graph token provided. The following Cosmo Cloud
features are disabled. Not recommended for Production.
{"features": ["Schema Usage Tracking", "Persistent operations",
"Cosmo Cloud Tracing", "Cosmo Cloud Metrics"]}
```

The full startup log of Mosaic's router, colour stripped, captured with
`docker compose logs mosaic-router --no-log-prefix` on 2026-08-09. Eleven lines,
of which three are warnings:

```
INFO cmd/main.go:230 Config file watching is disabled, you can still trigger reloads by sending SIGHUP to the router process
INFO cmd/main.go:125 Config file provided. Values in the config file have higher priority than environment variables {"config_file": ["/etc/mosaic-router/config.yaml"]}
INFO core/supervisor_instance.go:47 GOMEMLIMIT set automatically {"limit": "0 B"}
WARN core/router.go:464 No graph token provided. The following Cosmo Cloud features are disabled. Not recommended for Production.
WARN core/router.go:536 Development mode enabled. This should only be used for testing purposes
INFO metric/prometheus_server.go:63 Prometheus metrics enabled {"listen_addr": "127.0.0.1:8088", "endpoint": "/metrics"}
INFO core/router.go:1020 Serving GraphQL playground {"url": "http://0.0.0.0:3002/"}
WARN core/router.go:1570 Advanced Request Tracing (ART) is enabled in development mode but requires a graph token to work in production.
INFO core/router.go:1697 Server initialized and ready to serve requests {"listen_addr": "0.0.0.0:3002", "playground": true, "introspection": true, "config_version": "00000000-0000-0000-0000-000000000000"}
INFO core/router.go:1715 Watching config file for changes. Router will hot-reload automatically without downtime {"path": "/etc/mosaic/supergraph.json"}
INFO core/supervisor.go:155 Router started
```

The `config_version` of all zeroes is chapter 9's `version` field arriving where
chapter 7 first met it: a locally composed config has no registry to take a
version from.

**Two lines in that log both say "config file" and they mean different files.**
Line 1 is `watch_config`, which watches `config.yaml`, and is off. Line 10 is
`execution_config.file.watch`, which watches `supergraph.json`, and is on
because `router/config.yaml` turns it on. The two are unrelated settings with
almost the same name, reported eight lines apart, one saying watching is
disabled and the other saying the router will hot-reload.

## C. The query that stopped working

The storefront query chapters 2 to 5 opened with. Since chapter 8, no single
service can answer it. Measured rather than assumed, by sending the whole
document to each subgraph directly:

```
catalog (5101)   HTTP 400, 4 errors
    The field `price` does not exist on the type `Product`.
    The field `availableQuantity` does not exist on the type `Product`.
    The field `averageRating` does not exist on the type `Product`.
    The field `reviews` does not exist on the type `Product`.

mosaic  (5100)   HTTP 400, 1 error
    The field `browseProducts` does not exist on the type `Query`.
```

Through the router, at `http://localhost:3002/graphql`:

```graphql
{
  browseProducts(first: 3) {
    nodes {
      title
      price { amount currency }
      availableQuantity
      averageRating
      reviews(first: 2) { totalCount nodes { rating author { displayName } } }
    }
  }
}
```

The first of the three products, captured 2026-08-09:

```json
{
  "title": "Beech Cutting Board",
  "price": { "amount": 69, "currency": "EUR" },
  "availableQuantity": 61,
  "averageRating": 4.166666666666667,
  "reviews": {
    "totalCount": 6,
    "nodes": [
      { "rating": 5, "author": { "displayName": "Katharina Brandt" } },
      { "rating": 4, "author": { "displayName": "Tomas Novak" } }
    ]
  }
}
```

`title` is Catalog's. Everything else is Mosaic's, hung off a `Product` whose
only field there is the key.

### What each service did for it

Read off the two consoles after one warm request. Mosaic's, twice in a row:

```
parse - validate - compile - coerce 0.056ms execute 7.802ms total 7.895ms (document cache hit, operation cache hit, 19 resolvers, 6 SQL)
Service lookups this request: 5
parse - validate - compile - coerce 0.045ms execute 13.220ms total 13.290ms (document cache hit, operation cache hit, 19 resolvers, 6 SQL)
Service lookups this request: 5
```

The first request of a session reports `document cache miss, operation cache
miss` and 93.9 ms of execute, which is chapter 3's warning about cold first
requests arriving again in a federated setting.

**Catalog reports nothing at all.** It has no request timeline, no resolver
count and no lookup counter: chapter 3 built all three in `Mosaic.Api` and
chapter 8's extraction left them there. Grepping `src/Mosaic.Catalog` for
`RequestTimeline`, `ServiceCallCounter`, `SqlCommandCounter` and
`PipelineReport` returns one hit and it is a comment in `CatalogService.cs`
saying the counter is gone. So half of every federated query is now
unobserved, and nothing about the extraction announced that. Chapter 23 owns
observability across services.

## D. The plan on a real graph

Chapter 7 established the mechanics of a query plan on a two-field sample:
`Sequence` and `Parallel`, `Single` and `BatchEntity`, `dependsOnFetchIds`, the
`dependencies` array, and the three request headers. None of that is
re-derived here. What follows is what is different when the graph is real.

Headers, unchanged from chapter 7: `X-WG-Include-Query-Plan: true` puts the
plan under `extensions.queryPlan`, and `X-WG-Skip-Loader: true` stops the router
executing it. Both need dev mode, which `router/config.yaml` sets.

The plan for the storefront query above, captured 2026-08-09. Query strings are
reproduced as the router wrote them, including the four-space indentation:

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
        "query": "query($a: Int){\n    browseProducts(first: $a){\n        nodes {\n            title\n            __typename\n            id\n        }\n    }\n}"
      }
    },
    {
      "kind": "Single",
      "fetch": {
        "kind": "BatchEntity",
        "path": "browseProducts.nodes",
        "subgraphName": "mosaic",
        "subgraphId": "1",
        "fetchId": 1,
        "dependsOnFetchIds": [0],
        "representations": [
          { "kind": "@key", "typeName": "Product",
            "fragment": "fragment Key on Product {\n    __typename\n    id\n}" }
        ],
        "query": "query($representations: [_Any!]!, $b: Int){\n    _entities(representations: $representations){\n        ... on Product {\n            __typename\n            price {\n                amount\n                currency\n            }\n            availableQuantity\n            averageRating\n            reviews(first: $b){\n                totalCount\n                nodes {\n                    rating\n                    author {\n                        displayName\n                    }\n                }\n            }\n        }\n    }\n}",
        "dependencies": [ ... four entries ... ]
      }
    }
  ],
  "normalizedQuery": "query($a: Int, $b: Int){browseProducts(first: $a){nodes {title price {amount currency} availableQuantity averageRating reviews(first: $b){totalCount nodes {rating author {displayName}}}}}}"
}
```

Three things here that chapter 7's sample could not show.

**1. `path` is `browseProducts.nodes`, not `browseProducts`.** Chapter 5 made
`browseProducts` a connection, so the entities are one level below the root
field. The path is how the router knows where to put the second fetch's answers
back.

**2. Four fields cross the boundary and there is still one fetch.** The
`dependencies` array has four entries, one per field the client asked for:

```
price               isUserRequested: true   dependsOn catalog.Product.id  isKey: true
availableQuantity   isUserRequested: true   dependsOn catalog.Product.id  isKey: true
averageRating       isUserRequested: true   dependsOn catalog.Product.id  isKey: true
reviews             isUserRequested: true   dependsOn catalog.Product.id  isKey: true
```

Deduplicated, the whole array says one thing: `catalog.Product.id`, `isKey`
true, `isRequires` false. Four fields on one key is one round trip. So the
array is per user-requested field rather than per fetch, and its length is not
a count of anything expensive.

**3. The planner lifts literal arguments out into variables.** The client sent
`first: 3` and `first: 2`; the plan says `$a` and `$b`. Measured three ways:

- `first: 3`, `first: 5` and `first: 7` on a two-field query produce plans that
  are identical as JSON strings.
- The storefront query at `(3, 2)` and at `(7, 4)` likewise: `JSON.stringify`
  of the two plans compares equal.
- A client that declares its own variables properly gets a **different** plan
  document. `query Storefront($first: Int!, $reviews: Int!)` normalises to
  `query Storefront($a: Int!, $b: Int!){...}`, keeping the operation name and
  the non-null types, where the inlined form gives `query($a: Int, $b: Int)`.
  Compared with `===`: false.

Careful about what that last one licenses. It shows the two plan *documents*
differ, not that a plan cache keyed on them holds two entries. Chapter 17 owns
the cache. What is fair to say is that inlining literals costs nothing here,
because the planner takes them out again.

## E. Configuring it

`router/config.yaml` at tag `ch10` sets five things: `version`,
`execution_config`, `listen_addr`, `dev_mode` and `log_level`. The schema at
0.337.1 accepts **66 top-level keys**, counted from
`Object.keys(schema.properties).length`, with `additionalProperties: false` at
the root, so a misspelt key is a startup failure rather than a setting that
does nothing. [source]

**A misspelt key is a startup failure, and that is measured rather than
inferred from `additionalProperties: false`.** Cosmo's configuration page
frames the schema as an editor aid, so the runtime consequence needed its own
run. `dev_mode` written `dev_moed`, everything else unchanged: the container
exits 1 before serving anything.

```
Could not load config: errors while loading config files: router config validation error for /etc/mosaic-router/config.yaml: jsonschema validation failed with 'https://raw.githubusercontent.com/wundergraph/cosmo/main/router/pkg/config/config.schema.json#'
- at '': additional properties 'dev_moed' not allowed
```

Defaults worth knowing, all from the schema:

| Key | Default | Why it matters here |
|---|---|---|
| `listen_addr` | `localhost:3002` | Inside a container that is the container's own loopback. Mosaic sets `0.0.0.0:3002` |
| `localhost_fallback_inside_docker` | `true` | Section I |
| `query_plans_enabled` | `true` | But only served to a signed request or in dev mode |
| `playground.enabled` / `playground.path` | `true` / `/` | The router serves an IDE at its root |
| `introspection.enabled` | `true` | `introspection_enabled` is the deprecated spelling |
| `health_check_path` | `/health` | |
| `readiness_check_path` | `/health/ready` | |
| `liveness_check_path` | `/health/live` | |
| `execution_config.file.watch` | `false` | |
| `execution_config.file.watch_interval` | `1s`, minimum `100ms` | |
| `watch_config.enabled` | `false` | A different watcher, for `config.yaml` |
| `router_config_path` | - | **Deprecated** in favour of `execution_config.file` |
| `subgraph_error_propagation.mode` | `wrapped` | Why section F's error says so little |

Measured, all three endpoints answer 200 with the body `OK`: `/health`,
`/health/ready`, `/health/live`. `/metrics` on the GraphQL port answers 404,
because Prometheus is served on `127.0.0.1:8088` inside the container.

### The config file beats the environment variable

Documented: "Values specified in the config file have precedence over
Environment variables. This also includes empty values so only specify values
that should be overwritten."~[web]

And announced by the router itself, on the second line of its startup log:

```
INFO cmd/main.go:125 Config file provided. Values in the config file have higher priority than environment variables
```

Measured both ways, because a precedence claim needs a control:

| Run | `config.yaml` | environment | debug lines in the startup log |
|---|---|---|---|
| control | none | `LOG_LEVEL=debug` | 9 |
| experiment | `log_level: info` | `LOG_LEVEL=debug` | 0 |

Both runs also set `DEV_MODE`, so that the only difference between them is
where `log_level` comes from. Committed as `config-beats-env` in
`scripts/router-cases.mjs`.

This is the opposite of what twelve-factor tooling trains you to expect, and it
matters most where it is least visible: a deployment that sets `LOG_LEVEL` or
`LISTEN_ADDR` in its orchestrator, against an image carrying a `config.yaml`
that also names them, silently gets the file's values.

**A counting trap worth recording.** The first version of the case counted zero
debug lines in both runs and would have reported the finding backwards had the
control not been there. The router colours its log, so ` DEBUG ` never matches:
the bytes are an escape sequence, `DEBUG`, another escape sequence. The case
strips ANSI before matching, the way chapter 9's `composition-cases.mjs` does.

### Hot reload

`execution_config.file.watch: true`. Reproduced by
`node scripts/measure-router.mjs --reload`, which composes a config from a
schema with one field removed, drops it over the watched file, polls
introspection every 100 ms, and restores the healthy config afterwards.

Two runs: the change appeared after **1,090 ms** and **1,326 ms** at a 1 s watch
interval, with **zero** failed requests on either. The router logs

```
INFO core/router.go:1744 Config file changed. Updating server with new config {"watcher_label": "execution_config", "path": "/etc/mosaic/supergraph.json"}
```

Three follow-ups, because a bind-mounted single file is the obvious way for
this to break:

- Mounting the file on its own rather than its directory works. An in-place
  overwrite fires the watcher.
- `wgc router compose -o <the mounted path>` writes **in place**: the inode is
  the same before and after, and the measurement script asserts it on every
  run. So `docker-compose.yml` can bind the single file, as chapter 7's already
  does, and recomposing on the host swaps the graph over.
- **The watcher reads the modification time, not the content.** Found by
  falling into it: the first version of the measurement script restored the
  healthy config with `copyFileSync`, and the router went on serving the thin
  graph for minutes afterwards. On Windows `copyFileSync` carries the source's
  mtime across, so the restored file looked older than the graph already
  loaded. Confirmed from the other side by rewriting the committed config with
  byte-identical content: the router reloaded 2,000 ms later. The script now
  writes bytes rather than copying, and says why in a comment.

## F. The config chapter 9 could not test

Chapter 9's section H composed the `unsatisfiable-key` pair with
`--disable-resolvability-validation` and looked at the file. This is what a
router does with it. Reproduced as `resolvability-off` in
`scripts/router-cases.mjs`.

The setup, unchanged from chapter 9: Mosaic's `Product` gets
`@key(fields: "id", resolvable: false)`, one edit, matched exactly once. Without
the flag the composer reports four unresolvable-path errors and writes nothing.
With it, a config, whose `engineConfig.graphqlSchema` is `===` identical to the
healthy one and whose only flag-attributable difference is
`keys[0].disableEntityResolver: true`.

Measured, in order:

1. **The router starts.** `/health` answers 200. Warning lines in the startup
   log mentioning resolvability, unreachable fields, entities or subgraphs: 0.
   Eleven lines, like any other start, and counted rather than assumed after
   the audit questioned it. One line differs from Mosaic's router and it is
   nothing to do with the graph: this case's config does not set
   `execution_config.file.watch`, so `core/router.go:1715 Watching config file
   for changes` is replaced by `core/router.go:1722 Static execution config
   provided. Polling and watching is disabled.`
2. **A query that stays inside Catalog is fine.**
   `{ browseProducts(first: 2) { nodes { title sku } } }` answers 200 with data.
3. **A query that crosses fails with HTTP 500** and a body that says nothing:

   ```json
   {"errors":[{"message":"internal server error"}]}
   ```

4. **The log has the real cause, and it names the wrong type:**

   ```
   1 error occurred: * printOperation planner id: 1: validation failed: external: Cannot query field "price" on type "Query"., locations: [], path: [query]
   ```

   `price` is not a field of `Query` and never was. Unable to route through an
   entity it may not enter, the planner built a subgraph document that asks for
   the field at the root, and that document failed validation against Mosaic's
   schema. The message is about the operation the planner printed, not about the
   query the client sent.

5. **It fails at plan time, not fetch time.** The request logger records
   `"latency": 0.000822445` and the same 500 comes back with
   `X-WG-Skip-Loader: true` set, which means no subgraph was called at all.

So the flag does exactly what its help text warns: it moves a build-time error
that names four fields and the path to each of them into a request-time 500
that names nothing, for the subset of queries that cross a boundary.

## G. What the router exposes, and what it does not

Introspected at `http://localhost:3002/graphql`, 2026-08-09.

| Name | Present in the router's schema |
|---|---|
| `_Service`, `_Entity`, `_Any` | absent |
| `FieldSet` | **present** |
| `Node`, `Product`, `PageCursor` | present |

39 types in total. `Product` has all nine fields from both services and still
`implements Node`.

`{ _service { sdl } }`, `{ _entities(representations: []) { __typename } }` and
`{ node(id: "...") { id } }` are all rejected with `Cannot query field "X" on
type "Query"`. The first two exist on both subgraphs; the third exists on
neither, since chapter 8 passed `registerNodeInterface: false` in both services.

`scalar FieldSet` reaching the client is chapter 9's open item, now measured
from the outside rather than inferred: it is in the router's schema and any
client can see it. Chapter 9 said "visible to anyone who introspects the
router", and that is now a measurement.

### Same document, four differences from a subgraph

Sent to the router and to Catalog:

| | router | Catalog (HotChocolate 16.6.0) |
|---|---|---|
| `{ _service ... _entities ... node ... }` | HTTP 200, 1 error, names `_service` | HTTP 400, 1 error, names `node` |
| `{ nope1 nope2 nope3 }` | HTTP 200, 1 error, names `nope1` | HTTP 400, 3 errors, names all three |

Three of those are real differences: the status code, the number of errors
reported, and the wording. The router writes

```
Cannot query field "node" on type "Query".
```

and HotChocolate writes

```
The field `node` does not exist on the type `Query`.
```

The fourth row is not a difference at all: Catalog names only `node` because
`_service` and `_entities` do exist there.

### A counting mistake worth recording

The first pass at the introspection above asked `__schema { queryType { fields
{ name } } }` and got five root fields, with no `products` among them. That was
the query, not the router: introspection hides deprecated fields unless
`includeDeprecated: true` is passed. With it, six fields, `products` among them,
carrying chapter 5's deprecation reason, and the field still answers with all
25 products. Chapter 9's decision 59 is the rule that caught this: a count is of
a thing, not of what a default happened to return.

## H. Measurements

All on the author's machine, 2026-08-09. Router 0.337.1 in a container reaching
the host through `host.docker.internal`; both subgraphs under `dotnet run` on
the host. 60 timed requests after 15 warm-up requests per row, every row in the
same run, back to back.

Reproduced by `node scripts/measure-router.mjs`, committed at tag `ch10`. It is
deliberately **not** part of the verification gate: these are single-machine
timings, and a gate that asserts them fails on a busier laptop. The audit found
the first version of this section printing numbers with no harness behind them
and no recipe in section K, which is decision 55's rule about listings applied
to measurements.

Two passes against the composed `mosaic-router` on 3002, medians in ms. These
two are the ones chapter 10 prints:

| Row | pass 1 | pass 2 |
|---|---|---|
| catalog direct, titles only | 1.1 | 1.4 |
| router, titles only (one fetch) | 3.3 | 4.5 |
| mosaic direct, `_entities` for 10 products | 1.9 | 2.4 |
| the two calls by hand, in sequence | 3.7 | 3.9 |
| router, the storefront query (two fetches) | 6.2 | 6.4 |
| **derived: router overhead, one fetch** | **2.2** | **3.1** |
| **derived: router overhead, two fetches** | **2.5** | **2.5** |

Earlier passes, taken before the harness was committed and against an
identically configured container, gave one-fetch and two-fetch overheads of
3.2 / 2.6, then 2.9 / 2.5, then 2.2 / 3.6, then 1.7 / 1.8, then 2.3 / 3.1, then
1.9 / 3.7. Seven passes in all.

**What survives all of them**: the router adds roughly 2 to 3 ms to a query on
this machine. **What does not**: any claim that the two-hop overhead differs
from the one-hop overhead. The run-to-run spread on that difference is larger
than the difference, which is why the table prints two passes rather than one.

The caveat chapter 7's open item records applies unchanged and is the reason
these are upper bounds: the router reaches the subgraphs across Docker's bridge
and out through a published port, while the direct rows are loopback on the
host. A router next to its subgraphs pays less than this.

Other numbers:

| Thing | Value |
|---|---|
| Top-level keys the router config schema accepts | 66 |
| Keys `router/config.yaml` sets | 5 |
| A misspelt top-level key | exit 1 before serving, schema validation error |
| Lines in the startup log | 11, of which 3 are warnings |
| Same, for a config with no `watch` | also 11; line 10 differs, naming a static config rather than a watched one |
| Selections in the storefront document | 14 |
| Types in the router's schema | 39 |
| Root fields, `includeDeprecated` false / true | 5 / 6 |
| Hot reload, at a 1 s watch interval | 1,323 ms, 0 failed requests |
| Hot reload after a recompose into the mounted path | picked up within 200 ms |
| Mosaic's half of the storefront query, warm | 19 resolvers, 6 SQL, 5 service lookups |
| Mosaic's half, cold | the same counts, 93.9 ms execute, both caches missed |
| Catalog's half | not reported by anything |
| Crossing query on a resolvability-off config | HTTP 500, 0.0008 s, no subgraph called |

## I. Where docs and behaviour disagree

- **The config file beats the environment variable.** Documented and announced
  in the log, and still the opposite of the convention every container runtime
  trains for. Section E.
- **`localhost` in a routing URL works from inside a container**, because
  `localhost_fallback_inside_docker` defaults to `true` and rewrites it to
  `host.docker.internal`. Nothing in the composed config, the router's log or
  the request says this happened. Control: with the setting `false` and
  everything else identical, the same query answers
  `{"errors":[{"message":"Failed to fetch from Subgraph 'catalog'."}]}` with
  HTTP 200 and `data: null`. Committed as `localhost-fallback`.
- **A failed fetch is an HTTP 200.** The GraphQL convention, and worth stating
  because a health check or a load balancer reading status codes will see
  nothing wrong with a graph that is answering nulls. The wrapped error names
  the subgraph and nothing else; at `info` with dev mode on, the router's own
  log adds only that the request errored, not why the dial failed.
- **Two settings named "config file".** Section B.
- **`router_config_path` is deprecated**, and the environment variable chapter 7
  used, `EXECUTION_CONFIG_FILE_PATH`, is not: it is the env form of
  `execution_config.file.path`. The deprecation is on the older YAML key alone.

- **A claim chapter 9 and an early draft of chapter 10 both got wrong.**
  Chapter 9 closes by saying a router will answer a cross-boundary question
  "for the first time anything in this book will have answered one across a
  boundary without me assembling the answer by hand", and chapter 10's first
  draft said the same of its storefront answer. Chapter 7's sample router did
  it first. Chapter 10 now says "the first answer about Mosaic"; chapter 9's
  sentence is still there and is in the open items.

## J. What the gate asserts

Added to `scripts/verify.ps1` and `scripts/verify.sh` at tag `ch10`, as section
8c, after the composed config has been checked against a fresh compose and
before chapter 7's wire section, which publishes the same port:

```
[ok]   the router answers on http://localhost:3002/health
[ok]   the router answers the query neither subgraph can
[ok]   the router behaves the three ways chapter 10 says it does
```

The middle one is `postman/mosaic-router.postman_collection.json`: seven
requests, 23 assertions, all against the router. The storefront query and the
fields from both services in its answer; the plan, including
`path: browseProducts.nodes` and the four dependencies on one key; the same plan
for `first: 7`; the three fields the router will not answer and the single error
it reports for them; `Product` with nine fields and the deprecated root field
hidden by default; and readiness.

The last one is `scripts/router-cases.mjs`, which is to chapter 10 what
`composition-cases.mjs` is to chapter 9: one node implementation, called by both
verify scripts, starting real containers.

```
node scripts/router-cases.mjs --list

config-beats-env    a value in config.yaml wins over the environment variable for it
localhost-fallback  localhost in a routing URL reaches the host, until you turn that off
resolvability-off   a graph composed with --disable-resolvability-validation, in front of a router
```

Each case carries its own control, which is the part worth keeping: the
precedence case fails loudly if `LOG_LEVEL=debug` stops producing debug lines
at all, and the fallback case fails if the query succeeds with the fallback off.
Without those, both would pass against a router that had simply stopped
answering.

Captured from a passing `pwsh scripts/verify.ps1` run on 2026-08-09, 33 steps,
`PASS`.

## K. Reproduction recipes

Needs Docker, the .NET SDK and node.

```
git checkout ch10
npm ci

docker compose up -d mosaic-db
dotnet run --project src/Mosaic.Catalog     # 5101
dotnet run --project src/Mosaic.Api         # 5100
docker compose up -d mosaic-router          # 3002
```

The query, and the plan behind it:

```
curl -s http://localhost:3002/graphql -H 'Content-Type: application/json' \
  -d '{"query":"{ browseProducts(first: 3) { nodes { title price { amount currency } availableQuantity averageRating reviews(first: 2) { totalCount nodes { rating author { displayName } } } } } }"}'

curl -s http://localhost:3002/graphql -H 'Content-Type: application/json' \
  -H 'X-WG-Include-Query-Plan: true' -H 'X-WG-Skip-Loader: true' \
  -d '{"query":"{ browseProducts(first: 3) { nodes { title price { amount } } } }"}'
```

The three cases, and the evidence behind each:

```
node scripts/router-cases.mjs
node scripts/router-cases.mjs --print resolvability-off
node scripts/router-cases.mjs --print config-beats-env
```

The latency table and the hot-reload timing, which are not gated:

```
node scripts/measure-router.mjs            # run it twice, and print both
node scripts/measure-router.mjs --reload
```

Hot reload by hand, with the router up:

```
npx wgc router compose -i federation/mosaic.yaml -o federation/supergraph.json
docker compose logs mosaic-router | grep "Config file changed"
```

The plan claims the lab's exercises 2 and 3 rest on, checked before they were
written into the lab: removing one field at a time from the storefront
selection gives 4, 3, 2 then 1 entries in `dependencies` with the fetch count
staying at 2, and removing `reviews` as well collapses it to a single fetch
with no `dependencies`. Two independent root fields
(`browseProducts` and `customerById`) plan as a `Sequence` whose single child
is a `Parallel` of two `Single` fetches.

A misspelt configuration key, which the chapter prints:

```
# change dev_mode to dev_moed in a copy of router/config.yaml, start a router
# on it, and read `docker logs`: exit 1, jsonschema validation failed.
```

The config schema, at the pinned version:

```
curl -sL -o config.schema.json \
  "https://raw.githubusercontent.com/wundergraph/cosmo/router%400.337.1/router/pkg/config/config.schema.json"
node -e "console.log(Object.keys(require('./config.schema.json').properties).length)"
```

## L. Left unmeasured, and who owns it

- **The plan cache.** Section D shows two documents planning to the same JSON
  and a third planning to different JSON. Whether the router keyed a cache on
  any of that was not measured. Chapter 17.
- **Mutations and subscriptions through the router.** `submitReview` and
  `onReviewAdded` are in the router's schema and neither was sent. Chapters 12
  and 14, which already own them.
- **`subgraph_extension_propagation`.** The setting exists and would carry a
  subgraph's `extensions` object through to the client, which is one way to see
  both services' request timelines in one response. Mosaic emits no extensions,
  so it would demonstrate nothing here. Chapter 23.
- **A subgraph that is down, slow, or erroring.** Section I has one accidental
  data point from the fallback control and nothing deliberate. Chapter 24.
- **Header forwarding.** Chapter 7 measured that the router forwards nothing by
  default; the `headers` config block that changes this was not exercised.
  Chapter 15 needs it for claim forwarding.
- **Everything the router does that is not routing**: traffic shaping, rate
  limits, CORS, persisted operations, authentication, batching, cache warmup,
  modules, MCP. 61 of the 66 top-level keys are untouched. Chapters 15, 21, 23,
  24 and 25 between them own most of that surface.
- **The Prometheus endpoint** on `127.0.0.1:8088` was seen in the startup log
  and never scraped. Chapter 23.
- **`overrides.subgraphs.routing_url`.** Named in the compose comments and in
  the chapter as the deployment answer to section I's localhost rewriting, and
  not exercised, because Mosaic does not need it. Chapter 21 or 22.
- **Whether Catalog's missing instrumentation is worth fixing.** Chapter 23.

## M. Bibliography keys

Reused:

- `cosmo2026queryplan` - the three query-plan request headers, cited in chapter
  7 and again here for the two this chapter uses.

New:

- `cosmo2026routerconfiguration` - the router configuration page, for the
  precedence sentence quoted in section E. URL
  https://cosmo-docs.wundergraph.com/router/configuration

Everything else in this chapter is measured, or read out of the configuration
schema at `router@0.337.1`, which carries the defaults and the deprecation
messages and is the authority for them in a way no prose page is.
