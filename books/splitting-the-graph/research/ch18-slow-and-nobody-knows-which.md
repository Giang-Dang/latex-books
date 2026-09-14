# Chapter 18 - Slow, and Nobody Knows Which Subgraph

Research note for the ninth and last chapter of part III: what a federated
request carries through the router into each subgraph that would attribute
its cost or its failure to a service, where that trail stops, and what the
router's caches do and do not save.

Web sources accessed **2026-09-14**; everything else was measured on this
machine on the same date.

Five things are worth stating before any of it.

**The router already mints a trace id per request and sends it to every
subgraph.** With no `telemetry` block at all, no graph token and no exporter,
each subgraph fetch carries a W3C `traceparent` whose trace id is the same for
all three fetches of the canonical page and whose parent id differs per fetch.
The router's own access log line records the same id, beside the
`config_version` chapter 8 read as thirty-two zeroes.

**The id stops at every seam, and not because anything drops it.** ASP.NET
Core adopts the incoming `traceparent` as `Activity.Current` in each service
with the book's unmodified `Program.cs`: inside the Ratings service the
current activity's trace id is the router's, and its parent span id is the
parent id the router sent that fetch. Nothing prints it. The console
formatter's scopes are off by default, `StatementLog` writes a number and the
SQL, and the router does not return the id to the client.

**A resolver exception is written nowhere by Hot Chocolate.** The router's
error names the service in `extensions.serviceName`; the service answers
`Unexpected Execution Error`; and unless the exception came out of EF Core,
which logs its own failures, the service's console holds nothing at all for
the request, with scopes on or off. A diagnostic event listener is what writes
it, and registering one that takes an `ILogger<T>` needs that logger added as
an application service first or the host refuses to start.

**The router's caches never save a subgraph a statement.** The execution plan
cache answers `HIT` on a repeated page and each service still spends its one
statement. `cache_control_policy` writes a `Cache-Control` for whoever sits in
front of the router, taking the most restrictive value over the subgraphs a
request actually reached, treating a subgraph with no value as having no
opinion, forcing `no-store` on any response with errors, and marking a
response that carried a bearer token and a guarded column `public` when the
global value says `public`.

**The response cache in WunderGraph's current documentation is not in the
router this book pins.** `router@0.341.0` refuses a `response_cache` key as an
unknown property. Documentation and machine disagree; the machine wins and
the chapter says the pinned router has no response cache.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| `wgc` | 0.129.9, `@wundergraph/composition` 0.63.3 |
| Cosmo Router | 0.341.0, go1.26.6 |
| Baseline before this chapter | `verify.ps1` PASS at 607, tag `ch17` |
| After this chapter | see Tags below |

All experiments were run in a detached worktree of the verification repo at
tag `ch17`, with `tools/router.exe` copied in and every `*.db` deleted before
each start (the chapter 4 mutation trap recorded in the SPEC's open items).
Services were started with `dotnet run --no-build` from their project
directories, as `verify.ps1` starts them.

## 1. What goes over the wire

**Procedure.** A header-recording reverse proxy listening on 6001 to 6004 and
forwarding to 5001 to 5004; a copy of `graph/graph.yaml` whose routing urls
name the proxy ports; `wgc router compose` on that copy; the router started on
the book's `router/config.yaml` with only the execution config path changed.
In `verify.ps1` the proxy is an `HttpListener` in a thread job, so the run
needs nothing but PowerShell. One request:

```
{ sessions(first: 10) { nodes { title speaker { name } averageScore ratingCount } } }
```

**Captured, with the book's config as chapter 17 left it (no telemetry
block):**

```
port 6001 POST ... Traceparent=00-515457460e4ab1a45a57b5b745491f0d-856a85a0e4c3f7c4-01
port 6002 POST ... Traceparent=00-515457460e4ab1a45a57b5b745491f0d-d32570b5eacb6961-01
port 6003 POST ... Traceparent=00-515457460e4ab1a45a57b5b745491f0d-3b798df673db39f6-01
```

Full header set the router sent Sessions on that fetch, verbatim:

```
Host=localhost:6001 | User-Agent=Go-http-client/1.1 | Content-Length=121 | Accept=application/json | Accept-Encoding=deflate | Content-Type=application/json | Traceparent=00-515457460e4ab1a45a57b5b745491f0d-856a85a0e4c3f7c4-01
```

