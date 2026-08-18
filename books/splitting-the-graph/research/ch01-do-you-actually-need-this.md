# Chapter 1 - Do You Actually Need This?

Research note for the chapter that owns hard case 11, the adoption threshold
(`2026-08-hard-cases.md`). All web sources accessed **2026-08-19**.

This chapter ships no code, so nothing here was measured on a machine. Every
fact below is an external claim, and the note records the byline that carries
it, because SPEC's Sources rule turns on the byline rather than the domain.

## How these were fetched

`netflixtechblog.com` and `medium.com` both refuse an ordinary fetch: 403 for
the first, a TLS reset for the second. Both were read through the Wayback
Machine instead, `https://web.archive.org/web/<year>/<url>`, which returns the
published page as archived rather than a summary of it. Everything else was
fetched directly and returned HTTP 200.

This matters for reproduction: a later session that gets a 403 from these two
domains has hit the same block, not a dead link.

## Sources that carry a claim in the chapter

### Netflix - the single-team graph and its three bottlenecks

Tejas Shikhare, *How Netflix Scales its API with GraphQL Federation (Part 1)*,
Netflix TechBlog, 9 November 2020.
https://netflixtechblog.com/how-netflix-scales-its-api-with-graphql-federation-part-1-ae3557c187e2

Byline confirmed in the archived page: "By Tejas Shikhare", with additional
credits to Stephen Spalding, Jennifer Shin, Philip Fisher-Ogden, Robert Reta,
Antoine Boyer, Bruce Wang and David Simmer. Netflix engineer, Netflix's own
blog, describing Netflix. **Passes the named-engineer rule.**

Verbatim, on what Studio API was and how well it worked before it broke down.
Both sentences are quoted in the chapter and are recorded here because a
quotation the note does not hold is a quotation nobody can check:

> Graph API: To better address the underlying needs, our team started building
> a curated graph API called "Studio API". Its goal was to provide an unified
> abstraction on top of data and relationships.

> The One Graph exposed by Studio API was a runaway success; product teams
> loved the reusability and easy, consistent data access.

Verbatim, the three bottlenecks of Studio API:

> But new bottlenecks emerged as the number of consumers and amount of data in
> the graph increased. First, the Studio API team was disconnected from the
> domain expertise and the product needs, which negatively impacted the
> schema's health. Second, connecting new elements from a back-end into the
> graph API was manual and ran counter to the rapid evolution promised by a
> microservice architecture. Finally, it was hard for one small team to handle
> the increasing operational and support burden for the expanding graph.

And on what preceded it:

> Inconsistent data across different Studio applications was the top support
> issue in Studio Engineering in 2018.

And on the fix:

> We still wanted to keep the unified GraphQL schema of Studio API but
> decentralize the implementation of the resolvers to their respective domain
> teams.

The chapter uses the first and third bottlenecks and the decentralize
sentence. It does not use the 2018 support-issue line, which is about data
consistency rather than coordination.

### Booking.com - what a single GraphQL service costs its owning team

Christian Ernst, *Improving GraphQL Federation Resiliency: Investigating
Failed Schema Updates*, Booking.com Engineering, 24 October 2022.
https://medium.com/booking-com-development/improving-graphql-federation-resiliency-ca3e95075de4

Byline confirmed in the archived page: "Christian Ernst", published in
Booking.com Engineering. **Passes.**

**The byline records no job title**, only the name and the publication. So the
chapter calls him "writing on Booking.com's engineering blog" and does not call
him an engineer: the SPEC's Sources rule is satisfied by a named person on the
company's own engineering blog describing that company, and asserting a role
the page does not state would be inventing a fact to decorate a citation.

On what Booking.com had before it federated, which the chapter paraphrases:

> Many GraphQL layers start out as a single service calling downstream services
> for data, and Booking.com's was no exception here.

> As our single GraphQL service grew, it became more difficult to maintain not
> only for the GraphQL team who had dozens of merge requests a day to review
> for schema changes and service mappings but also manage frequent service
> deployments and help resolve merge conflicts with multiple teams. This also
> made it difficult for service owners to have strong ownership of their data
> and schema as they were heavily tied to the single service.

On the operating cost after federating:

> Currently we have nearly 1,000 instances of our Gateway running in
> production.

"Dozens of merge requests a day" is the only quantity the chapter takes from
this source, plus the gateway instance count. Both are counts, so both are
inside SPEC decision 19.

### Zalando - one GraphQL service, twelve-plus domains

Aditya Pratap Singh, Senior Software Engineer, *How we use GraphQL at Europe's
largest fashion e-commerce company*, Zalando Engineering Blog, 4 March 2021.
https://engineering.zalando.com/posts/2021/03/how-we-use-graphql-at-europes-largest-fashion-e-commerce-company.html

**Passes.** Fetched directly, HTTP 200.

