# Chapter 14 - Real-Time in a Federated World

Research for "Real-Time in a Federated World". Tags: `[web]` a primary source
on the web, `[docs]` vendor documentation, `[source]` read out of a cloned
source tree at a release tag, `[measured]` run on this machine.

Decision 32 applies throughout: an internals claim is read out of the source at
a tag, not out of a documentation page.

## Contents

- A. Version baseline
- B. What the graph already had, and what nobody had run
- C. Subscriptions through the router: it works, and what that costs
- D. The plan for a subscription, which has a node kind no earlier chapter saw
- E. What one event costs, counted
- F. The handshake, and two protocols both called graphql-ws
- G. The five transports, and the two the documentation gets wrong
- H. Event-driven federated subscriptions: a subgraph with no service
- I. Mutations through the router
- J. `@defer` and `@stream`, measured rather than assumed
- K. Where docs and behaviour disagree
- L. What chapter 14 changed in Mosaic
- M. What the gate asserts
- N. Reproduction recipes
- O. Left unmeasured, and who owns it
- P. Bibliography keys

## A. Version baseline

Unchanged from chapter 13 except for the two additions.

| Component | Version |
|-----------|---------|
| HotChocolate / HotChocolate.ApolloFederation | 16.6.0, tag `16.6.0`, commit `8fea46e`, cloned at F:/repo/graphql-platform |
| WunderGraph Cosmo Router | 0.337.1, image `ghcr.io/wundergraph/cosmo/router:0.337.1` |
| wgc (Cosmo CLI) | 0.129.7, bundling `@wundergraph/composition` 0.63.2 |
| NATS server | 2.12-alpine, added at `ch14`, `-js -m 8222` |
| NATS.Net / NATS.Client.Core | 3.1.0, added at `ch14`, in `Mosaic.Reviews` only |
| .NET | 10 (LTS) |

Machine for every `[measured]` line: Windows 11, .NET SDK 10.0.302, PostgreSQL
18-alpine and NATS 2.12-alpine in Docker Desktop on the same box, seven
subgraphs built Release and started with `dotnet run --no-build`, router in a
container reaching the host through `host.docker.internal`.

## B. What the graph already had, and what nobody had run

Chapter 5 built `Subscription.onReviewAdded` over an in-memory pub/sub and
exercised it against one service over server-sent events. Nothing since has
sent it through a router. Decision 43 recorded that as deliberate and named
chapter 19 as the owner of a fix.

At tag `ch13` the composed graph already carried the field. `[measured]`
`federation/supergraph.json` at `ch13` has `Subscription.onReviewAdded` in its
`graphqlSchema`, and every one of the seven datasources carries

```json
"subscription": {
  "enabled": true,
  "url": {"staticVariableContent": "http://localhost:5105/graphql"},
  "protocol": "GRAPHQL_SUBSCRIPTION_PROTOCOL_WS",
  "websocketSubprotocol": "GRAPHQL_WEBSOCKET_SUBPROTOCOL_AUTO"
}
```

with its own url, including the six subgraphs that have no `Subscription` type
at all. Chapter 9 found this block and could not ask a question of it; section
G is the answer.

## C. Subscriptions through the router: it works, and what that costs

`[measured]` At tag `ch13`, unmodified, a client posting

```
POST http://localhost:3002/graphql
Accept: text/event-stream

subscription { onReviewAdded(productId: "UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAW") {
  id rating body author { displayName } } }
```

is answered `200 text/event-stream`, receives `:heartbeat` comments, and
receives an event when a review is submitted:

```
event: next
data: {"data":{"onReviewAdded":{"id":"UmV2aWV3OjHunwGkClh8nA5sKCe2ci8=",
       "rating":1,"body":"Event 1.",
       "author":{"displayName":"Mateusz Kowalczyk"}}}}
```

The interesting part is `author.displayName`. Reviews declares `Customer` as a
two-field stub since chapter 12 and has no display name anywhere in it, so that
value is the router having fetched the customer from Accounts. Section E counts
how often.

**A caution about timing.** The first bytes a client sees are usually a
heartbeat rather than the subscription being live, and the heartbeat is on the
router's own schedule. Across the runs recorded here the first byte arrived
between 1.0 and 4.8 seconds after the POST, and that number is the heartbeat
interval, not a latency. Do not print it as one. What is a real measurement is
the gap between a publish and the event: 24 ms to 259 ms across five events in
one run, which is a single-machine number and subject to this book's rule that
the ratio is the claim and the milliseconds are not.

