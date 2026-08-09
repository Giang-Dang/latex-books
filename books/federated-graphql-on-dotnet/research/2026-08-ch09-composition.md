# Chapter 09 research - composition

Research date: 2026-08-09. Every number and every listing in this file was
captured from a running tool on the author's machine, or read out of a primary
source at a pinned version. Where the two disagree the running tool wins and the
disagreement is recorded in section J.

The chapter's companion code is `mosaic-graph` at tag `ch09`. Neither service
changes: chapter 9 is about what a tool says when it is handed the two schemas
chapter 8 produced.

## Contents

- A. Version baseline
- B. The command, and what it is not
- C. What the composed file actually contains
- D. The client schema has no federation in it
- E. Satisfiability, measured
- F. The error catalogue
- G. Five errors produced on purpose
- H. The switch that turns satisfiability off
- I. Measurements
- J. Where docs and behaviour disagree
- K. What the gate asserts
- L. Reproduction recipes
- M. Left unmeasured, and who owns it
- N. Bibliography keys

## A. Version baseline

| Component | Version | How checked |
|---|---|---|
| wgc (Cosmo CLI) | 0.129.7 | pinned exactly in `package.json` |
| `@wundergraph/composition` | 0.63.2 | `node_modules/@wundergraph/composition/package.json`, hoisted from wgc |
| HotChocolate, HotChocolate.ApolloFederation | 16.6.0 | `Directory.Packages.props`; unchanged from chapter 8 |
| Federation version the subgraphs emit | v2.6 | the `@link` line of both committed schemas |
| Apollo Federation specification | v2.15 (LTS, Jul 2026) | SPEC version baseline, unchanged |
| node | 24.15.0 | `node --version` |

No service runs in this chapter's own experiments and no router is involved.
`wgc router compose` reads two files and writes one.

## B. The command, and what it is not

```
npx wgc router compose -i federation/mosaic.yaml -o federation/supergraph.json
```

`federation/mosaic.yaml` was created in chapter 8 and names the two subgraphs,
their routing URLs and the file holding each one's schema. The schema files are
what `_service { sdl }` returns, committed under `schema/`.

Cosmo's own documentation for the command says it "does not interact with the
control plane and completely runs locally"~[web]. Chapter 7 established the same
thing by watching the subgraph consoles: with the `file:` form nothing is called
at all, and with the `introspection:` form the composer sends one
`{ _service { sdl } }` query. Not re-measured here.

**The output is not a supergraph schema.** It is a *router execution config*:
one JSON file the router loads. Section C takes it apart. The distinction is the
whole reason the chapter's second section exists, because "compose the
supergraph" is what every tutorial calls this step and the artifact does not
match the name.

Options the CLI offers, from `wgc router compose --help` at 0.129.7:

```
-i, --input <path-to-input>
-o, --out [string]
--suppress-warnings
--disable-resolvability-validation
--ignore-external-keys
--split-configs-enabled
```

`--disable-resolvability-validation` is section H. The other three are named in
the chapter and not exercised.

## C. What the composed file actually contains

Measured on `federation/supergraph.json`, composed from the two committed
schemas at tag `ch09`. The file is **31,555 bytes** on one line.

Top level, five keys:

| Key | Type | Bytes as JSON |
|---|---|---|
| `engineConfig` | object | 31,272 |
| `version` | string | 38 |
| `subgraphs` | array of 2 | 146 |
| `featureFlagConfigs` | object | 2 (empty) |
| `compatibilityVersion` | string | 10 |

```
"version": "00000000-0000-0000-0000-000000000000",
"compatibilityVersion": "1:0.63.2"
```

The all-zero version is what a locally composed config gets, because there is no
registry to take a version from; chapter 7 met the same value and watched the
router log it as `config_version`.

**`compatibilityVersion` is two numbers joined by a colon, and both are
checkable.** The `1` is `ROUTER_COMPATIBILITY_VERSION_ONE` in
`@wundergraph/composition/dist/router-compatibility-version/router-compatibility-version.js`,
where `LATEST_ROUTER_COMPATIBILITY_VERSION = '1'` is the only member of
`ROUTER_COMPATIBILITY_VERSIONS`. The `0.63.2` is the `version` field of that
package's own `package.json`. So the string names the router contract and the
library that produced the file. [source]

