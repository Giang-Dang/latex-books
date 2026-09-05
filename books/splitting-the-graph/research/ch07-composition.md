# Chapter 7 - Composition

Research note for the chapter that runs a composer for the first time:
`wgc router compose`, what the router execution config contains, and
resolvability as a walk over the graph. It is the first chapter whose central
tool is not .NET, and the first whose opening failure is a disagreement
between two vendors rather than a mistake anybody made.

Web sources accessed **2026-08-23**; everything else was measured on this
machine on the same date.

Two things are worth stating before any of it.

**The composer is WunderGraph's own, not Apollo's.** `@wundergraph/composition`
declares no `@apollo/*` dependency of any kind, and it calls the check Apollo
calls satisfiability **resolvability** throughout. So no error text in this
chapter may be attributed to Apollo's specification: it is Cosmo's
implementation of that specification, wording included. Recorded in full below,
because the distinction decides how the chapter attributes every message it
prints.

**Nothing in this chapter talks to a running service.** Composition reads
schema files. That is why the chapter can compose a second subgraph that does
not exist, why `verify.ps1` runs its composition block after the Sessions
process has been stopped, and why chapter 8 rather than this one is where a
port matters.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| `wgc` (Cosmo CLI) | **0.129.9**, installed globally through npm |
| Node | 24.15.0 |
| Gate | `pwsh verify.ps1`, run on each of the four tags below. All PASS 2026-08-23 |

| Tag | Branch | What it is | Assertions |
|-----|--------|-----------|------------|
| `ch07` | `main` | the finished chapter: cost defaults off, `node` and `nodes` shareable, `graph/` composing | 195 |
| `ch07-costly` | `ch07-costly` | chapter 6's subgraph unchanged, plus `graph/`. Does not compose | 14 |
| `ch07-unshared` | `ch07-unshared` | the cost fix in, the shareable fix out. One subgraph composes; two do not | 12 |
| `ch07-typelevel` | `ch07-typelevel` | `[Shareable]` on the `Query` class instead of the interceptor, and what a second subgraph can then claim | 12 |
| `ch07-hc14` | `hc14` | both fixes on 14.3.1, the interceptor with four renamed types | 174 |

**No new package.** Chapter 7 adds a tool rather than a dependency:
`ModifyCostOptions` is in `HotChocolate.CostAnalysis`, which
`HotChocolate.AspNetCore` already brought in, and `TypeInterceptor` is in
`HotChocolate.Types`.

### The version was stale and is now re-pinned

The SPEC pinned `wgc` at 0.129.7 while drafting chapter 5 and told this chapter
to re-confirm it first. It had moved.

From the npm registry record at `https://registry.npmjs.org/wgc`, fetched
2026-08-23:

| Version | Published |
|---|---|
| 0.129.7 | 2026-07-31 |
| 0.129.8 | 2026-08-10 |
| 0.129.9 | 2026-08-11, and `dist-tags.latest` |

Reproduce with
`curl -s https://registry.npmjs.org/wgc | jq '.["dist-tags"].latest'`.
A registry record is an artifact rather than a claim about one, so it passes
the Sources bar unsigned on the same reasoning as SPEC decision 39.

Upgraded with `npm install -g wgc@latest` and every measurement below was
taken on 0.129.9. `verify.ps1` asserts the version rather than accepting
whatever is installed, because the chapter quotes the composer's error text
and another version may word it differently.

The chapter prints the install as `npm install -g wgc`, unpinned, and points
at appendix A for the version, under SPEC decision 35; added by the 2026-09-05
reading-flow pass, which found the tool used on the page before it had been
installed on one. Chapter 8's "chapter 7 added `wgc` through npm" is true
from that pass onward rather than before it.

### The router version, for chapter 8

Not npm. The Cosmo Router ships as a container image at
`ghcr.io/wundergraph/cosmo/router` and as a GitHub release. Latest release
`router@0.341.0`, published 2026-08-18, read from
`https://api.github.com/repos/wundergraph/cosmo/releases` on 2026-08-23; the
GHCR manifest for tag `0.341.0` answers 200, so the image exists at that exact
tag and not only the release note. Recorded here so that chapter 8 starts from
a number rather than from nothing. **Not verified by running it**, which is
chapter 8's job, so the SPEC's open item stays open.

## The failure the chapter opens on

### What happened

The Sessions subgraph exactly as chapter 6 left it, composed alone:

```
wgc router compose -i graph.yaml -o router.json
```

Exit 1, no config written. Seven rejections over one subgraph, none about
federation. The full block, with the box wgc draws around it stripped:

```
The subgraph "sessions" could not be federated for the following reasons:
The 1st instance of the directive "@cost" declared on coordinates "Query.node" is invalid for the following reason:
 The value ""10"" provided to argument "@cost(weight: ...)" is not a valid "Int!" type.
The 1st instance of the directive "@cost" declared on coordinates "Query.nodes" is invalid for the following reason:
 The value ""10"" provided to argument "@cost(weight: ...)" is not a valid "Int!" type.
The 1st instance of the directive "@listSize" declared on coordinates "Query.sessions" is invalid for the following
reason:
 The definition for "@listSize" does not define the following argument that is provided: "slicingArgumentDefaultValue…
The 1st instance of the directive "@cost" declared on coordinates "Query.sessions" is invalid for the following
reason:
 The value ""10"" provided to argument "@cost(weight: ...)" is not a valid "Int!" type.
The 1st instance of the directive "@cost" declared on coordinates "Query.sessionById" is invalid for the following
reason:
 The value ""10"" provided to argument "@cost(weight: ...)" is not a valid "Int!" type.
The 1st instance of the directive "@cost" declared on coordinates "Mutation.rescheduleSession" is invalid for the
following reason:
 The value ""10"" provided to argument "@cost(weight: ...)" is not a valid "Int!" type.
The 1st instance of the directive "@cost" declared on coordinates "Session.speaker" is invalid for the following
reason:
 The value ""10"" provided to argument "@cost(weight: ...)" is not a valid "Int!" type.
```

Asserted line for line on `ch07-costly`. Two details of the text are worth
naming because they look like transcription errors and are not. The doubled
quotes in `""10""` are wgc quoting a value that is itself a quoted string. The
trailing `…` on the `@listSize` line is wgc's own truncation: it draws a
fixed 120-column box and elides the argument name to fit, so the message as
printed does not contain the full word. That character is a real byte in the
output and the reason the capture cannot be ASCII.

**Counts.** Six `@cost(weight: "10")` uses in the exported schema and six
rejections, plus one `@listSize` argument, so seven rejections from six
directives. The seventh `@cost` occurrence a naive grep finds is the directive
*definition* line, which is not a use. Both numbers asserted on `ch07-costly`.

**Scope of the six**, because the first draft got this wrong and the audit
caught it. The schema declares far more than six fields; the six that carry a
weight are the ones with a resolver behind them: `Query.node`, `Query.nodes`,
`Query.sessions`, `Query.sessionById`, `Mutation.rescheduleSession` and
`Session.speaker`. So the claim is not that Hot Chocolate weights every field,
and no chapter says it does. Chapter 2's wording, "applies a cost weight to
fields", was already careful about this.

### Why

Neither directive is federation's. Both come from the cost-analysis work Hot
Chocolate applies with no configuration at all, which chapter 2 already noted
arriving unasked. The composer holds **its own definitions** of both and
ignores the ones the document declares alongside them:

| Directive | Hot Chocolate 16.6.1 emits | Cosmo 0.129.9 expects |
|---|---|---|
| `@cost` | `weight: String!`, value `"10"` | `weight: Int!` |
| `@listSize` | five arguments including `slicingArgumentDefaultValue` | a definition without that argument |

The subgraph document declares `directive @cost(weight: String!)` in full, and
the composer rejects the value anyway, which is what establishes that the
composer is not reading the document's definition. Measured rather than
reasoned: the definition is in the file, and the error is about the value.

**Not established:** which of the two is right about `@cost`. The chapter
therefore says that the two disagree and which way each goes, and does not say
that either is wrong. See "Checked and not established" below.

### The fix, and the three flags that were tried

`HotChocolate.CostAnalysis.CostOptions` carries nine properties, read out of the
shipped 16.6.1 assembly by reflection. Two look relevant and only one is:

| `ApplyCostDefaults` | `ApplySlicingArgumentDefaultValue` | `@cost` uses | `@listSize` uses | `slicingArgumentDefaultValue` | composes |
|---|---|---|---|---|---|
| true | true | 6 | 1 | present | no |
| true | false | 6 | 1 | absent | no |
| false | true | 0 | 0 | absent | **yes** |
| false | false | 0 | 0 | absent | **yes** |

So `ApplySlicingArgumentDefaultValue` narrows the `@listSize` directive and
does not remove it, which leaves the `@cost` rejections standing;
`ApplyCostDefaults = false` removes `@cost` and `@listSize` together, uses and
definitions both, and is the whole fix. The book ships one line:

```csharp
.ModifyCostOptions(options => options.ApplyCostDefaults = false)
```

Counts the chapter prints, all measured on the exported file:

| Thing | Value |
|---|---|
| `schema.graphql` at `ch06`, cost defaults on | 201 lines |
| `schema.graphql` at `ch07`, cost defaults off | 165 lines |
| `graph/speakers.graphql` | 24 lines |
| `src/Sessions/ShareNodeFields.cs` | 33 lines |
| `graph/router.json` for one subgraph | 17412 bytes |

Reproduce by editing the flags in `src/Sessions/Program.cs`, rebuilding,
re-exporting and composing; the line counts with `wc -l`, and the `ch06`
figure with `git show ch06:src/Sessions/schema.graphql | wc -l`. There is no export-side filter:
`dotnet run -- schema export --help` on 16.6.1 lists `--output`,
`--schema-name` and `--semantic-non-null`, and nothing that drops a directive.

### What that cost, and what was done about it

Turning the defaults off removes `@listSize` from `Query.sessions`, and that is
where chapter 3's two paging numbers were readable. `verify.ps1` asserted
`assumedSize: 10` and `slicingArgumentDefaultValue: 2` out of the exported
file, and both assertions stopped holding.

Both numbers are now asserted behaviourally instead, measured 2026-08-23:

| Request | Result |
|---|---|
| `{ sessions { nodes { title } } }` | 2 nodes, `hasNextPage` true |
| `{ sessions(first: 10) { nodes { title } } }` | 4 nodes |
| `{ sessions(first: 11) { nodes { title } } }` | error, `The maximum allowed items per page were exceeded.` |

So `DefaultPageSize = 2` and `MaxPageSize = 10` still govern, and the removed
directive was only ever the cost analyser's view of them. This is a firmer
claim than reading the directive text, because it is what a reader observes.
Recorded explicitly because the SPEC forbids loosening an assertion to make a
run pass, and this is the opposite: the assertion moved to firmer ground and
the commit message says so.

Chapter 3's prose is unaffected. It **elides** `@listSize` and `@cost` from the
SDL it prints and only mentions them in a sentence about what the exported file
carries; that sentence describes chapter 3's state, which is still what tag
`ch03` produces. Chapter 2 prints `@cost(weight: "10")` inside a full schema
listing, and that listing is of the chapter-2 state at tag `ch02`, which also
still holds. Checked by grep across all drafted chapters before making the
change.

## Paying the `Query.node` bill

The open item asked where the declaration goes: "an attribute on the type
class, or a schema-building call in `Program.cs`". Both were tried. The first
works and costs too much; the second does not work at all; the answer is a
third thing.

`node` and `nodes` are generated by `AddGlobalObjectIdentification()`. They are
declared in no class the book writes, so there is no method or property for
`[Shareable]` to sit on.

### Route 1: `[Shareable]` on the `Query` class - works, over-declares

Tagged `ch07-typelevel`, because the chapter quotes the exported line and
states the measurement below, and decisions 48 and 51 both apply.


`HotChocolate.ApolloFederation.Types.ShareableAttribute` is valid on Class,
Struct, Method and Property, read off the attribute by reflection. Putting it
on `[QueryType] public static class Query` compiles and exports:

```
type Query @shareable {
```

Which does clear the collision. Composed against the second document with
`node` and `nodes` carrying no field-level directive, and the `Query` block is
absent from the error entirely.

It also declares every other root field shareable, because that is what
`@shareable` on an OBJECT means. Measured what that permits, and the result is
stronger than "no complaint about that field": with `type Query @shareable` on
Sessions, `graph/speakers-greedy.graphql` declares `sessionById(id: Int!)` on
its own `Query`, and the whole composition **succeeds**. Exit 0, a router
execution config written, no warning of any kind. The composer's protection
against a second service claiming a field this one owns is switched off for the
whole type, and the composed client schema still offers `sessionById` exactly
once, so nothing downstream looks wrong either. That is the measurement the
chapter prints, and the reason the book does not ship this route. Asserted on
`ch07-typelevel`.

### Route 2: `ObjectTypeExtension` in `Program.cs` - does not work

`new ObjectTypeExtension(descriptor => ...)` naming `Query` and calling
`.Field("node").Shareable()` does not merge with the generated field. Two
failures, in order:

Without an explicit type on the extension field:

```
1. Unable to infer or resolve the type of field Query.node. Try to explicitly provide the type like the following: `descriptor.Field("field").Type<List<StringType>>()`. (HotChocolate.Types.ObjectType)
2. Unable to infer or resolve the type of field Query.nodes. ...
```

With the types supplied as syntax nodes (`NamedTypeNode("Node")` and
`NonNullTypeNode(ListTypeNode(NamedTypeNode("Node")))`):