## D. The plan for a subscription, which has a node kind no earlier chapter saw

`[measured]` With `X-WG-Include-Query-Plan: true` and `X-WG-Skip-Loader: true`:

```
{
  "kind": "Sequence",
  "trigger": {
    "kind": "Trigger",
    "path": "onReviewAdded",
    "subgraphName": "reviews",
    "fetchId": 0,
    "query": "subscription($a: ID!){ onReviewAdded(productId: $a){ id rating body
               author { __typename id } } }"
  },
  "children": [
    { "kind": "Single", "fetch": {
        "kind": "Entity", "path": "onReviewAdded.author",
        "subgraphName": "accounts", "fetchId": 1, "dependsOnFetchIds": [0],
        "representations": [{"kind": "@key", "typeName": "Customer",
                             "fragment": "fragment Key on Customer { __typename id }"}],
        "query": "query($representations: [_Any!]!){ _entities(representations: $representations){
                   ... on Customer { __typename displayName } } }" } }
  ]
}
```

Two things worth printing.

1. `Trigger` is a plan node kind chapters 7 and 10 to 13 never saw. Their plans
   are made of `Sequence`, `Parallel`, `Single` and `Entity`. The trigger is the
   part that happens once; everything under `children` happens again per event.
2. The trigger asks the subgraph for `author { __typename id }` and not for
   `displayName`. The subgraph could not answer it.

`[measured]` A subscription plan has **no `normalizedQuery` member**, where the
mutation plan in section I does. Not chased further; recorded because a reader
comparing the two will notice.

## E. What one event costs, counted

`[measured]` Method: count `Mosaic.RequestTimeline` lines in each of the seven
subgraph consoles before subscribing, after subscribing, and after five reviews
have been submitted through the router while the subscription is open. Each
subgraph logs exactly one timeline per GraphQL request it serves.

Run of 2026-08-11, on the committed `ch14` configuration:

```
                       catalog pricing inventory accounts reviews ordering nodes
opening the subscription     0       0         0        0       1        0     0
five events                  0       0         0        5       5        0     0
```

Read it as three findings:

- **Opening a subscription costs one request, to one subgraph.** The router
  opens a WebSocket to Reviews and sends one `subscribe`; nothing else in the
  graph is touched. No entity fetch happens at subscribe time.
- **Every event costs one entity fetch to Accounts.** Five events, five
  requests. The router re-resolves the non-trigger part of the payload on every
  event, so a subscription selecting a field from another subgraph costs one
  extra round trip per message for as long as it is open.
- The five Reviews requests in the second row are the five mutations, not the
  events. The events come down the WebSocket that was already open.

An identical run before the `ch14` changes produced the same two rows, so the
pinned subprotocol did not move these numbers.

**Now a gate step, after the chapter 14 audit.** A first draft printed this
table with nothing committed behind it, which fails this book's own rule that a
printed number has something that produces it again, and decision 66's split
that puts counts in a gate. Both verification scripts now count
`Mosaic.RequestTimeline` lines in the Accounts console either side of
`scripts/subscription-run.mjs`, which submits three reviews on one pair of open
subscriptions. Two subscriptions each selecting `author.displayName` means the
expected delta is twice the number of writes, and the gate asserts exactly
that. A smaller number would mean the router had started caching the author
across events, which would be a better graph and a wrong chapter.

## F. The handshake, and two protocols both called graphql-ws

This is the chapter's sharpest finding and it comes in two halves.

### F1. The names are crossed

`[source]` `src/HotChocolate/AspNetCore/src/Transport.Sockets/WellKnownProtocols.cs`
at tag `16.6.0`:

```csharp
/// The sub-protocol name for the GraphQL over WebSocket Protocol
/// https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md
public const string GraphQL_Transport_WS = "graphql-transport-ws";

/// The sub-protocol name for the GraphQL over WebSocket Protocol from Apollo
/// https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md
public const string GraphQL_WS = "graphql-ws";
```

So on the wire, `graphql-transport-ws` is the modern protocol from the
`graphql-ws` npm package, and `graphql-ws` is the legacy Apollo
`subscriptions-transport-ws` protocol. The subprotocol name and the library
name are swapped, which is a fact about the ecosystem rather than about either
tool, and it is why the rest of this section is worth measuring rather than
reasoning about.

### F2. HotChocolate picks by registration order, not by client preference

`[source]` `HotChocolateAspNetCoreServiceCollectionExtensions.Subscriptions.cs`:

```csharp
private static IRequestExecutorBuilder AddSubscriptionServices(
    this IRequestExecutorBuilder builder)
    => builder
        .ConfigureSchemaServices(...)
        .AddApolloProtocol()               // graphql-ws, the legacy one
        .AddGraphQLOverWebSocketProtocol(); // graphql-transport-ws, the modern one
```

`[source]` `AspNetCore.Pipeline/Subscriptions/WebSocketConnection.cs`:

```csharp
if (webSocketManager.WebSocketRequestedProtocols.Count > 0)
{
    foreach (var protocolHandler in _protocolHandlers)
    {
        if (webSocketManager.WebSocketRequestedProtocols.Contains(protocolHandler.Name))
        {
            _webSocket = await webSocketManager.AcceptWebSocketAsync(protocolHandler.Name);
            return protocolHandler;
        }
    }
}
```

The loop is over the **server's** handlers and the membership test is against
the client's list, so the server's registration order decides and the client's
preference order is ignored. Apollo is registered first.

`[measured]` A client offering `graphql-transport-ws, graphql-ws` in that order:

```
against http://localhost:5105/graphql (HotChocolate 16.6.0)  ->  graphql-ws
against http://localhost:3002/graphql (Cosmo Router 0.337.1) ->  graphql-transport-ws
```

The same list, the opposite answer. Both assertions are steps of
`scripts/subscription-run.mjs` and therefore of both gates.

### F3. The wire, captured

`[measured]` With `scripts/subscription-wire.mjs` on 5105 forwarding to a
Reviews moved to 5115. One recording, two connections, because the harness
probes before the router subscribes.

Connection 1 is the probe, offering both:

```
GET /graphql HTTP/1.1
sec-websocket-protocol: graphql-transport-ws, graphql-ws
user-agent: node

HTTP/1.1 101 Switching Protocols
Sec-WebSocket-Protocol: graphql-ws
```

Connection 2 is the router, on the committed `ch14` configuration, which pins
the subprotocol:

```
GET /graphql HTTP/1.1
Host: host.docker.internal:5105
User-Agent: Go-http-client/1.1
Connection: Upgrade
Sec-Websocket-Protocol: graphql-transport-ws
Sec-Websocket-Version: 13
Upgrade: websocket

HTTP/1.1 101 Switching Protocols
Sec-WebSocket-Accept: 0+wyIeBPin4+OloVC9wc4/bHeys=
Sec-WebSocket-Protocol: graphql-transport-ws
```

and its frames:

```
router ->   {"type":"connection_init","payload":{}}
subgraph -> {"type":"connection_ack"}
router ->   {"id":"d9t72ovgpr8s73bm6qs0","type":"subscribe","payload":{"query":
             "subscription($a: ID!){onReviewAdded(productId: $a){id rating author
             {__typename id}}}","variables":{"a":"UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAW"},
             "extensions":{"initialPayload":{}}}}
subgraph -> {"id":"d9t72ovgpr8s73bm6qs0","type":"next","payload":{"data":
             {"onReviewAdded":{"id":"UmV2aWV3OkrunwGI8rlynU+zZQ2jRtY=","rating":4,
             "author":{"__typename":"Customer","id":"Q3VzdG9tZXI6AAAAwAAAAECAAAAAAAAABA=="}}}}}
router ->   {"id":"d9t72ovgpr8s73bm6qs0","type":"complete"}
```

`[measured]` Before the pin, with `websocketSubprotocol` left at auto, the same
recording produced the other half of the story: the router offered
`graphql-transport-ws,graphql-ws`, the subgraph answered `graphql-ws`, and the
frames used the legacy message names `start` and `stop` rather than `subscribe`
and `complete`. Reproducible by deleting the two pinned lines from
`federation/mosaic.yaml`, recomposing and recording again, which is what the
chapter's lab asks for.

Both arrangements deliver events. The cost of the default is not a failure, it
is running on a protocol Apollo deprecated, chosen by nobody, invisible in
every schema and every log.

## G. The five transports, and the two the documentation gets wrong

`[docs]` https://cosmo-docs.wundergraph.com/cli/router/compose, fetched
2026-08-11, gives the composer input's subscription block verbatim as:

```yaml
    subscription:
      url: http://localhost:4001/sse #Optional, defaults to routing_url
      protocol: sse # Optional, defaults to ws (websockets)
      websocket_subprotocol: graphql-ws # Optional, defaults to auto.
      # Available options are auto, graphql-ws, graphql-transport-ws
```

