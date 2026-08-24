# Chapter 8 - Enter the Router

Research note for the chapter that starts the Cosmo Router for the first time:
what it loads, what it serves, what it refuses to do without, and what a query
plan looks like over a graph with one subgraph in it.

Web sources accessed **2026-08-24**; everything else was measured on this
machine on the same date.

Two things are worth stating before any of it.

**The router is the first component in this book that is not ours and not a
build tool.** `wgc` runs, writes a file and exits, so chapter 7 could treat it
as a compiler. The router is a long-running server that sits in front of the
service the reader wrote, and everything it does to a request is a thing the
reader can no longer see by reading their own code. That is why this chapter
spends its length on what the router says at startup and on the query plan,
rather than on configuration surface.

**Nothing here needed a Cosmo Cloud account, and the router's default is that
it does.** Started with no arguments the router gets as far as opening a
listener and then refuses, because its default source for an execution config
is WunderGraph's CDN. Every measurement below is on the local path, and the
open item the SPEC carried about the router being read but not run is closed by
this note.

## The machine, and how to reproduce any of this

| Thing | Value |
|-------|-------|
| Verification repo | `F:/repo/splitting-the-graph-graph` |
| .NET SDK | 10.0.303 |
| Hot Chocolate on `main` | 16.6.1, on `net10.0` |
| Hot Chocolate on `hc14` | 14.3.1, on `net8.0` |
| `wgc` (Cosmo CLI) | 0.129.9, installed globally through npm |
| **Cosmo Router** | **0.341.0**, the released Windows binary |
| Node | 24.15.0 |
| Gate | `pwsh verify.ps1`, run on each tag below. All PASS 2026-08-24 |

| Tag | Branch | What it is | Assertions |
|-----|--------|-----------|------------|
| `ch08` | `main` | the finished chapter: `router/config.yaml` with `dev_mode`, the router serving the one subgraph | 241 |
| `ch08-noplan` | `ch08-noplan` | the same config without `dev_mode`. The graph serves and the query plan header is ignored in silence | 12 |
| `ch08-hc14` | `hc14` | the same router over the 14 graph | 214 |

**No new package, and no new dependency in any `.csproj`.** Chapter 8 adds a
binary that runs beside the service, not a library inside it. The Sessions
subgraph is byte-identical to the one chapter 7 left: `git diff ch07..ch08`
over `src/` is empty, which makes `ch08` the book's second tag on an unchanged
tree after `ch05` (SPEC decision 66).

### The router version, now verified by running it

Chapter 7 recorded 0.341.0 from the GitHub release list and a GHCR manifest and
said plainly that nothing had run it. It has now been run.

Still the newest stable on 2026-08-24. From
`https://api.github.com/repos/wundergraph/cosmo/releases?per_page=100`, filtered
to tags beginning `router@`:

| Release | Published |
|---|---|
| `router@0.341.0` | 2026-08-18T12:27:11Z |
| `router@0.340.0` | 2026-08-13T14:58:17Z |
| `router@0.339.0` | 2026-08-12T13:07:48Z |

Reproduce with:

```
curl -s "https://api.github.com/repos/wundergraph/cosmo/releases?per_page=100" \
  | jq -r '.[] | select(.tag_name|startswith("router@")) | .tag_name'
```

**The release ships standalone binaries, not only a container image.** Fourteen
assets on `router@0.341.0`: `darwin-amd64`, `darwin-arm64`, `linux-386`,
`linux-amd64`, `linux-arm64`, `windows-386` and `windows-amd64`, each with a
`.md5` beside it. This matters to the book, because SPEC decision 23 fixed an
example with no container in it, and a router chapter that opened with
`docker run` would have contradicted it. Docker was not used anywhere in this
chapter; the Docker daemon was in fact not running on this machine while every
measurement below was taken.

Downloaded `router-router@0.341.0-windows-amd64.zip`, 39,445,970 bytes. Its
published md5 is `43ce903c40d88c7a352fc7db8017f027` and the downloaded file
hashes to the same, checked with `md5sum`. The archive holds exactly two
files: `router.exe`, 93,034,496 bytes, and `LICENSE`.

`router.exe -version`:

```
Router:
  Version: 0.341.0
  Go version: go1.26.6
  OS: windows
  Arch: amd64
  Built: 2026-08-18T12:27:33Z
  VCS Revision: e7b12b1beac4cde7f80cca8b12fdd250ef50cc63
  Dependencies:
    github.com/wundergraph/astjson v1.1.0
    github.com/wundergraph/graphql-go-tools/v2 v2.16.0
```