```
1. The following fields `node, nodes` are declared multiple times on `Query`. (HotChocolate.Types.ObjectType)
```

So the extension adds fields beside the generated ones rather than configuring
them. Both messages are schema-build exceptions at startup, not compile errors:
the C# is fine and the service does not start.

**Neither message is quoted in the chapter.** No tagged state of the
verification repo produces either, because neither is a state the book ships,
so SPEC decision 53 applies: they are described in prose and recorded verbatim
here.

### Route 3: a `TypeInterceptor` - works, and reaches exactly the two

`ShareNodeFields`, shipped in full in the chapter and in the repo at
`src/Sessions/ShareNodeFields.cs`. It hooks `OnBeforeCompleteType`, matches the
`Query` object configuration by name, and adds a `shareable` directive node to
the two fields it recognises. Registered with
`.TryAddTypeInterceptor<ShareNodeFields>()`.

Exported result:

```
node("ID of the object." id: ID!): Node @shareable
nodes("The list of node IDs." ids: [ID!]!): [Node]! @shareable
```

Asserted on `ch07` five ways: each field by name, a count of exactly two
`@shareable` in the `Query` block, `sessions` and `sessionById` each checked to
be without one, and `type Query @shareable` checked to be absent. A count alone
would also pass if the interceptor had painted the whole type, which is the
outcome the chapter rejects.

### That both sides must declare it, and what the error looks like each way

Chapter 5's note recorded the symmetric form of the message. Chapter 7 met
both forms in one error block, on `ch07-unshared`, where `speakers.graphql`
declares the directive and Sessions does not:

```
The Object "Query" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "node" is defined and declared "@shareable" in the following subgraph: "speakers".
 However, it is not declared "@shareable" in the following subgraph: "sessions".
 The field "nodes" is defined and declared "@shareable" in the following subgraph: "speakers".
 However, it is not declared "@shareable" in the following subgraph: "sessions".
The Object "Speaker" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "name" is defined in the following subgraphs: "sessions", "speakers".
 However, it is not declared "@shareable" in any of them.
 The field "bio" is defined in the following subgraphs: "sessions", "speakers".
 However, it is not declared "@shareable" in any of them.
```

The asymmetric form names the subgraph that is missing the directive. The
symmetric form says neither has it. Both asserted on `ch07-unshared`, and the
whole block is asserted in order, because the chapter reads the two objects
against each other: `node` is shared on purpose and Sessions has to catch up,
`Speaker.name` is shared by accident and one side has to give it up.

### After the fix, exactly one error is left

On `ch07`, composing `graph-with-speakers.yaml`:

```
The Object "Speaker" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "name" is defined in the following subgraphs: "sessions", "speakers".
 However, it is not declared "@shareable" in any of them.
 The field "bio" is defined in the following subgraphs: "sessions", "speakers".
 However, it is not declared "@shareable" in any of them.
```

Asserted as the whole block, plus three assertions that `Query` is absent from
the error at all, plus a count that exactly one object is reported. That last
one is what makes the chapter's closing claim checkable.

## What a router execution config contains

### The term is WunderGraph's own

On success wgc prints:

```
Router execution config successfully written to "...".
```

and its own documentation for the command, at
`https://cosmo-docs.wundergraph.com/cli/router/compose` fetched 2026-08-23,
describes it as: "Compose generates the router execution config locally from
your subgraphs. The config can be used to start your router with a pre-built
router config." The word **supergraph does not appear on that page at all**,
checked by grepping the fetched HTML. So "router execution config" and "router
config" are the vendor's two names for one artifact and "supergraph" is
Apollo's word, which matters because chapter 5 used Apollo's.

The same page documents `-i, --input`, `-o, --out`, `--suppress-warnings`,
`--disable-resolvability-validation`, `--ignore-external-keys` and
`--split-configs-enabled`, and recommends against this command for production
in favour of `router fetch` against the Cosmo platform.

The CLI's own help, captured from `wgc router compose --help` on 0.129.9 on
this machine, words the resolvability flag more strongly than the docs page
does, and this is the sentence the chapter refers to:

```
--disable-resolvability-validation  This flag will disable the validation for
                                    whether all nodes of the federated graph
                                    are resolvable. Do NOT use unless
                                    troubleshooting.
```

### The format has no user documentation, only a protobuf

No page on the Cosmo documentation site defines the JSON structure of the
generated file. What defines it is a Protocol Buffers message, `RouterConfig`,
at `proto/wg/cosmo/node/v1/node.proto` in `wundergraph/cosmo`, fetched from
`raw.githubusercontent.com` on 2026-08-23:

```protobuf
message RouterConfig {
  EngineConfiguration engine_config = 1;
  string version = 2;
  repeated Subgraph subgraphs = 3;
  optional FeatureFlagRouterExecutionConfigs feature_flag_configs = 4;
  string compatibility_version = 5;
}
```

The generated file's five top-level keys match that message exactly:
`engineConfig`, `version`, `subgraphs`, `featureFlagConfigs`,
`compatibilityVersion`. Asserted on `ch07`. The absence of documentation is
itself the fact the chapter uses, so it is recorded as a finding rather than
as a gap in the search.

### What was read out of a real one

17412 bytes for one subgraph. Everything below asserted on `ch07`.

| Key | Value, for this graph |
|---|---|
| `compatibilityVersion` | `1:0.63.3` |
| `version` | `00000000-0000-0000-0000-000000000000` |
| `subgraphs` | one entry: `id` `0`, `name` `sessions`, `routingUrl` `http://localhost:5001/graphql` |
| `engineConfig` keys | `defaultFlushInterval`, `datasourceConfigurations`, `fieldConfigurations`, `graphqlSchema`, `stringStorage` |

`compatibilityVersion` is worth its own line. `0.63.3` is the version of
`@wundergraph/composition`, read independently out of that package's
`package.json` on `main` at
`https://raw.githubusercontent.com/wundergraph/cosmo/main/composition/package.json`.
So the artifact records which composer produced it, and it is the only place a
reader handed a config can find that out. **Caveat recorded:** the package.json
read was of the `main` branch rather than of the exact tarball inside
`wgc@0.129.9`, so the corroboration is strong rather than airtight; the string
in the config is measured either way.

The nil UUID is what a graph with no control plane gets. Not verified against
documentation, only observed, and the chapter says only that it is nil here.

**`engineConfig.graphqlSchema` is the client-facing schema**, 144 lines. Checked
that it carries none of `@key`, `@shareable`, `@link`, `_entities`, `_service`,
`_Any`, `_Entity`, `@cost`, `@listSize`, and that it still carries `node`. This
is chapter 5's promise about the composed document, now measured rather than
asserted.

**One leftover.** The line `scalar FieldSet` survives into the client schema,
and `FieldSet` appears exactly once in the whole document, so nothing
references it. It is the scalar `@key`'s argument was typed with, and it
outlives the directive that needed it. Asserted as a whole line, plus a count
that the single occurrence is the declaration itself.

**The subgraph's own document is in there too**, at
`engineConfig.datasourceConfigurations[0].customGraphql.federation.serviceSdl`,
carrying `@key(fields: "id")`, `@shareable`, `_entities` and `@link`. So the
config holds both views: what the client reads and what the router needs. Note
for anyone comparing bytes: that string carries CRLF, because the export wrote
it on Windows.

**The datasource entry** is `kind: GRAPHQL` with `rootNodes`, `childNodes`,
`keys`, `customGraphql` and `requestTimeoutSeconds`. `rootNodes` lists `Query`,
`Mutation`, `Session` and `Speaker` with the fields this datasource can answer;
`childNodes` lists the eight types reachable only as children. `keys` is the
`@key` directives compiled into a lookup table:

```json
[{"typeName":"Session","selectionSet":"id"},{"typeName":"Speaker","selectionSet":"id"}]
```

On `hc14` that table has one row, `Speaker`, because decision 71 left `Session`
unfederated there. Same composer, same inputs otherwise. `verify.ps1` branches
the expected table on the pinned major like every other 14/16 difference.

`subscription` is enabled in the datasource with protocol
`GRAPHQL_SUBSCRIPTION_PROTOCOL_WS` although `graph.yaml` says nothing about
subscriptions and the service has none. Observed, not investigated, and no
chapter claims anything about it.

## Resolvability, which is Cosmo's word for satisfiability

### Whose concept, and whose word

Apollo's documentation does not define satisfiability. The composition page at
`https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/composition`
does not contain the word, nor does the subgraph specification, both checked by
grepping the fetched HTML on 2026-08-23. The only normative-ish use found is the
`SATISFIABILITY_ERROR` entry at
`https://www.apollographql.com/docs/federation/errors`: "Subgraphs can be
merged, but the resulting supergraph API would have queries that cannot be
satisfied by those subgraphs."

Apollo's *implementation* describes it as a walk. `composition-js/src/validate.ts`
in `apollographql/federation`, fetched 2026-08-23, carries a
`class ValidationTraversal` with `private readonly stack: ValidationState[]`
and a `previousVisits` record "for each vertex in the supergraph", under a
docstring: "Validates that all the queries expressible on the API schema
resulting of the composition of the provided subgraphs can be executed on those
subgraphs."