`[source]` wgc 0.129.7, `dist/src/commands/router/commands/compose.js`:

```javascript
subscriptionUrl: s.subscription?.url || s.routing_url,
subscriptionProtocol: s.subscription?.protocol || 'ws',
websocketSubprotocol: s.subscription?.protocol === 'ws'
  ? (s.subscription?.websocketSubprotocol ?? 'auto') : 'auto',
```

and its own type definition, `dist/src/commands/router/commands/types/types.d.ts`:

```typescript
subscription?: {
    url?: string;
    protocol?: 'ws' | 'sse' | 'sse_post';
    websocketSubprotocol?: 'auto' | 'graphql-ws' | 'graphql-transport-ws';
};
```

The key is `websocketSubprotocol`, camelCase, in a file where every other key is
snake_case. The documented spelling is read by nothing.

`[source]` wgc has a `validateSubscriptionProtocols` in `dist/src/utils.js` that
rejects an unknown subprotocol by name, and it is called by the `subgraph`,
`feature-subgraph` and `monograph` commands. `router compose` does not call it.

`[measured]` Composing Mosaic's eight subgraphs with the reviews entry varied,
reading `datasourceConfigurations[4].customGraphql.subscription` out of the
result. All eight compose; none produces a message.

| reviews `subscription:` block | composed `protocol` | composed `websocketSubprotocol` |
|---|---|---|
| absent | `..._WS` | `..._AUTO` |
| `protocol: ws`, `websocketSubprotocol: graphql-transport-ws` | `..._WS` | `..._TRANSPORT_WS` |
| `protocol: ws`, `websocket_subprotocol: graphql-transport-ws` | `..._WS` | `..._AUTO` |
| `protocol: ws`, `websocketSubprotocol: totally-not-a-protocol` | `..._WS` | *absent* |
| `protocol: sse` | `..._SSE` | `..._AUTO` |
| `protocol: sse_post` | `..._SSE_POST` | `..._AUTO` |
| `protocol: carrier-pigeon` | *absent* | `..._AUTO` |

Note the difference between rows three and four. A misspelled **key** falls back
to the default; an unrecognised **value** removes the member from the composed
config altogether. Both are silent, and the second is the one that produces a
config a reader cannot explain.

All seven rows are cases in `scripts/realtime-cases.mjs`, plus a baseline that
fails if `federation/mosaic.yaml` stops pinning the subprotocol.

### G1. What each transport does against HotChocolate

`[measured]` Wire captures, router to subgraph.

**`ws`** works, either subprotocol. Section F has both.

**`sse`** fails. The router sends a bare GET:

```
GET /graphql HTTP/1.1
Host: host.docker.internal:5105
Accept: text/event-stream
Cache-Control: no-cache
```

and HotChocolate answers

```
HTTP/1.1 301 Moved Permanently
Location: http://host.docker.internal:5105/graphql/
```

which is `MapGraphQL` redirecting a GET with no query to the GraphQL IDE. The
router does not follow it. The client receives

```
event: next
data: {"errors":[{"message":"Internal server error"}],"data":null}
```

and the stream closes.

**Corrected after the chapter 14 audit.** A first draft said the router logs
nothing about this at `log_level: debug`. That claim had been made against a
probe router running at the default `info`. Re-measured on 2026-08-11 with a
router explicitly at `debug`, against the same `sse` config, there is exactly
one line: `[measured]`

```
DEBUG abstractlogger@v0.0.4/zap.go:61 sseTransport.Subscribe
  {"endpoint": "http://localhost:5105/graphql", "method": "GET"}
```

Nothing about the 301, nothing about the failure, and no line at all at `info`,
which is what the committed `router/config.yaml` sets. The subgraph logs
nothing at any level, because its Kestrel logging is at `Warning` and a 301 is
not a warning. So the diagnostic trail is: a one-word configuration change, no
composition error, an error message that names nothing, and one debug line
whose significance is the word `GET` in a field.

**`sse_post`** works:

```
POST /graphql HTTP/1.1
Accept: text/event-stream
Cache-Control: no-cache
Content-Type: application/json

HTTP/1.1 200 OK
Content-Type: text/event-stream; charset=utf-8
Cache-Control: no-cache
```

which is exactly the request chapter 5 made by hand against the subgraph. So of
the three names, the one that sounds like what chapter 5 did is the one that
does not work, and the one with the awkward suffix is the one that does.

