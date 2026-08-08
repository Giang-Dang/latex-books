# Federation landscape - facts verified 2026-08-08

Web-verified background for planning this book. These facts rot: re-verify
anything here before drafting a chapter that cites it, especially Parts VI-VII
and the preface version baseline.

## HotChocolate (ChilliCream)

- Latest stable major: **Hot Chocolate 16**, announced 2026-05-11; latest
  release 16.6.0 on 2026-08-05. Targets .NET 8+.
- **HotChocolate 14 is out of support**: the repo's SECURITY.md lists only
  16.x and 15.x for security fixes. Last 14.x patch: 14.3.1 (2026-04-10).
  HC 14 targeted netstandard2.0/net6/net7/net8 (era: Oct 2024).
- HC 16 highlights: rearchitected type system, new batching engine, semantic
  introspection for AI agents, onError mode, MCP/OpenAPI adapters.

## Fusion

- Fusion was **completely rewritten** for 16 (blog 2026-05-15): standalone
  ASP.NET Core gateway, decoupled from the HC type system. The old
  HotChocolate.Fusion line ("v1", HC 13/14-era, pre-spec directives, fusion
  compose CLI) effectively ended at 15.1.17 (2026-06-16).
- New Fusion implements the **GraphQL Composite Schemas specification** (draft
  under the GraphQL Foundation; working group of ChilliCream, Apollo, and The
  Guild, announced 2024-05-16). Composition via Nitro CLI
  (`nitro fusion publish`) or .NET Aspire; `dotnet new graphql-gateway`.
- Fusion 16.5 (blog 2026-07-12) added **Apollo Federation support in the
  gateway core** - mixed Composite-Schemas + Apollo-Federation graphs; scored
  100% on The Guild's federation gateway audit (only Hive Router and Fusion
  have perfect scores).

## HotChocolate.ApolloFederation

- Alive and current: 16.6.0 published 2026-08-05, releases in lockstep with
  the platform, no deprecation. Builds Apollo Federation v2 subgraphs; this
  is the book's subgraph package.

## Apollo

- Federation spec v2.15 (LTS, Jul 2026; min Router 2.16.0); composition
  rewritten in Rust in 2.15.
- Apollo Router Core and Federation 2.x libraries are **Elastic License v2**
  (no offering as a managed service).
- GraphOS pricing: free tier (~60 req/min self-hosted router, 3 devs) ->
  usage-based ~$5/M requests -> annual Standard (~$2,500/mo, third-party
  figure) -> Enterprise.

## Gateway market (one line each)

- **WunderGraph Cosmo**: open-source full-stack federation platform (Go
  router + registry/studio), Federation v1/v2 - the book's gateway.
- **The Guild / Hive**: Hive Gateway (TypeScript) plus Hive Router (Rust,
  perfect audit score); GraphQL Mesh for many-protocol composition.
- **Grafbase**: commercial Rust gateway, publishes aggressive query-planning
  benchmarks.
- **Apollo Connectors**: declarative REST-to-graph in the router, being
  pushed hard by Apollo.

## ChilliCream tooling names

- Banana Cake Pop was renamed **Nitro** (2024-10-07): Nitro app (IDE), Nitro
  CLI (fka Barista), Nitro Server. "Barista" no longer exists as a name.

## Sources

- https://chillicream.com/blog/2026/05/11/hot-chocolate-16/
- https://chillicream.com/blog/2026-05-15-fusion-16
- https://chillicream.com/blog/2026-07-12-fusion-16-5
- https://chillicream.com/blog/2025/02/01/hot-chocolate-15/
- https://chillicream.com/blog/2024/08/30/hot-chocolate-14/
- https://github.com/ChilliCream/graphql-platform/releases
- https://github.com/ChilliCream/graphql-platform/blob/main/SECURITY.md
- https://www.nuget.org/packages/HotChocolate.ApolloFederation
- https://graphql.github.io/composite-schemas-spec/draft/
- https://graphql.org/blog/2024-05-16-composite-schemas-announcement/
- https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/versions
- https://www.apollographql.com/trust/licensing
- https://chillicream.com/blog/2024/10/07/introducing-nitro/
- https://grafbase.com/blog/benchmarking-graphql-federation-gateways
