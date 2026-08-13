# Inside the router and the composer - facts verified 2026-08-12

Four source trees, all cloned locally and read rather than fetched a page at a
time (decision 32). Paths in this note are prefixed with the tree they belong
to.

| Prefix | Tree | Tag | Commit |
|---|---|---|---|
| `composer:` | `F:/repo/cosmo-composition` | `@wundergraph/composition@0.63.2` | `818c67e2668bc0d911dbd0121c18d510392d1032` |
| `router:` | `F:/repo/cosmo-router` | `router@0.337.1` | `2f50ab88b985810645ceb8504e1bed0208d5d9f4` |
| `gqltools:` | `F:/repo/graphql-go-tools` | `v2.14.2` | `ed1d3adf74d9a08ad434f01b38bb2da72ab2873b` |
| `apollo:` | `F:/repo/apollo-federation` | `@apollo/query-planner@2.14.3` | `7d9eda8dfa6753cd05385ae333cf31e452cef75f` |

The third tree is the one that matters most and is the one no earlier chapter
knew about. `router: router/go.mod:34` reads
`github.com/wundergraph/graphql-go-tools/v2 v2.14.2`, and normalization,
planning, the fetch tree and the loader all live there. The Go code in
`router/core/` is a shell around it.

`[source]` means read out of one of those trees. `[measured]` means run on this
machine, with the recipe in section M.

Chapter 9 read what the composer emits; chapter 10 read what the router loads.
This chapter goes inside both. It pays six debts recorded against it in the
SPEC's progress row.

## A. The composer's resolvability graph

**[source]** `composer: composition/src/resolvability-graph/graph.ts:20-32`. One
`Graph` instance for the whole composition run, not one per subgraph:

```typescript
export class Graph {
  edgeId = -1;
  entityDataNodeByTypeName = new Map<TypeName, EntityDataNode>();
  nodeByNodeName = new Map<NodeName, GraphNode>();
  nodesByTypeName = new Map<TypeName, Array<GraphNode>>();
  resolvedRootFieldNodeNames = new Set<NodeName>();
  rootNodeByTypeName = new Map<RootTypeName, RootNode>();
  subgraphName: SubgraphName = NOT_APPLICABLE;
  resDataByNodeName = new Map<NodeName, NodeResolutionData>();
```

Nodes are keyed `${subgraphName}.${typeName}` - one node per (subgraph, type)
pair rather than one per federated type, which is what lets the walk ask "can I
get from here to there without leaving a subgraph that can answer".

**[source]** `composer: composition/src/v1/normalization/batch-normalization/batch-normalizer.ts:209-217`.
The graph is created before any subgraph is normalized and the same instance is
threaded through every subgraph's pass, so the edges accumulate in subgraph
order and, within a subgraph, in SDL document order.

**[source]** `composer: composition/src/v1/federation/federation-factory.ts:3097-3113`.
Satisfiability is the **last** thing the composer does, and only if everything
else already passed:

```typescript
    // Return any composition errors before checking whether all fields are resolvable
    if (this.errors.length > 0) {
      return { errors: this.errors, success: false, warnings: this.warnings };
    }
```

That is worth stating on its own: a schema pair with a shareability error never
reaches the resolvability check at all, so "it composed apart from one error" and
"it is resolvable" are different claims and the composer only ever tells you the
first.

The walk itself is an ordinary recursive depth-first traversal
(`composer: composition/src/resolvability-graph/walker/root-field-walkers/root-field-walker.ts:196-207`),
with cycle detection by stamping a per-walk index into each edge's
`visitedIndices` set rather than a visited-node bitmap on the graph.

## B. Why the satisfiability error names one root field out of four

Chapter 9 measured this and explicitly declined to explain it: `catalog` has
four root fields returning a product - `products`, `browseProducts`,
`productById`, `productBySku` - and the `unresolvable-key` error names only
`Query.products`. That chapter recorded "the message reports *a* route that
fails, not every route that fails" and stopped.

**[source]** `composer: composition/src/resolvability-graph/graph.ts:225-279`.
`Graph.validate()` loops over root fields and **returns on the first failure**.
The two exits are at 259 and 271:

```typescript
        const fieldData = getOrThrowError(rootNode.fieldDataByName, rootFieldName, 'fieldDataByName');
        const rootFieldData = newRootFieldData(rootNode.typeName, rootFieldName, fieldData.subgraphNames);
        // If there are no nested entities, then the unresolvable fields must be impossible to resolve.
        if (!involvesEntities) {
          return {
            errors: generateRootResolvabilityErrors({
              unresolvablePaths: rootFieldWalker.unresolvablePaths,
              resDataByPath: rootFieldWalker.resDataByPath,
              rootFieldData,
            }),
            success: false,
          };
        }

        const result = this.validateEntities({ isSharedRootField, rootFieldData, walker: rootFieldWalker });
        if (!result.success) {
          return result;
        }
```