The build timestamp is 22 seconds after the release's own `published_at`, which
is consistent with the release being cut by the build.

**License, checked in the artifact rather than in a repository.** The `LICENSE`
inside the downloaded zip is the Apache License 2.0, first lines
`Apache License / Version 2.0, January 2004`. This is a better check than the
repository root, because it is the license shipped with the binary the reader
would run. It is kept in the verification repo at `tools/router-LICENSE.txt`.

Cross-checked against `https://raw.githubusercontent.com/apollographql/router/dev/LICENSE`
(fetched 2026-08-24): Apollo's router carries `Elastic License 2.0`. SPEC
decision 7's license contrast therefore still holds, now with both halves read
off the licenses themselves.

### `router.exe -help`, in full

Five flags, and only one of them matters to this chapter:

```
  -config value
    	Path to the router config file e.g. config.yaml, in case the path is a comma separated file list e.g. "config.yaml,override.yaml", the configs will be merged
  -cpuprofile string
    	Path to write cpu profile. CPU is measured from when the program starts until the program exits
  -help
    	Prints the help message
  -memprofile string
    	Path to write memory profile. Memory is a snapshot taken at the time the program exits
  -override-env string
    	Path to .env file to override environment variables
  -pprof-addr string
    	Address to listen for pprof requests. e.g. :6060 for localhost:6060
  -version
    	Prints the version and dependency information
```

Worth noticing what is absent: there is no flag for the execution config, no
flag for the port, and no flag for the subgraph. Everything the router knows is
in the config file or in the environment.

### Where the planner actually lives

The chapter says the planner, the normalizer and the introspection answerer are
in `graphql-go-tools` rather than in the router. Established from the binary
itself, which is the artifact rather than a claim about it:

```
grep -aoh "graphql-go-tools/v2/pkg/[a-z/]*" router.exe | sort -u
```

returns, among others, `engine/plan`, `astnormalization`,
`engine/datasource/introspection`, `engine/datasource/graphql`,
`engine/datasource/httpclient`, `astparser`, `astprinter` and
`engine/postprocess`. Those three are what the chapter names and each maps onto
something it observes: the query plan, the rewriting of literal arguments into
variables, and introspection being planned against a pseudo-subgraph.

**Not established**: which package produces
`Failed to fetch from Subgraph 'sessions'.`
`engine/datasource/graphql` and `engine/datasource/httpclient` are the
plausible homes and neither was confirmed, so the chapter attributes that
message to the router and to no library.

## The failure the chapter opens on

Run the binary with no arguments, in an empty directory. It does not fail
early. It reads its defaults, warns about the machine, opens a metrics listener,
announces a playground, and only then refuses:

```
INFO  Config file watching is disabled, you can still trigger reloads by sending SIGHUP to the router process
WARN  GOMEMLIMIT was not set. Please set it manually to around 90% of the available memory to prevent OOM kills  { error="failed to set GOMEMLIMIT: cgroups is not supported on this system" }
WARN  No graph token provided. The following Cosmo Cloud features are disabled. Not recommended for Production.  { features=["Schema Usage Tracking","Persistent operations","Advanced Request Tracing","Cosmo Cloud Tracing","Cosmo Cloud Metrics"] }
WARN  Net poller is only available on Linux and MacOS. Falling back to less efficient connection handling method.  { error="epoll/kqueue is not supported on this system" }
INFO  Prometheus metrics enabled  { listen_addr="127.0.0.1:8088", endpoint="/metrics" }
INFO  Serving GraphQL playground  { url="http://localhost:3002/" }
ERROR  Could not start router  { error="router start error: failed to start router: failed to bootstrap router: graph token is required to fetch execution config from CDN. Alternatively, configure a custom storage provider or specify a static execution config" }
```

The raw lines are newline-delimited JSON, one object per line, with
`hostname`, `pid`, `service` and `service_version` on every one of them. The
block above is the same lines with those four fields removed, which is how the
chapter prints them; the untouched form is in
`scratchpad`-captured `bare/raw.log` and reproduced by running the binary in an
empty directory.

Four facts fall out of that block and all four are load-bearing for the chapter:

1. **The default source of an execution config is WunderGraph's CDN**, and a
   graph token is what fetches it. Running the router with nothing is running a
   cloud client.
2. **The error names the alternative**: "specify a static execution config".
   The local path is a documented mode, not a workaround.
3. **The default address is `localhost:3002`**, announced before the failure.
4. **Prometheus metrics are on by default**, on a second listener at
   `127.0.0.1:8088/metrics`. Nobody asked for that, and it is the third time in
   this book a library has written something into a public surface without being
   asked (chapters 6 and 7 are the other two).

Five Cosmo Cloud features are named as disabled. **Advanced Request Tracing is
one of them**, and that is the one that costs this chapter something; see the
query plan section.

## Two files and a port

### What the router actually needs

Measured four ways. All four serve the same graph; the differences are what the
reader has to type.

| What was supplied | Starts and serves? |
|---|---|
| `EXECUTION_CONFIG_FILE_PATH=router.json`, no config file at all | yes |
| `config.yaml` with `execution_config.file.path`, no `version` key | yes |
| `config.yaml` with `version: "1"` and the same | yes |
| `ROUTER_CONFIG_PATH=router.json`, no config file | yes |

So `config.yaml` is **optional**: one environment variable is enough. The book
prints a `config.yaml` anyway, because SPEC decision 15 puts files on the page
and a file is a thing a reader can type once and keep, where an environment
variable is a thing they retype per shell.

`ROUTER_CONFIG_PATH` is an older field that still works. Both it and
`EXECUTION_CONFIG_FILE_PATH` are present in the router's source at
`router@0.341.0`
(`https://raw.githubusercontent.com/wundergraph/cosmo/router%400.341.0/router/pkg/config/config.go`,
fetched 2026-08-24). **Which of the two is current and which is legacy was not
established**, and the chapter therefore names only `execution_config.file.path`,
which is the structured form and the one the config schema documents. See
"Checked and not established".

### The config file is validated against a published JSON schema

This is the find of the section, and it is the exact opposite of what chapter 7
found one file up.

Put an unknown key in `config.yaml` and the router refuses to start, naming the
schema it validated against:

```
Could not load config: errors while loading config files: router config validation error for cfg.yaml: jsonschema validation failed with 'https://raw.githubusercontent.com/wundergraph/cosmo/main/router/pkg/config/config.schema.json#'
- at '': additional properties 'not_a_real_key' not allowed
```

Reproduced twice, once with a bogus key at the top level and once nested under
`execution_config.file`; both refuse. Note that this message is **not** JSON and
carries no `level` field: it is printed by Go's standard logger before the
structured logger is configured, which is why it looks unlike every other line
the router emits.

Two consequences the chapter uses:

- A typo in `config.yaml` is caught at startup rather than ignored, so a key
  that is silently doing nothing is not a failure mode here.
- `version: "1"` is a **real key**, not something the router tolerates. It
  passes a validator that rejects `not_a_real_key`, so it is in the schema.

The contrast worth printing: the file the composer writes has no published
schema at all and is defined only by a protobuf in the source tree (chapter 7),
while the file the reader writes by hand has a published JSON schema that the
router validates against and names by URL when it fails.

### The path is resolved against the working directory

Measured, because it decides what the chapter tells the reader to type. With
`path: ../graph/router.json` in `router/config.yaml`:

| Started from | Command | Result |
|---|---|---|
| `router/` | `router -config config.yaml` | serves |
| the repo root | `router -config router/config.yaml` | does not start |

So the relative path is resolved against the **current working directory**, not
against the location of `config.yaml`. Same file, same contents, two outcomes.

### The port, settled

**The router listens on `localhost:3002`, which is its own default, and this
book leaves it there.** SPEC decision 44 pinned the three services at 5001,
5002 and 5003 in their own `launchSettings.json` and left the router's port to
this chapter.

The reason to take the default rather than pin one: 5001 to 5003 had to be
pinned because `dotnet new web` picks a random port, so a book printing raw
HTTP under decision 34 would otherwise print fiction. The router has no such
problem. It prints its address in its own startup log, the same number every
time, on every machine. A `listen_addr` line in `config.yaml` would be a line
that can drift out of step with the log beside it and buys nothing.

Confirmed on every run in this note: `listen_addr: localhost:3002` in the
startup log, and `Serving GraphQL playground { url="http://localhost:3002/" }`.
GraphQL is served at `/graphql`; the playground is at `/`.

