# Reading-flow repair ledger

Base: `origin/main` at `55949caabc1ced4ef98d72e8dc9a7c3107aab527`.
Work branch: `draft/splitting-the-graph-ch01-17-reading-flow`.
Scope approved: chapters 1-17, preface, appendices A-E. Chapters 18-20,
shared tooling, released artifacts and the pinned runtime are out of scope.

## Severity rubric

- Critical: unsafe or unusable central design with no local recovery. None found.
- High: a false mental model or missing state transition breaks a core lesson or build-along.
- Medium: a misleading explanation, missing evidence or unmarked assumption forces backtracking.
- Low: local imprecision or a reading interruption with an obvious recovery.

The 68 stable identifiers below preserve the review's 18 high, 42 medium and
8 low findings. All 68 are fixed and checked against the acceptance targets.
The two cold audits' 22 residual findings are resolved in
`reading-flow-validation.md`; their fixes propagate the original repairs.
Prose-only claims use source inspection; executable claims use fresh captures
in the isolated verifier. Historical counts are not used as fresh-run evidence.

| ID | Severity | Location | Reason / acceptance target | Status |
|---|---|---|---|---|
| H01 | High | 4.5 | Output nullability is confused with input compatibility; teaches a false breaking-change rule. | Fixed |
| H02 | High | 4.4 | Arguments are called positional; this gives readers the wrong GraphQL call model. | Fixed |
| H03 | High | 3.3 | Router HTTP batching and database N+1 are conflated. | Fixed |
| H04 | High | 5.4 | Global node and shareable are presented as universal capabilities; Ratings cannot implement them. | Fixed |
| H05 | High | 5.3 | A pure reference stub advertises resolvability without a resolver. | Fixed |
| H06 | High | 5.3 | The entity/value-type distinction incorrectly forbids shared value types. | Fixed |
| H07 | High | 5.2 | Composition and runtime checks are assigned guarantees they do not provide. | Fixed |
| H08 | High | 5.4 | An unordered override deployment can route to an unavailable resolver. | Fixed |
| H09 | High | 9.3 | The reduced Speaker record leaves incompatible seed and EF code behind. | Fixed |
| H10 | High | 4.5 | Mutation and non-null experiments leave an undocumented next-chapter state. | Fixed |
| H11 | High | 10.4 | The second loader experiment relies on restoring the first loader without saying so. | Fixed |
| H12 | High | 11 end | The hand-written loader is not the canonical state expected by chapter 12. | Fixed |
| H13 | High | 12.2 | Authorization experiments silently retain a root guard while claiming no directives. | Fixed |
| H14 | High | 15.4-5 | False-pass experiments refer to an ambiguous previous configuration. | Fixed |
| H15 | High | 14.2 | Two observed null blast radii are stated as the only possible outcomes. | Fixed |
| H16 | High | 11.4 | Database row count is confused with the positional entity response contract. | Fixed |
| H17 | High | 7.4-5 | Unnamed graph variants make it unclear which subgraphs are composed. | Fixed |
| H18 | High | A-E | Required reference destinations are placeholders; readers cannot finish setup or recover source. | Fixed |
| M01 | Medium | 4.1 | Versionless evolution is presented as forbidding retirement. | Fixed |
| M02 | Medium | 1.2 | A shared schema is equated with a single deployment unit. | Fixed |
| M03 | Medium | 5.4;17.2 | Routing permission is confused with fresh business-owner approval. | Fixed |
| M04 | Medium | 2 summary | Schema construction is called compile-time instead of startup. | Fixed |
| M05 | Medium | 3.1 | Two DbContext registration APIs are not distinguished. | Fixed |
| M06 | Medium | 3.5 | Paging is introduced without showing how to request the next page. | Fixed |
| M07 | Medium | 4.4 | The claimed generic error fallback is absent from the operation. | Fixed |
| M08 | Medium | 4.4 | Top-level errors are incorrectly said to be unbranchable. | Fixed |
| M09 | Medium | 4.3-4 | Different HTTP error statuses lack operation and coercion context. | Fixed |
| M10 | Medium | 4.3;6.4 | Node projection SQL examples do not identify their operations consistently. | Fixed |
| M11 | Medium | 6.4 | Decoding the identifier is falsely blamed for missing projection. | Fixed |
| M12 | Medium | 6.1-3 | Export is requested before the required reference resolver exists. | Fixed |
| M13 | Medium | 7.3 | SDL includes a directive before the code that adds it. | Fixed |
| M14 | Medium | 7.4 | Single-subgraph composition is said to have nothing to check. | Fixed |
| M15 | Medium | 8.2 | Compose and router commands use different working directories without a transition. | Fixed |
| M16 | Medium | 8.2;summary | No network and no extra cost claims omit their scope. | Fixed |
| M17 | Medium | 9.4 | The displayed plan and response do not share explicit paging arguments. | Fixed |
| M18 | Medium | 9.4;10.2 | Entity positions and unique wire representations are counted as the same thing. | Fixed |
| M19 | Medium | 9.5 | The zero-score example violates the stated rating domain and misdescribes missing keys. | Fixed |
| M20 | Medium | 9.5 | Parent dependency metadata is described as changing the CLR parameter type. | Fixed |
| M21 | Medium | 10.2 | A SQL trace alone is treated as proof of router deduplication. | Fixed |
| M22 | Medium | 10.2 | Evidence relies on an unprinted private wire capture. | Fixed |
| M23 | Medium | 10.4-5 | Entity type, destination and selected field switch without explanation. | Fixed |
| M24 | Medium | 11.3 | An alias batching comparison omits the defining query. | Fixed |
| M25 | Medium | 11.4 | An unordered remote batch is said to require a hand-written loader. | Fixed |
| M26 | Medium | 12.1 | The security requirement changes from private list to private email mid-chapter. | Fixed |
| M27 | Medium | 12.5 | Token forwarding is configured after the observation that depends on it. | Fixed |
| M28 | Medium | 13.2 | Fewer than first items is incorrectly treated as a pagination violation. | Fixed |
| M29 | Medium | 13.6 | A new page owner is described as reversing an unrelated seam. | Fixed |
| M30 | Medium | 14.4 | The account of earlier cost-directive composition contradicts chapter 7. | Fixed |
| M31 | Medium | 14.7 | Exported semantic-null metadata is confused with executor behavior. | Fixed |
| M32 | Medium | 15.5 | Nullability is used to explain absence of an error entry. | Fixed |
| M33 | Medium | 15.7 | Repeating identical composition is proposed as a routing regression test. | Fixed |
| M34 | Medium | 15 summary | A wrong downstream query is described as a wrong client field value. | Fixed |
| M35 | Medium | 16.1 | The number and identity of ratingCount declarations is ambiguous. | Fixed |
| M36 | Medium | 16.4 | Structural breaking changes and traffic-based blocking policy are conflated. | Fixed |
| M37 | Medium | 16.4 | A text diff is described as if it classifies compatibility changes. | Fixed |
| M38 | Medium | 16.4 | Local checks are said to be incapable of catching old-client failures. | Fixed |
| M39 | Medium | 16.5 | The root-field advice appears to contradict the discovery root introduced in chapter 13. | Fixed |
| M40 | Medium | 17 summary | Adding a public field and rerouting an existing field are both called schema-neutral. | Fixed |
| M41 | Medium | 17.4 | Duplicated ownership is condemned without distinguishing a derived Search projection. | Fixed |
| M42 | Medium | 1.4-5;7.5 | Research-process apologies interrupt the reader's argument. | Fixed |
| L01 | Low | Preface | A placeholder gives no audience, prerequisites or reading route. | Fixed |
| L02 | Low | 1.4 | Absence of blocked independent teams is treated as proof of one team. | Fixed |
| L03 | Low | 4.4 | No null in data contradicts the null session in the shown payload. | Fixed |
| L04 | Low | 6.1 | No SDL file conflates generated artifacts with authoritative source. | Fixed |
| L05 | Low | 7.3 | Proto and JSON key names are called identical despite case conversion. | Fixed |
| L06 | Low | 10.1 | The stated work multiplier uses inconsistent request-count denominators. | Fixed |
| L07 | Low | 15.2 | The heading counts six routes while the chapter now lists eight. | Fixed |
| L08 | Low | 17.5 | A redundant exception corrects an already qualified earlier claim. | Fixed |