- One trace id across the three fetches, three distinct parent ids.
- No request to 6004: Search is not on this page's plan.
- Response headers to the client, verbatim: `Vary: Accept-Encoding`, `Date`,
  `Content-Length: 463`, `Content-Type: application/json; charset=utf-8`. No
  trace id.
- The router's access log line for the request, verbatim:

```
16:29:42 PM INFO requestlogger/requestlogger.go:206 /graphql {"hostname": "DESK-HOME-GIANG", "pid": 153308, "log_type": "request", "method": "POST", "path": "/graphql", "query": "", "ip": "[REDACTED]", "user_agent": "Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; vi-VN) PowerShell/7.6.5", "config_version": "00000000-0000-0000-0000-000000000000", "trace_id": "515457460e4ab1a45a57b5b745491f0d", "latency": 0.4650941, "status": 200, "request_id": "DESK-HOME-GIANG/P7Owh9okIt-000002"}
```

The line carries `latency`. Decision 19 prints no timings, so the chapter
prints this line with that field and the host-identifying fields removed and
says it did.

Startup log, relevant line verbatim: `No graph token provided. The following
Cosmo Cloud features are disabled. Not recommended for Production.
{... "features": ["Schema Usage Tracking", "Persistent operations", "Cosmo
Cloud Tracing", "Cosmo Cloud Metrics"]}`. So Cosmo Cloud tracing is off and
trace ids are still minted and propagated.

**The same statements, from inside the services.** With `StatementLog`
temporarily printing `Activity.Current?.TraceId`, `SpanId` and `ParentSpanId`
(experiment code, never committed):

```
-- statement 1 trace 28e6f9ac4db57cf00133e557551557d7 span 2b316c3d958f01f7 parent dc275c8ef1914cd7
-- statement 1 trace 28e6f9ac4db57cf00133e557551557d7 span 04698fb1c71bd1e8 parent 0612a0f81b91e9c9
-- statement 1 trace 28e6f9ac4db57cf00133e557551557d7 span d6c737a360f8121d parent 515c62734647c809
```

and the proxy saw `...-dc275c8ef1914cd7-01` for Sessions,
`...-0612a0f81b91e9c9-01` for Speakers and `...-515c62734647c809-01` for
Ratings. The parent span id inside each service is exactly the parent id the
router sent that fetch. Nothing in `Program.cs` was changed for this.

**A client's own trace.** Sending
`traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01` to the
router: the router's log line carries `trace_id` `0af7651916cd43dd8448eb211c80319c`,
all three subgraphs receive that trace id with new parent ids, and (with the
response header on) `X-Wg-Trace-Id: 0af7651916cd43dd8448eb211c80319c`. The
router continues a client's trace rather than starting its own. `verify.ps1`
asserts this with the W3C specification's own example id,
`4bf92f3577b34da6a3ce929d0e0e4736`.

## 2. The response header

Config appended to the book's `config.yaml`:

```yaml
telemetry:
  tracing:
    response_trace_id:
      enabled: true
```

Response header, verbatim as .NET prints it: `X-Wg-Trace-Id:
28e6f9ac4db57cf00133e557551557d7`. `telemetry.tracing.enabled` was not set.
The header name on the wire is Go's canonical form of the documented default
`x-wg-trace-id`. Two consecutive requests get different ids.

Config schema at tag `router@0.341.0`
(`router/pkg/config/config.schema.json`, fetched with `gh api`):
`response_trace_id` has `enabled` (no default declared) and `header_name`
(default `x-wg-trace-id`). The same schema declares `tracing.enabled` with
`"default": false`, and the documentation's configuration table gives
`TRACING_ENABLED` a default of `true`. **The two disagree and no chapter says
which is right**: what was measured is that ids are minted and propagated with
the key absent, which is consistent with the documentation's value.

## 3. Logging scopes, and a configuration trap

ASP.NET Core's logging scope already carries the ids (Microsoft documents
`SpanId`, `TraceId` and `ParentId` as enabled by default). The simple console
formatter does not print scopes unless told to.

Measured, one fresh `pwsh` process per variant, each a request to the Ratings
service with `Microsoft.AspNetCore` raised to Information so a hosting line is
logged:

| Setting | Scope line printed |
|---|---|
| nothing | no |
| `Logging__Console__FormatterOptions__IncludeScopes=true` | **no** |
| same, in `appsettings.json` | **no** |
| `Logging__Console__FormatterName=simple` plus the above | yes |
| `Logging__Console__IncludeScopes=true` (the obsolete `ConsoleLoggerOptions` property) | yes |
| `builder.Logging.AddSimpleConsole(o => o.IncludeScopes = true)` in code | yes |