### The startup log with the config in place

Run from `router/` with the shipped `config.yaml`. With `dev_mode: true` the
router **switches its log format** from newline-delimited JSON to a
human-readable console format with ANSI colour, which is itself worth a
sentence: the format of the log is a function of a setting nobody set for that
purpose.

Fields trimmed for width; the four constant ones are on every line as before.

```
INFO  Config file watching is disabled, you can still trigger reloads by sending SIGHUP to the router process
INFO  Config file provided. Values in the config file have higher priority than environment variables  { config_file=["config.yaml"] }
WARN  No graph token provided. The following Cosmo Cloud features are disabled. Not recommended for Production.  { features=["Schema Usage Tracking","Persistent operations","Cosmo Cloud Tracing","Cosmo Cloud Metrics"] }
WARN  Development mode enabled. This should only be used for testing purposes
WARN  Net poller is only available on Linux and MacOS. Falling back to less efficient connection handling method.
INFO  Prometheus metrics enabled  { listen_addr="127.0.0.1:8088", endpoint="/metrics" }
INFO  Serving GraphQL playground  { url="http://localhost:3002/" }
WARN  Advanced Request Tracing (ART) is enabled in development mode but requires a graph token to work in production. For more information see https://cosmo-docs.wundergraph.com/router/advanced-request-tracing-art
INFO  Server initialized and ready to serve requests  { listen_addr="localhost:3002", playground=true, introspection=true, config_version="00000000-0000-0000-0000-000000000000" }
INFO  Static execution config provided. Polling and watching is disabled. Updating execution config is only possible by restarting the router
INFO  Router started  { component="supervisor" }
```

Three things in that block the chapter uses:

1. **The disabled-features list is now four, not five.** Advanced Request
   Tracing has left it, and a new WARN says why: ART is enabled because dev mode
   is on. The router documents the exact mechanism the query plan section below
   depends on, in its own log, without being asked.
2. **`config_version` is the nil uuid**, thirty-two zeroes. Chapter 7 read a
   `version` field of exactly that shape out of `router.json` and said it had
   not seen what a config fetched from the platform carries there. This is where
   that field surfaces: the router reads it back and logs it as the version of
   the graph it is serving.
3. **"Polling and watching is disabled."** Handed a static execution config, the
   router stops being a cloud client entirely. The corollary is in the same
   sentence: updating it means restarting the router.

### The router starts with the subgraph stopped

Measured. With nothing listening on 5001, the router reaches
`Router started` exactly as above, and answers introspection.

This is the same fact chapter 7 established about the composer, one layer down,
and the chapter says so: composition reads files and never calls a service, and
the router loads a file and does not call a service either. Neither of the two
things standing between a client and the data checks that the data is there.

## What the router serves, against what the subgraph serves

Both introspected on the same run, router on 3002, Sessions on 5001.

**Type counts: the router exposes 21 named types, the subgraph 24**, counting
only types whose names do not begin with `__`. Introspection's own types are
excluded on both sides; `verify.ps1` filters them and the chapter says it does.

The three the router does not expose are exactly:

```
_Any
_Entity
_Service
```

**Query fields: the router exposes 3, the subgraph 5** asking without
`includeDeprecated`, and **4 against 6** asking with it, because chapter 4
deprecated `sessionById` and introspection hides deprecated fields by default.
The chapter prints both pairs and `verify.ps1` asserts both. The difference is
the same two fields either way:

```
_entities
_service
```

So the federation route is invisible through the front door and fully open on
5001, where `{ _service { sdl } }` still answers with the whole subgraph
document, `@link` header and all. This is chapter 12's subject arriving early,
and chapter 8 states the fact and leaves the consequence to that chapter.

Full type list the router exposes, sorted:

```
Boolean, DateTime, Error, FieldSet, Float, ID, Int, Mutation, Node, PageInfo,
Query, RescheduleSessionError, RescheduleSessionInput,
RescheduleSessionPayload, Session, SessionNotFoundError, SessionsConnection,
SessionsEdge, Speaker, SpeakerDoubleBookedError, String
```

**`FieldSet` is in that list**, which confirms chapter 7's reading of
`graphqlSchema` from the other side. That chapter found `scalar FieldSet`
surviving into the client schema with nothing referring to it and called it a
generated document's untidiness. It is not only in the file: it is served, and a
client introspecting the router gets it. `{ __type(name:"FieldSet"){ name kind } }`
answers `{"name":"FieldSet","kind":"SCALAR"}` through the router.