`subgraphs` is the routing table in its smallest form:

```json
[
  { "id": "0", "name": "catalog", "routingUrl": "http://localhost:5101/graphql" },
  { "id": "1", "name": "mosaic",  "routingUrl": "http://localhost:5100/graphql" }
]
```

`engineConfig`, five keys:

| Key | Type | Bytes as JSON |
|---|---|---|
| `defaultFlushInterval` | string `"500"` | 5 |
| `datasourceConfigurations` | array of 2 | 13,980 |
| `fieldConfigurations` | array of 8 | 1,367 |
| `graphqlSchema` | string | 6,546 |
| `stringStorage` | object of 2 | 9,264 |

### `datasourceConfigurations` is where ownership lives

Per datasource: `rootNodes`, `childNodes`, `keys`, `customGraphql`,
`requestTimeoutSeconds` (`"10"` for both), `overrideFieldPathFromAlias` (`true`
for both).

`rootNodes` is the set of types the router may *enter* this subgraph at.
Measured:

```
catalog  Query:   products, browseProducts, productById, productBySku
         Product: id, sku, title, description, category

mosaic   Query:        customerById, ordersByCustomer
         Mutation:     submitReview
         Subscription: onReviewAdded
         Product:      availableQuantity, price, reviews, averageRating, id
```

`Product` is a root node in **both**, which is what being an entity means: the
router can enter either subgraph at `Product` through `_entities`. Every other
root node is a genuine operation root.

`childNodes` is what is reachable once inside: 5 types for catalog
(`PageCursor`, `PageInfo`, `ProductConnection`, `ProductEdge`, `Node`), 15 for
mosaic (`Customer`, `CustomerNotFoundError`, `DuplicateReviewError`, `Money`,
`Order`, `OrderLine`, `PageCursor`, `PageInfo`, `RatingOutOfRangeError`,
`Review`, `ReviewConnection`, `ReviewEdge`, `SubmitReviewPayload`, `Error`,
`Node`).

`keys` is identical in both:

```json
[ { "typeName": "Product", "selectionSet": "id" } ]
```

### Each subgraph's schema is in the file twice

`customGraphql` holds `fetch`, `subscription`, `federation` and
`upstreamSchema`. Two of those carry SDL, and they are not the same SDL.

- **`federation.serviceSdl`** is the subgraph's schema **byte for byte as the
  composer read it**. Verified with SHA-256 over both: `schema/catalog.graphql`
  and the `serviceSdl` of datasource 0 are both 5,127 bytes and hash to
  `b72585e2b4c146e6...`; `schema/mosaic.graphql` and datasource 1's are both
  5,150 bytes and hash to `6df83eccb48234b5...`. The composer copies its input.
- **`upstreamSchema`** is `{"key": "<sha1>"}`, a reference into
  `engineConfig.stringStorage`, which holds a **normalised** form: 4,224 bytes
  for catalog against the 5,127 it came from.

`stringStorage` has exactly two entries here, one per subgraph, and **the key of
each is the SHA-1 of its value**. Verified in node for both entries:

```
35fef470f114894fa41bd5ab1cedf9f40b322b70   4224 bytes   catalog, normalised
cf63f1d70b93c81773a0d3dd92a34c9e5a2d6fd1   4259 bytes   mosaic, normalised
```

What the normalisation does, read off the catalog pair by diffing the two
documents rather than by reading the shorter one and guessing:

**It removes the federation entry points.** This is where the 903 bytes go.
`Query` loses `_service` and `_entities`, and the types `_Service`, `_Entity`
and `_Any` are gone from the document entirely. Measured by extracting the
top-level declaration names from both and taking the set difference.

**It adds the definitions the router needs to validate against.** In: the
`directive @key`, `@link` and `@shareable` definitions, plus `scalar
link__Import`, `enum link__Purpose` and `scalar openfed__FieldSet`.

