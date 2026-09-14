# Reading-flow repair validation

## Empirical gates

Fresh 2026-09-14 runs, not historical counts: canonical chapter 17 passes
607 assertions; HC14 passes 216; the false-pass variant passes 32. The healthy
service builds report zero warnings and errors. Exact source comparisons pass
27 historical mappings (one explicit corrected-comment fixture), 11 supplemental
chapter listings, 63 canonical appendix files and 18 compatibility appendix
files. See `reading-flow-empirical.md` for tags, hashes, commands and captures.

## Manuscript gates

Full LuaLaTeX, no includeonly: 352 physical pages after the cold-audit fixes.
The successful build followed `latexmk -C` and subsequent corrected rebuilds;
no engine, font, package, shared gate or policy relaxation was used.
The prose gate resolves:

```
chars=Ascii(captured:minted:text) cite=autocite(tie,keys) quotes=on index=on+forbid dashes=on contractions=english spelling=en-US+variants numbers=research/*.md verbatim=minted:text,minted:json json=minted:json listings=73+alias gloss=off figures=7 reserved keys+node text log=0/0
```

It passed after the layout fixes. A further index check found four rejected
directive entries and one unmatched range; these were corrected. Makeindex
then accepted 1144 entries, rejected 0 and emitted 0 warnings. No policy changed.

Visual inspection used the installed Poppler renderer. Physical pages 269-326
cover every new appendix page, including normal blank verso pages. Pages 11-12
cover the preface. Additional inspected physical pages: 45-50, 83-84, 89,
103-104, 139, 158-159, 163, 176-177, 192-193, 233-234, 237, 247. The final one
is figure 16.2; brackets and labels do not collide. Physical page numbers are
printed body pages plus 12; the preface uses roman numbers. The first-page
SQL lead-in in section 3.5 was clarified during the visual reading.

## Cold audit

Two independent read-only contexts cover contiguous manuscript slices:
chapters 01-09 with preface/A, and chapters 10-17 with B-E. No drafting history
or rationale is in either brief. All 22 report entries were independently
checked by the main editor and accepted. No finding was rejected. These are
residuals and propagation failures within the repair, not 22 unrelated new
features. The following table records the final resolution of every entry.

| Audit ID | Severity | Location / finding | Resolution and evidence |
| --- | --- | --- | --- |
| F01 | Medium | 4.5 default page cannot return four titles | Printed first:10; fresh ch04-orphan probe returns all four. |
| F02 | Medium | 4 summary says top-level errors cannot be branched on | Summary now distinguishes extension codes from schema-declared payload types; also propagates the field-retirement correction. |
| F03 | Medium | 5.7 reference-only stub still advertises resolution | Added resolvable:false, matching 5.3 and the exact ch09 stub. |
| F04 | Medium | 6.6 says every service exports nodes | Limited to Sessions/Speakers; also limited PageInfo to services with paging and separated shared definitions from page values. |
| F05 | Medium | 9.8 claims unmeasured one-node-owner runtime result | Kept measured composition pass; explicitly states runtime was not tested, matching SPEC 136. |
| F06 | Medium | 3.5 variables precede their first explanation | Explains variable declaration, dollar-sign use, Nitro editors and the query/variables HTTP envelope before the two-page walk. |
| F07 | High | 4.5 seed edit never reaches SQLite | Reset before the request and rebuild; fresh orphan probe confirms path index 3, null list and expected CS8603. |
| F08 | High | 8.3 introspects a stopped service | Restarts Sessions before direct introspection and live queries. |
| F09 | High | 9.3 restarts before obsolete loader is removed | Moved reset/rebuild after resolver replacement and loader deletion; complete source mappings pass. |
| F10 | High | 9.4 failure request still skips execution | Explicitly removes both plan headers before stopping Speakers and sending the live request. |
| F11 | Medium | 9.5 third service has no export/start/config reload | Added exact cwd-scoped export, start, compose and router-restart commands. |
| F12 | High | 9.8 expects Speakers after leaving it stopped | Restarts it at the close of the earlier outage exercise. |
| F13 | Medium | A reset runs stale executable | Changed reset command to dotnet run, which builds changed seed/model source. |
| F14 | Low | 6 reorder leaves wrong union/next-section references | Uses the local union subsection and the named measurement section. |
| C01 | Medium | 14.4 and E comment denies permissive nullability merge | Corrected canonical source comment and both exact printed copies; fresh ch17 PASS607 and explicit fixture hash. |
| C02 | Medium | 14 advice/summary universalizes list blast radius | Scoped both to sessions.nodes:[Session!] and restated nearest nullable ancestor, including sessionById counterexample. |
| C03 | Medium | 11 summary says remote storage forces manual loader | Propagates the keyed-dictionary adapter explanation from 11.4. |
| C04 | Medium | 12 responses use the verifier's mutated schedule | Fresh noforward/routeronly captures on original seeds; both complete JSON bodies match the corrected print. |
| C05 | Medium | 15 control fails to restore Speakers document | Restores original export before root-order controls and again before composing the served false-pass variant. |
| C06 | Medium | 16 still claims local suites/control-plane limits categorically | Current-schema assertions, retained client corpus and operation coverage are distinguished in 16.1 and 16.5. |
| C07 | Medium | 17 prose/caption/figure implies fresh owner approval | All three now specify initially unmarked declarations and distinguish an existing sharing permission from approval. |
| C08 | Medium | 10 middleware and 15 YAML are forbidden partial listings | Prints the complete measured Program.cs with highlighted addition; describes the single YAML scalar change in reproducible prose. |

The original historical listing script reports one deliberate four-comment-line
delta in Speakers/NullableNodesField.cs; its other 26 mappings pass. The ignored
check-historical-with-fixtures.ps1 is a copy with one explicit source-file
mapping and a required blob hash, not a comment-stripping exception. It passes
all 27. The unchanged original script, its result and the fixture-aware result
are retained. No shared gate or original verifier was changed.

The final PDF was re-rendered after the audit fixes. Additional inspected
physical pages: 49-50, 63-65, 137-138, 159-161, 189-191, 255, 271 and 297.
Figure 17.1 has separated labels and brackets; the complete temporary middleware
listing spans two pages without clipping and its changed lines stay highlighted.
The final prose gate has zero overfull boxes and zero undefined references;
makeindex still accepts 1144 entries with zero rejections and warnings.
The final comment-only wire-listing rebuild was inspected on physical pages
46-48, 144-145, 159-160, 192-196 and 302. Its reader-facing wording changes
no request handling. The two-page pagination walkthrough and both recaptured
authorization responses remain within the page measure.

## Retro proposals, not implemented

- Add an opt-in shared log check for actual makeindex rejected entries and
  unmatched ranges. The source index check did not catch all five problems.
  A future change needs tests, a default-off policy setting and an explicit
  book SPEC rule; this session changes none of the shared tooling.
- Keep book-specific state transitions explicit: altered source, altered seed,
  composed input and router configuration are four different restoration
  obligations. This lesson is recorded in the book, not in a shared skill.
