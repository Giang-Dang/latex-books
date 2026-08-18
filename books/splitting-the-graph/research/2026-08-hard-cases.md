# The hard cases this book owns

Established 2026-08-19 during the requirements interview. SPEC decision 24
names this file. Every entry here is a problem developers report hitting when
they implement federated GraphQL, with the source that reports it and the
chapter that owns it.

This note is the origin of Part III's chapter list. It is not a chapter note:
each chapter gets its own note under `research/`, and that note re-verifies the
claim before the chapter prints it. Nothing below has been reproduced in code
yet, and nothing below may be printed as fact until it has.

## The twelve

| # | Case | Chapter | Source |
|---|------|---------|--------|
| 1 | N+1 at the reference resolver. The router sends `_entities` a batch of representations; a naive reference resolver issues one lookup per representation | 10 | Apollo, *Handling the N+1 Problem*; Hot Chocolate v16 Apollo Federation docs |
| 2 | Entity representation order. `_entities` must answer in the order it was asked. Out of order, fields merge onto the wrong entities and the data is silently wrong | 11 | Apollo, *Aggregating Data Across Subgraphs* |
| 3 | `_entities` bypasses authorization. A guard on the root field does not guard the same object reached through the entity route | 12 | ChilliCream `graphql-platform` issue 6546 |
| 4 | Filtering, sorting and paginating across a seam. No directive fixes it; the accepted answer is a dedicated search domain with its own index | 13 | apollographql/federation issue 2668; Apollo, *Aggregating Data Across Subgraphs* |
| 5 | Non-null blast radius. An error in a non-null field propagates to the first nullable ancestor, so one subgraph failing destroys branches far beyond the field that failed | 14 | graphql/graphql-spec issue 719; Apollo, *Nullability*; graphql-wg `SemanticNullability` RFC |
| 6 | Breaking changes are the highest availability risk in a federated system | 16 | *GraphQL Federation in 2026: Contracts, Composition, and Runtime Governance* |
| 7 | Ownership. If multiple teams can alter the same field, nobody owns it, and schema evolution becomes a social problem disguised as an API problem | 17 | *GraphQL Federation in 2026*; *Federation Isn't Just an API Problem* |
| 8 | Blame routing. When the graph fails, the federation team is first line of defence for a bug in a downstream team's domain | 18 | Apollo, *9 Lessons From a Year of Apollo Federation* |
| 9 | Latency and caching. Underprovisioned gateway, no caching, a round trip per branch | 18 | *Battling Latency: Lessons from Implementing GraphQL Federation* |
| 10 | Mirroring REST into the schema produces fields nobody uses and years of removal work | 16 | Apollo, *9 Lessons From a Year of Apollo Federation* |
| 11 | The adoption threshold. Federation pays when several teams need independent ownership of one API surface; below that it costs more than it returns | 1 | *Federation Isn't Just an API Problem*; WunderGraph, *GraphQL Federation: A Complete Guide* |
| 12 | `@requires`, `@provides`, `@external` and satisfiability. Composition errors that name one failing route out of several | 15 | apollographql/federation issue 2668 (adjacent); to be reproduced against the composer |

## Sources, with access date

All accessed 2026-08-19.

- Apollo, *Handling the N+1 Problem* - https://www.apollographql.com/docs/graphos/schema-design/guides/handling-n-plus-one
- Apollo, *Aggregating Data Across Subgraphs* - https://www.apollographql.com/docs/graphos/schema-design/guides/aggregating-data-across-subgraphs
- Apollo, *Nullability* - https://www.apollographql.com/docs/graphos/schema-design/guides/nullability
- Apollo, *9 Lessons From a Year of Apollo Federation* - https://www.apollographql.com/blog/9-lessons-from-a-year-of-apollo-federation
- ChilliCream, Hot Chocolate v16 Apollo Federation Subgraph Support - https://chillicream.com/docs/hotchocolate/v16/api-reference/apollo-federation/
- ChilliCream `graphql-platform` issue 6546, authorization on `_entities` - https://github.com/ChilliCream/graphql-platform/issues/6546
- apollographql/federation issue 2668, filtering and sorting relational data - https://github.com/apollographql/federation/issues/2668
- graphql/graphql-spec issue 719, error propagation considered harmful - https://github.com/graphql/graphql-spec/issues/719
- graphql/graphql-wg, `SemanticNullability` RFC - https://github.com/graphql/graphql-wg/blob/main/rfcs/SemanticNullability.md
- *GraphQL Federation in 2026: Contracts, Composition, and Runtime Governance* - https://thebackenddevelopers.substack.com/p/graphql-federation-in-2026-contracts
- *GraphQL Federation Isn't Just an API Problem, It's an Organisational One* - https://musingsonsoftware.substack.com/p/graphql-federation-isnt-just-an-api
- *Battling Latency: Lessons from Implementing GraphQL Federation in a Microservices Architecture* - https://medium.com/@ebutrera910322/battling-latency-lessons-from-implementing-graphql-federation-in-a-microservices-architecture-70838b70e0dc
- WunderGraph, *GraphQL Federation: A Complete Guide* - https://wundergraph.com/graphql-federation

Several of the above are practitioner blogs rather than primary sources. Under
the SPEC's Sources rule a vendor-published source is usable only when it quotes
a named engineer at the company being described. Cases 8, 9 and 11 currently
rest on sources that do not meet that bar, and each must be re-sourced or
re-stated before its chapter prints it.

## Measurements

**Pygments SDL lexing, 2026-08-19, this machine.** Pygments 2.19.2. Nine lines
of federation SDL (`type ... @key(fields: "id")`, `extend type`, `@external`,
non-null markers) tokenized through two lexers, counting `Token.Error`:

- `graphql` lexer: 77 Error tokens
- `ruby` lexer: 0 Error tokens

Reproduce by writing that snippet to a file and running, for each lexer name:

```
from pygments.lexers import get_lexer_by_name
from pygments.token import Error
sum(1 for t, v in get_lexer_by_name(NAME).get_tokens(src) if t is Error)
```

This is the whole justification for SPEC decision 31 and `\newminted[graphqlsdl]{ruby}{}`.

## Version facts carried in from the interview, not yet verified

These were stated during the interview and are recorded so that verification
has something to check against. **None has been verified for this book.**

- Hot Chocolate 16 is the current major; 16.6.0 released 2026-08-05.
- Hot Chocolate 14 is out of support: the platform's `SECURITY.md` lists only
  16.x and 15.x. Last 14.x patch 14.3.1, 2026-04-10. HC 14 targets
  netstandard2.0, net6.0, net7.0 and net8.0, which is why the `hc14` branch
  pins `net8.0`.
- The Fusion v1 line (HC 13 and 14 era) ended at 15.1.17 on 2026-06-16. Fusion
  16 is a rewrite on the GraphQL Composite Schemas specification. This is the
  basis of SPEC decision 6.
- Fusion 16.5 added Apollo Federation support in the gateway core.
- Apollo Router Core and the Federation 2.x libraries are Elastic License v2.
  Basis of SPEC decision 7.
- Cosmo Router is Apache-2.0 and speaks Federation v1 and v2.

## Claims checked and found false

None yet. SPEC decision 36 requires this section in every note; an empty one is
a statement that nothing has been disproved yet, not an omission.