`validate()` is called once, from `federation-factory.ts:3109`, and its result
is returned as-is, so nothing retries the remaining root fields.

`rootNode.headToSharedTailEdges` is a JS `Map`, which iterates in insertion
order, and edges are inserted while `graphql-js` walks each subgraph's AST
(`composer: composition/src/v1/normalization/walkers.ts:288-309`). So the order
is SDL declaration order.

### B.1 The control chapter 9 never ran

**[measured]**, recipe in M.1. Four composition runs, each making chapter 9's
edit to `pricing` and varying only `catalog`'s `type Query` block:

| catalog's root fields | root field named |
|---|---|
| all four, as committed | `Query.products` |
| `products` deleted | `Query.browseProducts` |
| `products` and `browseProducts` deleted | `Query.productById` |
| all four, `productBySku` moved to the top | `Query.productBySku` |

The message follows the declaration order, and moving a field changes which one
is named without changing anything else. So the practical rule is that fixing
the route the error names does not necessarily fix the error; it surfaces the
next one.

In all four runs the same two fields are reported unresolvable, `price` and
`shippingCost`, which are the two `pricing` contributes. Field-level errors
under the one named root field are **not** collapsed - only root fields are.
`generateRootResolvabilityErrors`
(`composer: composition/src/resolvability-graph/utils/utils.ts:312-348`) emits
one error per unresolvable path found under that single traversal.

Chapter 9 saw four fields where this run sees two, and that is decision 72
rather than a discrepancy: chapter 9's edit was made to the `mosaic` subgraph,
which does not exist at `ch12`, and the edit is made to `pricing` now.

### B.2 A second collapse in the same function, which never fires here

Lines 231-234 of the same file skip a root field whose named type another
unshared root field already reached:

```typescript
        if (!isSharedRootField) {
          const namedTypeNodeName = sharedRootFieldEdges[0]!.node.nodeName;
          if (this.resolvedRootFieldNodeNames.has(namedTypeNodeName)) {
            continue;
          }
          this.resolvedRootFieldNodeNames.add(namedTypeNodeName);
        }
```

This is a second, independent reason a later root field can go unreported, and
it is **not** what produces the measurement above. Two things stop it. The four
fields do not share a tail node: `products` and the two by-argument lookups
return `Product`, but `browseProducts` returns `ProductConnection`, and the tail
node is the field's *named type*. And the early return fires first in every one
of the four runs, so execution never reaches a second field returning `Product`.
Worth recording because the name reads like the explanation and is not it.

## C. The composer prints some errors more than once

Chapter 9 recorded this with no pattern established: twice for one case, three
times for another, identically each time.

**[measured]**, recipe in M.2. Re-counted at the current six schemas by making
each of `composition-cases.mjs`'s edits and counting how often each distinct
error sentence appears:

| case | distinct sentences | total lines | repeated |
|---|---|---|---|
| `unsatisfiable-key` | 7 | 10 | three sentences, each twice |
| `duplicate-field` | 2 | 2 | nothing |
| `incompatible-type` | 5 | 10 | **every** sentence, twice |
| `missing-key` | 2 | 2 | nothing |
| `enum-drift` | 0 | 0 | nothing |
| `key-mismatch` | 3 | 3 | nothing |

The `unsatisfiable-key` row was first recorded here as 9 distinct sentences over
10 lines, from a throwaway probe whose line filter did not strip the `- ` that
begins each bullet under `This is because:`. The committed case strips it and
counts 7, with three sentences appearing twice: the one naming the root field,
the one about the entity ancestor, and the one about descendants. Two errors,
nine lines of explanation between them, three shared sentences. The chapter
prints the committed numbers.

So `incompatible-type` is the whole error printed twice, not one line repeated
inside it, and `unsatisfiable-key` repeats exactly one line of a nine-line
message - the line naming the root field, once per unresolvable field under it.
That second one is explained by section B: two unresolvable fields under one
root field produce two errors, and each error renders the same root-field
sentence.

**[source]** `composer: composition/src/v1/federation/federation-factory.ts:278`
is `errors: Array<Error> = [];`, and every call site is a bare `.push()`; there
is no deduplication anywhere in the composer.
`composer: cli/src/commands/router/commands/compose.ts:240-277` calls
composition once and prints each array entry once, so the CLI is not doubling
anything.

What is **not** established is which two call sites construct the
`incompatible-type` error. The mechanism for the shape of the repeat is known
(no dedup, one error per path), the specific call pair is not. Recorded as open
in section O rather than guessed at.

## D. What normalization does, in order

The plan cache key is a hash of the normalized document, so what normalization
does is what the key means.

**[source]** `router: router/core/graphql_prehandler.go:847,873,879,935`. Four
steps in this order, and validation sits **between** the two normalizations:

1. `NormalizeOperation`
2. `ValidateOperation`
3. `NormalizeVariables`
4. `RemapVariables`

