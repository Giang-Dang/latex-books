# Chapter 13 research - hard modeling problems

Research date: 2026-08-10. Every number and every listing in this file was
captured from a running service on the author's machine, or read out of a
primary source at a pinned version. Internals claims are read from
`ChilliCream/graphql-platform` at tag `16.6.0`, commit `8fea46e`, cloned at
F:/repo/graphql-platform (decision 32). Composer claims are read from
`@wundergraph/composition` 0.63.2, which is what wgc 0.129.7 bundles, under
`node_modules/` in the companion repo.

The chapter's companion code is `mosaic-graph` at tag `ch13`. What is new:
`src/Mosaic.Nodes` is a seventh subgraph with no database; `Review` and `Order`
became federation entities; `CatalogService.BrowseProductsAsync` got one line
that fixes a defect chapter 4 shipped; and there are two new samples' worth of
schemas plus `scripts/modeling-cases.mjs`.

## Contents

- A. Version baseline
- B. What the chapter inherited
- C. The connection that works, and why
- D. What a cursor actually is
- E. The cursor defect, and the federation twist that hid it
- F. The page you cannot ask for
- G. Nested and multi-subgraph `@requires` (chapter 11's debt)
- H. `Node` in the composed schema, before this chapter
- I. Giving the graph a `node` field
- J. Where `node` must not go
- K. Abstract types across a boundary
- L. `@interfaceObject`, measured
- M. The enum declared twice
- N. Value types and scalars
- O. What the gates assert
- P. Reproduction recipes
- Q. Left unmeasured, and who owns it
- R. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; unchanged since chapter 8 |
| graphql-platform source | tag `16.6.0`, commit `8fea46e` | `git log --oneline -1` in F:/repo/graphql-platform |
| WunderGraph Cosmo Router | 0.337.1 | `ghcr.io/wundergraph/cosmo/router:0.337.1`, pinned in `docker-compose.yml` |
| wgc (Cosmo CLI) | 0.129.7 | pinned exactly in `package.json`; unchanged since chapter 9 |
| @wundergraph/composition | 0.63.2 | `node_modules/@wundergraph/composition/package.json` |
| .NET SDK | 10.0.302 | `dotnet --version` |
| node | 24.15.0 | `node --version` |
| PostgreSQL | 17 (compose image) | `docker-compose.yml` |
| Apollo Federation specification | v2.15 | unchanged from the SPEC baseline |

## B. What the chapter inherited

At tag `ch12` the graph is six subgraphs. The four things this chapter is about
were all already true and none of them had been looked at:

- `ProductCategory` is declared twice, in `catalog` and in `pricing`, with the
  same five members.
- `Money` is declared twice, in `pricing` and in `ordering`, `@shareable` in
  both, and identical.
- `Decimal` and `DateTime` are declared in two subgraphs each, as scalars with a
  `@specifiedBy` url.
- Four types implement `Node` in the composed client schema, and **no field
  anywhere returns one**. Read out of `federation/supergraph.json` at tag
  `ch12`:

```
type Product implements Node {
type Customer implements Node {
type Review implements Node {
type Order implements Node {
```

  and a grep for a field whose type is `Node` finds nothing. The interface is in
  the schema, four types promise to satisfy it, and there is no way to use it.
  That is decision 50's cost, and this chapter is where it is paid back.

Also true and worth stating because the chapter's second section depends on it:
`Product.reviews` is a connection served entirely by `reviews`, and
`Query.browseProducts` is a connection served entirely by `catalog`. No
connection in Mosaic spans two services, and that is not an accident of the
model. It is the only arrangement that works, which is section F's subject.

## C. The connection that works, and why

`Product.reviews` pages correctly through the router. Measured against a running
graph at tag `ch13`:

```
{ browseProducts(first: 2) { nodes { title
    reviews(first: 2) { totalCount pageInfo { endCursor hasNextPage } nodes { rating } } } } }
```

Each product gets its own page, its own `totalCount` and its own `endCursor`.
The first product returned `totalCount 6`, the second `totalCount 3`, and the
two `endCursor` values differ.

The reason it works is that nothing about the page crosses a boundary. The
router locates `Product` in `catalog`, hands `reviews` a representation, and
`reviews` runs one keyset query per branch of its DataLoader. The connection's
items, its cursors, its `totalCount` and its ordering are all one service's
answers about one table.

## D. What a cursor actually is

HotChocolate 16's connections are **keyset** paged, not offset paged, and the
cursor is legible once decoded. Captured through the router at tag `ch13`:

```
e31CZWVjaCBDdXR0aW5nIEJvYXJkOmEwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAxNg==
```

base64-decodes to

```
{}Beech Cutting Board:a0000000-0000-4000-8000-000000000016
```

That is the sort key, then a colon, then the tiebreaker, behind a two-byte
prefix. `CatalogService.DefaultOrder` sorts by `Title` and appends `Id`, and
both appear.

The same for `Product.reviews`, whose order is `OrderBy(r => r.CreatedAt)`:

```
{}202505311348000000000+0000:e0000000-0000-4000-8000-000000000087
```

Ordering is ascending, so a page of reviews is **oldest first**. Worth
recording because `ProductReviewsNode.GetReviewsAsync`'s summary said "newest
page first" from chapter 5 to chapter 12, which is wrong. Corrected in
`mosaic-graph` commit `5589c42`, which tag `ch13` points at; the published schema
does not change, because the summary is not emitted as a GraphQL description.

### Cursor stability under an insert (chapter 5's open item)

Chapter 5 left "cursor stability when a row is inserted ahead of an open
cursor" to this chapter. Measured, on the reviews of the first product:

Page one, `first: 2`:

```
2025-05-31T13:48:00Z  rating 5
2025-08-20T17:35:00Z  rating 4
totalCount 6
```

A review was then inserted directly into the `reviews` database one second
before the cursor row:

```sql
insert into reviews (id, product_id, customer_id, rating, body, created_at)
values ('ffffffff-0000-4000-8000-0000000000f1', <product>, <customer>, 1,
        'inserted ahead of an open cursor',
        timestamptz '2025-08-20T17:35:00Z' - interval '1 second')
```

Page two, `first: 2, after: <the cursor from page one>`:

```
2025-10-09T10:12:00Z  rating 5
2026-01-05T19:26:00Z  rating 4
totalCount 7
```

Correct: no row repeated, no row skipped that the client had not already been
past. The same data by offset would have repeated one. `select created_at,
rating from reviews where product_id = <product> order by created_at offset 2
limit 2` after the insert returns:

```
2025-08-20 17:35:00+00|4
2025-10-09 10:12:00+00|5
```

and `2025-08-20` is the row page one already showed. So the answer to chapter
5's question is that keyset paging is stable under an insert ahead of the
cursor, at the price that the inserted row is invisible until the client starts
again from page one. The inserted row was deleted afterwards.

## E. The cursor defect, and the federation twist that hid it

`browseProducts` had a real defect from chapter 4 until this chapter.

### What was wrong

`QueryContextParameterExpressionBuilder.CreateQueryContext` builds the selector
from the selection set and from nothing else. Read at tag `16.6.0`, commit
`8fea46e`, in
`src/HotChocolate/Data/src/Data/QueryContextParameterExpressionBuilder.cs`:

```csharp
return new QueryContext<T>(
    selection.AsSelector<T>(context.IncludeFlags),
    filterContext?.AsPredicate<T>(),
    sortContext?.AsSortDefinition<T>());
```

Nothing adds the sort keys to the selector. The cursor, though, is serialised
from the entity that projection materialised. So a client selecting only `title`
got a `Product` whose `Id` was `Guid.Empty`, and every cursor on the page
carried the same tiebreaker. Measured at tag `ch12`:

```
without id:
   "{}Beech Cutting Board:00000000-0000-0000-0000-000000000000"
   "{}Brant Ottoman:00000000-0000-0000-0000-000000000000"
with id:
   "{}Beech Cutting Board:a0000000-0000-4000-8000-000000000016"
   "{}Brant Ottoman:a0000000-0000-4000-8000-000000000004"
```

The consequence, at tag `ch12`, is a repeated row:

```
page 1: Beech Cutting Board | Brant Ottoman
page 2: Brant Ottoman | Brant Two-Seat Sofa
```

Reproduced identically against `catalog` directly on 5101 and through the
router on 3002, so the router is not the cause.

`Product.reviews` is unaffected: its cursors carry a real review identifier
whether or not `id` is selected, because that resolver goes through a DataLoader
with no `QueryContext` and no projection.

### The twist

Through the router, the defect is invisible to any query that crosses a
boundary. Measured at tag `ch12`, page two after page one's second cursor:

```
selection: "title"                             page2: Brant Ottoman | Brant Two-Seat Sofa
selection: "title price { amount }"            page2: Brant Two-Seat Sofa | Canvas Storage Bin
selection: "title availableQuantity"           page2: Brant Two-Seat Sofa | Canvas Storage Bin
selection: "title reviews(first:1){totalCount}" page2: Brant Two-Seat Sofa | Canvas Storage Bin
```

Asking for one more field from any other subgraph makes the planner add `id` to
the catalog fetch so it can build representations, which puts the key back in
the projection and fixes the cursor. The only query that reproduces the defect
is one that stays inside a single subgraph, which is why eight chapters of
federated queries never tripped over it.

### The fix

`GreenDonutQueryContextExtensions.Include` is the supported way to force a
column into the selector, read at tag `16.6.0` in
`src/GreenDonut/src/GreenDonut.Data/Extensions/GreenDonutQueryContextExtensions.cs`.
`CatalogService.BrowseProductsAsync` now reads:

```csharp
return await db.Products
    .AsNoTracking()
    .With((query ?? QueryContext<Product>.Empty).Include(p => p.Id), DefaultOrder)
    .ToPageAsync(pagingArguments, cancellationToken);
```

It does not work out of the box for a positional record. `ExpressionHelpers.Rewrite`
ends with

```csharp
var newInitExpression = Expression.MemberInit(Expression.New(typeof(TRoot)), bindings);
```

and `Expression.New(Type)` wants a parameterless constructor, which
`record Product(Guid Id, ...)` does not have. The symptom is
`Unexpected Execution Error` on the field and nothing in the log. `Product`
therefore gained

```csharp
public Product()
    : this(Guid.Empty, string.Empty, string.Empty, null, default)
{
}
```

After the fix, the SQL is still projected. Captured with
`Logging__LogLevel__Microsoft.EntityFrameworkCore.Database.Command=Information`:

```
SELECT p.title AS "Title", p.id AS "Id"
FROM products AS p
ORDER BY p.title, p.id
LIMIT @p
```

Two columns rather than five, and the tiebreaker among them. And the published
schema is byte-identical before and after: `git diff schema/catalog.graphql`
after re-exporting reports no change, so no schema-comparison tool could see
either the defect or the fix.

## F. The page you cannot ask for

Sorting or filtering `browseProducts` by a field another subgraph owns fails at
the router, in validation, before any subgraph is asked. Measured:

```
{ browseProducts(first: 3, order: [{ price: { amount: ASC } }]) { nodes { title } } }
```

```
Field "price" is not defined by type "ProductSortInput".
```

```
{ browseProducts(first: 3, where: { availableQuantity: { gt: 0 } }) { nodes { title } } }
```

```
Field "availableQuantity" is not defined by type "ProductFilterInput".
```

The composed inputs carry exactly Catalog's own columns, read through the
router's introspection:

```
sort:   id, sku, title, description, category
filter: and, or, id, sku, title, description, category
```

That is not a composition failure and not something a directive can repair.
`ProductSortInput` is generated from the entity Catalog holds; Pricing
contributes a field to `Product` but cannot contribute a column to Catalog's
table, and the order of a page is decided by whoever runs the query that
produces it.

## G. Nested and multi-subgraph `@requires` (chapter 11's debt)

Chapter 11's open items left two `@requires` questions here. Both compose, and
both were measured against the seven committed schemas with edits applied.

**Nested field set.** `inventory` declares `Product.price: Money! @external`
and `restockThreshold: Int! @requires(fields: "price { amount }")`, where
`price` is owned by `pricing`:

```
composed: true
```

**Multi-subgraph field set.** `pricing`'s `shippingCost` requires
`category availableQuantity`, one field from `catalog` and one from
`inventory`:

```
composed: true
```

and the routing table afterwards:

```
Product.category           catalog
Product.shippingCost       pricing
Product.availableQuantity  inventory
```

Both are committed as cases in `scripts/modeling-cases.mjs`,
`requires-a-nested-field-set` and `requires-across-two-other-subgraphs`, so
neither claim rests on a run nobody can repeat.

So `@requires` can name a nested field set, and can name fields from more than
one other subgraph. What it cannot do is help with section F, and the reason is
about when rather than what: `@requires` feeds a field resolver on an entity the
router has already located, and the ordering of a page is decided before any
entity exists.

## H. `Node` in the composed schema, before this chapter

See section B. Four implementations, no field returning the interface.

The mechanism is decision 50: every Mosaic subgraph calls
`AddGlobalObjectIdentification(registerNodeInterface: false)` through
`AddMosaicSubgraph`. That keeps the node id serialiser, the `Node` interface,
`implements Node` and every `[NodeResolver]`, and drops only `Query.node` and
`Query.nodes`.

## I. Giving the graph a `node` field

### The arrangement

`src/Mosaic.Nodes`, on 5107, is the seventh subgraph. It has no database, no
`depends_on` in `docker-compose.yml`, and no domain. Its published schema is
`schema/nodes.graphql`, 60 lines by `wc -l`, and its type list is the graph's
addressable surface. Below is that file with four things cut, all of them
boilerplate every subgraph in this book publishes: the `Node` interface, the
`_Service` type, the `FieldSet` and `_Any` scalars, and the `@key` and `@link`
directive definitions. Everything else in the file is here, verbatim including
the descriptions HotChocolate generates:

```
type Query {
  "Fetches an object given its ID."
  node("ID of the object." id: ID!): Node
  "Lookup nodes by a list of IDs."
  nodes("The list of node IDs." ids: [ID!]!): [Node]!
  _service: _Service!
}

type Customer implements Node @key(fields: "id", resolvable: false) {
  id: ID!
}

type Order implements Node @key(fields: "id", resolvable: false) {
  id: ID!
}

type Product implements Node @key(fields: "id", resolvable: false) {
  id: ID!
}

type Review implements Node @key(fields: "id", resolvable: false) {
  id: ID!
}
```

The chapter prints the first two of the four stubs and says the other two are
the same three lines with a different name, which they are.

No `_entities`: every key is `resolvable: false`, so nothing here is an entity
this service answers for.

Each stub carries a node resolver that hands the key straight back:

```csharp
[NodeResolver]
public static Product ResolveProduct(Guid id) => new() { Id = id };
```

Nothing in the project parses a base64 string. HotChocolate's `node` field
decodes the identifier, reads the type name out of it, finds the node type of
that name and calls its resolver with the internal identifier. The four copies of
`ProductKey.TryDecode` elsewhere in the repository, plus `ReviewKey` and
`OrderKey` which are the same file with a different type name checked, exist
because a *reference* resolver is handed the key raw and
`HotChocolate.ApolloFederation` does not know it is a relay identifier; the
`node` field is the one place that does. Counted with `find src -name "*Key.cs"`
excluding `bin` and `obj`: seven files, of which four are `ProductKey.cs` and the
other three are `CustomerKey`, `ReviewKey` and `OrderKey`.

### What had to change on the other side

`Review` and `Order` implemented `Node` and were not entities. Composing the
stubs against them fails:

```
The Object "Review" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "id" is defined and declared "@shareable" in the following subgraph: "catalog".
 However, it is not declared "@shareable" in the following subgraph: "reviews".
```

A key field is implicitly shareable and an ordinary field is not, which is the
only reason a stub does not collide with the real type. Both became entities at
`ch13`: `[Key("id")]` plus a `[ReferenceResolver]` on the record, behind the
DataLoader their node resolvers already used. `schema/ordering.graphql` gained
`_entities` and a `union _Entity = Order` in consequence; that subgraph had
never had a resolvable key before.

### It works

Measured through the router at tag `ch13`, one identifier of each kind:

```
Product   UHJvZHVjdDoAAACgAAAAQIAAAAAAAAAW
Review    UmV2aWV3OgAAAOAAAABAgAAAAAAAAIc=
Customer  Q3VzdG9tZXI6AAAAwAAAAECAAAAAAAAACQ==
Order     T3JkZXI6AAAA0AAAAECAAAAAAAAABg==
```

and `node(id:)` on each, asking for fields the node service does not have:

```
Product:  { "__typename": "Product", "title": "Beech Cutting Board", "price": { "amount": 69 }, "availableQuantity": 61 }
Review:   { "__typename": "Review", "rating": 5, "body": "End grain, so it is kind to the knife edge.", "author": { "displayName": "Katharina Brandt" } }
Customer: { "__typename": "Customer", "displayName": "Katharina Brandt", "email": "k.brandt@example.org" }
Order:    { "__typename": "Order", "placedAt": "2026-04-07T19:20:00Z", "total": { "amount": 858 }, "lines": [ { "quantity": 2 } ] }
```

`nodes(ids:)` with one of each in a single call answers four objects in the order
asked.

### The plan

For `node(id) { ... on Product { title price { amount } } }`, with
`X-WG-Include-Query-Plan` and `X-WG-Skip-Loader`:

```
Sequence
  Single    nodes     query($a: ID!){ node(id: $a){ __typename ... on Product { __typename id } } }
  Parallel
    Entity  catalog   fetchId 1  dependsOnFetchIds [0]   ... on Product { __typename title }
    Entity  pricing   fetchId 2  dependsOnFetchIds [0]   ... on Product { price { amount } }
```

The first fetch asks the node service for a type name and a key, and everything
else is an entity fetch keyed on what came back.

### What it cannot do

A well-formed identifier for a row nobody has:

```
Cannot return null for non-nullable field 'Query.node.title'.
```

The node service returns a stub for any identifier that decodes, because it has
nothing to check against. The failure surfaces at the owner, as a non-null
violation on a field, rather than as `node` answering null.

Selecting only the identifier on the same missing row succeeds, because nothing
on that path has to find a row:

```
{ "node": { "__typename": "Product", "id": "UHJvZHVjdDoAAAAAAAAAAAAAAAAAAAAA" } }
```

Two failures it does catch, both from the node service:

```
There is no node resolver registered for type `OrderLine`.
```

```
The node ID string has an invalid format.
```

## J. Where `node` must not go

Three cases, all in `scripts/modeling-cases.mjs`.

**Two subgraphs, neither shareable.** `catalog` publishes `node` as well:

```
The Object "Query" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "node" is defined in the following subgraphs: "catalog", "nodes".
 However, it is not declared "@shareable" in any of them.
```

**Two subgraphs, both shareable.** This is the one worth keeping. It
**composes**, and the routing table says:

```
Query.node    catalog, nodes
```

Decision 50 asserted that `@shareable` "would be a lie" without measuring it.
It is: two subgraphs are advertised as able to answer `node`, the router is free
to pick either, and `catalog` can resolve one of the four addressable types.

**Stubs without keys.** Dropping `@key` from the four stubs turns four
two-line types into four shareability errors:

```
The Object "Product" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "id" is defined and declared "@shareable" in the following subgraphs: "catalog", "pricing", "inventory", "reviews", "ordering".
 However, it is not declared "@shareable" in the following subgraph: "nodes".
```

## K. Abstract types across a boundary

**An interface whose implementations are declared in different subgraphs**
composes, and Mosaic is the evidence rather than a synthetic pair: `interface
Node` is declared in `accounts`, `catalog`, `nodes`, `ordering` and `reviews`,
and its four implementations are owned by four different services. The composed
client schema in section B is what came out. Each subgraph declares the interface
and its own implementations and nobody declares anybody else's.

**A union whose members are declared in different subgraphs** was probed on a
synthetic pair during research and composes into the union of members, but
nothing in the companion repo reproduces it, so decision 55 applies and the
chapter does not print it. Recorded in section Q as unmeasured instead.

## L. `@interfaceObject`, measured

The sample is `samples/interface-object`: `library` on 5207 owns
`interface Media @key(fields: "id")` with `Book` and `Film`, both entities;
`ratings` on 5208 declares

```
type Media @key(fields: "id") @interfaceObject {
  id: ID!
  averageRating: Float
  ratingCount: Int!
}
```

HotChocolate 16.6.0 has `[InterfaceObject]` in
`HotChocolate.ApolloFederation.Types`, attributed `[Package(Federation23)]`, so
it is available at the v2.6 default this book emits.

### The composed schema

`averageRating` and `ratingCount` land on the interface and on every
implementation:

```
Media: INTERFACE  id, title, averageRating, ratingCount
Book:  OBJECT     id, title, pages, averageRating, ratingCount           implements Media
Film:  OBJECT     id, title, runtimeMinutes, averageRating, ratingCount  implements Media
```

The routing table sends all three `averageRating` coordinates to `ratings`.

### On the wire

Asking the whole library for a field the library subgraph has never heard of:

```
{ "__typename": "Book", "title": "The Mezzanine", "averageRating": 4.666666666666667, "ratingCount": 3 }
{ "__typename": "Book", "title": "Pale Fire", "averageRating": 5, "ratingCount": 2 }
{ "__typename": "Film", "title": "La Jetee", "averageRating": 4.5, "ratingCount": 4 }
{ "__typename": "Film", "title": "Sans Soleil", "averageRating": null, "ratingCount": 0 }
```

`f2` has no ratings row, and the field is nullable for exactly that reason: a
subgraph contributing to an interface cannot know which implementations exist.

The ratings subgraph's own log of what it was asked:

```
_entities  Media/b1
_entities  Media/b2
_entities  Media/f1
_entities  Media/f2
```

It is never told that `b1` is a `Book`. Meanwhile the router's plan builds the
representations from the concrete types:

```
representations:
  @key  Book   fragment Key on Book  { __typename id }
  @key  Film   fragment Key on Film  { __typename id }
query: query($representations: [_Any!]!){ _entities(representations: $representations){ ... on Media { averageRating } } }
```

So the router reads keys as `Book` and `Film`, and sends them typed as `Media`.
That is the whole mechanism, and the reason the contributing subgraph needs no
knowledge of the implementations.

Asking through a concrete fragment narrows what is fetched. For
`{ library { __typename ... on Book { pages averageRating } } }` the ratings log
is:

```
_entities  Media/b1
_entities  Media/b2
```

Two representations rather than four.

### Its failure modes

**The contributor forgets the directive**, declaring `Media` as an ordinary
object:

```
"Media" is defined using incompatible types across subgraphs. It is defined as type "Interface" in subgraph "library"
but type "Object" in subgraph "ratings".
```

Captured from `node scripts/modeling-cases.mjs --print
interface-object-without-the-directive`. An earlier scratch probe used the
subgraph names `io-owner` and `io-ratings`, which is why the first draft of the
chapter printed a truncated `"io-owne`; the committed case uses `library` and
`ratings` and the message is not truncated.

**An implementation has no key.** `Film` loses its `@key` while the interface
keeps one, and the composer stops being a composer:

```
Error: Fatal: Expected key "Film" to exist in the map "entityDataByTypeName".
    at invalidKeyFatalError (.../@wundergraph/composition/dist/errors/errors.js:433:12)
    at getOrThrowError (.../@wundergraph/composition/dist/utils/utils.js:28:49)
    at FederationFactory.handleEntityInterfaces (.../v1/federation/federation-factory.js:1337:68)
```

preceded by wgc's own "please open an issue" box. This is a crash rather than a
composition error, and it is asserted by name in `modeling-cases.mjs` so that a
release turning it into a message fails the gate rather than quietly making the
chapter wrong.

**The owning interface has no key at all** while the contributor declares one:
this **composes**, which is the quietest of the three and is recorded here
rather than in the chapter, because a router was never pointed at the result.
See section Q.

## M. The enum declared twice

Three measurements, and the answer depends only on where the enum is used.

**Both input and output.** `ProductCategory` is `Product.category` and is also
inside `ProductCategoryOperationFilterInput`. Add a member to `pricing`'s copy
and there is no safe merge:

```
Enum "ProductCategory" was used as both an input and output but was inconsistently defined across inclusive subgraphs.
To update an Enum used as both an input and output, add any new Enum values with the @inaccessible directive in the
origin subgraph. Next, add those new Enum values to all other subgraphs that define the Enum—this time without the
@inaccessible directive. Finally, once all subgraphs have been updated, remove @inaccessible from the Enum values in
the origin subgraph.
```

Removing a member from `pricing`'s copy produces the identical message. Note the
em dash in "the Enum—this time": that is the composer's own punctuation, and it
is what decision 60's `Characters.AllowInCapturedListings` exists for.

**Output position only.** A new `StockCondition` declared in `inventory` as
`NEW, REFURBISHED` and in `pricing` as `NEW, DAMAGED`, used only as a field's
return type in both. This **composes**, and the client schema is the union:

```
enum StockCondition {
  NEW
  DAMAGED
  REFURBISHED
}
```

**Input position only.** The same two declarations, used only as an argument
type. This **composes**, and the client schema is the intersection:

```
enum StockCondition {
  NEW
}
```

`REFURBISHED` and `DAMAGED` are gone from the graph although each is a value one
subgraph accepts, and nothing is reported at any severity.

Both merges are the safe direction for their position: every value a subgraph
can emit survives for a client reading, and only values every subgraph accepts
survive for a client writing. The cost is that the second one is silent feature
loss.

## N. Value types and scalars

**Nullability drifts permissively.** `Money.currency` declared `String!` in
`pricing` and `String` in `ordering` composes, and the client schema takes the
weaker side:

```
type Money {
  amount: Decimal!
  currency: String
}
```

Same rule decision 64 found for an `@external` field, now for a `@shareable`
value type, and with the same consequence: the field is weakened for every
client of the graph with no error and no warning.

**An extra field is unresolvable.** `Money` gains `formatted: String!` in
`ordering` only:

```
The field "formatted" is unresolvable at the following path:
 query {
  products {
   price {
    formatted <--
   }
  }
 }
This is because:
 - The root type field "Query.products" is defined in the following subgraph: "catalog".
 - The field "Money.formatted" is defined in the following subgraph: "ordering".
 - The entity ancestor "Product" in subgraph "pricing" has no accessible target entities (resolvable @key directives) in the subgraphs where "Money.formatted" is defined.
 - The type "Money" is not a descendant of any other entity ancestors that can provide a shared route to access "formatted".
 - The type "Money" has no accessible target entities (resolvable @key directives) in any other subgraph, so accessing other subgraphs is not possible.
```

The error is not about value types. A value type is not an entity, so there is
no key the router could use to fetch the missing field, and satisfiability says
exactly that.

**`@shareable` is required on every copy.** Dropping it from `ordering`'s
`Money`:

```
The Object "Money" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "amount" is defined and declared "@shareable" in the following subgraph: "pricing".
 However, it is not declared "@shareable" in the following subgraph: "ordering".
 The field "currency" is defined and declared "@shareable" in the following subgraph: "pricing".
 However, it is not declared "@shareable" in the following subgraph: "ordering".
```

**A scalar promises nothing.** Two subgraphs declaring `Decimal` with
disagreeing `@specifiedBy` urls compose with no message. Both urls are dropped
on the way in, so the composed client schema is:

```
scalar Decimal
```

The composer checks structure, and a scalar has none. Two teams can mean euros
and cents by the same name and nothing in the toolchain can notice.

## O. What the gates assert

New in `scripts/verify.ps1` and `scripts/verify.sh`, both:

- `nodes` joins the subgraph list: builds, exports a schema that must match
  `schema/nodes.graphql`, answers `/health`, publishes the committed SDL through
  `_service`, and assembles the same 13 middleware as the other six.
- `nodes` joins `SilentForStorefront`: a storefront query must not reach it.
- `scripts/modeling-cases.mjs`, sixteen cases, two of which are chapter 11's
  `@requires` questions.
- The two interface-object sample schemas are checked for drift, and the two
  directives the chapter prints are checked by name.
- `node()` is asked for all four addressable types through the router, and each
  answer must carry a field owned by a different service.
- The cursor check: a page selecting only `title` must not produce an all-zero
  tiebreaker, and page two must not repeat a title from page one.
- `postman/mosaic-nodes.postman_collection.json`, seven requests and 27
  assertions, run through newman.

## P. Reproduction recipes

Composition behaviour, no services needed:

```
node scripts/modeling-cases.mjs
node scripts/modeling-cases.mjs --list
node scripts/modeling-cases.mjs --print enum-in-input-only-is-intersected
```

The node field, needing the graph:

```
docker compose up -d --build mosaic-db mosaic-catalog mosaic-pricing \
    mosaic-inventory mosaic-accounts mosaic-reviews mosaic-ordering \
    mosaic-nodes mosaic-router
npx newman run postman/mosaic-nodes.postman_collection.json \
    -e postman/mosaic-nodes.local.postman_environment.json
```

The interface-object sample, needing two processes and its own router:

```
dotnet run --project samples/interface-object/Mosaic.Sample.InterfaceObject.Library
dotnet run --project samples/interface-object/Mosaic.Sample.InterfaceObject.Ratings
npx wgc router compose -i samples/interface-object/graph.yaml \
                       -o samples/interface-object/supergraph.json
docker compose --profile interfaces up -d interfaces-router
```

then port 3004, and `{ resolutionLog }` on 5208 for what the router asked.

The cursor defect, against an older tag:

```
git checkout ch12
docker compose up -d --build mosaic-catalog
# page one, then page two with its second cursor, selecting only title
```

## Q. Left unmeasured, and who owns it

- **A router pointed at an `@interfaceObject` graph whose owning interface has
  no `@key`.** It composes; nothing was run against the result. Chapter 17 reads
  the composer and owns the answer.
- **`@interfaceObject` where two subgraphs both contribute to the same
  interface**, and whether the router batches their entity fetches. Chapter 17.
- **An entity interface with an implementation added after the contributing
  subgraph was deployed.** The claim that the new implementation gets the field
  for free follows from the composition rules and was not run. Chapter 22 owns
  the deployment story.
- **Whether the plan cache keys on the `node` field's argument.** Chapter 17.
- **What `node` costs in milliseconds** against a typed root field like
  `productById`. Decision 62 keeps timings out of the gate, and no committed
  script measures this one. Chapter 24.
- **`Query.nodes` with a list long enough to matter**, and whether the router
  batches the entity fetches per type. Chapter 24.
- **Authorisation on `node`.** A single field that returns anything in the graph
  is a single field that has to be authorised for anything in the graph, and
  nothing here does that. Chapter 15.
- **A cursor whose sort key is not unique**, where two products share a title.
  The seed data has no duplicate titles, so the tiebreaker's job was inferred
  from the code rather than from a collision. Chapter 24 or a seed change.
- **A union whose members are declared in different subgraphs.** Probed on a
  synthetic pair during research, where it composes into the union of members.
  Nothing in the companion repo reproduces it and Mosaic has no instance, so
  decision 55 keeps it out of the chapter. Chapter 17 reads the composer and
  owns it, or a later chapter that grows Mosaic a union across a seam.
- **Whether `--split-configs-enabled` does anything**, still the only wgc flag
  this book has not exercised. Chapter 22.

## R. Bibliography keys

No new citations. Every claim in this chapter is measured on this machine or
read out of a pinned source tree, and the two directives it describes
(`@interfaceObject`, `@key` on an interface) are exercised rather than quoted.
The Apollo specification version in the SPEC baseline is unchanged.