The first two "no" rows are the trap: `FormatterOptions` is the documented
place and on its own it is ignored. The book ships the `FormatterName` form in
`appsettings.json`, which is the one that uses the non-obsolete options type.
Why the formatter options are not bound without a formatter name was **not
established**; the table is what was measured.

Scope line as printed, verbatim:

```
info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
      => SpanId:a0b11df03c7561f0, TraceId:11111111111111111111111111111111, ParentId:2222222222222222 => ConnectionId:0HNOI8E1UO03U => RequestPath:/graphql RequestId:0HNOI8E1UO03U:00000001
      Request starting HTTP/1.1 POST http://localhost:5003/graphql - application/json 166
```

(The `traceparent` here was sent by hand, which is why the ids are ones and
twos.)

## 4. Failures

**A database failure.** The Ratings table renamed out from under the running
service (`ALTER TABLE Ratings RENAME TO ...`). Through the router, the page
answers 200 with every title and speaker present, `averageScore` and
`ratingCount` null on all four sessions, and one outer error. Verbatim, trimmed
in the middle only by removing six of the eight identical inner errors:

```
{"errors":[{"message":"Failed to fetch from Subgraph 'ratings' at Path 'sessions.nodes'.","extensions":{"errors":[{"message":"Unexpected Execution Error","path":["sessions","nodes","averageScore"],"extensions":{"code":"DOWNSTREAM_SERVICE_ERROR"}},{"message":"Unexpected Execution Error","path":["sessions","nodes","ratingCount"],"extensions":{"code":"DOWNSTREAM_SERVICE_ERROR"}}, ... ],"serviceName":"ratings","statusCode":200}}],"data":{...}}
```

Eight inner errors: two fields on four sessions. Response header
`Cache-Control: no-store, must-revalidate, no-cache`, with no policy
configured. EF Core logged the failure itself (`fail:
Microsoft.EntityFrameworkCore.Database.Command[20102]` and `fail:
Microsoft.EntityFrameworkCore.Query[10100]` with `SqliteException ... no such
table: Ratings`), without any trace id while scopes were off.

**A resolver exception that is not the database's.** `GetFeedbackUrl` in the
Ratings service changed, in the experiment worktree only, to throw
`InvalidOperationException`. Page `{ sessions(first: 10) { nodes { title
feedbackUrl } } }` through the router: 200, four `Unexpected Execution Error`
inner errors at `sessions.nodes.feedbackUrl`, `serviceName` `ratings`. The
Ratings console received **zero lines** for the request, with scopes off and
again with scopes on. No tagged state produces this, so under decision 53 the
chapter describes it and quotes no log. Chapter 9 already recorded the same
silence for the entity route without its serializer (decision 86).

A second measurement of the same shape: an `_entities` representation carrying
`"id":"not-a-node-id"` sent directly to Ratings answers
`{"errors":[{"message":"The node ID string has an invalid format.","path":["_entities"],"extensions":{"originalValue":"not-a-node-id"}}],"data":{"_entities":[null]}}`
and logs nothing either. Not used in the chapter.

**The listener.** `ExecutionDiagnosticEventListener.ResolverError(IMiddlewareContext, IError)`
compiles against 16.6.1 and fires once per resolver error. Registration
attempts:

1. `.AddDiagnosticEventListener<ErrorLog>()` with `ErrorLog(ILogger<ErrorLog>)`:
   compiles; the host refuses to start: `System.InvalidOperationException:
   Unable to resolve service for type
   'Microsoft.Extensions.Logging.ILogger`1[Ratings.LabErrorLog]' while
   attempting to activate 'Ratings.LabErrorLog'.` (logged as `fail:
   Microsoft.Extensions.Hosting.Internal.Host[11] Hosting failed to start`).
   Listeners are built from the schema's service provider.
2. `sp.GetApplicationService<T>()`: does not exist on 16.6.1 (`CS1061`).
3. `.AddApplicationService<ILogger<ErrorLog>>()` followed by
   `.AddDiagnosticEventListener<ErrorLog>()`: starts and works. This is what
   ships. (`GetRootServiceProvider` also exists in the 16.6.1 assemblies and
   was not tried.)

With the thrown exception and the listener, the Ratings log, verbatim for one
of the four entries (stack trimmed):

```
fail: Ratings.LabErrorLog[0]
      => SpanId:4d3fec897e4590bb, TraceId:ebcf167de4ca77b33caa63f52c5acd89, ParentId:715d82eca5efd472 => ConnectionId:0HNOI8L4Q7DAJ => RequestPath:/graphql RequestId:0HNOI8L4Q7DAJ:00000001
      _entities Unexpected Execution Error
      System.InvalidOperationException: lab: feedback service unavailable