**[source]** `router: router/core/operation_processor.go:1601-1631`. The static
normalizer is built with four options and, notably, without variable
extraction:

```go
func buildNormalizationOptions(enableDefer bool, validateInlineArguments config.ValidateInlineArguments) []astnormalization.Option {
	opts := []astnormalization.Option{
		astnormalization.WithRemoveNotMatchingOperationDefinitions(),
		astnormalization.WithInlineFragmentSpreads(),
		astnormalization.WithRemoveFragmentDefinitions(),
		astnormalization.WithRemoveUnusedVariables(),
	}
```

Step 1's live stages, in order
(`gqltools: v2/pkg/astnormalization/astnormalization.go:229-376`): drop every
operation definition but the requested one; statically evaluate a literal
`@skip`/`@include` and delete the selection (a variable-driven one survives);
inline named-fragment spreads **in place, at the spread's position**; remove
self-aliasing (`foo: foo` only); splice inline fragments into their parent;
merge sibling inline fragments; drop the now-unused fragment definitions;
deduplicate identical fields, keeping the position of the first occurrence.

Nothing in that list reorders fields.

### D.1 Where literals become variables

Not in step 1. **[source]**
`gqltools: v2/pkg/astnormalization/variables_extraction.go:39-144`, reached
through `NewVariablesNormalizer()` at step 3. Every non-variable argument value
is serialized to JSON, written into `operation.Input.Variables` under a
generated name, and the argument rewritten to point at that variable. The name
comes from
`gqltools: v2/pkg/ast/ast_operation_definition.go:134-155`:

```go
const (
	alphabet = `abcdefghijklmnopqrstuvwxyz`
)

func (d *Document) GenerateUnusedVariableDefinitionName(operationDefinition int) []byte {
	var i, k int64

	for i = 1; i < math.MaxInt64; i++ {
		out := make([]byte, i)
		for j := range alphabet {
			for k = 0; k < i; k++ {
				out[k] = alphabet[j]
			}
			_, exists := d.VariableDefinitionByNameAndOperation(operationDefinition, out)
			if !exists {
				return out
			}
		}
	}

	return nil
}
```

so `a`, `b`, ... `z`, `aa`, `bb`. This is the mechanism behind chapter 10's
finding that `first: 3` and `first: 7` produce identical plans: the literal
leaves the document text entirely and travels in a JSON side channel.

Step 4 then renames the *declared* variables by the same scheme
(`gqltools: v2/pkg/astnormalization/variables_mapping.go:158-192`), positionally
by first use.

### D.2 The name is blanked, and only for the hash

**[source]** `router: router/core/operation_processor.go:1118-1141`:

```go
	// Print the operation without the operation name to get the pure normalized form
	// Afterward we can calculate the operation ID that is used as a stable identifier for analytics

	o.kit.normalizedOperation.Reset()
	// store the original name of the operation
	nameRef := o.kit.doc.OperationDefinitions[o.operationDefinitionRef].Name

	staticNameRef := o.kit.doc.Input.AppendInputBytes([]byte(""))
	o.kit.doc.OperationDefinitions[o.operationDefinitionRef].Name = staticNameRef

	err = o.kit.printer.Print(o.kit.doc, o.kit.normalizedOperation)
```

The name is restored immediately afterwards and the document is printed a second
time into `NormalizedRepresentation`, which is what other caches key on. So the
operation name is in the normalized representation and not in the plan cache
key.

## E. What the plan cache keys on

The question chapters 7, 10, 11 and 13 each left for this one.

**[source]** `router: router/core/graph_server.go:691` - the cache is
`*ristretto.Cache[uint64, *planWithMetaData]`. **[source]**
`router: router/core/operation_planner.go:168` - `operationID := opContext.internalHash`,
and `router: router/core/graphql_prehandler.go:955` sets that from
`parsedOperation.InternalID`, which is section D.2's hash.

Planning is single-flighted on the same id
(`router: router/core/operation_planner.go:188`), which is the router's version
of the coalescing chapter 16 found in HotChocolate's operation cache.

### E.1 Measured, on the real graph

**[measured]**, recipe in M.3. The router exposes
`request.operation.queryPlanHash` to access-log expressions and that string is
the cache key, so one request per document and the log says which documents
share a plan. Nineteen documents, each sent twice.

Same plan as the baseline `{ browseProducts(first: 3) { nodes { title } } }`:

| variation | shares the plan |
|---|---|
| `query A` versus `query B` versus anonymous | yes |
| `$n` versus `$count` | yes |
| `first: 3` versus `first: 7` inline | yes |
| inline literal versus declared `$f: Int` | yes |
| `$f = 3` versus `$f = 9` at request time | yes |
| whitespace and a leading comment | yes |
| named fragment versus the same selection inlined | yes |
| **`x: browseProducts` versus `y: browseProducts`** | **no** |
| **`{ title sku }` versus `{ sku title }`** | **no** |
| **`$f: Int` versus `$f: Int!`** | **no** |
| `node(id:)` with two different ids | yes |