## H. Event-driven federated subscriptions: a subgraph with no service

`[docs]` https://cosmo-docs.wundergraph.com/router/cosmo-streams (formerly
EDFS), fetched 2026-08-11: "An Event-Driven Subgraph does not need to be
implemented. It is simply a Subgraph Schema that instructs the Router on how to
connect specific root fields to the Event Source."

`[source]` `@wundergraph/composition` 0.63.2 has built-in definitions for
`@edfs__natsRequest`, `@edfs__natsPublish`, `@edfs__natsSubscribe`,
`@edfs__kafkaPublish`, `@edfs__kafkaSubscribe`, `@edfs__redisPublish`,
`@edfs__redisSubscribe`, plus `edfs__PublishResult` and
`edfs__NatsStreamConfiguration`, in `dist/v1/constants/directive-definitions.js`
and `non-directive-definitions.js`.

Mosaic's, committed as `schema/streams.graphql`:

```graphql
type Subscription {
  reviewPublished(productId: ID!): Review!
    @edfs__natsSubscribe(subjects: ["mosaic.reviewAdded.{{ args.productId }}"])
}

type Review @key(fields: "id", resolvable: false) {
  id: ID! @external
}
```

`[measured]` It composes into an eighth datasource which is not a GraphQL one:

```json
{
  "kind": "PUBSUB",
  "customEvents": {"nats": [{
    "engineEventConfiguration": {"providerId": "default", "type": "SUBSCRIBE",
                                 "typeName": "Subscription", "fieldName": "reviewPublished"},
    "subjects": ["mosaic.reviewAdded.{{ args.productId }}"]}]}
}
```

with no `customGraphql.fetch.url` at all.

**Corrected after the chapter 14 audit.** A first draft of this note and of the
chapter said the `routing_url` appears nowhere in the composed config. It does:
`subgraphs[7]` is `{"id":"7","name":"streams","routingUrl":
"http://localhost:5108/graphql"}`, beside the other seven. What has no url is
the *datasource*, which is the half the router fetches with. Mosaic points the
routing url at 5108, which nothing listens on, so a reader can check that
nothing calls it.

The router config half, in `router/config.yaml`:

```yaml
events:
  providers:
    nats:
      - id: default
        url: "nats://host.docker.internal:4222"
```

and on startup: `Nats Event source enabled {"provider_id": "default"}` followed
by `NATS connection established`.

`[measured]` The plan, for the document the chapter prints a frame of, which
selects `id rating body author { displayName }`:

```
Sequence
  Trigger  subgraphName "7-nats-0"  fetchId 0
  Entity   reviews   fetchId 1  dependsOnFetchIds [0]
           ... on Review { __typename rating body author { __typename id } }
  Entity   accounts  fetchId 2  dependsOnFetchIds [1]
           ... on Customer { __typename displayName }
```

The trigger names a datasource index and a provider rather than a subgraph,
because there is no service to name. That string is positional, so the Postman
collection asserts only that the trigger's source mentions the broker rather
than the exact literal. Two entity fetches rather than the held subscription's
one, because the broker message carries no data: even `rating` has to be
fetched.

(A first draft of this note recorded a plan for a document without `body` and
the chapter printed it beside a frame for a document with it. The audit caught
the mismatch; the plan above is the one for the document actually shown.)

`[measured]` Publishing by hand, with a minimal NATS client, on the subject the
template produces:

```
PUB mosaic.reviewAdded.UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAW
{"__typename":"Review","id":"UmV2aWV3OgAAAOAAAABAgAAAAAAAAIc="}
```

produces, at the client:

```
event: next
data: {"data":{"reviewPublished":{"id":"UmV2aWV3OgAAAOAAAABAgAAAAAAAAIc=",
       "rating":5,"body":"End grain, so it is kind to the knife edge.",
       "author":{"displayName":"Katharina Brandt"}}}}
```

A type name and a key on the wire; three subgraphs' worth of fields at the
client.

### H1. The `__typename` trap

`[measured]` The same publish with the type name omitted, so the body is
`{"id":"UmV2aWV3OgAAAOAAAABAgAAAAAAAAIc="}`, produces:

```
event: next
data: {"errors":[{"message":"Cannot return null for non-nullable field
       'Subscription.reviewPublished.rating'.","path":["reviewPublished","rating"]}],
       "data":null}
```

The router logs the message arriving, at debug:

```
DEBUG nats/adapter.go:204 subscription update {"pubsub": "nats", "provider_id": "default",
  "method": "subscribe", "subjects": ["mosaic.reviewAdded.UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAW"],
  "data": "{\"id\":\"UmV2aWV3OgAAAOAAAABAgAAAAAAAAIc=\"}"}
```

and then makes no entity fetch and says nothing about why. The error names a
field the publisher never mentioned. `ReviewStreamPublisher` carries a comment
saying so, because nothing else would.

### H2. The subject carries whatever the client wrote

The template is `{{ args.productId }}`, and the argument is a global object
identifier, so the subject contains base64. Mosaic's publisher therefore has to
**encode** a product identifier where every other file in Reviews decodes one:
`INodeIdSerializerAccessor.Serializer.Format(nameof(Product), productId)`,
reached through `IResolverContext.Schema.Services` exactly as `ProductKey` does.

Nothing checks that the publisher's subject and the schema's template agree.
Chapter 13's rule about shared types applies to shared strings, and the only
thing holding these two together is the gate.

## I. Mutations through the router

Owed since chapter 10, which recorded that `submitReview` was in the router's
schema and had never been sent to it, and again by chapter 12.

`[measured]` It works. The plan is a `Sequence` with no trigger:

```
Single  reviews   mutation($a: SubmitReviewInput!){ submitReview(input: $a){ review {
                    id rating author { __typename id } } } }
Entity  accounts  dependsOnFetchIds [0]  ... on Customer { __typename displayName email }
```

and it carries a `normalizedQuery` member that the subscription plan does not.

The payload is resolved across a boundary exactly like a query's: the write
goes to Reviews and `review.author.displayName` comes from Accounts. Sent to
the Reviews subgraph directly, as chapters 5 to 13 did, that field answers null,
because Reviews' `Customer` is a two-field stub.

`[measured]` A typed domain error survives the trip unchanged:

```json
{"data":{"submitReview":{"review":null,"errors":[
  {"__typename":"DuplicateReviewError","message":"You have already reviewed this product."}]}}}
```

One correction to a first draft of this note, recorded because it was nearly
printed as a finding: selecting `errors { message }` on the payload produces
`cannot select field: message on union: SubmitReviewError` from the router.
That is not a router defect. `SubmitReviewError` is a union and selecting a
field on a union without a fragment is invalid GraphQL; the router is right and
the query was wrong. `errors { __typename ... on Error { message } }` works.

## J. `@defer` and `@stream`, measured rather than assumed

`[source]` HotChocolate 16.6.0 ships both, behind options that default off.
`src/HotChocolate/Core/src/Types/SchemaOptions.cs`:

```csharp
public bool EnableDefer { get; set; }
public bool EnableStream { get; set; }
```

Auto-properties with no initialiser, so `false`. `EnableDefer` is line 110 and
`EnableStream` line 113; the contrast is at line 119 of the same file, where a
default of true is written out: `public bool EnableTag { get; set; } = true;`.
(A first draft of this note said "three lines below" and the chapter 14 audit
counted them: it is six lines below `EnableStream`, with
`StripLeadingIFromInterface` between.) The interface documents both as "Defer
and stream both are at the moment preview features."

`[measured]` Introspecting the Reviews subgraph for its directive list gives
`skip, include, deprecated, shareable, key, specifiedBy, link`. No defer, no
stream. Sending `@defer` to a subgraph directly:

```
The specified directive `defer` is not supported by the current schema.
```

`[measured]` Introspecting the **router** gives
`include, skip, deprecated, specifiedBy, oneOf, defer` - so `@defer` is in the
client-facing schema of a graph composed entirely from subgraphs that have never
heard of it. The router adds it. `@stream` is not there. Two of the six are
absent from the subgraph list, not one: `oneOf` as well, which is uninteresting
because it describes input objects and is in the specification.

`[measured]` The same introspection, asking for locations, gives `defer` on
`FRAGMENT_SPREAD | INLINE_FRAGMENT`:

```
{ __schema { directives { name locations } } }
->  ... {"name":"defer","locations":["FRAGMENT_SPREAD","INLINE_FRAGMENT"]}
```

`[measured]` Sending `@defer` to the router, with `Accept: multipart/mixed`, on
a fragment whose fields live in another subgraph:

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 96

{"data":{"browseProducts":{"nodes":[{"title":"Beech Cutting Board",
  "price":{"amount":69.00}}]}}}