The rest is canonicalisation, so that two schemas meaning the same thing are
spelled the same way:

- sorts types, fields **and arguments** alphabetically (an earlier version of
  this note said fields only)
- rewrites `"..."` descriptions as `"""..."""` block strings
- collapses the multi-line `@link(...)` onto one line
- **distributes an object-level `@shareable` onto every field of the object**:
  chapter 8's `type PageCursor @shareable` becomes `cursor: String! @shareable`
  and `page: Int! @shareable`
- rewrites `@key(fields: FieldSet!)` as `@key(fields: openfed__FieldSet!)`
- adds `@specifiedBy(...)` to `scalar UUID`

Note the direction: every item on that second list adds bytes or leaves the
count alone. Only the removed federation machinery explains a shorter document,
which is the check that caught the first version of this section.

## D. The client schema has no federation in it

`engineConfig.graphqlSchema` is a 6,035-character string, 285 newlines.

**Measured: it contains no `join__` anything.** Grepping the whole 31 KB config
for `join__` returns nothing. Grepping the extracted schema for every federation
directive returns one line, and it is not a directive:

```
scalar FieldSet
```

The only directive appearing anywhere in that schema is `@deprecated`, on
`Query.products`, which chapter 5 put there.

This is a real structural difference from Apollo, not a presentational one.
Apollo's documentation describes three schema types: a subgraph schema, a
supergraph schema that "combines all of the types and fields from your subgraph
schemas, plus some federation-specific information that tells your router which
subgraphs can resolve which fields", and an API schema that "omits
federation-specific types, fields, and directives that are considered
'machinery'"~[web]. Apollo's supergraph schema carries that information as
`@join__type`, `@join__field` and `@join__graph` annotations in one document.

Cosmo splits the same information in two: the API schema as a plain string, and
the routing information as `datasourceConfigurations`. There is no annotated
middle document in a Cosmo execution config at all.

### The `FieldSet` leak

`scalar FieldSet` is in the client-facing schema and nothing in that schema uses
it. Cause: HotChocolate writes

```
@link(url: "https://specs.apollo.dev/federation/v2.6",
      import: ["@key", "@shareable", "@tag", "FieldSet"])
```

so `FieldSet` is imported as a *named type* rather than only as the directive's
argument type, and the composer keeps imported named types. Both subgraphs do
it, so it survives into the merged schema. A scalar nobody wrote and no client
can send. Not fatal, not documented, and visible to anyone who introspects the
router. Reported as an observation rather than as a bug in either tool, because
which of the two should have dropped it is exactly the sort of question chapter
8 declined to adjudicate about `@cost`.

## E. Satisfiability, measured

Apollo states the rule as one of three composition rules: "If multiple subgraphs
define the same type, each field of that type must be resolvable by every valid
GraphQL operation that includes it", and calls it "the most complex and the most
essential to Federation 2"~[web].

Cosmo implements it as a graph walk. The implementation is
`@wundergraph/composition/dist/resolvability-graph/`, which contains `graph.js`,
`graph-nodes.js`, `walker/`, `node-resolution-data/` and `utils/utils.js`.
[source]

**There is exactly one satisfiability error factory.** `unresolvablePathError`
in `dist/errors/errors.js`:

```js
function unresolvablePathError({ fieldName, selectionSet }, reasons) {
    const message = `The field "${fieldName}" is unresolvable at the following path:\n${selectionSet}` +
        `\nThis is because:\n - ` +
        reasons.join(`\n - `);
    return new Error(message);
}
```

Everything a satisfiability failure can tell you is in the `reasons` array, and
those strings are assembled by `generateResolvabilityErrorReasons` and
`generateSharedResolvabilityErrorReasons` in
`dist/resolvability-graph/utils/utils.js`. Reading those two functions is the
cheapest way to learn what the check knows: it can say which root field it
started from, which subgraphs define the field, which of them declare it
`@external`, and whether the entity ancestor could satisfy a key field set to
reach the subgraph that has it.