### The subtraction runs one way only, and the exception is a built-in scalar

Found on the `hc14` branch, where the first form of the assertion failed. The
router serves a `Float` that the subgraph does not.

| | Named types | Scalars |
|---|---|---|
| Sessions on `hc14`, direct | 23 | Boolean, DateTime, FieldSet, ID, Int, String, `_Any` |
| The router over it | 21 | Boolean, DateTime, FieldSet, **Float**, ID, Int, String |

`Float` appears in neither the composed client schema nor the `serviceSdl`
inside `router.json`, checked by reading both out of the file, so it is not the
composer adding it. GraphQL defines five built-in scalars and the router serves
all five; Hot Chocolate 14.3.1 leaves `Float` out of a schema with no
floating-point field in it, and 16.6.1 keeps it, which is why the difference
shows on one branch and not the other.

So the chapter's claim is about the types the graph declares rather than about
every name an introspection result contains, and `verify.ps1` asserts it that
way: the router hides exactly `_Any`, `_Entity` and `_Service`, and adds
nothing but a built-in scalar. **Which of 14 and 16 is right about emitting an
unused built-in was not established** and no chapter says.

**Deprecation survives the router intact.** Asking with
`includeDeprecated: true` the router returns four Query fields, and
`sessionById` carries chapter 4's reason word for word:

```
Ask for `node(id:)` instead. This field takes the database key, which is only
unique among sessions.
```

## The query plan

### Getting one at all

The header is `X-WG-Include-Query-Plan: true`, and on a router started without
`dev_mode` **it does nothing at all**. No plan, no error, no warning: the
response is byte-identical to one sent without the header. Measured, because
the silence is the trap.

The reason is in the startup log quoted above. The query plan is an Advanced
Request Tracing option; ART is one of the five features disabled without a
graph token; and `dev_mode: true` re-enables it locally. The router says so
itself once dev mode is on.

There is a third route, which this book does not take and names only here:
`ENGINE_FORCE_UNAUTHENTICATED_REQUEST_TRACING`, whose own description in the
config schema begins "UNSAFE - DO NOT ENABLE IN PRODUCTION. Bypasses the
authorization gate for Advanced Request Tracing (ART) when dev_mode is false."
(The dash in that string is an em dash in the original; it is transcribed here
as a hyphen and the chapter does not quote it.)

A second header pairs with the first: `X-WG-Skip-Loader: true` returns the plan
and does not execute it. **The response body carries `"data": null`** alongside
`extensions.queryPlan`, measured, and `verify.ps1` asserts both halves. The
router's own playground sends the two headers together, plus
`X-WG-DISABLE-TRACING`, which is how they were found.

### The startup log with no `dev_mode`, for comparison

The chapter prints two startup logs and they differ, so both are recorded.
Captured from the `ch08-noplan` config, which is the one section 8.2 prints:

```
INFO  Config file watching is disabled, you can still trigger reloads by sending SIGHUP to the router process
INFO  Config file provided. Values in the config file have higher priority than environment variables
      config_file=["config.yaml"]
WARN  GOMEMLIMIT was not set. Please set it manually to around 90% of the available memory to prevent OOM kills
      error="failed to set GOMEMLIMIT: cgroups is not supported on this system"
WARN  No graph token provided. The following Cosmo Cloud features are disabled. Not recommended for Production.
      features=["Schema Usage Tracking","Persistent operations","Advanced Request Tracing","Cosmo Cloud Tracing","Cosmo Cloud Metrics"]
WARN  Net poller is only available on Linux and MacOS. Falling back to less efficient connection handling method.
      error="epoll/kqueue is not supported on this system"
INFO  Prometheus metrics enabled
      listen_addr="127.0.0.1:8088" endpoint="/metrics"
INFO  Serving GraphQL playground
      url="http://localhost:3002/"
INFO  Server initialized and ready to serve requests
      listen_addr="localhost:3002" playground=true introspection=true config_version="00000000-0000-0000-0000-000000000000"
INFO  Static execution config provided. Polling and watching is disabled. Updating execution config is only possible by restarting the router
INFO  Router started
      component="supervisor"
```

