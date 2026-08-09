# Chapter 06 research - The Federation Model

Research date: 2026-08-09. Web-verified against primary sources. This chapter
is conceptual and ships no companion code (SPEC decision 21 applies: SDL
sketches allowed, framed as sketches).

## Apollo Federation v2 specification

- Current: v2.15 LTS (Jul 2026), minimum Router 2.16.0.
- Specification source: https://specs.apollo.dev/federation/v2.15/
- The spec defines the directives, the composition algorithm, and the subgraph
  contract.
- Federation v2 was a substantial re-architecture: it replaced the monolithic
  query planner of Federation v1 with a modular one, allowed entities to have
  multiple key directives, and introduced @shareable, @inaccessible, @override,
  @interfaceObject, @tag, and the @link import mechanism.

## Directives verified

All directive semantics below are drawn from the Apollo Federation Subgraph
Specification at https://www.apollographql.com/docs/federation/subgraph-spec,
accessed 2026-08-09, and the Apollo docs "Federated Schemas" overview.

### Core directives

| Directive | Purpose | Argument(s) |
|-----------|---------|-------------|
| @key | Marks a type as an entity; the `fields` argument names the primary key field(s). Multiple @key directives on one type define multiple ways to look up the entity. | `fields: String!`, `resolvable: Boolean` (default true) |
| @shareable | Marks a field that more than one subgraph can resolve. Without this, a field can appear on only one subgraph. | None |
| @external | Declares that a field is defined elsewhere in the supergraph. Used with @requires and @provides. | None |
| @requires | Declares that this field depends on fields from other subgraphs to resolve. The router fetches the `fields` list before calling this resolver. | `fields: String!` |
| @provides | Declares that a field can supply additional fields of the same entity, saving a second fetch of that entity. | `fields: String!` |

### Migration and extension directives

| Directive | Purpose | Argument(s) |
|-----------|---------|-------------|
| @override | Moves field resolution from one subgraph to another. The `from` argument names the subgraph that previously resolved it. | `from: String!` |
| @interfaceObject | A subgraph can define an entity interface, and another subgraph can use @interfaceObject to contribute fields to every entity implementing that interface. | None |
| @inaccessible | Hides a type, field, enum value, or argument from the composed supergraph schema while keeping it available within the subgraph. | None |

### Auxiliary directives

| Directive | Purpose | Argument(s) |
|-----------|---------|-------------|
| @link | Imports federation directives from a spec URL. Required at the top of every subgraph schema. | `url: String!`, `import: [String]`, `as: String` |
| @tag | Attaches an arbitrary string tag to a schema element for tooling use. | `name: String!` |
| @authenticated | Requires the request to carry an authenticated identity. | None |
| @requiresScopes | Requires the request to carry specific OAuth scopes. | `scopes: [[String!]!]!` |

## Key concepts

### Entity

A type marked with @key. The key fields are the unique identifier the router
uses to ask a subgraph for one specific instance of that type. In the
supergraph, a Product entity might have its name and price in the Catalog
subgraph, its reviews in the Reviews subgraph, and its inventory in the
Inventory subgraph. The key (e.g. `id`) is the tie that lets the router
assemble a complete Product from several subgraph responses.

### Entity ownership

The subgraph that defines @key on a type is the authoritative source for the
entity's existence. Other subgraphs extend the entity: they declare the type
again (with the same key), add fields, and provide a reference resolver that
maps the key back to their local data.

### Reference resolver

A subgraph that extends an entity must be able to resolve it from its key
fields. The router sends a `_entities` query with a list of representations
(`{ __typename: "Product", id: "..." }`), and the subgraph returns the
requested fields for each representation. Details in chapter 07.

### Composition

The composition algorithm takes all subgraph schemas and produces a single
supergraph schema. It validates that:
- Every field of every type is resolvable (satisfiability)
- Shared fields have compatible types across subgraphs
- @override targets are valid
- @requires fields are reachable

### Key differences from Federation v1

- Federation v1 had only one @key per type; v2 allows multiple
- v1 used `extend type ... @key` to add key fields; v2 uses @link imports
- v1 had no @shareable (every field was implicitly shareable on an entity,
  which was the cause of many silent composition bugs)
- v1 had no @override, @interfaceObject, @inaccessible, or @tag

## The subgraph contract

A subgraph must:

1. Import the federation spec via @link
2. Provide `Query._service { sdl }` - returns the subgraph's own SDL
3. Provide `Query._entities(representations: [_Any!]!): [_Entity]!` - resolves
   entities from their key representations
4. Define `scalar _Any` and `union _Entity`

These are the mechanical requirements; chapter 07 covers the wire protocol in
detail.

## Sources

- Apollo Federation Subgraph Specification:
  https://www.apollographql.com/docs/federation/subgraph-spec (2026-07-24)
- Apollo Federation Composition Rules:
  https://www.apollographql.com/docs/graphos/reference/federation/composition-rules
  (2026-07-31)
- Apollo Federation Entities overview:
  https://www.apollographql.com/docs/federation/federated-types/entities
- Apollo Federation v2 announcement:
  https://www.apollographql.com/blog/announcement/apollo-federation-2/
- Federation v2.15 release notes: https://github.com/apollographql/federation/releases
- GraphQL Composite Schemas Subcommittee announcement (for context on the
  competing spec): per research/2026-08-federation-landscape.md section on Fusion

## Notes for drafting

- This chapter is the first conceptual chapter since ch01. It sets up Part II.
- No C# appears in this chapter (no companion code, same as ch01).
- All SDL is illustrative and framed as sketches.
- The voice from ch05: first-person practitioner, concrete, British-leaning
  spelling, `~\\autocite{}` with tilde, `\\enquote{}` for quotes.
- Cross-references: forward to ch07 (query execution), ch08 (extracting Catalog),
  ch09 (composition), ch11 (entity resolution done right), ch12 (strangling),
  ch13 (hard modeling problems). Backward to ch01 (why one graph is never enough).
- The chapter label is already `ch:the-federation-model` in the stub.