The selection set in the message is *rendered*, not quoted: `renderSelectionSet`
draws the path from the root as a GraphQL document and marks the offending field
with `<--`. `MAX_RESOLVABILITY_PATH_SIZE` truncates long paths with a
`... # and N truncated selections` line. So the error is a query the router
could not plan.

## F. The error catalogue

Counted in `@wundergraph/composition@0.63.2`, `dist/errors/errors.d.ts`.

**Count the declared types, not the declarations.** The module exports 203
things, and only 123 of them are errors; the other 80 are `string` message
fragments spliced into the errors to build a sentence. An earlier version of
this note, and the first draft of the chapter, said 203 and was wrong by nearly
a factor of two. The independent audit caught it.

| | Error | string | total |
|---|---|---|---|
| `export declare function` | 119 | 74 | 193 |
| `export declare const` | 4 | 6 | 10 |
| **total** | **123** | **80** | **203** |

The six string constants are three declared `: string` and three assigned a
literal, which is why a `: string` grep undercounts them.

Reproduce, from `node_modules/@wundergraph/composition`:

```
node -e "const t=require('fs').readFileSync('dist/errors/errors.d.ts','utf8');
  const f=[...t.matchAll(/export declare function\s+\w+[\s\S]*?\):\s*(\w+);/g)];
  const c=[...t.matchAll(/export declare const\s+\w+\s*:\s*(\w+);/g)];
  const n=(a,t)=>a.filter(m=>m[1]===t).length;
  console.log('fn Error',n(f,'Error'),'fn string',n(f,'string'),
              'const Error',n(c,'Error'));"
```

A plain `grep -c 'export declare function .*: Error;'` returns 118 rather than
119, because one declaration wraps onto a second line. That is why the
reproduction above parses rather than greps.

Exactly one of the 123 is about satisfiability. The rest are structural: 
duplicate definitions, invalid directive locations, incompatible merged types,
shareability, `@override` targets, event-driven graph rules, and so on. The
chapter uses the number to make one point - that the check which people worry
about is a single error, and the errors they will actually meet are the boring
structural ones.

## G. Five errors produced on purpose

