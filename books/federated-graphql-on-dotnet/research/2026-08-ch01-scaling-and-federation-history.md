# Graph scaling and federation history - facts verified 2026-08-08

Source research for chapter 01. Every URL below was fetched and returned HTTP
200 on 2026-08-08 unless noted. These facts rot: re-verify before reusing them,
especially in chapters 26 and 28.

Division of labour with the other research file: `2026-08-federation-landscape.md`
owns current-state facts (versions, the gateway market, tooling names). This
file owns history and case studies. Where they overlap, the landscape file wins
on "what is true now" and this file wins on "what happened when".

## A. The promise of one graph

- GraphQL was built at Facebook starting 2012 and open-sourced in July 2015.
  The first public commits to `graphql/graphql-js` ("GraphQL technical
  preview") and `graphql/graphql-spec` ("GraphQL Specification, Working Draft")
  are both 2015-07-02, both by Lee Byron.
  Announcement post: Lee Byron, "GraphQL: A data query language",
  2015-09-14. <https://engineering.fb.com/2015/09/14/core-infra/graphql-a-data-query-language/>
  Verbatim: "We developed GraphQL three years ago to fill this need."
- IMPORTANT NEGATIVE FINDING: there is no Facebook/Meta statement that GraphQL
  was intended as one unified graph per organisation. The 2015 post talks about
  Facebook's own product needs. Do not attribute the "one graph" doctrine to
  Facebook.
- The "one graph" doctrine is Apollo's, from Principled GraphQL by Geoff
  Schmidt and Matt DeBergalis. <https://principledgraphql.com/>
  Principle 1, verbatim: "Your company should have one unified graph, instead
  of multiple graphs created by each team." Principle 2 is "Federated
  Implementation".
  The page carries NO publication date. Earliest Internet Archive capture
  2019-02-12; first HTTP 200 capture 2019-03-01. So: early 2019, which is
  roughly three months BEFORE Federation shipped. The doctrine and the product
  arrived together, which is worth noting when citing it.

## B. Schema stitching (2017 to 2018)

- `graphql-tools` repo created 2016-03-22 (GitHub API `created_at`), 18 months
  before stitching: stitching was added to an existing schema-building toolkit.
- 2017-09-07, the idea is published: Sashko Stubailo, "GraphQL schema
  stitching". <https://www.apollographql.com/blog/graphql-schema-stitching>
  Verbatim: stitching is "the idea that you can take two or more GraphQL
  schemas, and merge them into one endpoint that can pull data from all of
  them."
- 2017-10-04, it ships stable in graphql-tools 2.0: Mikhail Novikov.
  <https://www.apollographql.com/blog/graphql-tools-2-0-with-schema-stitching-8944064904a5>
  Three moving parts: `makeRemoteExecutableSchema` (introspect a remote API
  into a local schema), `mergeSchemas`, and hand-written resolvers to link
  types across backends. Verbatim: "it's possible to link between any two types
  in your new schema (even across backends) by extending the schema and passing
  the custom resolvers option."
  Git tag `v2.0.0` is 2017-10-03; the blog post is dated 2017-10-04. Cite the
  post date for "Apollo shipped stitching".
- 2018-04-09, schema delegation named as the third leg: Mikhail Novikov,
  `delegateToSchema`.
  <https://www.apollographql.com/blog/graphql-schema-delegation-9d832648c543>
- 2018-04-26, graphql-tools 3.0 adds schema transforms: Sashko Stubailo, "The
  next generation of schema stitching".
  <https://www.apollographql.com/blog/the-next-generation-of-schema-stitching-2716b3b259c0>
  Git tag `v3.0.0` matches the post date exactly. Conceptually: the glue got a
  plugin architecture, and more imperative surface area.
- Apollo added a retirement banner to both stitching posts: "This post
  discusses Schema Stitching, an approach we explored that eventually led to
  the development of Apollo Federation."

## C. Federation (2019 to 2022)

- 2019-05-01, Apollo Federation announced: James Baxley III.
  <https://www.apollographql.com/blog/apollo-federation-f260cf525d21>
  (the old `blog.apollographql.com/...` URL 301s here; cite the `www` form)
  Verbatim, stated purpose: "It's designed to replace schema stitching and
  solve pain points such as coordination, separation of concerns, and brittle
  gateway code."
  Verbatim, declarative principle: "Building a graph should be declarative.
  With federation, you compose a graph declaratively from within your schema
  instead of writing imperative schema stitching code."
  Verbatim, the Conway argument in Apollo's own words: "Code should be
  separated by concern, not by types. Often no single team controls every
  aspect of an important type like a User or Product, so the definition of
  these types should be distributed across teams and codebases, rather than
  centralized."
  Verbatim, entities: "A type that can be connected to a different service in
  the graph is called an entity, and we specify directives on it to indicate
  how both services should connect."
  Verbatim, the router's job: "The gateway crunches all of this into a single
  schema, indistinguishable from a hand-written monolith."
- 2019-07-16, managed federation: Matt DeBergalis.
  <https://www.apollographql.com/blog/announcing-managed-federation-265c9f0bc88e>
  Composition moves out of gateway startup and into a build step against a
  registry. This is the origin of composition-as-build-artifact, which Part VI
  of the book depends on.
- Federation 2 dates, all three are real and distinct. Cite the GA date.
  - 2021-11-03 alpha announcement, Phil Prasek.
    <https://www.apollographql.com/blog/announcing-federation-2>
  - 2022-03-16 preview, Vivek Ravishankar.
  - 2022-04-13 GENERALLY AVAILABLE, Phil Prasek.
    <https://www.apollographql.com/blog/announcement/backend/apollo-federation-2-is-now-generally-available/>
    Corroborated by Apollo's changelog, which dates spec v2.0 to April 2022.
  Verbatim on `extend`: "All types are shared equally across subgraphs. This
  means you don't have to use the `extend` keyword."
  Verbatim on composition: "The rewritten composition engine now validates all
  theoretically possible queries and provides more descriptive error messages."
  Also introduced in the GA post: `@shareable`, `@override` ("mark it with
  @override to accept production traffic without downtime"), `@inaccessible`.
- Anything claiming "Federation 2 launched in 2021" is describing the alpha.

## D. What actually happened to stitching

Needed so the book does not repeat the vendor line that stitching died.

- The Guild took over `graphql-tools` from Apollo in spring 2020, announced
  2020-05-21 by Arda Tanrikulu.
  <https://the-guild.dev/graphql/hive/blog/graphql-tools-v6>
  Verbatim: "As the Guild, we recently took over the popular GraphQL Tools
  repository from the team at Apollo, who created this amazing library."
  Exact transfer date is UNVERIFIED and no published date exists. Bracket:
  after 2020-04-14 (the v5.0.0 release notes still link
  `apollographql/graphql-tools`) and by 2020-05-21. Write it as "spring 2020".
- 2021-01-14, The Guild's counter-position: Greg MacWilliam, "A new year for
  GraphQL schema stitching".
  <https://the-guild.dev/graphql/hive/blog/a-new-year-for-schema-stitching>
  Verbatim: "If you want out-of-the-box workflows, Federation is the tool for
  you. Otherwise, Stitching is the comparable alternative that keeps you in
  control of your full system architecture."
- 2021-07-28, graphql-tools v8 adds `federationToStitchingSDL`: the two
  lineages became interoperable, one day after Apollo published the Expedia
  migration story. <https://the-guild.dev/graphql/hive/blog/graphql-tools-v8>
- 2024-11-18, most recent dated evidence that The Guild still treats stitching
  as a live option, and concedes the gateway-complexity point: Emily Goodwin.
  <https://the-guild.dev/graphql/hive/blog/extending-your-graphql-service>
  Verbatim: "Schema Stitching requires less knowledge from subschema teams but
  more knowledge from the team owning the gateway as the stitching logic can
  become complex as the number of services grow."

## E. The strongest sourced criticism of stitching

- 2021-07-27, Expedia's migration, published by Apollo (so: Apollo's framing of
  a customer's experience, not an independent account): David Isquick.
  <https://www.apollographql.com/blog/expedia-improved-performance-by-moving-from-schema-stitching-to-apollo-federation>
  Verbatim: "Their gateway code was becoming more complex, and there was no way
  to determine the 'true schema' without running the gateway."
  Verbatim: "With Federation, we saw a reduced latency compared to schema
  stitching. Because there was a reduced latency, we were able to reduce our
  compute quite significantly by about 50%."
  The "true schema" quote is the sharpest available statement of the
  gateway-owns-the-glue problem. The 50% compute figure is a single company's
  before-and-after on a vendor's blog; do not generalise it.
- The old Apollo Server v2 "why not stitching" docs page is GONE (404). The
  polemical version of that argument now survives only in the Expedia post.

## F. The present, for the bridging paragraph only

- 2024-05-16, Composite Schemas subcommittee announced.
  <https://graphql.org/blog/2024-05-16-composite-schemas-announcement/>
  Authors: Jeff Auriemma, Benjie Gillam, Michael Staib, Kamil Kisiela,
  Praveen Durairaju.
  CORRECTION to `2026-08-federation-landscape.md`, which called it a working
  group of ChilliCream, Apollo and The Guild: the named contributing
  organisations are Apollo GraphQL, ChilliCream, Google, Graphile, The Guild,
  Hasura and IBM (seven), and it is formally the Composite Schemas
  Subcommittee of the GraphQL Specification Working Group, which "re-convened"
  rather than a newly created body. The landscape file has been corrected.
  Verbatim on the split in approaches: "Federation and Fusion take an approach
  that optimizes for collaborative schema composition, whereas Mesh and Hasura
  prioritize flexibility with a variety of heterogenous services or even
  databases."
- `graphql/composite-schemas-spec` repo created 2023-10-11, seven months before
  the public announcement.
- As of 2026-08-07 the spec is an actively edited draft with ZERO releases and
  ZERO tags. Draft renders at
  <https://graphql.github.io/composite-schemas-spec/draft/> and carries no
  version or date stamp. Accurate phrasing: "an actively edited draft with no
  published version".
- CORRECTION to the landscape file's implication about Rust: "Composition is
  now written in Rust" belongs to Apollo Federation spec v2.15 (July 2026), per
  <https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/versions>
  The 2022 Rust work was the Router, a different component. Do not conflate.

## G. URL and citation hazards (verified 2026-08-08)

- `blog.apollographql.com/*` 301s to `www.apollographql.com/blog/*`. Always
  cite the `www` form.
- `the-guild.dev/blog/<slug>` 301s to `the-guild.dev/graphql/hive/blog/<slug>`.
  Cite the Hive path.
- DO NOT cite `specs.apollo.dev/federation/...` URLs as readable documents.
  They are `@link` identifiers; `specs.apollo.dev/federation/v2.15/` is a 404.
  Cite instead
  <https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec>
- Apollo kept a frozen v1 docs tree, which is genuinely useful for history:
  <https://www.apollographql.com/docs/federation/v1/federation-spec> (200).
- `graphql.org` returns 403 to automated fetchers but 200 in a browser. The
  URLs are fine to cite; content was verified via the site's source repo.

## H. Documented single-schema failure modes, by company

Every item is the company's own engineering blog or its own engineers on a
recorded talk, except where flagged. Medium-hosted posts (Netflix, PayPal,
Booking.com, Volvo Car Mobility) block automated fetching; they were verified
through Internet Archive snapshots reading `datePublished` plus the on-page
byline. Cite the canonical URLs below, not archive URLs.

- **Booking.com**, Christian Ernst, 2022-10-24. The best single source: four
  failure modes in one paragraph.
  <https://medium.com/booking-com-development/improving-graphql-federation-resiliency-ca3e95075de4>
  Verbatim: "As our single GraphQL service grew, it became more difficult to
  maintain not only for the GraphQL team who had dozens of merge requests a day
  to review for schema changes and service mappings but also manage frequent
  service deployments and help resolve merge conflicts with multiple teams. This
  also made it difficult for service owners to have strong ownership of their
  data and schema as they were heavily tied to the single service."
- **Netflix**, Jennifer Shin and Stephen Spalding, QCon Plus Nov 2020, InfoQ
  page 2020-11-23. <https://www.infoq.com/presentations/netflix-api-graphql-federation/>
  Shin, verbatim: "We have hundreds of mature services providing APIs for UIs to
  consume. Yet they're all aggregated into a single API monolith... We had done
  all of this work to break apart our system into microservices. Yet, we still
  found ourselves with an API monolith."
  Spalding, verbatim: "the API gateway had become the new monolith." The
  surrounding transcript is garbled (it lists fallback logic, caches, in-memory
  datastores and business logic accumulating in the gateway); quote only the
  clean clause and paraphrase the mechanism.
  Also Shin on governance: "We actually have a schema working group that meets
  weekly. We have a schema architect that understands the entire surface area of
  the graph of studio."
- **Netflix part 1**, Tejas Shikhare and others, 2020-11-09.
  <https://netflixtechblog.com/how-netflix-scales-its-api-with-graphql-federation-part-1-ae3557c187e2>
  Section heading is literally "Bottlenecks of Studio API". Verbatim: "the
  Studio API team was disconnected from the domain expertise and the product
  needs, which negatively impacted the schema's health. Second, connecting new
  elements from a back-end into the graph API was manual and ran counter to the
  rapid evolution promised by a microservice architecture. Finally, it was hard
  for one small team to handle the increasing operational and support burden for
  the expanding graph."
  Verbatim: "Inconsistent data across different Studio applications was the top
  support issue in Studio Engineering in 2018."
  Also: "We're live with 70 DGSes and hundreds of developers"; "Query Planning
  and Execution adds a ~10ms overhead in the worst case".
- **Netflix part 2**, Tejas Shikhare, 2020-12-11.
  <https://netflixtechblog.com/how-netflix-scales-its-api-with-graphql-federation-part-2-bbe71aaec44a>
  The source of BOTH the governance-overhead admission and the maturity warning:
  "While reviews add overhead to the product development process, we believe
  that prioritizing the quality of the graph model will reduce the amount of
  future changes and reworking needed."
  "Despite our positive experience, GraphQL Federation is early in its maturity
  lifecycle and may not be the best fit for every team or organization. Learning
  GraphQL and DGS development, running a federation layer, and doing a migration
  requires high commitment from partner teams and seamless cross-functional
  collaboration."
  "only the monolith Studio API team needed to learn GraphQL. In Studio Edge,
  every DGS team needs to build expertise in GraphQL."
- **Netflix**, Tejas Shikhare, InfoQ podcast, 2023-01-16, on deploy coupling.
  <https://www.infoq.com/podcasts/netflix-expanding-graphQL-federation/>
  Verbatim: "you don't have to implement the feature in the backend service, in
  the GraphQL service before the client can use it, so that is one of the big
  problems that federation solves".
- **Volvo Car Mobility**, Iman Radjavi, Christopher Gustafson, Alexander
  Lindquister, 2023-02-23.
  <https://medium.com/volvo-car-mobility-tech/why-volvo-car-mobility-use-apollo-federation-59c647a2ab60>
  NOTE: Volvo Car Mobility is the car-sharing business, a distinct engineering
  org from Volvo Cars. Do not merge them.
  Verbatim: "all teams still had to work within the monolith for GraphQL schema
  changes, but with the addition of having to define gRPC service-to-service
  APIs and implement changes in one or more microservices. Additionally, our
  uptime was heavily dependent on this monolithic service."
- **Major League Baseball**, Matt Oliver and Olessya Medvedeva, QCon Plus Nov
  2021, InfoQ page 2022-03-24.
  <https://www.infoq.com/presentations/graphql-major-league-baseball/>
  Verbatim: "we have low visibility into who is making calls on our platform...
  which makes making model changes and potentially breaking changes really hard".
- **PayPal**, Mark Stuart, 2019-10-30.
  <https://medium.com/paypal-tech/scaling-graphql-at-paypal-b5b5ac098810>
  Verbatim: "In reality, assembling a single graph is difficult." / "This is the
  most difficult problem that we have with GraphQL." / "scaling in the
  Enterprise isn't about horizontal scaling or paying a lot of money for servers
  or cloud compute. Scaling people, tooling and processes are most challenging."
- **PayPal**, Shruti Kapoor, 2021-08-31, on governance as a delivery tax.
  <https://medium.com/paypal-tech/graphql-at-paypal-an-adoption-story-b7e01175f2b7>
  Verbatim: "we established a standards body" / "Our adoption of one graph
  approach has been slow. Teams have to change a lot of behavior... adding
  process and time to deliver."
- **Wayfair**, Leah Hurwich Adler. FLAGGED: Apollo's own blog, 2024-04-10, but
  quotes a named Wayfair engineering lead.
  <https://www.apollographql.com/blog/how-wayfair-achieved-graphql-success-with-federated-graphql>
  Verbatim: "The monolith was so unwieldy that we hit a ceiling in our velocity,
  and hiring more engineers didn't help us push code to production faster."
  Also: "a graph that sees 220 million requests a day from 80 different
  subgraphs".
- **Netflix**, Dane Avilla, 2021-02-22, naming and rejecting the doctrine, which
  is useful given this chapter's title.
  <https://netflixtechblog.com/beyond-rest-1b76f7c20ef6>
  Verbatim: efforts to unify an enterprise-wide model "often entail multiple
  calendar quarters of coordination between internal organizations"; he contrasts
  his approach with "this 'One Graph to Rule Them All' approach".
- **Edmunds**, Yuhan Zhang and Suresh Narasimhan, 2022-04-04.
  <https://technology.edmunds.com/2022/04/04/Edmunds-GraphQL-Federation-Adoption/>
  Verbatim: "Central GraphQL is a monolith and houses all the schema and
  resolvers."
- **Glassdoor**, 2020-02-20. Useful but do NOT use as monolith-pain evidence:
  their driver was client-side call overhead across several *already separate*
  GraphQL services, which is evidence that many graphs is also a problem.
  <https://medium.com/glassdoor-engineering/journey-to-federation-59299a6ca64e>

Dropped as unverified: Netflix federated-graph request volume (no RPS/QPS
figure appears in any primary source; treat any such number in secondary
sources as unverified), Netflix schema size and team counts, Netflix subgraph
count after the 70 DGSes of Nov 2020, Zillow, Instacart, Indeed, eBay,
Priceline.

## I. The case against federating

- **Twitter Core API Platform**, posted under the handle `jbellenger`,
  graphql-java discussion 2591. Opening post 2021-10-18; THE FEDERATION ANSWER
  IS IN A SEPARATE REPLY DATED 2021-10-20, answering a direct question about why
  not federate. Cite the reply.
  <https://github.com/graphql-java/graphql-java/discussions/2591>
  Verbatim, scale: "we use one unified schema to serve data to first-party
  twitter clients and to power our rest api. The schema defines the entirety of
  our api data model and includes roughly 1000 object types, 100 input types, and
  300 mutation fields. The schema itself grows daily as several hundred
  developers across the company add fields and types to the schema to support
  their projects." / "Our graphql api serves around 500k requests per second...
  one of our most frequently-executed queries is 2500 lines long and returns 50k
  fields per request."
  Verbatim, the decision: "We haven't seen a need to federate our graphql schema
  because our underlying data layer (known as strato) is itself federated.
  Having federation as a data-layer building block gives us most of the perks of
  federation while also allowing us to have a unified schema with strong network
  effects and without too many performance gotchas."
  No real name is given for the poster; attribute to the team.
- **Zalando**, Aditya Pratap Singh, Senior Software Engineer, 2021-03-04.
  <https://engineering.zalando.com/posts/2021/03/how-we-use-graphql-at-europes-largest-fashion-e-commerce-company.html>
  Verbatim: "instead of having multiple Graphs connected via a library and
  gateway we have a single service at Zalando which connects all the domains in a
  single schema Graph... we gain by keeping a single Graph in terms of tooling,
  deployment and governance." He is even-handed elsewhere, which makes him more
  citable, not less.
- **GitHub**, the schema itself. IMPORTANT: GitHub publishes NO type or field
  counts. The numbers used in chapter 01 are our own measurement of the
  published schema file, taken 2026-08-08 and independently reproduced twice.
  Attribute them as counted, never to GitHub.
  <https://docs.github.com/public/fpt/schema.docs.graphql> (1,546,469 bytes,
  74,315 lines on that date)
  Counted: 1,025 object types + 50 interfaces + 50 unions + 254 enums + 415
  input objects + 13 custom scalars = **1,807 named types**; **6,809 fields** on
  object and interface types; **32** `Query` root fields; **274** `Mutation`
  root fields; **1,258** `@deprecated` usages.
  Breaking-change policy (undated living docs, three months' notice, changes
  land on quarter boundaries):
  <https://docs.github.com/en/graphql/overview/breaking-changes>
  Schema download page: <https://docs.github.com/en/graphql/overview/public-schema>
  NOTE: `docs.github.com/en/graphql/overview/schema-previews` is DEAD (301s to
  `/en/graphql`). The last resolving copy is under `enterprise-server@3.12`.
- **graphql.org's own Learn documentation** warns against adopting federation
  casually, which is the most quotable caution available because it is not a
  competitor talking. Undated living docs, accessed 2026-08-08.
  <https://graphql.org/learn/federation/>
  Verbatim: federation "requires substantial infrastructure support, including a
  dedicated team to manage the gateway, schema registry" and "it's crucial to
  consider whether your organization truly needs this level of complexity."
  Same page: "Meta (formerly Facebook), where GraphQL was created, has continued
  to use a monolithic GraphQL API since 2012."
- **Booking.com's operational bill**, same Ernst post as section H.
  Verbatim: "Within a 24-hour period we saw 2,000 `503` responses and 181,668
  the RETRY_LATER error message, which indicated a total failure rate of ~2.4% -
  a number that is considerably higher than the expected 0.05%."
  Also: "nearly 1,000 instances of our Gateway running in production"; the schema
  is fetched "approximately 8,300,00 times a day" (THE DIGIT COUNT IS A TYPO IN
  THE ORIGINAL; paraphrase as roughly 8.3 million, do not quote it); schema
  "nearly 350 KB+ in size".
  TRUNCATION WARNING: "This inability to pull a schema also means no rollouts"
  continues "and appeasing the chaos monkeys to not to take down an internal
  data center while Apollo is down." Do not quote the first half as a complete
  sentence; paraphrase instead.
- **Netflix quantifies a federation defect**: Stephen Chambers, "Solving GraphQL
  Performance Issues at Netflix Scale", GraphQLConf 2025, video published
  2026-01-12. <https://www.youtube.com/watch?v=jlpH9nz_0tw>
  Verbatim from the official description: "our two principal Subgraph Services
  collectively manage over a million GraphQL queries per second" and a bug "at
  the query planning layer, which culminated in a 20% reduction in requests per
  second and yielded substantial cost savings amounting to hundreds of thousands
  of dollars."
  CAREFUL: the 20% and the dollars are the RESULT OF THE FIX, not the cost of
  the bug. Only the abstract is verified; no transcript retrieved.
- **Airbnb**, Ryan Tanner, Raymie Stata, Adam Miskiewicz, 2026-05-13.
  <https://airbnb.tech/infrastructure/viaduct-1-0-and-the-future-of-airbnbs-data-mesh/>
  Verbatim: "Federation distributes development by distributing servers. Viaduct
  distributes development by distributing modules." / "a federated approach
  requires running hundreds of independent subgraph servers".
  DO NOT overstate: the same paragraph says "We don't see Viaduct as an
  alternative to federation, but as a complement to it."
- **Artsy**, Christopher Pappas, RFC opened 2022-04-11, accepted and closed
  2022-05-02. <https://github.com/artsy/README/issues/459>
  The only properly documented public retreat that exists. NOT USED IN CHAPTER 01
  because it concerns schema stitching rather than Apollo Federation and needs
  careful framing; it belongs in ch 26 or 28.
  Verbatim: stitching "requires a great deal of specialized knowledge compared
  to the REST approach, which can be applied by arguably any engineer regardless
  of skill-level or depth of domain specific knowledge."
  Their current playbook heading is literally "## Schema stitching (DEPRECATED)":
  <https://github.com/artsy/README/blob/main/playbooks/graphql-schema-design.md>
- **Marc-Andre Giroux**, "On GraphQL schema stitching and API gateways",
  2018-10-22, six months before Federation shipped.
  <https://magiroux.com/posts/on-graphql-schema-stitching-api-gateways>
  Verbatim: "if you imagine a large stitched schema, we end up with a lot of
  'glue' code at the gateway itself, defining all the important relations
  there." / "our API gateway becoming responsible of everything" / "At this
  point, what is the point of having decentralized schemas when in reality, we
  need a centralized point to merge and extend the schemas?" / on the two-step
  cost: "To me, that's far from an ideal developer experience."
  His later pieces, for ch 26 and 28: "The rise of GraphQL overambitious API
  gateways" 2019-04-01, "GraphQL is a trap" 2022-05-06, "Eight years of GraphQL"
  2024-05-31, all under `magiroux.com/posts/`.
- **Martin Fowler**, "MonolithFirst", 2015-06-03.
  <https://martinfowler.com/bliki/MonolithFirst.html>
  With the dissent hosted on the same site, which is worth citing for balance:
  Stefan Tilkov, "Don't start with a monolith", 2015-06-09.
  <https://martinfowler.com/articles/dont-start-monolith.html>
  Also available: "MicroservicePremium" 2015-05-13, "MicroservicePrerequisites"
  2014-08-28.
- **Shopify**, for ch 26's modular-monolith alternative rather than ch 01:
  Kirsten Westeinde, "Deconstructing the monolith", 2019-02-21
  (<https://shopify.engineering/deconstructing-monolith-designing-software-maximizes-developer-productivity>),
  verbatim: "Communicating between services means crossing the network, which
  adds latency and decreases reliability with every call."
  Philip Muller, "Under deconstruction: the state of Shopify's monolith",
  2020-09-16 (<https://shopify.engineering/shopify-monolith>), verbatim:
  "splitting a single monolithic application into a distributed system of
  services increases the overall complexity considerably", plus 2.8M lines of
  Ruby and 500,000 commits.
  API versioning: <https://shopify.dev/docs/api/usage/versioning> (quarterly
  releases, 12 month minimum support) and Tom Newton, 2019-12-17
  (<https://shopify.engineering/shopify-manages-api-versioning-breaking-changes>).
  Shopify does NOT publish the Admin schema as a fetchable file, so there is no
  Shopify equivalent of the GitHub counts.

## J. Fabrications and traps to avoid citing

Recorded because these rank highly in search results and would each be a
published error.

- "How Shopify Quietly Abandoned GraphQL After Betting Everything On It"
  (`techpreneurr.medium.com`, 2025-10-06, pseudonymous) is AI-generated and its
  central claim is BACKWARDS: Shopify is deprecating REST in favour of GraphQL.
  Same category: `byteiota.com`; "We Killed Our GraphQL API and Went Back to
  REST"; "GraphQL Killed Our API Performance. We Went Back to REST".
- Matt Bessey's post, the most-read GraphQL-regret piece on the internet, never
  mentions federation, stitching, subgraphs or gateways. The loudest GraphQL
  critic is not a federation critic. Do not recruit him as one.
- Every "lessons learned" writeup for Expedia, Intuit, Booking.com, Wayfair,
  StockX and Netflix lives on Apollo's own properties. Usable when a named
  engineer is quoted, but always flag the venue.
- Vendor content arguing against competitors: Hasura, StepZen, Grafbase. Not
  citable.
- The confirmed negative is itself a finding: NO company has published a "we
  removed federation" account. Exactly one documented a retreat (Artsy, about
  stitching). State the silence carefully: teams rarely blog about removing
  expensive infrastructure, so the absence is real but its cause is unknown.
  Do not read it as vindication either way.

## Candidate bib keys

Entries marked "in refs.bib" are already cited by chapter 01.

| Source | Key | Status |
|--------|-----|--------|
| Byron, GraphQL: A data query language, 2015 | `byron2015graphql` | in refs.bib |
| Schmidt and DeBergalis, Principled GraphQL | `schmidt2019principled` | in refs.bib |
| Stubailo, GraphQL schema stitching, 2017 | `stubailo2017stitching` | in refs.bib |
| Novikov, graphql-tools 2.0, 2017 | `novikov2017tools2` | in refs.bib |
| Stubailo, Next generation of schema stitching, 2018 | `stubailo2018nextgen` | in refs.bib |
| Baxley, Apollo Federation, 2019 | `baxley2019federation` | in refs.bib |
| DeBergalis, Announcing managed federation, 2019 | `debergalis2019managed` | in refs.bib |
| Tanrikulu, GraphQL Tools v6 / new leadership, 2020 | `tanrikulu2020tools6` | in refs.bib |
| MacWilliam, A new year for schema stitching, 2021 | `macwilliam2021stitching` | in refs.bib |
| Isquick, Expedia migration, 2021 | `isquick2021expedia` | in refs.bib |
| Prasek, Federation 2 GA, 2022 | `prasek2022federation2` | in refs.bib |
| Composite Schemas announcement, 2024 | `graphql2024composite` | in refs.bib |
| Composite Schemas draft spec | `compositeschemas2026draft` | in refs.bib |
| Apollo federation version changelog | `apollo2026versions` | in refs.bib |
| Conway, How do committees invent?, 1968 | `conway1968committees` | in refs.bib |
| Ernst, Booking.com federation resiliency, 2022 | `ernst2022booking` | in refs.bib |
| Netflix federation part 1, 2020 | `shikhare2020netflix1` | in refs.bib |
| Netflix federation part 2, 2020 | `shikhare2020netflix2` | in refs.bib |
| Shin and Spalding, QCon talk, 2020 | `shin2020netflixtalk` | in refs.bib |
| Shikhare, InfoQ podcast, 2023 | `shikhare2023podcast` | in refs.bib |
| Volvo Car Mobility, 2023 | `radjavi2023volvo` | in refs.bib |
| Oliver and Medvedeva, MLB, 2022 | `oliver2022mlb` | in refs.bib |
| Stuart, Scaling GraphQL at PayPal, 2019 | `stuart2019paypal` | in refs.bib |
| Kapoor, PayPal adoption story, 2021 | `kapoor2021paypal` | not yet cited |
| Hurwich Adler, Wayfair, 2024 | `adler2024wayfair` | in refs.bib |
| Twitter Core API Platform discussion, 2021 | `twitter2021unified` | in refs.bib |
| Singh, Zalando, 2021 | `singh2021zalando` | in refs.bib |
| GitHub public schema file | `github2026schema` | in refs.bib |
| GitHub breaking-change policy | `github2026breaking` | in refs.bib |
| graphql.org Learn, Federation | `graphqlorg2026federation` | in refs.bib |
| Giroux, On schema stitching and API gateways, 2018 | `giroux2018stitching` | in refs.bib |
| Fowler, MonolithFirst, 2015 | `fowler2015monolithfirst` | in refs.bib |
| Tilkov, Don't start with a monolith, 2015 | `tilkov2015dontstart` | in refs.bib |
| Chambers, Netflix performance talk, 2026 | `chambers2026netflix` | in refs.bib |
| Tanner and others, Airbnb Viaduct, 2026 | `tanner2026viaduct` | in refs.bib |
| Pappas, Artsy stitching RFC, 2022 | `pappas2022artsy` | in refs.bib, deliberately uncited until ch 26/28 |
| Novikov, schema delegation, 2018 | `novikov2018delegation` | not yet cited |
| graphql-tools v8, federationToStitchingSDL, 2021 | `tanrikulu2021tools8` | not yet cited |
| Goodwin, Federation or schema stitching, 2024 | `goodwin2024extending` | not yet cited |
| Avilla, Beyond REST, 2021 | `avilla2021netflix` | not yet cited |
| Edmunds federation adoption, 2022 | `zhang2022edmunds` | not yet cited |
| Westeinde, Deconstructing the monolith, 2019 | `westeinde2019shopify` | not yet cited (ch 26) |
| Muller, State of Shopify's monolith, 2020 | `muller2020shopify` | not yet cited (ch 26) |