## Verification and provenance

The private verifier is cloned under this worktree's ignored book `build/`
directory. Historical tags remain unchanged. Appendix E must be generated
from the verified canonical chapter-17 source, including all four services;
it must not expose the verifier's existence or paths to readers. Compatibility
material is an isolated Hot Chocolate 14 baseline, not a four-service port.

Official sources and version disagreements are recorded separately in
`reading-flow-sources.md`. The current documentation is not a license to
upgrade the pinned example or rewrite an observed response.

## Closure evidence

| Evidence group | Issue coverage | Result |
| --- | --- | --- |
| Official versioned contracts | H01-H08, H15-H16; M01-M05, M08-M09, M11-M14, M19-M20, M25-M26, M28-M31, M35-M41; L02, L04-L05 | Normative sources and pinned/current disagreements in reading-flow-sources.md; corrected claims propagated into summaries and figures. |
| Fresh request and state probes | H09-H14, H17; M06-M07, M10, M15-M18, M21-M24, M27, M32-M34; L03, L06-L07 | Original-seed paging, mutation, orphan, request-wire, alias, auth and false-pass captures in reading-flow-empirical.md; restoration instructions audited end to end. |
| Reader destinations and voice | H18, M29, M39, M42, L01, L08 | Preface/A-E complete; both independent audits report no actionable voice drift; scope remains through chapter 17. |
| Whole-book gates | All 68 | Fresh canonical PASS607, HC14 PASS216, false-pass PASS32; exact full-source comparisons; full LuaLaTeX and prose gate pass; PDF and index inspected. |

The historical checker has one expected comment delta, not an unexplained
listing mismatch. The explicit corrected-source fixture is hashed and compared
in full; validation records both the original result and the final 27-mapping
fixture-aware pass. No shared gate, historical tag or original verifier changed.