```

One response, `application/json`, deferred field inlined. Accepted and ignored.
Sending `@stream`:

```
{"errors":[{"message":"directive: stream undefined","path":["query","products"]}]}
```

`[web]` WunderGraph's position on this is published under a named byline:
Jens Neuse, CEO and co-founder, "GraphQL's @defer and @stream Directives are
overkill", 23 February 2023, edited 27 July 2026. The claim quoted in the
chapter is that "the @defer and @stream directives are complete overkill and the
whole idea of incrementally loading data can be done in a much simpler way".
Usable under this book's vendor rule because the post names an engineer at the
company being described, and the prose says whose it is.

## K. Where docs and behaviour disagree

Four, all in this chapter.

1. **`websocket_subprotocol` versus `websocketSubprotocol`.** Section G. The
   documented spelling is inert.
2. **`router compose` validates neither the protocol nor the subprotocol**,
   although wgc has a validator for exactly that and every other command calls
   it. Section G.
3. **`sse` against HotChocolate.** The name suggests chapter 5's transport and
   is a different one. Section G1.
4. **`@defer` in the router's schema.** Advertised by introspection, accepted by
   validation, not honoured. Section J. No documentation claims it is honoured;
   the disagreement is between the schema and the behaviour, which is worse,
   because a client generator reads the schema.

## L. What chapter 14 changed in Mosaic

Tag `ch14`.

- `docker-compose.yml`: `mosaic-nats` (nats:2.12-alpine, `-js -m 8222`, health
  checked on `/healthz` at 8222 because the image has no shell and no curl);
  `mosaic-reviews` gains a `depends_on` and `ConnectionStrings__Nats`.
- `schema/streams.graphql`: new, the schema-only subgraph.
- `federation/mosaic.yaml`: an eighth entry, `streams`, and a `subscription:`
  block on `reviews` pinning `websocketSubprotocol: graphql-transport-ws`.
- `router/config.yaml`: the `events.providers.nats` block.
- `src/Mosaic.Reviews`: `NATS.Net` and `NATS.Client.Hosting` referenced;
  `Reviews/Streams/ReviewStreamPublisher.cs`; `AddReviewStreams` in
  `ReviewsRegistration.cs`; one call added to `SubmitReviewAsync`.
  `NatsConnection` is constructed directly rather than through
  `AddNatsClient`, because the one-line `ConfigureOptions` overload is obsolete
  at 3.1.0 and its replacement takes an options builder.
- `scripts/realtime-cases.mjs`, `scripts/subscription-run.mjs`,
  `scripts/subscription-wire.mjs`: new.
- `postman/mosaic-realtime.*`: new, 7 requests and 23 assertions.
- `federation/supergraph.json`: recomposed, eight datasources.

Nothing was removed. `onReviewAdded` and its in-memory pub/sub stay, because
the contrast between the two arrangements is the chapter.

## M. What the gate asserts

Both `verify.ps1` and `verify.sh`, in the same commit, per this book's rule.

- `mosaic-nats` is started and healthy before the build, and stopped in the
  finally block on the same switch as the database.
- `scripts/realtime-cases.mjs`: eight cases, section G's table plus the pubsub
  datasource, plus a baseline that reads the pinned subprotocol out of
  `federation/mosaic.yaml` and fails if it is gone.
- `scripts/subscription-run.mjs`: seven checks. Which subprotocol each end
  picks; the mutation through the router; `onReviewAdded` delivering the review
  with its author resolved from Accounts; `reviewPublished` delivering the same
  review from a broker message.
- `postman/mosaic-realtime`: 23 assertions.

That closes decision 43 for the two fields Mosaic has. `verify.ps1` passed twice
in a row on 2026-08-11 with these steps in, at 53 summary lines.

`scripts/subscription-wire.mjs` is deliberately **not** called by either script,
per decision 62: the behaviour it shows is already asserted by
`subscription-run.mjs` without needing the bytes, and a proxy in the middle of a
gate is a thing to debug rather than a thing that catches defects.

## N. Reproduction recipes

Every measurement above, in order.

```
# the graph
docker compose up -d --wait mosaic-db mosaic-nats
dotnet build -c Release
#   then seven services, ASPNETCORE_URLS=http://localhost:510N, MOSAIC_RESET_DATABASE=1
docker compose up -d mosaic-router

# C, E, I: subscriptions and mutations through the router
node scripts/subscription-run.mjs --product <global id> --customer <global id>

