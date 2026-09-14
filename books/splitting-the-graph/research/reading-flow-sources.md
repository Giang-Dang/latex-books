# Official-source cross-check for the reading-flow repair

Accessed 2026-09-14 during review/planning and implementation. Reference
contracts are admitted by SPEC decision 39; these are not attributed
engineering experience. Runtime behavior remains pinned to the toolchain in
the book, not to whichever API the current documentation happens to show.

| Source | What it establishes | Used by |
|---|---|---|
| [GraphQL September 2025](https://spec.graphql.org/September2025/) | Named unordered arguments and input fields; validation; nearest-nullable-position propagation; errors and extensions | H01, H02, H15, M08, M09 |
| [Apollo change management](https://www.apollographql.com/docs/graphos/platform/production-readiness/change-management) | Output strengthening versus input strengthening; runtime-first rollout | H01, M01, M36 |
| [Apollo nullability](https://www.apollographql.com/docs/graphos/schema-design/guides/nullability) | Compatibility directions and tradeoffs, not a universal nullable-seam mandate | H01, H15 |
| [Federation directives](https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/directives) | Resolvable keys, external/provides/requires, version-gated directives | H04-H06, appendix C |
| [Sharing types](https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/sharing-types) | Shared value types need not be entities; shareable resolution must agree | H06, M03, M41 |
| [Migrating fields](https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/entities/migrate-fields) | Deploy receiver before routing to it, retire old implementation afterwards | H08 |
| [Subgraph specification](https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec) | Positional entity response contract, missing-entity nulls | H16, M18 |
| [Hot Chocolate DataLoader](https://chillicream.com/docs/hotchocolate/fetching-data/batching/dataloader) | Keyed batch adapters, request cache, dispatch rather than one batch per depth | H11, H12, M25 |
| [Hot Chocolate EF integration](https://chillicream.com/docs/hotchocolate/fetching-data/integrations/entity-framework) | Application DI factory versus resolver integration | M05 |
| [Relay connections](https://relay.dev/graphql/connections.htm) | first is an upper bound; after and cursor ordering | M06, M28 |
| [Hot Chocolate authorization](https://chillicream.com/docs/hotchocolate/security/authorization) | Field/type guards, application attributes, error codes | H13, M26, M27 |
| [Cosmo authorization](https://cosmo-docs.wundergraph.com/router/authentication-and-authorization) | Authentication is separate from forwarding; default post-fetch field filtering | H13, M27 |
| [Hot Chocolate 15 to 16 migration](https://chillicream.com/docs/hotchocolate/migrating/migrate-from-15-to-16) | Export rewrite and executor error-handling mode are separate | M31 |
| [Hot Chocolate 16.6 to 16.7 migration](https://chillicream.com/docs/hotchocolate/migrating/migrate-from-16-6-to-16-7) | Current API documentation has advanced beyond the pin | Appendix A/B |
| [Cosmo schema checks](https://cosmo-docs.wundergraph.com/studio/schema-checks) | Structural change detection versus observed-operation policy | M36-M38 |
| [Cosmo check command](https://cosmo-docs.wundergraph.com/cli/subgraph/check) | skip-traffic-check applies a stricter structural policy | M36 |
| [Apollo ownership guidance](https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/entities/enforce-ownership) | Custom owner metadata requires an external policy; no built-in business approval | M03, M41 |
| [ChilliCream security policy](https://github.com/ChilliCream/graphql-platform/blob/main/SECURITY.md) | Current supported security line is 16.x, not 14 | Appendix A/B |

## Disagreements and moving references

- The current Hot Chocolate documentation describes 16.7. Some old versioned
  URLs redirect or fail. Code must come from the verified 16.6.1 source, not
  from copying the current page.
- The current GraphQL-over-HTTP draft at
  <https://http-spec.graphql.org/draft/> is not a frozen contract for these
  captures. Its response-status recommendations have changed. Preserve the
  operation, request headers, media type and observed pinned-server status;
  do not turn an observed 200/400 into a universal GraphQL rule.
- The Apollo Federation v2.6 specification URL redirects to a current page.
  A version in a link is not proof that the retrieved contents are frozen.
- The current subgraph specification and directive reference disagree about
  some printed directive locations/repeatability, notably tag and context.
  Appendix C must distinguish the pinned exported declarations from
  later-version reference features, rather than silently reconciling them.
- Current Cosmo documentation includes an optional pre-fetch authorization
  mechanism. This repair does not assume that option exists in router 0.341.0.
- Apollo's published provides prerequisites and the pinned Cosmo composer's
  acceptance differ in the existing chapter-15 experiment. Preserve both
  facts, including the routed request that exposes the false pass.

No benchmark timing is inferred from these sources. Statement counts and
wire-request counts require the corresponding local observation.

## Versioned directive inventory

The baseline is the Apollo Federation internals package tag
`@apollo/federation-internals@2.6.0`, commit
`b6bcfd84addedfd9f3144aeb485ed24982841428`, in `internals-js/src/specs/`:
[federationSpec.ts](https://github.com/apollographql/federation/blob/b6bcfd84addedfd9f3144aeb485ed24982841428/internals-js/src/specs/federationSpec.ts),
plus tagSpec.ts, authenticatedSpec.ts, requiresScopesSpec.ts and policySpec.ts
at that same commit. This is not a guessed `v2.6.0` repository tag.

- v1: key, extends, external, requires, provides; tag joins at v1.1.
- v2.0: link, shareable, override, inaccessible; composeDirective at v2.1;
  shareable repeatability at v2.2; interfaceObject and entity interfaces at
  v2.3; authenticated/requiresScopes at v2.5; policy at v2.6.
- The baseline has 15 Federation/link names including extends. Later
  context/fromContext (2.8), cost/listSize (2.9) and cacheTag (2.12) bring the
  reference inventory to 20. Progressive override labels begin at 2.7.
  Connector source/connect are a separate specification, first requiring
  Federation 2.10; they are pointers, not tested features in this book.
- The [official changelog](https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/versions)
  supplies these later-version boundaries. The
  [directive reference](https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/directives)
  supplies listSize's assumedSize, slicingArguments, sizedFields and
  requireOneSlicingArgument (default true).
- At the pinned source, external has optional reason: String and
  composeDirective has nullable name: String. The current documentation
  omits the former and prints String! for the latter. Appendix C exposes the
  disagreement rather than making the implementations look identical.
- Pinned tag spec v0.3 includes SCHEMA; the current subgraph reference omits
  it. Context source at commit cd071d441fed05fc047fb6783d57217b930958cb
  (contextSpec.ts) is repeatable and defines fromContext's field as nullable
  ContextFieldValue. Current reference presentations differ on repeatability.
- requiresScopes and policy use a required nested list; outer alternatives
  are OR, inner members AND. Parsing a directive does not prove router
  enforcement. No new runtime support is claimed for either here.

## Layout constants

The decimal-number gate also sees TeX dimensions. These are authored table
column widths, not measurements of the system: appendix A uses 0.49 and
0.38 times linewidth; appendix B uses 0.40 and 0.47; appendix D uses 0.25
and 0.62. Their acceptance criterion is the rendered page and a zero-overfull
build, not an empirical benchmark.
