# Upstream reports, drafted 2026-08-11

Two defects this book measured and committed cases for, written up as issue
bodies ready to post to https://github.com/wundergraph/cosmo/issues.

**Drafted, not filed.** Posting is public under the author's account and is the
author's to do. Both are recorded in the decision log (89 and 90) with the case
that reproduces them, so nothing here is load-bearing for the book: a release
that fixes either one fails the gate and gets read whether or not the report was
ever sent.

Both were re-measured today against the newest published versions, not taken
from the chapter. wgc `0.129.8` (the book pins `0.129.7`; `0.129.8` is latest on
the registry as of 2026-08-11) and `@wundergraph/composition` `0.63.2`, which is
what wgc `0.129.8` depends on and is also the latest published composition.

Search performed before drafting, so neither is a duplicate:
`gh search issues --repo wundergraph/cosmo` for `handleEntityInterfaces`,
`entity interface key`, `websocket_subprotocol`, and
`router compose subscription protocol validation`. One near hit, discussed under
report 1; nothing at all for report 2.

---

## Report 1 - composition crashes instead of erroring when an entity interface implementation has no key

**Component:** composition (via wgc router compose)
**wgc version:** 0.129.8 (also 0.129.7)
**@wundergraph/composition version:** 0.63.2

### What happened

An entity interface carries `@key`, and one of the object types implementing it
does not. Instead of a composition error naming the implementation, the composer
throws, prints a stack trace, and shows the "please open an issue" box.

Two subgraphs. `library` owns the interface:

```graphql
interface Media @key(fields: "id") {
  id: ID!
  title: String!
}

type Book implements Media @key(fields: "id") {
  id: ID!
  title: String!
  pages: Int!
}

type Film implements Media {     # <- no @key, which is the mistake
  id: ID!
  title: String!
  runtimeMinutes: Int!
}

union _Entity = Book
```

`ratings` contributes a field to the interface:

```graphql
type Media @key(fields: "id") @interfaceObject {
  id: ID!
  averageRating: Float
  ratingCount: Int!
}
```

`wgc router compose` on that pair produces:

```
Error: Fatal: Expected key "Film" to exist in the map "entityDataByTypeName".
    at invalidKeyFatalError (...\@wundergraph\composition\dist\errors\errors.js:433:12)
    at getOrThrowError (...\@wundergraph\composition\dist\utils\utils.js:28:49)
    at FederationFactory.handleEntityInterfaces (.../v1/federation/federation-factory.js:1337:68)
```

preceded by wgc's own box:

```
Please try the below steps to solve the issue [1] Upgrade to the latest
version: npm i -g wgc@latest [2] If it persists, please open an issue:
https://github.com/wundergraph/cosmo/issues/new/choose
```

No execution config is written.

### What I expected

A composition error naming `Film` and the missing `@key`, in the same form as
the neighbouring mistake in this area already produces. Dropping `@interfaceObject`
from the `ratings` declaration, for instance, gives a clear message:

```
"Media" is defined using incompatible types across subgraphs. It is defined as
type "Interface" in subgraph "library" but type "Object" in subgraph "ratings".
```

An entity interface with an unkeyed implementation is an ordinary modelling
mistake and seems like it should land in the same channel.

### Related

Issue #1669, "Interface Object with 2 Keys causing runtime error on WGC Router",
closed 2025-03-19 and labelled `confirmed bug`, is a different trigger reaching a
crash in the same function: there an interface carries two `@key`s and an
`@interfaceObject` carries one, and the fatal is
`Expected key "SubGraph B" to exist in the map "A.aTWO.externalFieldDataBySubgraphName"`.
This report is a separate path into `handleEntityInterfaces` - a different map
(`entityDataByTypeName`) and a different cause - and it still reproduces on
0.63.2.

### Reproduction

Committed as the case `interface-object-implementation-without-a-key` in
`scripts/modeling-cases.mjs` at https://github.com/Giang-Dang/mosaic-graph,
tag `ch13` onward. `node scripts/modeling-cases.mjs --print
interface-object-implementation-without-a-key` reproduces it from the committed
schemas in `schema/samples/interface-object-*.graphql`.

---

## Report 2 - `router compose` reads a different subscription key than the docs give, and validates neither key nor value

**Component:** wgc (CLI)
**wgc version:** 0.129.8 (also 0.129.7)

Two halves. They are filed together because the second is what makes the first
silent.

### Half one: the documented spelling does nothing

The compose input's subscription block is documented as
`websocket_subprotocol`, matching the snake_case of every other key in that
file. The code reads `websocketSubprotocol`:

```js
// dist/src/commands/router/commands/compose.js:306
websocketSubprotocol: s.subscription?.protocol === 'ws'
  ? s.subscription?.websocketSubprotocol ?? 'auto'
  : 'auto',
```

So an input written the documented way composes to `auto` with no message, and
`auto` is not inert: the subgraph is then offered both subprotocols and picks by
its own registration order. On HotChocolate 16.6.0 that lands on the legacy
Apollo `subscriptions-transport-ws` protocol rather than the modern
`graphql-transport-ws`, and nothing in any schema, config or log says a choice
was made.

### Half two: `router compose` skips the validator every other command calls

wgc ships `validateSubscriptionProtocols` in `dist/src/utils.js:220`, which
rejects an unknown protocol and an unknown subprotocol by name. It is imported
and called by seven commands:

```
subgraph create / publish / update
feature-subgraph create / publish
monograph create / update
```

`dist/src/commands/router/commands/compose.js` does not import it. The
consequences on the composed config, all measured:

- an unrecognised `websocketSubprotocol` value composes with the key dropped
- an unrecognised `protocol` composes with the protocol key dropped entirely
- the documented `websocket_subprotocol` spelling composes to `auto`

all three silently, and all three only visible by reading the execution config,
since none of it reaches the client-facing schema.

### What I expected

Either spelling accepted, or the wrong one rejected. And `router compose` calling
`validateSubscriptionProtocols` the way the registry commands do - the
router-only path is the one chosen by anyone composing without a control plane,
so it is the path where a silent misconfiguration is least likely to be caught by
anything else.

### Reproduction

Committed as cases in `scripts/realtime-cases.mjs` at
https://github.com/Giang-Dang/mosaic-graph, tag `ch14`:
`documented-spelling-does-nothing`, `unknown-subprotocol-is-ignored`,
`unknown-protocol-drops-the-key`, plus `baseline` and
`no-subscription-block-is-auto` for the two ends. Each edits the real committed
`federation/mosaic.yaml`, composes, and asserts what appears in the execution
config.

---

## Re-measurement log

| Date | Tool | Version | Result |
|------|------|---------|--------|
| 2026-08-11 | @wundergraph/composition | 0.63.2 | Report 1 reproduces. All 16 `modeling-cases.mjs` cases pass, including the crash case |
| 2026-08-11 | wgc | 0.129.8 | Report 2 reproduces, both halves. All 8 `realtime-cases.mjs` cases pass |

The 0.129.8 check was run from a clean export of companion tag `ch14` with
`wgc@0.129.8` installed over it, leaving the companion repo's own pin at
`0.129.7` untouched. Both halves were confirmed a second way by reading the
installed 0.129.8 tree directly: `compose.js:306` for the key, and the import
list of `validateSubscriptionProtocols` for the missing validation.