Eleven of the nineteen documents share one key. The two that surprised me are
the alias and the field order: renaming a field in your own response costs a
second plan, and asking for a different slice of the catalogue costs nothing.

### E.2 The control

Decision 100's rule, applied. One shared plan has to still answer two
questions, or the sharing is a defect rather than a feature. **[measured]**,
same recipe:

```
  first: 3 -> 3 nodes
  first: 7 -> 7 nodes
  $f = 3 -> 3 nodes
  $f = 9 -> 9 nodes
```

### E.3 Chapter 10 is extended, not corrected

Chapter 10 found that a properly declared variable produces a **different plan
document** from the inlined form, and was careful to say that this "shows the
two plan *documents* differ, not that a plan cache keyed on them holds two
entries", handing the cache question here.

Both halves stand, and the reason they look contradictory is the declared type.
**[measured]**, the normalized query the router prints for five forms:

```
inline-3       query($a: Int){browseProducts(first: $a){nodes {title}}}
declared-null  query($a: Int){browseProducts(first: $a){nodes {title}}}
declared-nonnl query($a: Int!){browseProducts(first: $a){nodes {title}}}
named+nonnull  query Storefront($a: Int!){browseProducts(first: $a){nodes {title}}}
named+null     query Storefront($a: Int){browseProducts(first: $a){nodes {title}}}
```

Chapter 10's declared form was `$first: Int!`; the lift synthesises `Int`. Their
plan hashes:

| form | plan hash |
|---|---|
| `inline-3` | 17972416575696450974 |
| `declared-null` | 17972416575696450974 |
| `declared-nonnl` | 16573561200335999562 |
| `named+nonnull` | 16573561200335999562 |
| `named+null` | 17972416575696450974 |

The three pairs the chapter prints for the splits, from the same run, recorded
here because the chapter prints them and a number in the prose needs a record
even when the number is not the claim:

| pair | left | right |
|---|---|---|
| alias | 12452750417983769066 | 2728077130562092255 |
| field order | 15843417663884115703 | 1777378001281248594 |
| nullability | 17972416575696450974 | 16573561200335999562 |

All of these are properties of this composed config. Recompose against a changed
router schema and every one of them moves; what the gate asserts, and what the
chapter claims, is which of them match.

So the `!` splits the key and the operation name does not, even though the name
is in the printed plan document. Two documents can share a cache entry and have
different plan documents, and the one stored is whichever was planned first.

## F. Asking to see the plan guarantees it was made

**[source]** `router: router/core/operation_planner.go:141-166`:

```go
func (p *OperationPlanner) plan(opContext *operationContext, options PlanOptions) (err error) {
	// if we have tracing enabled or want to include a query plan in the response we always prepare a new plan
	// this is because in case of tracing, we're writing trace data to the plan
	// in case of including the query plan, we don't want to cache this additional overhead

	skipCache := options.TraceOptions.Enable || options.ExecutionOptions.IncludeQueryPlanInResponse
```

The `skipCache` branch returns before `planCache.Get`, before `planCache.Set`
and before the singleflight group, so such a request neither reads nor writes
the cache.

The two headers are `X-WG-Trace` (`router: router/core/request_tracing.go:11`)
and `X-WG-Include-Query-Plan`
(`router: router/core/graphql_prehandler.go:1407-1411`), both gated on dev mode
or a signed request.

**[measured]**, recipe in M.4. One document, eight requests, plan hash identical
throughout:

```
untraced-1   planHit=false
untraced-2   planHit=true
untraced-3   planHit=true
traced-1     planHit=false
traced-2     planHit=false
planonly     planHit=false
untraced-4   planHit=true
untraced-5   planHit=true
```

Two traced requests both miss, on a document the router had already planned
twice, and the untraced requests afterwards still hit - so a traced request does
not poison the cache either, it simply is not part of it.

The consequence worth printing: `planner_stats` in a trace is always the cold
number. Two consecutive traced requests for the same document reported
832,666 ns and 1,083,310 ns of planning. There is no way to see the warm cost
from inside a response.

**[source]** the reason it has to work this way is in
`gqltools: v2/pkg/engine/resolve/loader.go:1661-1669` and the fetch-tree trace
walk: trace data is written onto fields of the plan object itself, so a traced
request sharing a cached plan with concurrent requests would race on it.

## G. Planning: from a document to a fetch tree

**[source]** `gqltools: v2/pkg/engine/plan/planner.go:92-230`. Select the
operation, then `NodeSelectionBuilder.SelectNodes`, then
`PathBuilder.CreatePlanningPaths`, then a per-datasource visitor walk that
builds the raw plan. Post-processing is **not** inside `Plan()`; the router runs
it itself at `router: router/core/operation_planner.go:100-103`.

### G.1 How a subgraph is chosen when more than one could serve a field

**[source]** `gqltools: v2/pkg/engine/plan/datasource_filter_visitor.go:814-842`:

```go
		nodesInfos = append(nodesInfos, nodeInfo{
			nodeIdx:            i,
			jumpCount:          jumpCount,
			hasSelectedSibling: hasSelectedSibling,
			selectableChilds:   countOfSelectableChilds,
		})
	}

	// sort by the number of jumps, selectable child count, selected siblings
	slices.SortFunc(nodesInfos, func(a, b nodeInfo) int {
		if usePriority {
			// desc on count
			if n := cmp.Compare(b.selectableChilds, a.selectableChilds); n != 0 {
				return n
			}

			if a.hasSelectedSibling != b.hasSelectedSibling {
				if a.hasSelectedSibling {
					return -1 // a comes first
				}
				if b.hasSelectedSibling {
					return 1 // b comes first
				}
			}
		}

		// acs order from 0 to n
		return cmp.Compare(a.jumpCount, b.jumpCount)
	})
```

Three keys, in order: how much of the remaining subtree this datasource can
serve (more is better), whether a sibling on the same source was already
selected (prefer it, which is what keeps one fetch from splitting into two), and
how many `@key` jumps it takes to get there (fewer is better). There is no cost
model and no search: the candidates are sorted and the first is taken.

`@provides` enters at node collection
(`gqltools: v2/pkg/engine/plan/datasource_filter_collect_nodes_visitor.go:358-410`);
`@requires` and `@key` both expand through `addRequiredFields` in
`gqltools: v2/pkg/engine/plan/required_fields_visitor.go`.

### G.2 What post-processing adds

**[source]** `gqltools: v2/pkg/engine/postprocess/postprocess.go`. Fetch
deduplication, fetch-id assignment, input-template resolution, conversion of a
generic fetch into a concrete `EntityFetch` or `BatchEntityFetch`, and the
dependency ordering that decides what runs in parallel. It is a separate pass
because the per-datasource walk cannot see the whole flat fetch list while it is
still building it.

## H. Entity fetch batching, and the deduplication nobody has seen yet

**[measured]**, recipe in M.5. The storefront query's fetch tree, from a trace:

```
Sequence
  Single      catalog    path=''
  Parallel
    BatchEntity pricing    path='browseProducts.nodes'   reps=3
    BatchEntity inventory  path='browseProducts.nodes'   reps=3
    BatchEntity reviews    path='browseProducts.nodes'   reps=3
  BatchEntity accounts   path='browseProducts.nodes.@.reviews.nodes.@.author'  reps=5
```

Three subgraphs contribute to `Product` and their three entity fetches are one
`Parallel` node. The fourth is a level deeper, and its path carries `@` where a
list is traversed.

Five representations, and there were **six** review authors: three products,
`reviews(first: 2)` each, and one customer had written two of the six reviews.

### H.1 The router deduplicates representations before the request goes out

**[measured]**, control in M.5. `nodes(ids: [X, X, Y])`, the same identifier
twice on purpose:

```
  BatchEntity catalog  path='nodes'  reps= 2
  BatchEntity pricing  path='nodes'  reps= 2
```

and the client still gets three items, the first two identical.

**[source]** `gqltools: v2/pkg/engine/resolve/loader.go:1718-1742`:

```go
			res.tools.keyGen.Reset()
			_, _ = res.tools.keyGen.Write(itemInput.Bytes())
			itemHash := res.tools.keyGen.Sum64()
			if existingIndex, ok := res.tools.batchHashToIndex[itemHash]; ok {
				batchStats[existingIndex] = arena.SliceAppend(res.tools.a, batchStats[existingIndex], items[i])
				continue WithNextItem
			} else {
```

The rendered representation is hashed; a repeat is appended to the bucket of the
one already queued and is never written into the outgoing buffer.
`batchStats` is the map back, and `loader.go:748-753` merges each answer onto
every item in its bucket.

This is a different layer from the deduplication chapter 11 measured. That one
was GreenDonut inside the subgraph, collapsing four resolver calls to one key
lookup. This one is the router, deciding what to put on the wire at all. Both
are live at once, and the router's runs first.

### H.2 No batch size limit

**[source]** searched `gqltools: v2/pkg/engine/resolve/loader.go` for a cap on
the number of representations in one `_entities` call and found none: the loop
at `loader.go:1697` runs over every matching item unconditionally. The
`BatchSize` settings elsewhere in the router are an OTEL exporter's and the
client-side HTTP request batching feature's, and neither is this.

Confidence: high on the loop, medium that nothing upstream bounds the item list,
because I did not read every path that produces `items`. Section O keeps it.

### H.3 Parallelism

**[source]** `gqltools: v2/pkg/engine/postprocess/create_parallel_nodes.go:9-41`
decides grouping from the fetch dependency graph, and
`gqltools: v2/pkg/engine/resolve/loader.go:291-306` runs a group with an
`errgroup.Group`. So "parallel" in a printed query plan is a real
`errgroup`, not a label.