# D: the plans
curl -s -X POST http://localhost:3002/graphql \
  -H 'content-type: application/json' \
  -H 'X-WG-Include-Query-Plan: true' -H 'X-WG-Skip-Loader: true' \
  -d '{"query":"subscription { onReviewAdded(productId: \"...\") { id rating author { displayName } } }"}'

# F3: the wire
ASPNETCORE_URLS=http://localhost:5115 dotnet run --project src/Mosaic.Reviews -c Release
node scripts/subscription-wire.mjs 5105 5115

# G: the transport table
node scripts/realtime-cases.mjs
node scripts/realtime-cases.mjs --print documented-spelling-does-nothing

# H: EDFS by hand - publish with any NATS client
#   subject mosaic.reviewAdded.<product global id>
#   body    {"__typename":"Review","id":"<review global id>"}

# J: defer and stream
curl -s -X POST http://localhost:3002/graphql -H 'content-type: application/json' \
  -H 'Accept: multipart/mixed' \
  -d '{"query":"{ browseProducts(first:1){ nodes { title ... @defer { price { amount } } } } }"}'
curl -s -X POST http://localhost:3002/graphql -H 'content-type: application/json' \
  -d '{"query":"{ products @stream(initialCount: 1) { title } }"}'
```

The five-event table in section E was first produced by a scratch script that
read the seven subgraph console logs before and after. It is a count, so under
decision 66 it belongs in a gate, and after the chapter 14 audit it is one:
both verification scripts count `Mosaic.RequestTimeline` lines in the Accounts
console either side of a three-write run and assert the delta. A reader
reproducing the full seven-column table by hand counts the same lines in each
console.

## O. Left unmeasured, and who owns it

- **Kafka and Redis.** `@edfs__kafkaSubscribe` and `@edfs__redisSubscribe` exist
  in the composer and neither was run. NATS was chosen because it is one
  container and no configuration. Nothing here is NATS-specific except the
  directive name and the provider block. Chapter 21 owns the platform.
- **`@edfs__natsPublish` and `@edfs__natsRequest`.** Mosaic publishes from C#
  because the write is a domain operation with three typed errors, and a
  `@edfs__natsPublish` mutation would have been a second write path with no
  validation behind it. The directives are described and not exercised.
  Chapter 21 or 24.
- **JetStream.** `edfs__NatsStreamConfiguration` gives a subscription a durable
  consumer, which is what makes an event survive a router restart. The compose
  file starts NATS with `-js` so the server supports it, and no subject uses it.
  This is the difference between at-most-once and at-least-once delivery and it
  is chapter 24's, with the rest of the resilience story.
- **More than one subscriber, and a restart.** Chapter 5 left both and this
  chapter did not take them. The in-memory provider's limits are still only
  documented, not provoked. What has changed is that the event-driven field has
  no such limit, and nothing measured that either. Chapter 24.
- **Multipart HTTP to the client.** The router supports it and this chapter used
  SSE and WebSockets only. Chapter 18 owns the wire.
- **What a subscription costs in milliseconds**, and what the per-event entity
  fetch of section E costs at a hundred concurrent subscribers. Decision 62
  keeps timings out of the gate; this needs `measure-router.mjs`'s treatment
  rather than an assertion. Chapter 24.
- **Authorising a subscription.** Nothing in Mosaic is authorised at all, and a
  subscription is the case where a connection outlives the token that opened
  it. Chapter 15.
- **`initialPayload`.** The router sends `"extensions":{"initialPayload":{}}` in
  its `subscribe` frame, which is how a WebSocket connection's init payload
  reaches a subgraph, and is the obvious route for a claim. Empty here because
  nothing authenticates. Chapter 15.
- **The router's heartbeat interval**, which section C had to be careful about
  and which is a config key nobody read. Chapter 21.
- **A subgraph that goes away while a subscription is open.** Not provoked.
  Chapter 24.

## P. Bibliography keys

- `cosmodocs2026streams` - WunderGraph, "Cosmo Streams (EDFS)", cosmo-docs,
  urldate 2026-08-11. Vendor documentation, cited for what the feature is
  defined to be rather than for what it does here.
- `cosmodocs2026compose` - WunderGraph, "wgc router compose", cosmo-docs,
  urldate 2026-08-11. Cited for the documented spelling of
  `websocket_subprotocol`, which is the point.
- `neuse2023defer` - Jens Neuse, "GraphQL's @defer and @stream Directives are
  overkill", wundergraph.com, 23 February 2023, urldate 2026-08-11. Named
  engineer at the company being described, per this book's vendor rule.