> instead of having multiple Graphs connected via a library and gateway we
> have a single service at Zalando which connects all the domains in a single
> schema Graph

> The unified GraphQL schema has grown significantly in the last 2 years to a
> dense graph now with more than 12 domains and serves more than 80% of Web
> and 50% of the App use cases

**Important limit on this source, and the chapter must respect it.** The post
does not say Zalando evaluated and rejected Apollo Federation or schema
stitching. It describes what Zalando built, notes the approach "has tradeoffs
which we have addressed", and gives no comparative rationale. So this is
evidence that one service can carry twelve-plus domains at scale. It is *not*
evidence that anyone chose that over federation on the merits, and the chapter
does not claim it is.

### Martin Fowler - build the monolith first

Martin Fowler, *MonolithFirst*, martinfowler.com, 3 June 2015.
https://martinfowler.com/bliki/MonolithFirst.html

Independent named practitioner on his own site, not vendor-published.
**Passes.** Fetched directly, HTTP 200.

> you shouldn't start a new project with microservices, even if you're sure
> your application will be big enough to make it worthwhile

Supported by the two observations either side of it: almost all successful
microservice stories started with a monolith that got too big and was broken
up, and almost all systems built as microservices from scratch ended in
serious trouble.

### Shopify - splitting is deliberate, because it costs

Philip Mueller (spelled Muller with an umlaut in the byline; written in the
chapter as `M\"uller` so the source stays ASCII), *Under Deconstruction: The
State of Shopify's Monolith*, Shopify Engineering, 16 September 2020.
https://shopify.engineering/shopify-monolith

**Passes.** Fetched directly, HTTP 200.

> We are very deliberate about when to split functionality out into separate
> services, and we only do it for good reasons. That's because splitting a
> single monolithic application into a distributed system of services
> increases the overall complexity considerably.

**These two sentences are contiguous**, re-checked against the live page on
2026-08-19 after an audit asked whether joining them misrepresented the source.
They sit at the end of a paragraph that begins "We have a few other monolithic
apps going through similar processes of componentization right now". The
chapter quotes them as one continuous statement, which is what they are.

Not GraphQL-specific. The chapter uses it for the general claim about
distribution cost and says so rather than implying Shopify said anything about
graphs.

### Apollo - what federation is, and what a subgraph must implement

`apollographql/federation`, repository description, accessed 2026-08-19.
https://github.com/apollographql/federation

> Apollo Federation is an architecture for declaratively composing APIs into a
> unified graph. Each team can own their slice of the graph independently,
> empowering them to deliver autonomously and incrementally.

**Why these two pass without a named engineer, stated explicitly rather than
assumed.** Both are Apollo pages and neither carries a byline, so the SPEC's
Sources rule has to be applied on purpose. That rule bars vendor prose making
claims about a company or an outcome, where a byline is the only thing
separating evidence from marketing. Neither of these does that. One is the
definition of a specification by the body that publishes it, and the other is
the normative list of what that specification requires of an implementation:
they are the artifact, not a claim about the artifact, and a reader who doubts
either can check an implementation against them. The chapter's four-requirement
count comes from the second and is load-bearing, which is exactly why the
reasoning is written down here instead of left implicit. Recorded as SPEC
decision 39. An Apollo page arguing that federation made some customer faster
would fail the same rule, byline or not.

Primary: the specification's publisher describing its own specification. Also
confirmed on this fetch: the repository's default license is **Elastic License
2.0**, with some subdirectories under MIT-compatible terms. That corroborates
SPEC decision 7's reason for choosing Cosmo, though chapter 1 does not print
it; chapter 8 owns the gateway choice.

*Apollo Federation Subgraph Specification*, Apollo GraphQL Docs, accessed
2026-08-19.
https://www.apollographql.com/docs/graphos/schema-design/federated-schemas/reference/subgraph-spec
(reached after a redirect from `/docs/graphos/reference/federation/subgraph-spec`;
the URL above is the final form, per house style)

> For a GraphQL service to operate as an Apollo Federation 2 subgraph, it must
> do all of the following:

Four requirements follow: extend its schema with the federation definitions,
resolve `Query._service`, provide a mechanism for resolving entity fields via
`Query._entities`, and apply `@link` to the `schema` type to opt into
Federation v2. **Four** is the count the chapter prints.

### The GraphQL Foundation - federation is being standardized

*Announcing the Composite Schemas Working Group*, graphql.org, 16 May 2024.
https://graphql.org/blog/2024-05-16-composite-schemas-announcement/
(403 on a direct fetch; read through the Wayback Machine)

> That's why the GraphQL Specification Working Group is proud to announce that
> the Composite Schemas Subcommittee re-convened earlier this year and is
> making steady progress toward a common specification describing composition
> and distributed execution across multiple collaborative GraphQL services.

The post also names who contributed, and the chapter's sentence about engineers
rather than logos is carried by this one:

> Engineers from a wide variety of organizations including Apollo GraphQL,
> ChilliCream, Google, Graphile, The Guild, Hasura, and IBM have brought their
> valuable insights to meetings so far

The chapter names five of those seven and says "among those contributing", so
the list is explicitly partial rather than silently trimmed.

**A judgment call, recorded rather than buried.** The post carries no
individual byline. SPEC's Sources rule bars vendor prose without a named
engineer, but its target is a vendor writing about a company; this is a
standards body's record of its own working group, which is the same category
as the unsigned RFC documents `2026-08-hard-cases.md` already cites. Used on
that basis. If a later reader disagrees, the chapter's sentence is one
sentence and drops cleanly.

## Claims checked and found false, or not usable

- **"8,300,000 schema checks and fetches a day" at Booking.com is not what the
  source says.** The published sentence reads "This means that a schema check
  and fetch is made approximately **8,300,00** times a day" - seven digits
  intended, six printed. It is a typo in the source. Printing 8,300,000 would
  silently correct a source; printing 8,300,00 would quote a typo as a fact.
  The chapter prints neither and uses the gateway instance count instead,
  which is unambiguous in the same paragraph.

- **No named practitioner puts a number on the adoption threshold.** This was
  the chapter's main research question and it came back empty. Searches for a
  stated count of teams, services or subgraphs returned nothing attributable.
  The only source that gives a threshold at all is WunderGraph's *GraphQL
  Federation: A Complete Guide* (https://wundergraph.com/graphql-federation,
  published 8 June 2026), which says federation "starts to become compelling
  when several teams need independent ownership over a shared API contract"
  and names "one or two teams with a small API surface" as the regime where "a
  modular monolith is often simpler to operate". Its byline reads only
  "WunderGraph": no named engineer, so it **fails the bar**, exactly as
  `2026-08-hard-cases.md` predicted for case 11. Re-checked here and still
  unusable. The chapter therefore states its threshold as my judgment, in
  first person, and cites nobody for it.

- **No public account exists of a team dismantling a federated graph.**
  Searched twice, independently, for rollbacks, postmortems and "we removed
  our gateway" accounts. Nothing. The nearest adjacent finds and why each
  fails: WunderGraph founder Jens Neuse's *I Was Wrong About GraphQL*
  (https://wundergraph.com/blog/six-year-graphql-recap, 3 December 2024)
  reaffirms federation rather than regretting it, and is vendor prose besides;
  a GraphQLConf 2026 talk by David Stutt of WunderGraph titled *Federation,
  Reversed* is a pitch for an unreleased WunderGraph product, not a customer
  account. The chapter reports the absence and explicitly declines to read
  anything into it.

- **A GraphQLConf 2026 Meta/Instagram talk exists but its content is
  unavailable.** *Shifting Instagram Development Towards Monolith Server Via
  Federated Schema*, listed on the conference's own schedule
  (https://graphql.org/conf/2026/schedule/) with speakers Xiao Han, Chi Chan,
  Deepak Singh, Kristina Kamendova and Anirudh Padmarao, session 20 May 2026.
  The title is on-point for this chapter and the talk's existence is confirmed
  from a primary source, but no abstract, recording, transcript or slides
  could be found, and the conference wrap-up post does not mention it.
  **Nothing from this talk is used.** Worth re-checking when a recording
  surfaces; it may be the missing item 4.

- **The Apollo blog's Netflix retrospective is not usable as narrative.** *An
  Unexpected Journey: How Netflix Transitioned to a Federated Supergraph*
  (https://www.apollographql.com/blog/an-unexpected-journey-how-netflix-transitioned-to-a-federated-supergraph,
  10 July 2024) is written by Apollo marketing staff about a customer. It
  quotes Bruce Wang, a named Netflix engineer, which would pass the rule for
  that quote alone, but the quote adds nothing the Shikhare post does not say
  first and better. Not used.

## Numbers this chapter prints, and where each comes from

Recorded because the `number` check traces every printed decimal back to this
folder, and because a count with no procedure behind it is not a measurement.
None of these was measured here; each is quoted from the source named.

| Number | Where it appears | Source |
|--------|------------------|--------|
| dozens of merge requests a day | the coordination problem | Ernst, Booking.com, 2022 |
| nearly 1,000 gateway instances | what federation costs to run | Ernst, Booking.com, 2022 |
| more than 12 domains | one service at scale | Singh, Zalando, 2021 |
| more than 80% of Web, 50% of App use cases | one service at scale | Singh, Zalando, 2021 |
| four requirements | what a subgraph must implement | Apollo subgraph specification |
| three bottlenecks | Netflix's single-team graph | Shikhare, Netflix, 2020 |

No timing appears anywhere in this chapter, per SPEC decision 19. Two sources
above discuss latency; neither figure was carried across.