## I. Apollo's planner, for contrast

The TOC line asks for this and it is worth having, because the two planners
answer the same question in opposite styles.

**[source]** `apollo: query-planner-js/src/generateAllPlans.ts:13-41`, the
function's own comment:

```
 * Given some initial partial plan and a list of options for the remaining parts that need to be added to that plan to make it complete,
 * this method "efficiently" generates (or at least evaluate) all the possible complete plans and the returns the "best" one (the one
 * with the lowest cost).
```

**[source]** `apollo: query-planner-js/src/buildPlan.ts:129,139`:

```typescript
const fetchCost = 1000;
```

```typescript
const pipeliningCost = 100;
```

with `onFetchGroup: (group: FetchGroup) => (fetchCost + group.cost())` at
`buildPlan.ts:171`. A fetch is priced at a thousand fields, and fetches in
sequence are multiplied by a hundred relative to fetches in parallel, so the
cost model says outright that a round trip dwarfs field resolution and that
sequencing is what really hurts.

**[source]** `apollo: query-planner-js/src/config.ts:141` -
`maxEvaluatedPlans: 10000`, a configurable ceiling on how many complete plans
the search will consider, with a validation error below 1 at `config.ts:152`.

So: Apollo enumerates candidate plans, prices each one with an explicit cost
function, prunes by branch and bound, and needs a ceiling because the space is a
cartesian product. Cosmo sorts the candidates for each node by three local keys
and takes the first, with no cost model, no enumeration and nothing to bound.
One is an optimiser that needs a safety valve; the other is a heuristic that
cannot run long.

That is a real trade and neither side of it is obviously right. It also explains
why the two projects put their caches in different places: a planner that can
evaluate ten thousand plans has much more to amortise than one that sorts a
short list per node.

### F.1 The second witness, found while drafting

**[source]** `router: router/core/graphql_handler.go:39-43` declares five response
headers, and `router/core/router.go:496-506` shows the old per-cache settings
being folded into one:

```go
	ExecutionPlanCacheHeader          = "X-WG-Execution-Plan-Cache"
	PersistedOperationCacheHeader     = "X-WG-Persisted-Operation-Cache"
	NormalizationCacheHeader          = "X-WG-Normalization-Cache"
	VariablesNormalizationCacheHeader = "X-WG-Variables-Normalization-Cache"
	VariablesRemappingCacheHeader     = "X-WG-Variables-Remapping-Cache"
```

They are written when `engine.debug.enable_cache_response_headers` is on, and
each is `HIT` or `MISS`.

**[measured]**, recipe in M.6. One document, six requests, through a mechanism
that shares no code with the access-log expressions of M.3:

```
cold      plan=MISS normalization=MISS
warm-1    plan=HIT  normalization=HIT
warm-2    plan=HIT  normalization=HIT
traced    plan=MISS normalization=HIT
planonly  plan=MISS normalization=HIT
warm-3    plan=HIT  normalization=HIT
```

This confirms section F independently and says one thing F could not. On the
traced request the **normalization cache still hits** while the plan cache
misses, so tracing bypasses exactly one cache rather than making the request
look new all the way down. A single `planHit=false` could not have separated
those two readings.

Both witnesses are now asserted in the same case, so a release that changes
either fails the gate.

## J. Seven caches, and metrics for none of them

**[source]** `router: router/core/graph_server.go:930-954` registers cache
metrics for seven caches by name: `plan`, `query_normalization`,
`variables_normalization`, `remap_variables`,
`persisted_query_normalization`, `validation`, `query_hash`.

**[source]** `router: router/pkg/config/config.schema.json`,
`telemetry.metrics.prometheus.graphql_cache`, default **false**. So a stock
router publishes nothing about any of the seven, which is why no earlier chapter
could see the plan cache even though chapter 10 saw the Prometheus endpoint in
the startup log.