**Five disabled features here, and `Advanced Request Tracing` is among them.**
With `dev_mode: true` the list drops to four, ART leaves it, and two WARN lines
appear that are in neither of the other two logs. Six of these lines also
appear in the bare-run log above; four do not.

Every log block the chapter prints is these lines with exactly four fields
removed, `hostname`, `pid`, `service` and `service_version`, and everything
else indented under its message. Nothing else is changed and nothing is
dropped. Reproduce the transformation with the script at
`scratchpad/router/capture2.sh`.

One thing that transformation does **not** survive: with `dev_mode` on the
router switches to a coloured console format carrying a timestamp and a source
file and line, so the two ART lines the chapter prints are shown in the trimmed
JSON style rather than in the format they actually arrive in. The chapter says
so at the point it prints them.

### The plan for a single literal argument, verbatim

Recorded because the chapter prints the body and not only the prefix that
`verify.ps1` asserts. For `{ node(id:"U3BlYWtlcjox"){ __typename } }`:

```
query($a: ID!){
    node(id: $a){
        __typename
    }
}
```

and `normalizedQuery` beside it is `query($a: ID!){node(id: $a){__typename}}`.

### The plan, over a graph of one

For `{ sessions { nodes { id title speaker { name } } } }`:

```json
{
  "version": "1",
  "kind": "Sequence",
  "children": [
    {
      "kind": "Single",
      "fetch": {
        "kind": "Single",
        "subgraphName": "sessions",
        "subgraphId": "0",
        "fetchId": 0,
        "query": "{\n    sessions {\n        nodes {\n            id\n            title\n            speaker {\n                name\n            }\n        }\n    }\n}"
      }
    }
  ],
  "normalizedQuery": "{sessions {nodes {id title speaker {name}}}}"
}
```

A `Sequence` with one child, a `Single` fetch, against the one subgraph there
is. `subgraphName` is the name from `graph.yaml`, and `subgraphId` is `"0"`,
which is the generated id chapter 7 read out of the `subgraphs` list in
`router.json`.

**Every plan on this graph has that shape.** Measured four more:

| Operation | Plan |
|---|---|
| two root fields at once, `sessions` and `node(id:)` | Sequence, one Single, one fetch |
| the mutation `rescheduleSession` | Sequence, one Single, one fetch |
| the deprecated `sessionById` | Sequence, one Single, one fetch |
| `{ __schema { queryType { name } } }` | Sequence, one Single, **no `query` at all** |

The introspection row is the interesting one. Its fetch names a subgraph that
does not exist:

```json
"subgraphName": "introspection__schema&__type",
"subgraphId": "introspection__schema&__type",
"fetchId": 0
```

and carries no `query` key. The router answers introspection out of the schema
in its own execution config and never asks the subgraph, which is the mechanism
behind the measurement above that introspection still answers with the subgraph
stopped.

### The router rewrites the operation before it forwards it

Not looked for; found while reading the plans. Send a literal argument:

```
{ sessions { nodes { title } } node(id:"U3BlYWtlcjox"){ __typename } }
```

and the `query` in the plan is:

```
query($a: ID!){
    sessions {
        nodes {
            title
        }
    }
    node(id: $a){
        __typename
    }
}
```

The inline argument has been lifted into a variable named `$a`. The mutation
does the same thing to its `input:` object, and `sessionById(id: 1)` becomes
`query($a: Int!)`. So what the subgraph receives is not what the client sent,
and `normalizedQuery` beside it is the router's record of the operation it
actually planned.

This is the router's normalization, and the chapter states it as a fact about
what the subgraph sees rather than drawing a conclusion from it. **What it costs
or buys was not established** and no claim is made either way.

### The plan is free

Counted with chapter 3's `StatementLog`, which prints one numbered marker per
statement the service sends to SQLite.

| Request | Statements |
|---|---|
| `{ sessions { nodes { id title speaker { name } } } }` direct to 5001 | 2 |
| the same through the router on 3002 | 2 |
| the same through the router with `X-WG-Skip-Loader: true` | 0 |

Two things at once. **The router costs this graph nothing**: the same query is
the same two statements whether it goes through the router or straight at the
service, which is what a plan with one fetch in it means. And planning does not
touch the database, so a plan can be read without paying for the query. Chapter
10 is where the first number changes.

The responses through the router and direct to the subgraph are byte-identical
for this query, checked by eye on the same run and asserted in `verify.ps1`.

## What happens when the subgraph is not there