The GraphQL Composite Schemas Specification has a normative section, "3.5
Validate Satisfiability", with an error code `UNSATISFIABLE_QUERY_PATH` and an
explicit stack algorithm, `CollectExecutablePaths`: "Let stack be the set of
one-element paths ... While stack is not empty: Remove one path from stack ...
Add extendedPath to stack." Fetched from
`https://graphql.github.io/composite-schemas-spec/draft` on 2026-08-23. **Stage
0, Preliminary**, per the repository's own README, so it is a working-group
draft and not a ratified specification, and chapter 5 already declines to build
on it.

**None of which is what this book's composer runs.** Cosmo's composition
package declares no Apollo dependency, and its own vocabulary is different:
the directory is `composition/src/resolvability-graph/`, the classes are
`Graph`, `EntityWalker` and `RootFieldWalker`, the error function is
`unresolvablePathError`, and grepping `entity-walker.ts` for "satisfiab"
returns nothing. The CLI flag is `--disable-resolvability-validation`.

So: the chapter may say that the check is a walk over a graph, because both
implementations and the draft specification all say so in their own way, and
because Cosmo's own class names say it most plainly. It may **not** attribute
Cosmo's error text or the word "resolvability" to Apollo, and it may not print
the phrase "satisfiability as a graph walk" as anyone's term of art. Under SPEC
decision 38 the framing is stated as my judgment; the mechanics are cited.

### The walk, made visible

**First shape, built in a scratch directory and not used.** Speakers owning
`name` and `bio` behind `@key(fields: "id", resolvable: false)` with no `node`
field produces a four-step walk through `Session.speaker` to `Speaker.name`. It
works and it needs a Sessions that stubs `Speaker`, which is chapter 9's state
and not this chapter's, so it was replaced. Recorded because the four-step form
is the more general one and chapter 15 may want it.

**What the chapter ships.** `graph/ratings-unreachable.graphql` is the Ratings
subgraph of chapter 5's map, cut down, contributing `averageScore` to a
`Session` it declares `resolvable: false` and exporting no `node` field of its
own. It needs no change to Sessions at all, which is why it works here:

```
The field "averageScore" is unresolvable at the following path:
 query {
  node {
   ... on Session {
    averageScore <--
   }
  }
 }
This is because:
 - The root type field "Query.node" is defined in the following subgraph: "sessions".
 - The field "Session.averageScore" is defined in the following subgraph: "ratings".
 - The entity ancestor "Session" in subgraph "sessions" has no accessible target entities (resolvable @key directives)
in the subgraphs where "Session.averageScore" is defined.
 - The type "Session" is not a descendant of any other entity ancestors that can provide a shared route to access
"averageScore".
```

The composer prints the path it walked, as a query, with an arrow at the step
it could not take. That is the artifact the chapter's figure is drawn from, and
it is asserted line for line on `ch07`, so decision 65 no longer applies to it:
the message is produced by a tagged state and the chapter quotes it the
ordinary way.

**The same probe on `hc14` never reaches the second pass**, and that turned out
to be worth more than a matching run. `Session` is not an entity there
(decision 71), so both documents declare `Session.id`, only `ratings` declares
the key that makes it shareable, and the merge fails first:

```
The Object "Session" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "id" is defined and declared "@shareable" in the following subgraph: "ratings".
 However, it is not declared "@shareable" in the following subgraph: "sessions".
```

So a subgraph whose entity did not take cannot be told it has a routing
problem: it fails earlier and the message points at shareability. Asserted on
`ch07-hc14`, branched on the pinned major like every other 14/16 difference.

**Resolvability is a separate phase from merging**, and the flag proves it from
both sides. On `main`, `--disable-resolvability-validation` composes the
unreachable-field input and writes a config. On `hc14` the same flag leaves the
same input failing, because there the failure is a merge failure. And on either
branch the flag changes nothing about the `graph-with-speakers.yaml`
shareability error. All three asserted, which is what turns the two-pass claim
from a reading of the flag's name into a measurement.

### Two inputs that compose although they look as though they should not

Recorded so they are not re-derived.

`@key(fields: "id", resolvable: false)` on Speakers while Speakers *also*
declares `Query.node` returning `Node`, with `Speaker implements Node`:
**composes**. The route exists after all, through the second subgraph's own
`node` field. This is why the unresolvable case above has to remove `Query`
from Speakers as well as make the key unresolvable, and it is a good
illustration of the walk finding a path a reader would not have thought of.