Chapter 3 gave HotChocolate two caches, document and operation. The router in
front of it has seven, and they are at different granularities: the
`normalizationCacheHit` flag goes false on a document the plan cache is already
serving (visible throughout M.3's log), because the normalization cache keys on
something narrower than the plan cache does.

## K. The inherited composer questions

### K.1 `@interfaceObject` where the declaring subgraph has no key

**[source]** `composer: composition/src/v1/federation/federation-factory.ts:1790-1794`:

```typescript
        const keys = interfaceObjectConfiguration.keys;
        if (!keys) {
          // TODO no keys error
          continue;
        }
```

The `continue` skips roughly a hundred lines that would otherwise register the
interface-object's graph edges and copy its field data onto each concrete
implementing type. Composition reports success, no warning, and that subgraph's
contribution is **absent** rather than present-but-unroutable. The comment is
the composer's own admission that an error belongs there.

Not run against a router, because there is nothing to route: the fields are not
in the schema. Chapter 13 asked what a router does with such a graph and the
answer is that the graph it would be handed does not contain the thing.

Caveat, honestly held: this branch is about the `@interfaceObject`-declaring
subgraph having no key on its own type. Whether an interface with no `@key` in
*any* subgraph even reaches entity-interface handling is not established, and is
in section O.

### K.2 Two subgraphs both contributing to the same interface

**[source]** `composer: composition/src/v1/federation/federation-factory.ts:1774-1798`
processes each `@interfaceObject` subgraph independently, and nodes are keyed
`${subgraphName}.${typeName}`, so each gets its own graph node.
`addTargetSubgraphByFieldSet`
(`composer: composition/src/resolvability-graph/graph-nodes.ts:117-122`) records
a *set* of subgraph names per key field set, so both become routes. Keys merge
into the concrete type's configuration deduplicated by selection set
(`federation-factory.ts:1812-1837`), and field attribution happens the ordinary
way, through each `FieldData`'s own `subgraphNames`. No interface-object-specific
structure carries it.

Whether the router then batches their entity fetches is answered by section H
generically - two subgraphs contributing to one entity at one path is exactly the
`Parallel` group the storefront query already produces - and is not measured on
an `@interfaceObject` graph specifically. Section N.

### K.3 A union whose members are declared in different subgraphs

**[source]** `composer: composition/src/v1/federation/federation-factory.ts:1471-1483`:

```typescript
      case Kind.UNION_TYPE_DEFINITION:
        if (!areKindsEqual(targetData, incomingData)) {
          return;
        }
        addMapEntries({
          source: incomingData.memberByMemberTypeName,
          target: targetData.memberByMemberTypeName,
        });
```

`addMapEntries` (`composer: composition/src/utils/utils.ts:260-264`) is a plain
map copy. Unions are unioned unconditionally, with no cross-subgraph check of
any kind. This confirms chapter 13's synthetic probe and completes the ladder
that chapter set up: an enum is checked and the answer depends on where it is
used, a union is merged without checking, and a scalar is not looked at.

### K.4 `@override` on a key field

**[source]** `composer: composition/src/v1/normalization/normalization-factory.ts:2597-2608`
never inspects a key field set, which is why composition permits it - by
omission rather than by decision.

**[source]** `composer: composition/src/v1/normalization/batch-normalization/batch-normalizer.ts:186-194`:

```typescript
        const configurationData = internalSubgraph.configurationDataByTypeName.get(parentTypeName);
        if (!configurationData) {
          continue;
        }

        subtractSet(fieldNames, configurationData.fieldNames);
        if (configurationData.fieldNames.size < 1) {
          internalSubgraph.configurationDataByTypeName.delete(parentTypeName);
        }
```

The overridden name is subtracted from the owner's routable field list and
`configurationData.keys` is untouched, so the owner still declares a key whose
field it is no longer told to resolve. And if the subtraction empties the set,
the owner loses the type from its routing table entirely.

What a router does with that config is in section N: not run.

## L. Corrections owed, and subagent findings rejected

- **A subagent reported that a bare `X-WG-Trace: true` header gives the reduced
  trace capture**, citing `router: router/core/request_tracing.go:41-48`.
  Rejected. That block runs only when `len(values) == 0`, and `values` is set at
  line 35 from the header whenever the header is non-empty, so a bare `true`
  falls through to the switch at line 51, matches no case, and leaves every
  `Exclude` flag false. Confirmed against the machine: the trace captured in M.4
  carries `raw_input_data`, `input`, `output` and `planner_stats`. The block is
  reachable only when tracing is not enabled at all.
- **A subagent reported that all four of catalog's root fields have
  `catalog.Product` as their tail node.** Rejected; `browseProducts` returns
  `ProductConnection`. It does not change that agent's conclusion, and section
  B.2 records why the distinction matters.
- Nothing in this chapter corrects an earlier chapter. Section E.3 extends
  chapter 10 rather than correcting it, and that chapter's own hedge is the
  reason.

## M. Numbers this chapter may quote, and how to reproduce them

All five recipes need the stack up:

```
cd F:/repo/mosaic-graph
MOSAIC_JWT_SECRET=... docker compose up -d
```

### M.1 Which root field the satisfiability error names

Four composition runs, each applying chapter 9's `resolvable: false` edit to
`pricing` and one edit to `catalog`'s `type Query`. Committed as the
`satisfiability-routes` case; see section P.

Result table in section B.1. Deterministic across runs: composition is
deterministic (decision 56) and the ordering is SDL declaration order.

### M.2 How often the composer repeats an error

Run each existing composition case and count distinct error sentences against
total error lines. Committed as part of the same case script. Table in section
C.

### M.3 What the plan cache keys on

A router started with an access-log field carrying the plan hash:

```yaml
access_logs:
  enabled: true
  router:
    fields:
      - key: planHash
        value_from:
          expression: request.operation.queryPlanHash
      - key: planHit
        value_from:
          expression: request.operation.planCacheHit
```

then one request per document, each sent twice, and the log read back. Tables in
E.1 and E.3. The hashes themselves are stable for a given document and a given
composed config; a recomposition that changes the router schema would change
them, so the **classes** are the claim and the twenty-digit numbers are not.

### M.4 A traced request never hits the plan cache

Same router. Send one document three times untraced, twice with
`X-WG-Trace: true`, once with `X-WG-Include-Query-Plan` and
`X-WG-Skip-Loader`, then twice more untraced, and read `planHit` for the eight.
Output in section F.

The two planning durations quoted in F, 832,666 ns and 1,083,310 ns, are
single-machine numbers and the claim is that neither is a warm number, not that
either is the right number. Decision 62 keeps them out of a gate.

### M.5 Entity fetch batching and representation deduplication

```
curl -s -X POST http://localhost:3002/graphql \
  -H 'Content-Type: application/json' -H 'X-WG-Trace: true' \
  -d '{"query":"{ nodes(ids: [\"<id>\",\"<id>\",\"<other>\"]) { ... on Product { title price { amount } } } }"}'
```

and count `representations` in each fetch's traced input against the number of
items in `data`. Three ids in, two representations out, three items back. The
storefront tree in section H comes from the same header on the storefront query.

### M.6 The cache response headers

A router with `engine.debug.enable_cache_response_headers: true` and nothing
else, then the same document sent cold, twice warm, once with `X-WG-Trace`, once
with the query-plan headers, and once warm again, reading
`x-wg-execution-plan-cache` and `x-wg-normalization-cache` off each response.
Output in F.1. Gated inside `tracing-never-hits-the-plan-cache`.

### M.7 Cache sizes, from the config schema

`router: router/pkg/config/config.schema.json`, the `engine` block:
`execution_plan_cache_size` 1024, `normalization_cache_size` 1024,
`validation_cache_size` 1024, `operation_hash_cache_size` 2048,
`slow_plan_cache_size` 300, `slow_plan_cache_threshold` 100ms. The chapter's lab
quotes the first of these. Read from the schema rather than from documentation
prose, which is where the SPEC's rules say a default has to come from.

## N. Left unmeasured, deliberately

- **A router pointed at a config whose key field was overridden away from its
  owner.** Section K.4 has the composer's half. The router half needs a
  composed config with that edit and a query that crosses into the owner, and it
  is a planner question rather than a composer one. Chapter 24 or a later
  session; recorded in section O.
- **`@interfaceObject` entity-fetch batching specifically.** Section K.2
  establishes that two contributing subgraphs become two routes; whether their
  fetches group into one `Parallel` node was not run against
  `samples/interface-object`.
- **What planning costs warm.** Section F establishes that no trace can tell
  you. Measuring it needs the `measure-router.mjs` treatment rather than a gate,
  and chapter 24 owns timings.
- **The plan cache under eviction.** `ExecutionPlanCacheSize` and ristretto's
  admission policy were read and never pushed. A graph with more distinct
  documents than the cache holds is a chapter 24 subject.
- **`slowPlanCache`.** `router: router/core/operation_planner.go:175-181` has a
  second, fallback cache for expensive plans, and nothing here exercised it.
- **The other six caches.** Section J names them; only the plan cache and the
  normalization hit flag were watched.
- **Advanced Request Tracing's sub-options.** `?wg_trace=exclude_*` has nine
  values (`router: router/core/request_tracing.go:14-22`); none was used.
  Chapter 23 shares this.

## O. Still open at the time of writing

- **Which two call sites push the `incompatible-type` error.** Section C has
  the count and the absence of any deduplication; it does not have the pair.
  Settled by instrumenting the composer or by reading every `.push()` of that
  error's constructor, neither of which fits this chapter's budget.
- **Whether an interface with no `@key` in any subgraph reaches entity-interface
  handling at all.** Section K.1's caveat. Settled by composing two variants and
  diffing the client schema.
- **Whether anything upstream bounds the representation list.** Section H.2.
- **What a router does with an overridden key field.** Section N.

## P. What the companion tag adds

See the chapter's Progress row for the final list. The intent at the time of
writing:

- `scripts/planner-cases.mjs` - the plan-key equivalence classes as cases, the
  traced-request control, and the representation-deduplication count. All three
  are counts and classes rather than timings, which is decision 66's line.
- `scripts/satisfiability-routes.mjs` or a case added to
  `composition-cases.mjs` - the four-way root-field control from M.1 and the
  repeated-error counts from M.2.
- A `telemetry` block in `router/config.yaml` turning `graphql_cache` metrics
  on, because section J is a finding about a default and a router whose cache
  metrics are invisible is not one anybody should copy.

## Q. Bibliography keys

No new citations are expected. Every claim above is measured on this machine or
read out of one of the four pinned trees, and the two planners are read rather
than described. If the Apollo contrast in section I ends up quoting Apollo's
published documentation for what the specification requires, rather than for
what the implementation does, that would be one reused key.