Router up, Sessions stopped (`curl` to 5001 exits 7, connection refused).

```
HTTP/1.1 200 OK
Cache-Control: no-store, no-cache, must-revalidate
Content-Length: 93
Content-Type: application/json; charset=utf-8
Vary: Accept-Encoding

{"errors":[{"message":"Failed to fetch from Subgraph 'sessions'."}],"data":{"sessions":null}}
```

Four facts:

1. **HTTP 200.** A subgraph that is not running produces a successful HTTP
   response. Anything watching status codes sees nothing wrong.
2. **The error names the subgraph and nothing else.** No url, no status, no
   cause. It says which of your services failed and not why, which is chapter
   18's problem stated in one line.
3. **`data.sessions` is null rather than `data` being null.** The field is
   nullable, so the failure stopped there. Chapter 14 is what happens when it is
   not.
4. **`Cache-Control: no-store, no-cache, must-revalidate` appears on the error
   response.** Not on the successful one, which carried no `Cache-Control` at
   all.

And the router still reports itself healthy:

| Endpoint | With the subgraph stopped |
|---|---|
| `GET /health` | `200 OK`, body `OK` |
| `GET /health/ready` | `200 OK`, body `OK` |

`/health/live` is the third path the router's config defines
(`LivenessCheckPath`, default `/health/live`) and was not exercised.

A health check that passes while the graph cannot answer a query is worth one
sentence in this chapter and belongs to chapter 20. It is not a bug: the router
is up. It is the difference between the router being up and the graph working,
which is the thing this chapter exists to make visible.

## The federation gateway audit

The SPEC carried an open item: a public benchmark puts Cosmo Router behind two
alternatives on Apollo Federation compatibility, recorded because SPEC decision
7 chose Cosmo on license and version coverage and never on an audit score, and
unblocked by running the audit here. It has now been run. **No chapter prints
a number from it**, and the reasons are below.

### What was run

The audit is `graphql-hive/federation-gateway-audit`, cloned at commit
`7956ca1cabd08e02b1baee91e17457ee0847d784`, "Add Fusion Gateway (#353)", dated
2026-07-14. It is a Node harness: one in-process server hosts both the test
subgraphs and a per-suite endpoint of expected query and response pairs, and
each gateway under test gets a directory with a script that composes those
subgraphs and starts the gateway. It tests Apollo Federation conformance only.
No performance testing is in this repository.

**Measured here: 194 of 199 test cases, 43 of 46 suites**, for Cosmo Router
0.341.0. The five failures are in three suites: `complex-entity-call` (1),
`provides-on-interface` (2) and `provides-on-union` (2). A sample failure
returns `data: null` with no errors where nested entity data was expected, so
these are planning or execution gaps rather than harness noise.

**The audit publishes 183 of 199, 37 of 46, for Cosmo Router.** The measured
number is better than the published one by eleven test cases.

### Why no chapter prints either number

Four reasons, and any one of them would be enough.

1. **The harness had to be modified to run 0.341.0 at all.** Its
   `gateways/cosmo-router/install.sh` pins router **0.321.2** and downloads a
   Linux binary; its committed `config.yaml` uses the older `router_config_path`
   field and starts the binary with no flags, relying on a router that
   auto-loads `./config.yaml`. Router 0.341.0 does neither: with no `-config`
   and no graph token it fails with the same CDN error this chapter opens on.
   Running it needed a rewritten config in the current schema, an explicit
   `-config`, a wrapper script to invoke the Windows binary, the harness's
   readiness timeout raised from 5 to 60 seconds, and the Prometheus port moved.
   That is a lot of changed variables between the published number and this one.
2. **The controlled comparison was not possible here.** The published number was
   produced against 0.321.2, whose binary is Linux-only, and this machine has no
   Docker and no WSL. So the version difference is the best-evidenced
   explanation for the gap and it is an inference, not a diff. The test set is
   identical, 199 cases and 46 suites either way, and no other variable was
   deliberately changed.
3. **The audit's own repository disagrees with itself.** Every committed
   per-gateway `results.txt` at this commit is from an older 189-case run:
   Cosmo's says 180 of 189, Apollo Router's says 185 of 189. The README and
   `REPORT.md` tables are from a 199-case run whose per-gateway results were
   never committed. And `gateways/hot-chocolate-fusion/results.txt` exists at
   this commit showing 199 of 199, while Fusion appears in neither the README
   nor `website/data.json`; the live site at
   `https://the-guild.dev/graphql/hive/federation-gateway-audit`, fetched
   2026-08-24, does list it at 100 percent. So the committed numbers, the
   committed per-gateway results and the live site are three different states.