All five live in `scripts/composition-cases.mjs` at tag `ch09`. Each is the real
committed pair with one literal string replacement applied, so no fixture schema
was invented to produce any of them. Messages below are the composer's own,
unwrapped from the box wgc draws around them (`--print <case>` does the
unwrapping; the boxes and their line breaks are the CLI's, the text is not).

### 1. `unsatisfiable-key`

Edit: `mosaic`'s `type Product @key(fields: "id")` becomes
`@key(fields: "id", resolvable: false)`.

Four errors, one per field Mosaic contributes. The first, in full:

```
The field "availableQuantity" is unresolvable at the following path:
 query {
  products {
   availableQuantity <--
  }
 }
This is because:
 - The root type field "Query.products" is defined in the following subgraph: "catalog".
 - The field "Product.availableQuantity" is defined in the following subgraph: "mosaic".
 - The entity ancestor "Product" in subgraph "catalog" has no accessible target entities (resolvable @key directives) in the subgraphs where "Product.availableQuantity" is defined.
 - The type "Product" is not a descendant of any other entity ancestors that can provide a shared route to access "availableQuantity".
```

The other three are identical in shape for `price`, `reviews` and
`averageRating`. `price` and `reviews` have composite types, so their rendered
selection sets read `price { <--` followed by `...`.

**Observation worth stating carefully.** Catalog has four root fields returning
`Product` - `products`, `browseProducts`, `productById`, `productBySku` - and
the error names only `Query.products`. The message reports *a* route that fails,
not every route that fails. Not investigated further; the chapter says only what
was measured.

### 2. `duplicate-field`

Edit: `mosaic`'s `Product` gains `title: String!`.

```
The Object "Product" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "title" is defined in the following subgraphs: "catalog", "mosaic".
 However, it is not declared "@shareable" in any of them.
```

### 3. `incompatible-type`

Edit: `catalog`'s `Product` gains `averageRating: Int @shareable`, and mosaic's
existing `averageRating: Float` gains `@shareable`.

```
Each instance of a shared field must resolve identically across subgraphs.
The field "Product.averageRating" could not be federated due to incompatible types across subgraphs.
The discrepancies are as follows:
 The named type "Int" is returned by the following subgraph: "catalog".
 The named type "Float" is returned by the following subgraph: "mosaic".
```

**Printed twice by the composer**, identically. See section J.

### 4. `missing-key`

Edit: `mosaic`'s `type Product @key(fields: "id") {` becomes `type Product {`.

```
The Object "Product" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "id" is defined and declared "@shareable" in the following subgraph: "catalog".
 However, it is not declared "@shareable" in the following subgraph: "mosaic".
```

**The error does not mention the missing key.** A key field is implicitly
shareable, so removing the key demotes `id` to an ordinary field declared in two
subgraphs, and shareability is where the composer notices. This is the
chapter's central point about reading these messages.

### 5. `key-mismatch`

Edit: `mosaic` keys on `sku` and gains a `sku: String!` field.

```
The Object "Product" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "id" is defined and declared "@shareable" in the following subgraph: "catalog".
 However, it is not declared "@shareable" in the following subgraph: "mosaic".
 The field "sku" is defined and declared "@shareable" in the following subgraph: "mosaic".
 However, it is not declared "@shareable" in the following subgraph: "catalog".
```

Symmetric, and again never the words "your keys disagree". Each side's key field
is implicitly shareable at home and ordinary abroad.

Three of the five - 2, 4 and 5 - are the same error factory,
`invalidFieldShareabilityError`, from three different causes. Its two message
shapes are visible in its source: one for "shareable nowhere", one for
"shareable in some and not others". [source]

### A sixth case, measured and not committed

Declaring `enum ProductCategory` in both subgraphs with different members
produces:

```
Enum "ProductCategory" was used as both an input and output but was inconsistently
defined across inclusive subgraphs. ...
```

**Three identical copies.** This case is deliberately not in the committed set
and the chapter does not print it: the message contains a U+2014 em dash
("the Enum—this time"), and this book's `check-chapter.psd1` sets
`Characters.Mode = 'Ascii'`, which is a rule about pasted listings that this
message would break for a legitimate reason. Recording the finding here rather
than weakening the rule or altering captured text. See the retro.

## H. The switch that turns satisfiability off

`--disable-resolvability-validation`, whose own help text reads:

```
This flag will disable the validation for whether all nodes of the federated
graph are resolvable. Do NOT use unless troubleshooting.
```

Measured. The `unsatisfiable-key` pair from section G, which produces four
errors and no output, composes successfully with the flag and writes a config,
31,622 bytes against the good config's 31,555.

Flattening both configs to leaves and comparing gives **five** differing leaves,
and the split between them matters:

| leaf | why it differs |
|---|---|
| `...[1].customGraphql.federation.serviceSdl` | the edit: mosaic's SDL is 19 chars longer |
| `...[1].customGraphql.upstreamSchema.key` | `cf63f1d7...` becomes `04b6d7c0...` |
| `stringStorage.cf63f1d7...` | dropped |
| `stringStorage.04b6d7c0...` | added |
| `...[1].keys[0].disableEntityResolver` | **the flag** |

Four of the five are the edit echoing back through the content-addressed
storage, and have nothing to do with the flag. The fifth is the only thing in
the file that records the graph is broken.

A first version of this note claimed there was exactly one difference. That was
a comparison of the wrong pair reported as the right one: the honest statement
is that only one of the five differences is attributable to the flag, and there
is no same-input-two-outputs comparison available, because without the flag
there is no output at all. The independent audit caught it.

- `engineConfig.graphqlSchema` is **identical**. Compared with `===` in node:
  `true`. The client-facing schema still advertises `price`,
  `availableQuantity`, `reviews` and `averageRating` on `Product`.

So the router is handed a schema that promises four fields and a routing table
saying the only subgraph holding them cannot be entered. Nothing in the
composed API schema records that the graph was composed with the check off.

Reproduce with `scratchpad/leafdiff.js`-style flattening, or:

```
node -e "const a=require('./federation/supergraph.json'),b=require('./scratch.json');
  console.log(a.engineConfig.graphqlSchema===b.engineConfig.graphqlSchema)"
```

## I. Measurements

All on the author's machine, 2026-08-09, wgc 0.129.7, node 24.15.0.

| Thing | Value |
|---|---|
| `federation/supergraph.json` | 31,555 bytes, one line |
| Client schema inside it | 6,035 characters, 285 newlines |
| `stringStorage` entries | 2 |
| catalog SDL: as read / normalised | 5,127 / 4,224 bytes |
| mosaic SDL: as read / normalised | 5,150 / 4,259 bytes |
| `datasourceConfigurations` | 2, of 13,980 bytes total |
| `fieldConfigurations` | 8, one per field that takes arguments |
| Declarations in the error module | 203 |
| Of those, actual errors | 123 (119 functions + 4 constants) |
| Satisfiability error factories | 1 |
| Config composed with the check off | 31,622 bytes, 5 leaves differing, 1 of them the flag |
| Errors from the `unsatisfiable-key` case | 4 |
| `requestTimeoutSeconds`, both datasources | `"10"` |
| `defaultFlushInterval` | `"500"` |

**Composition is deterministic.** Composed twice from the same input and
compared with `cmp`: identical. That is what makes committing the output and
diffing it in the gate workable.

No timings are given for the command. It is a build step run by hand or in CI,
its cost is dominated by node start-up on this machine, and a millisecond figure
for it would be a number with nothing riding on it.

## J. Where docs and behaviour disagree

- **The command is called `router compose` and the artifact is not a
  supergraph.** Every tutorial phrase for this step, Cosmo's own included, is
  "compose the supergraph". What lands is a router execution config in which the
  supergraph schema, in Apollo's sense of an annotated merged document, does not
  appear at all. Not a documentation error so much as a name that survives its
  artifact.
- **`scalar FieldSet` reaches the client-facing schema** through HotChocolate's
  `@link` import list. Section D.
- **The composer prints some errors more than once**: twice for
  `incompatible-type`, three times for the uncommitted enum case, identically
  each time. Once for the three shareability cases and once per unresolvable
  field for satisfiability. No pattern was established and the chapter does not
  claim one; it says that a count of lines is not a count of faults.
- **The `missing-key` and `key-mismatch` errors never name the key.** Section G.
  This is correct behaviour reported at the point of comparison, and it is the
  single most useful thing to know before reading composition output.

## K. What the gate asserts

Added to `scripts/verify.ps1` and `scripts/verify.sh` at tag `ch09`, inside the
existing composition step:

- a fresh compose of `federation/mosaic.yaml` matches the committed
  `federation/supergraph.json`, compared with the same normalising text
  comparison used for the subgraph schemas
- `node scripts/composition-cases.mjs` exits 0, which means all six cases
  behave as the chapter says: the baseline composes and the other five fail
  with the expected message fragments

Both assertions exist because the chapter prints the artifacts they check. The
case runner has its own guard: each edit is a literal replacement that must
match exactly once, so a change to a committed schema that removes the text a
case edits fails with "matched 0 times" rather than composing something nobody
meant.

Captured from the summary of a passing `pwsh scripts/verify.ps1` run on
2026-08-09, which is where the chapter's three gate listings come from:

```
[ok]   catalog and mosaic compose into one supergraph
[ok]   the composed config matches federation/supergraph.json
[ok]   the composition errors chapter 9 prints are the ones wgc produces
[ok]   both subgraphs publish the committed schemas through _service
```

The last of those predates this chapter; chapter 8 added it, and chapter 9 cites
it in section 9.6 as the check that keeps the composer's file input honest.

And the guard firing, captured after putting one extra space inside the `@key`
on `Product` in `schema/mosaic.graphql` and running the case runner. Four of the
five cases edit that line, so four went stale at once:

```
  FAILED   missing-key         mosaic declares Product and forgets the key
             case "missing-key": the edit to mosaic matched 0 times, expected exactly 1.
             The text it looks for is:
             type Product @key(fields: "id") {
             The committed schema has changed under this case. Fix the case rather than the schema.
```

`scripts/composition-cases.mjs` is the first node script in the repository. The
alternative was implementing the same mutate-compose-assert logic twice, once in
PowerShell and once in sh, and letting the two drift, which is exactly the
failure the ch04 open item recorded about `verify.sh`.

## L. Reproduction recipes

Nothing here needs a database, a container or a running service.

```
git checkout ch09
npm ci

# the composed config the chapter takes apart
npx wgc router compose -i federation/mosaic.yaml -o federation/supergraph.json

# the five errors, and the sixth case that composes
node scripts/composition-cases.mjs --list
node scripts/composition-cases.mjs
node scripts/composition-cases.mjs --print unsatisfiable-key
```

To read the config in the shape section C describes:

```
node -e "const c=require('./federation/supergraph.json');
         console.log(Object.keys(c.engineConfig));
         console.log(JSON.stringify(c.engineConfig.datasourceConfigurations[0].rootNodes,null,1))"
```

To count the error catalogue:

```
cd node_modules/@wundergraph/composition
grep -c 'export declare function' dist/errors/errors.d.ts
grep -c 'export declare const'    dist/errors/errors.d.ts
```

To reproduce section H:

```
node scripts/composition-cases.mjs --print unsatisfiable-key    # four errors
# then compose the same pair by hand with the flag and diff the two configs
```

## M. Left unmeasured, and who owns it

- **Anything a router does with this config.** No router runs in this chapter.
  Chapter 10 loads exactly this file.
- **Whether the router rejects a config composed with the resolvability check
  off, or fails at request time.** Section H shows what the config looks like and
  stops there. Chapter 10 can answer it in one request.
- **`--split-configs-enabled`, `--ignore-external-keys`, `--suppress-warnings`.**
  Named from `--help`, none exercised. `--ignore-external-keys` needs
  `@external`, which arrives in chapter 11.
- **Warnings.** The composer has a `warnings` module and Mosaic's pair produces
  none, so no warning text was ever seen. Whatever first produces one owns it.
- **`@override`, `@requires`, `@provides`, `@interfaceObject` in composition.**
  Chapters 11 and 12. The `fieldConfigurations` entries in this config all carry
  `sourceType: FIELD_ARGUMENT`; `@requires` is what makes that field interesting.
- **The subscription protocol in the config.** Both datasources say
  `GRAPHQL_SUBSCRIPTION_PROTOCOL_WS` with `websocketSubprotocol` `AUTO`, while
  chapter 5 exercised Mosaic's subscription over SSE. Nothing here tested which
  the router would actually use. Chapter 14.
- **Composition against more than two subgraphs.** Chapter 12 carves the
  remaining five domains, and satisfiability gets interesting when a route can
  go through a third service.
- **Whether an Apollo-style annotated supergraph SDL can be obtained from wgc at
  all.** Not investigated. Chapter 28 contrasts the two stacks.

## N. Bibliography keys

Two existing keys are reused and two new `@online` entries are added.

Reused:

- `apollo2026compositionrules` - the three composition rules, and the
  field-resolvability rule quoted in section 9.3
- `cosmo2026routercompose` - that the command runs locally and contacts no
  registry, cited in section 9.1

New:

- `apollo2026schematypes` - Apollo's three schema types, for the supergraph and
  API schema definitions quoted in section 9.2. URL
  https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/schema-types
- `apollo2026compositionrulesref` - **not added.** The composition-rules page
  exists at two URLs, `/reference/federation/composition-rules` (already in
  `refs.bib` as `apollo2026compositionrules`) and
  `/schema-design/federated-schemas/reference/composition-rules`. Both were
  fetched on 2026-08-09 and both carry the field-resolvability rule in the same
  words. The existing key is kept and the second URL is not cited, because two
  keys for one document would make the bibliography claim two sources where
  there is one.

Everything else in this chapter is measured or read out of a pinned source tree,
and carries no citation for the same reason chapter 8 gave: naming a vendor page
as the authority for what a tool did would be a weaker claim than the capture.