```

`context.Path` in that experiment printed `_entities` only. The shipped
listener logs `error.Path` instead, which gives the item index and field.

**On `main` after the chapter**, the database failure through the router,
Ratings log, verbatim for the first `ErrorLog` entry, stack trimmed after the
exception line:

```
fail: Ratings.ErrorLog[0]
      => SpanId:161a2ce1c7f840fc, TraceId:262e3e16a3ca9dd8da4553a6834b0426, ParentId:d28132b2876aef8a => ConnectionId:0HNOI8R7TFM49 => RequestPath:/graphql RequestId:0HNOI8R7TFM49:00000004
      _entities[0].ratingCount: Unexpected Execution Error
      Microsoft.Data.Sqlite.SqliteException (0x80004005): SQLite Error 1: 'no such table: Ratings'.
```

Eight `fail: Ratings.ErrorLog` entries for the eight inner errors, every scope
line carrying the response header's trace id, and the statement that failed
printed as `-- statement N trace <same id>`.

## 5. The router's caches

**Operation caches.** Config `engine.debug.enable_cache_response_headers:
true`. Measured sequence, statements per service in order sessions, speakers,
ratings, search:

| Request | Plan cache | Normalization cache | Statements |
|---|---|---|---|
| page, first time | MISS | MISS | 1 1 1 0 |
| page, second time | HIT | HIT | 1 1 1 0 |
| page, third time | HIT | HIT | 1 1 1 0 |
| sessions titles only | MISS | MISS | 1 0 0 0 |
| same again | HIT | HIT | 1 0 0 0 |
| page, whitespace removed | HIT | MISS | 1 1 1 0 |
| page, `first: 2` | HIT | MISS | 1 1 1 0 |

Also emitted on every response: `X-Wg-Persisted-Operation-Cache: MISS`,
`X-Wg-Variables-Normalization-Cache`, `X-Wg-Variables-Remapping-Cache`. No
`Cache-Control` on any healthy response.

**`cache_control_policy`, static values.**

```yaml
cache_control_policy:
  enabled: true
  value: "max-age=180, public"
  subgraphs:
    - name: ratings
      value: "max-age=60, public"