4. **The maintainer competes in its own table.** `package.json` names The Guild
   as author, at `the-guild.dev`, and the audit lives in the `graphql-hive`
   GitHub organization. The Guild ships Hive Router and Hive Gateway, which
   occupy first and second place in the ranking, at 100 and 98.99 percent. That
   is not evidence of anything wrong with the harness, which is open and
   readable, and it is exactly the situation the book's Sources rule exists for:
   a vendor publishing a result about competitors.

**One coincidence worth recording so nobody re-derives it.** The measured
figure, 194 of 199 and 43 of 46, is numerically identical to the audit's
published Apollo Router row. It is a coincidence rather than a mix-up: Apollo's
committed results fail `keys-mashup` and `requires-with-argument`, which are
different suites from the three Cosmo failed here.

### What this changes

Nothing in decision 7, which chose Cosmo on license and on spanning both Hot
Chocolate versions, and never on a conformance score. The measured number is
better than the published one rather than worse, so the concern that prompted
the open item does not survive its own investigation. Chapter 8's scope is the
router running locally, and a conformance score that needs four paragraphs of
caveats to be honest is not something to put in it.

**One thing here is useful to the chapter and is used.** The audit's committed
`config.yaml` uses `router_config_path` with no `-config` flag, and 0.341.0
will not start that way. That is direct evidence about the
`ROUTER_CONFIG_PATH` versus `EXECUTION_CONFIG_FILE_PATH` question below: the
older field was the current one when the harness was written, both still work,
and what actually changed is that the router no longer auto-loads a bare
`config.yaml`. The chapter states neither, and names only
`execution_config.file.path`.

Reproduce with, from the cloned audit:

```
GATEWAY_TIMEOUT=60000 npm start -- test --cwd ./gateways/cosmo-router \
  --run-script ./run.sh --reporter dot \
  --graphql http://127.0.0.1:4000/graphql \
  --healthcheck http://127.0.0.1:4000/health/ready
```

## Checked and found false

- **"The router needs a `config.yaml`."** It does not. One environment
  variable, `EXECUTION_CONFIG_FILE_PATH`, starts and serves the same graph with
  no file at all. The book prints a file for the reader's sake, not the
  router's.
- **"`version: "1"` in `config.yaml` is decorative."** It is a schema key. The
  router validates the file and rejects an unknown property, so a key that
  survives validation is a key the schema declares.
- **"A relative path in `config.yaml` is relative to `config.yaml`."** It is
  relative to the working directory. The same file starts the router from
  `router/` and fails from the repo root.
- **"The query plan header works out of the box."** Without `dev_mode` it is
  ignored silently. The first two attempts in this session got a correct
  response with no `extensions` key and no indication that anything had been
  refused.
- **"A failing subgraph produces a non-200 response."** HTTP 200, with the
  error in the GraphQL envelope.
- **"The router needs Docker."** The release ships binaries for seven
  platform-architecture pairs. Every measurement in this note was taken with the
  Docker daemon not running.

## Checked and not established

- **Whether `ROUTER_CONFIG_PATH` or `EXECUTION_CONFIG_FILE_PATH` is the current
  field and which is legacy.** Both exist in `router/pkg/config/config.go` at
  tag `router@0.341.0` and both work on this machine. No fetched page reconciles
  them. The chapter names only the structured `execution_config.file.path` form
  and makes no claim about the other.
- **What a config fetched from Cosmo Cloud carries in `config_version`.** Still
  open from chapter 7. This chapter adds only that the local path logs the nil
  uuid it read out of the file.
- **What the router's normalization costs or buys.** It rewrites literal
  arguments into variables before forwarding. Whether that is for the subgraph's
  plan cache, the router's own, or something else was not established, and no
  chapter claims a reason.
- **Whether a semver-tagged GHCR image exists for 0.341.0.** Chapter 7's note
  recorded that the GHCR manifest for that tag answers 200. Not re-checked here,
  because this chapter does not use the image.
- **`/health/live`.** Defined in the router's config with that default and not
  exercised.
- **Whether the two Prometheus listeners can be turned off**, and what a
  federated subgraph should expose. Chapter 20's territory.