Sessions declaring `type Speaker { id: ID! }` with no `@key` at all, against a
Speakers that declares one: **fails, and blames the wrong thing.** Reproduced
on 0.129.9, matching what chapter 5's note recorded on 0.129.7:

```
The Object "Speaker" defines the same fields in multiple subgraphs without the "@shareable" directive:
 The field "id" is defined and declared "@shareable" in the following subgraph: "speakers".
 However, it is not declared "@shareable" in the following subgraph: "sessions".
```

The message is about shareability and the mistake is a missing key. It reveals
the composer's own view of `@key`: fields named in a key are treated as
shareable in the subgraph declaring it, so only the subgraph without one gets
named.

## Composing a document twice, which was tried and rejected

To produce the `Query.node` collision the chapter needs a second document that
declares `node`. The cheapest way is to compose the Sessions schema under two
names. Tried, and rejected for the book: it produces 73 lines of error naming
eight objects, because every field of every type collides. The error is
correct and teaches nothing.

The second document the chapter ships instead, `graph/speakers.graphql`, is
21 lines: a `@link` header, a `Query` with `node` and `nodes`, the `Node`
interface, `Speaker` with its three fields, and the `FieldSet` scalar. It
produces exactly two objects in the error, which are the two the chapter is
about.

It is a schema written by hand and no service exports it, and the chapter says
so plainly rather than letting a reader assume a Speakers service exists.
Composition reads files, so this is a legitimate thing to compose; it is not a
listing pretending to be a program.

## Chapter 5's note has a claim that does not hold

Chapter 5 recorded: "Adding `@shareable` to `Query.node` in both subgraphs,
**and** importing the directive in both `@link` lists, composes without error."

Both halves were done together, so the note establishes the conjunction and not
that either half is necessary. Tested the import half on its own, 2026-08-23:
`speakers.graphql` with `@shareable` written on `node` and `nodes` but removed
from its `@link` import list still clears the collision. So **wgc 0.129.9 does
not require the directive to be imported** to honour it.

No chapter claims the import is required. Whether the specification requires it
was not established and Cosmo's leniency is not evidence either way, so nothing
is said about conformance. The book's own documents import it, because that is
what Hot Chocolate emits and what the second document is written to match.

## Apollo's two pages still disagree

A third disagreement between Apollo pages, on top of the two chapter 5 found.
The directive-locations union for `@shareable` is written in opposite orders:

- `.../federated-schemas/reference/directives`: `directive @shareable repeatable on FIELD_DEFINITION | OBJECT`
- `.../federated-schemas/reference/subgraph-spec`: `directive @shareable repeatable on OBJECT | FIELD_DEFINITION`

Both raw-grepped from the fetched HTML on 2026-08-23. Semantically inert, since
order in a locations list means nothing, and recorded only because appendix C
will have to print one of them and the existing open item about `@tag` and
`@context` is the place that gets settled. Hot Chocolate emits the
subgraph-spec order, which is what the book's own exported schema shows.

On the substance, both pages agree and neither special-cases root fields:
`@shareable` "indicates that an object type's field is allowed to be resolved
by multiple subgraphs", and a field marked shareable in one subgraph "must be
marked as either @shareable or @external in every Federation 2 subgraph that
defines it". So `Query.node` is governed by the ordinary rule, which is what
this chapter assumes.

## HotChocolate 14

Everything in this chapter ports. Built and tagged at `ch07-hc14`.

| Thing | On 14.3.1 |
|---|---|
| The failure | identical. 14 emits the same `@cost(weight: "10")` and the same `@listSize` with `slicingArgumentDefaultValue`, so the subgraph does not compose |
| `ModifyCostOptions` | present, same name, same signature |
| `CostOptions.ApplyCostDefaults` | present, same name. Nine properties, the same nine as 16.6.1 |
| `ShareNodeFields` | compiles after four type renames |
| The result | `node` and `nodes` shareable, `type Query` not; one subgraph composes; two leave the `Speaker` error alone |
| The key table | one row, `Speaker`, where 16 has two. Decision 71's consequence, not this chapter's |

The four renames, read off the 14.3.1 assemblies by reflection:

| 16.6.1 | 14.3.1 |
|---|---|
| `TypeSystemConfiguration` | `DefinitionBase` |
| `ObjectTypeConfiguration` | `ObjectTypeDefinition` |
| `DirectiveConfiguration` | `DirectiveDefinition` |
| `HotChocolate.Types.Descriptors.Configurations` | `HotChocolate.Types.Descriptors.Definitions` |

`OnBeforeCompleteType` takes `DefinitionBase` on 14 where it takes
`TypeSystemConfiguration` on 16, and `DirectiveDefinition` has the same two
constructors `DirectiveConfiguration` has, including the `DirectiveNode` one
this class uses.