```

| Request | `Cache-Control` |
|---|---|
| sessions titles | `public, max-age=180` |
| sessions and speakers | `public, max-age=180` |
| sessions and ratings | `public, max-age=60` |
| the page | `public, max-age=60` |
| page with the Ratings table missing | `no-store, must-revalidate, no-cache` |
| sessions only, Ratings table still missing | `public, max-age=180` |

**Headers sent by subgraphs.** Policy enabled with no values; the proxy
replaced the subgraph response header, `Cache-Control: max-age=300, public`
from Speakers and `private, max-age=30` from Ratings; Sessions sent none
(the proxy logged each response's original headers before replacing them, and none of the three services sent a `Cache-Control` of its own).

| Request | `Cache-Control` |
|---|---|
| sessions titles | none |
| sessions and speakers | `public, max-age=300` |
| sessions and ratings | `max-age=30, private` |
| the page | `max-age=30, private` |

So `private` is kept when any subgraph says it, which the documentation's
algorithm does not mention. A proxy-injected header is not reproducible by a
reader, so the chapter uses the static per-subgraph form for the silence case
and `verify.ps1` asserts it that way: policy enabled, no global value,
`speakers` at `max-age=300, public`; titles only get no header, titles and
speakers get `public, max-age=300`.

**An authorized response.** Policy at global `max-age=180, public`, request
`{ sessions(first: 10) { nodes { title speaker { name email } } } }`:

- no token: 200, errors (`The current user is not authorized to access this
  resource.` at `sessions.nodes.@.speaker.email`), `Cache-Control: no-store,
  must-revalidate, no-cache`.
- with the chapter 12 bearer token: 200, `ada@example.test` in the data,
  `Cache-Control: public, max-age=180`, `Vary: Accept-Encoding`.

RFC 9111 section 3.5, verbatim: "A shared cache MUST NOT use a cached response
to a request with an Authorization header field (Section 11.6.2 of [HTTP]) to
satisfy any subsequent request unless the response contains a Cache-Control
field with a response directive (Section 5.2.2) that allows it to be stored by
a shared cache, and the cache conforms to the requirements of that directive
for that response." And: "In this specification, the following response
directives have such an effect: must-revalidate (Section 5.2.2.2), public
(Section 5.2.2.9), and s-maxage (Section 5.2.2.10)." Fetched from
https://www.rfc-editor.org/rfc/rfc9111.txt.

The router also answers a query sent as `GET /graphql?query=...` with 200 and
data, measured once. That matters because a shared cache in front of a router
will generally see GET requests and not POST ones; the chapter states the RFC
rule and the header, and makes no claim about any particular CDN.

**The response cache.** A config with `response_cache: { enabled: true }`,
router exits 1:

```
Could not load config: errors while loading config files: router config validation error for config.yaml: jsonschema validation failed with 'https://raw.githubusercontent.com/wundergraph/cosmo/main/router/pkg/config/config.schema.json#'
- at '': additional properties 'response_cache' not allowed
```

The schema fetched at tag `router@0.341.0` has no `response_cache` key.
WunderGraph's documentation page *Response Cache (Experimental)* describes one,
"in alpha", "disabled by default", caching entity fetches and root query
fetches by their `Cache-Control`. It describes a router later than the one
this book pins.

## 6. The two states the chapter argues from

**`ch18-blind`**: tag `ch17`'s tree with the Speakers reference resolver
replaced by chapter 10's naive form (`SpeakerContext db` injected,
`.Where(s => s.Id == key).FirstOrDefaultAsync(ct)`). Its own `verify.ps1`
asserts: the page response is byte-identical to the healthy one; statements
1, 3, 1, 0; each Speakers statement is `WHERE "s"."Id" = @key`; no
`X-Wg-Trace-Id`; the router logs one line with a trace id, no service log line
contains it, and every statement marker is a bare number.

**`ch18-naive`**: tag `ch18`'s tree with the same resolver. Its `verify.ps1`
asserts the same response and counts, that the header equals the router's
logged id, and that searching the four logs for each of two requests' ids
finds 1, 3, 1 and 0 statements.

### What the chapter prints from these two runs

From the `ch18-blind` run (router log `stg-ch18state-router.log`, Speakers
console `stg-ch18state-Speakers.log`, both in the temp directory):

Router request line, verbatim before trimming:

```
17:10:09 PM INFO requestlogger/requestlogger.go:206 /graphql {"hostname": "DESK-HOME-GIANG", "pid": 46096, "log_type": "request", "method": "POST", "path": "/graphql", "query": "", "ip": "[REDACTED]", "user_agent": "Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; vi-VN) PowerShell/7.6.5", "config_version": "00000000-0000-0000-0000-000000000000", "trace_id": "1cd345017494455980971dceaf195769", "latency": 0.4635516, "status": 200, "request_id": "DESK-HOME-GIANG/R1joa1oI8w-000002"}
```

Section 18.1 prints it with the timestamp, `hostname`, `pid`, `query`, `ip`,
`user_agent`, `latency` and `request_id` removed, and says so.

Speakers console for the page, verbatim:

```
-- statement 1
SELECT "s"."Id", "s"."Bio", "s"."Email", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" = @key
LIMIT 1
-- statement 2
SELECT "s"."Id", "s"."Bio", "s"."Email", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" = @key
LIMIT 1
-- statement 3
SELECT "s"."Id", "s"."Bio", "s"."Email", "s"."Name"
FROM "Speakers" AS "s"
WHERE "s"."Id" = @key
LIMIT 1
```

Response headers for the page, as `Invoke-WebRequest` reports them: `Vary:
Accept-Encoding`, `Date`, `Content-Length: 463`, `Content-Type:
application/json; charset=utf-8`. The chapter prints them as an HTTP header
block with the date left out.

From the `ch18-naive` run, second page request: `X-Wg-Trace-Id:
327f111c797fd261f05d6bce80d680ca`, and the Speakers console, marker lines:

```
-- statement 4 trace 327f111c797fd261f05d6bce80d680ca
-- statement 5 trace 327f111c797fd261f05d6bce80d680ca
-- statement 6 trace 327f111c797fd261f05d6bce80d680ca
```

Sessions printed `-- statement 2 trace 327f111c797fd261f05d6bce80d680ca`,
Ratings `-- statement 2 trace 327f111c797fd261f05d6bce80d680ca`, Search none.
The first request's id was `b73fc0b9807e8f105839c77bd1666228`, with
statements 1 to 3 in Speakers.

## Tags

| Tag | Tree | `verify.ps1` |
|---|---|---|
| `ch18-blind` | `ch17` plus chapter 10's naive Speakers resolver | its own script, 9 assertions, PASS |
| `ch18` | `ch17` plus this chapter's source changes and blocks | 659 assertions, PASS (607 before) |
| `ch18-naive` | `ch18` plus the naive resolver | its own script, 10 assertions, PASS |

## Sources

| Claim | Source | Byline | Notes |
|---|---|---|---|
| `traceparent` = version, trace-id (16 bytes), parent-id (8 bytes), flags; a vendor receiving one MUST update parent-id for each outgoing request | W3C, *Trace Context*, https://www.w3.org/TR/trace-context/ | W3C Recommendation | standards body, passes unsigned (decision 39) |
| ASP.NET web server decodes and encodes Activity IDs on HTTP messages automatically | Microsoft Learn, *Distributed tracing concepts*, https://learn.microsoft.com/en-us/dotnet/core/diagnostics/distributed-tracing-concepts | unsigned vendor reference | about Microsoft's own runtime |
| `SpanId`, `TraceId`, `ParentId` enabled by default in log scopes; `ParentId` shows the inbound parent-id | Microsoft Learn, *Logging in .NET and ASP.NET Core*, https://learn.microsoft.com/en-us/aspnet/core/fundamentals/logging/?view=aspnetcore-10.0 | unsigned vendor reference | |
| trace context propagation enabled by default; `response_trace_id` puts the id in a response header | WunderGraph, *OpenTelemetry*, https://cosmo-docs.wundergraph.com/router/open-telemetry | unsigned vendor reference | |
| `cache_control_policy` "is false by default" (configuration table row `CACHE_CONTROL_POLICY_ENABLED`, same page as the cache headers row below); cache control algorithm: no-cache and no-store override; smallest max-age; earliest Expires; errors get `no-store, no-cache, must-revalidate` | WunderGraph, *Adjusting Cache Control*, https://cosmo-docs.wundergraph.com/router/proxy-capabilities/adjusting-cache-control | unsigned vendor reference | does not mention `private`; measured above |
| hit/miss headers for the operation caches, default false | WunderGraph, *Router Configuration*, https://cosmo-docs.wundergraph.com/router/configuration | unsigned vendor reference | |
| experimental response cache: "Experimental feature. Response caching is in alpha and is subject to change, and should not be used in production environments."; entity fetch entries "are keyed per entity and per selection set"; "Response caching is disabled by default." | WunderGraph, *Response Cache (Experimental)*, https://cosmo-docs.wundergraph.com/router/response-cache | unsigned vendor reference | refused by 0.341.0 |
| shared cache and Authorization | RFC 9111, section 3.5, https://www.rfc-editor.org/rfc/rfc9111.txt | IETF | |
| Netflix: "In GraphQL, almost every response is a 200 with custom errors in the error block."; "To solve the "who do I ask about..." routing problem, we integrated deep linking from GraphQL types and fields to their owning team's support channels. Finding support is now as simple as clicking a link from a trace, which helps shorten MTTR and reduce the number of times the gateway team needs to get involved." | Tejas Shikhare, *How Netflix Scales its API with GraphQL Federation (Part 2)*, Netflix TechBlog, 2020-12-11, https://netflixtechblog.com/how-netflix-scales-its-api-with-graphql-federation-part-2-bbe71aaec44a | Tejas Shikhare | netflixtechblog.com answers 403; read through https://web.archive.org/web/2023/ with a browser user agent, paragraph text extracted from the page's embedded state; datePublished `2020-12-11T14:32:48.590Z`; four occurrences of the byline in the page |

The web research also turned up a WunderGraph post by Prithwish Nath on
field-level metrics; whether he is an engineer at the company could not be
established, so it fails the Sources rule and is not used. Netflix's *Edgar*
post could not be read verbatim and is not used.

## Claims checked and found false

- "The router needs tracing configured before it propagates a trace id." False:
  propagation and the access log's `trace_id` happen with no `telemetry`
  block, no graph token and Cosmo Cloud tracing reported disabled.
- "`Logging:Console:FormatterOptions:IncludeScopes` in appsettings.json turns
  on scopes." False on its own, measured; needs `FormatterName`.
- "A diagnostic event listener can take an `ILogger<T>` in its constructor."
  False as registered by `AddDiagnosticEventListener<T>()` alone; the host
  refuses to start.
- "The open-source router has a response cache." Not at 0.341.0, which refuses
  the key. The documentation page exists and describes a later router.
- The research brief's `UseQueryCachePolicy` for Hot Chocolate caching: the v16
  documentation names `UseQueryCache()`. Nothing in the chapter uses either,
  and whether Hot Chocolate's cache-control feature emits anything useful
  through a router was not measured.

## Audit, 2026-09-14

One read-only auditor with no drafting context. Accepted and fixed: the
router log line's trim did not admit removing `request_id` and `query`, and
the "only identifier" sentence depended on the cut; the `traceparent` block was
described as a name added in front when the capture was reformatted; a pointer
to section 18.3 printing parent ids it does not print; a validation cache named
in section 18.5 that was never measured; a causal "because" tying the plan hit
to chapter 8's lifted literal, which chapter 8 itself says it cannot explain;
"Hot Chocolate sends no Cache-Control" resting on one service in the note
(the proxy log shows all three sent none, and the note now says so); "most of
whose fields" where the page is titles and names; response-cache phrases and
the policy's default missing from this note (now quoted above); the chapter's
opening sentence saying nobody can tell which service failed while section 18.4
opens on the router naming it; "the second trap" with no first; "the three
edits" credited to service owners when one is the router's; the summary's
caching advice naming the response cache rather than `cache_control_policy`;
the table rename given no command; the email request not printed; `SpanId`
never glossed; the header's casing unexplained; section 18.5's hook misnaming
what 18.4 ends on; "every score" on a page with an unrated session; an
unindexed `Activity`; the resolver-exception claim unqualified in the summary;
the figure's lifeline layout diverging from the fixed router visual without a
decision row (now decision 168); the SPEC progress row missing its closing
pipe; a two-sentence punchline, an unsourced "people", an invented list of
three uses, a "which is deliberate" with no reason, two setup openers in a row
and a "So the division of labor is this" closer.

Rejected on the record:

- The Ratings `Program.cs` comment "Two lines here differ from the other two
  services", which is out of date since chapter 13. The listing is
  byte-identical to the file at tag `ch18`, the comment is chapter 9's, and
  correcting it means a source change and new tags for a comment. Recorded as
  an open item in the SPEC.
- The same unqualified "writes the exception nowhere" inside the `ErrorLog.cs`
  and `Program.cs` comments. Those are the tagged files; the prose and summary
  carry the qualifier, and the open item on log levels is where the claim gets
  settled.
- The parent-id match inside each service not being asserted by
  `verify.ps1`. It was measured with recorded values in section 1 above, and
  the chapter prints no listing of it; the trace-id half is asserted.
- Chapter 17 closing on "one request crossed four services" while 18.1's page
  reaches three. Chapter 17's line is about the graph, and 18.1 says in its own
  second paragraph that the page reaches three of the four.
- The `AddApplicationService` mechanism being unsourced. The sentence now says
  only what the error shows and that the registration works, which is what was
  measured.

## Re-verification on the pinned SDK, 2026-09-14

The runs recorded above used this machine's default `dotnet`, which resolves
to SDK 11.0.100-preview.7 because 10.0.303 is not installed here (SDKs present:
9.0.318, 10.0.401 and the preview). Decision 158 records the same drift and
the fix. All four states were re-run from clean `bin`/`obj` with the official
portable SDK 10.0.303 (runtime 10.0.11) on a process-local `PATH` and
`DOTNET_ROOT`, `DOTNET_MULTILEVEL_LOOKUP=0`:

| Tag | Result |
|---|---|
| `ch18` | exit 0, 659 ok, PASS |
| `ch18-blind` | exit 0, 9 ok, PASS |
| `ch18-naive` | exit 0, 10 ok, PASS |
| `ch18-hc14` | exit 0, 216 ok, PASS |

The first pass reported 11 and 12 for the two state scripts. Those were
miscounts, not different runs: the scripts hold 9 and 10 assertions, and the
verification repo's commit messages for `ch18-blind` and `ch18-naive` still
carry the wrong numbers.