## Checked and found false

- **That `wgc` was still at 0.129.7.** Two patch releases above it. Re-pinned to
  0.129.9 and the SPEC's version baseline updated.
- **That importing `@shareable` in the `@link` list is required for the
  composer to honour it.** It is not, on 0.129.9. Chapter 5's note stated the
  conjunction it tested; the necessity does not follow and does not hold.
- **That `ApplySlicingArgumentDefaultValue = false` helps with composition.** It
  removes one argument from a directive the composer rejects for a different
  reason, and changes nothing about whether the graph composes. Redundant once
  `ApplyCostDefaults` is off, and the book does not set it.
- **That an `ObjectTypeExtension` can configure a generated root field.** It
  declares a second field of the same name and the schema fails to build.
- **That the export has a switch for dropping directives.** `schema export`
  takes three options and none of them do that.
- **That seven `@cost` directives are applied.** Six uses; the seventh match is
  the definition. Caught by an assertion, which is what the assertions are for.
- **That "supergraph" is the word for what `wgc router compose` writes.** It is
  Apollo's word. WunderGraph's own reference for the command never uses it.

## Checked and not established

- **Which of Hot Chocolate and Cosmo is right about `@cost(weight:)`.** Hot
  Chocolate emits `String!`, Cosmo expects `Int!`, and the cost-analysis
  specification that governs the directive was not read in this session. The
  chapter says the two disagree and which way each goes, and calls neither
  wrong. Unblocked by reading the specification's own definition of the
  directive, at which point the chapter can name the side that drifted and this
  becomes a sentence rather than a shrug.
- **Whether `@wundergraph/composition` inside `wgc@0.129.9` is exactly
  0.63.3.** The config stamps `1:0.63.3` and the `main`-branch `package.json`
  says `0.63.3`, which agree, but the published tarball's own lockfile was not
  read. The chapter prints the string out of the config, which is measured
  regardless.
- **Why the datasource entry enables websocket subscriptions** for a service
  that has none and a `graph.yaml` that does not mention them. Observed only.
- **What `version` in the config is when there is a control plane.** Nil here;
  no claim made about the other case.
- **Whether the four-step form of the walk is worth reproducing.** The shipped
  probe gives a three-step path. The scratch version through `Session.speaker`
  to `Speaker.name` gives four and shows the walk crossing two types, which may
  read better in chapter 15. It needs a Sessions that stubs `Speaker`, so it
  becomes available for free once chapter 9 has moved the rows.

## Reproducing the whole thing

```
cd F:/repo/splitting-the-graph-graph
pwsh verify.ps1                                 # main: 195 assertions
git checkout hc14          && pwsh verify.ps1   # 174
git checkout ch07-costly   && pwsh verify.ps1   # 14
git checkout ch07-unshared && pwsh verify.ps1   # 12
```

## Two PowerShell traps that cost real time

Neither is about federation and both would cost the same time again.

`wgc` installs three ways over: a shell script, a `.cmd` shim and a `.ps1`
wrapper. Name resolution picks the `.ps1`, and capturing the streams of a
PowerShell script that spawns node kills the host with `0xC0000409`,
`STATUS_STACK_BUFFER_OVERRUN`, rather than returning output. The fix is to ask
`Get-Command` for the `Application` forms and take the first, which is the
`.cmd` on Windows and the shell script elsewhere.

`$Input` is an automatic variable holding the pipeline enumerator, so a
function parameter of that name binds to nothing and the command is silently
handed an empty argument. And a variable assigned from an `if` expression whose
branch evaluates to `@()` lands as `$null`, because an empty array emits no
output, so `$extra = if (...) { @($Flag) } else { @() }` passed no flag at all
and the run reported the wrong thing rather than failing. Both were caught by
an assertion disagreeing with a shell run of the same command, which is the
argument for asserting the exit code rather than only the message text.

## Why unsigned vendor pages are cited here

Three of the chapter's sources carry no byline, and SPEC decision 39 is the row
that admits them. Each is the artifact rather than a claim about one:
WunderGraph's command-line reference defines WunderGraph's own command,
`node.proto` is the source of record for a format with no other definition, and
Apollo's error reference is the normative list of what Apollo's own composer
reports. All three can be checked against something running, which is what a
byline would otherwise stand in for, and the chapter's own run does check the
first two. Nothing here is a vendor arguing a result. The benchmark post the
chapter 5 note recorded, which compares Cosmo with competitors, is still not
used and this chapter adds no reason to change that.

`wgc` must be on PATH at 0.129.9, and the script asserts that before it
composes anything.
