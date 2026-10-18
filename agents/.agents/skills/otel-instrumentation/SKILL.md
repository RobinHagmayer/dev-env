---
name: otel-instrumentation
description: >
  OpenTelemetry SDK setup, custom instrumentation, and exporting data over OTLP. Trigger
  phrases: "instrument my app", "add tracing", "set up OpenTelemetry", "configure OTel",
  "add custom spans", "add attributes to spans", "send traces over OTLP", "set up OTLP",
  "configure sampling", "add span events", "add span links", "set up tracing for [any
  language]", "configure the OTel Collector".
metadata:
  version: "1.0.0"
---

# OpenTelemetry Instrumentation

SDK setup, custom spans, attributes, span events, sampling, and layered telemetry.
For conceptual foundations (why wide events matter, how attributes connect to
investigation), see the **observability-fundamentals** skill.

## OTLP Configuration and SDK Setup

Every OTel SDK needs these environment variables to send data to your observability backend:

### Required Environment Variables

**Base configuration:**
```bash
OTEL_SERVICE_NAME=your-service-name
OTEL_EXPORTER_OTLP_ENDPOINT=<your OTLP endpoint>
OTEL_EXPORTER_OTLP_HEADERS="<auth headers required by your backend>"
```

**Optional but recommended:**
```bash
# Protocol selection (default: http/protobuf)
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf  # or grpc

# Signal-specific endpoints (override base endpoint for specific signals)
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=<your OTLP traces endpoint>
OTEL_EXPORTER_OTLP_METRICS_ENDPOINT=<your OTLP metrics endpoint>
```

**For metrics (preferred):** Use modern OTLP metrics and native datapoints. If metrics
need different credentials than traces, set them separately:
```bash
OTEL_EXPORTER_OTLP_METRICS_HEADERS="<auth headers required by your backend>"
```

### Protocol Selection

`OTEL_EXPORTER_OTLP_PROTOCOL` determines the wire format and transport:
- `http/protobuf` (default, recommended) — HTTP with protobuf encoding
- `grpc` — gRPC with protobuf encoding
- `http/json` — HTTP with JSON encoding (larger payload, slower)

Use `http/protobuf` unless you have specific infrastructure requirements for gRPC.

### Signal-Specific Endpoints

By default, OTel SDKs append `/v1/traces` and `/v1/metrics` to `OTEL_EXPORTER_OTLP_ENDPOINT`.
Use signal-specific endpoint vars to override:
- `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` — full URL for traces (including `/v1/traces`)
- `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` — full URL for metrics (including `/v1/metrics`)

Useful when routing signals to different backends or using non-standard endpoints.

### Common Pitfalls

**Silent auth failure:** Many backends silently reject OTLP requests that are missing or
have misconfigured auth headers — no error, no data. Set
`OTEL_EXPORTER_OTLP_HEADERS="<auth headers required by your backend>"` or pass headers
programmatically. If loading the key from `.env`, ensure dotenv runs before SDK init.

**Metrics:** Prefer modern OTLP metrics and native datapoints.

For the env var values, language-specific dependencies, and setup code (Go, Python,
Node.js, Java, Ruby, .NET, Rust), see
`references/sdk-setup-by-language.md`.

## Custom Instrumentation

### Adding Attributes to Existing Spans (Highest Impact)

Add business context to auto-instrumented spans — no new spans needed. Get the current
span from context and call `SetAttributes` (Go), `set_attribute` (Python), or
`setAttribute` (Node.js) with user, tenant, business, and deployment context.

### Creating Custom Spans

Wrap important business operations for visibility in the trace waterfall. Use
`tracer.Start(ctx, "operation-name")` (Go), `tracer.start_as_current_span("operation-name")`
(Python), or `tracer.startActiveSpan("operation-name", callback)` (Node.js).

For full code examples in all languages, consult
`references/custom-instrumentation.md`.

## When to Create a Span

Not every function needs a span. Two questions determine whether a span is worth creating:

1. **Is it interesting?** — Does the work meaningfully impact performance (latency or
   failures) for the overall request?
2. **Is it aggregable?** — If you group this span by name and attributes, will it produce
   useful trends and comparisons?

| Operation | Interesting? | Aggregable? | Create a Span? |
| :--- | :--- | :--- | :--- |
| HTTP request handler | Yes — variable latency, can fail | Yes — group by route, method, status | **Yes** |
| Database query | Yes — I/O bound, failure-prone | Yes — group by query type, table | **Yes** |
| External API call | Yes — network latency, dependencies | Yes — group by endpoint, status | **Yes** |
| Cache lookup | Yes — fast vs slow path | Yes — group by cache name, hit/miss | **Yes** |
| Message queue pub/consume | Yes — async boundary, delays | Yes — group by queue, message type | **Yes** |
| Business logic transaction | Yes — meaningful state change | Yes — group by type, outcome | **Yes** |
| Private helper function | No — trivial CPU, predictable | No — too granular | **No** |
| Loop iteration | Maybe — if slow | No — unbounded cardinality | **No** |
| Getter/setter | No — no meaningful duration | No — nothing to group by | **No** |
| Input validation (pure CPU) | No — fast, predictable | Maybe | **No** |
| Business logic orchestration | No — just calls instrumented code | No — duration is sum of children | **No** |

**Common mistakes:**
- **Too many spans**: A trace with millions of 2ms spans is far too detailed and rarely
  actionable. Roll them up — combine into a single span, or capture the detail as an
  attribute on the parent span instead.
- **Too few spans**: Collapsing hours of work into a single opaque handler leaves you
  guessing about where time is spent.
- **Test spans left in**: Spans named `test-span`, `debug-span`, or similar are
  artefacts that pollute your data. Remove any span created solely to verify tracing
  is working before finishing.

When in doubt, prefer **attributes on existing spans** over creating new child spans.

#### Timing Attributes (measure sub-operations without child spans)

Record important sub-operation durations as attributes on the parent span. These are
easier to query than child spans and can be compared directly across outlier and baseline
requests.

```go
// Go: time auth and record on the existing span
span := trace.SpanFromContext(r.Context())
authStart := time.Now()
user, err := authenticate(r)
span.SetAttributes(attribute.Float64("auth.duration_ms", float64(time.Since(authStart).Milliseconds())))
```

```python
# Python: time auth and record on the existing span
span = trace.get_current_span()
auth_start = time.monotonic()
user = authenticate(request)
span.set_attribute("auth.duration_ms", (time.monotonic() - auth_start) * 1000)
```

#### Exception telemetry: event details plus span-level dimensions

Use the Logs API for new exception events. Emit the record while the relevant span is
active and include the standard exception fields (`exception.type`, `exception.message`,
`exception.stacktrace`, and `exception.escaped` when applicable), an ERROR severity, and
`event.name="exception"`. Set the span status to ERROR separately when the operation failed.

A trace-correlated exception log carries the trace and span IDs of the active span. Its
full `exception.*` payload lives on the log record; search the exception log record, then
follow its trace ID to inspect the surrounding trace.

Use low-cardinality span attributes for aggregation and alerting:

- `error=true` and the span status indicate operation failure.
- `exception.slug` is a static, greppable identifier for the error site.
- An optional error category is safer to group by than full exception messages.

`record_exception` / `RecordError` remain compatibility APIs for existing SDKs and code,
but do not use them as the only new guidance when Logs API support is available.

Find operation failures by span dimensions: filter to `error = true` where `exception.slug`
is missing. Find Logs-API exception events by filtering to `event.name = exception` where
`exception.type` exists, and follow a sampled trace ID to the surrounding trace.

For extended examples, see
`references/custom-instrumentation.md`.

#### Optional compatibility: promote exception fields with a LogRecordProcessor

If existing span-level dashboards, alerts, or queries depend on exception fields being
present on the span itself (as produced by span-event exception recording), add a custom
**LogRecordProcessor** before the batch/export processor. When it sees an exception log,
it should use the log record's resolved context to find the active recording span and
promote a configured, minimal set of fields such as `error=true`, `error.type`,
`exception.type`, `exception.slug`, or an error category.

Do not recommend a standalone `SpanProcessor` for this: span processors receive span lifecycle
callbacks, not log records. Keep full `exception.message` and `exception.stacktrace` on the Logs
API event by default; copy them onto spans only when legacy query compatibility explicitly requires
it. The processor must run synchronously while the span context is valid, before the log reaches
batch export. It should no-op when there is no recording span and must not infer fields that the
application did not put on the log record.

This is an optional migration layer, not a replacement for querying the Logs API event. Treat
span-level promoted fields as instrumentation-dependent and continue to query
`event.name=exception` log records for full diagnostics.

## What to Instrument

### High Value (Instrument First)
- API entry points (HTTP handlers, gRPC methods)
- Database queries (auto-instrumented by most SDKs)
- External HTTP calls (auto-instrumented by most SDKs)
- Message queue producers/consumers

These are typically auto-instrumented by OTel SDKs and form the skeleton of your traces.

### Medium Value (Add Next)
- Business logic operations (checkout, payment, fulfillment)
- Cache operations (hits, misses, evictions)
- Authentication and authorization checks
- Background job execution

These are your business logic. Without custom spans here, you can see that a request was
slow but not *why* — the trace waterfall has gaps where the important work happens
invisibly.

### Attributes to Add

Attributes are the dimensions you use during investigations. Every attribute you
add is a new axis you can compare outlier and baseline requests on to find what's different
about the outliers.
For the complete catalog organized by category with rationale and example queries, see
`references/wide-event-attributes.md`.

For why attributes matter conceptually, see the **observability-fundamentals** skill.

## Span Events, Logs API Events, and Span Links

- **Point-in-time events**: Prefer the Logs API for new events, especially exceptions. Emit
  while the span is active so the record carries trace context. The event name is in
  `event.name` (and often the log body).
- **Legacy span events**: `span.add_event` / `AddEvent` remain valid compatibility paths. The
  event is stored on the span and its name is the span event's `name`.
- **Span links**: Connect spans across different trace hierarchies (async processing,
  fan-out/fan-in, cross-system correlation). Create a `Link` to the related span context.

For instrumentation examples, see `references/custom-instrumentation.md`.

## Sampling

### Sampling Strategy

Sampling is about tradeoffs — there is no free lunch:

- **Head sampling favors cost over debuggability.** You save resources, but a 0.1% error
  at 1% sampling becomes effectively invisible. Head sampling is oblivious to what
  happens downstream.
- **Tail sampling favors fidelity over simplicity.** You keep interesting traces but need
  infrastructure (such as the OpenTelemetry Collector) to buffer and evaluate complete traces.

The math matters: if an error occurs 0.1% of the time and you head-sample at 1%, you'll
capture roughly 1 in 100,000 of those errors. At moderate traffic, that error may never
appear in your data.

### Head Sampling (SDK-level)
Decides whether to sample a trace at creation time. Simple but can miss interesting traces.
- Configure via `OTEL_TRACES_SAMPLER` env var
- `always_on` (default), `always_off`, `traceidratio` (e.g., sample 10%)
- `parentbased_traceidratio` respects parent sampling decisions
- **Best for:** Very high-throughput services where you can tolerate missing rare events

### Tail Sampling (Collector)
Decides after the trace is complete. Keeps interesting traces (errors, slow requests).
- Configure the OpenTelemetry Collector's `tail_sampling` processor
- Can sample based on: latency, error status, specific attributes, trace duration
- **Best for:** Services where debuggability matters — keeps errors and outliers while
  sampling routine traffic

### Sampling Impact
- Sampling reduces data volume and cost
- Record the sampling rate (or use a backend that understands sampling probability) so
  counts and rates can be corrected for sampling
- Trace completeness may be affected — missing spans if not all services sample consistently
- Start with no sampling, then add as needed for cost management

## Layered Telemetry

OpenTelemetry is "trace-first" — context propagation is the glue that correlates all
signals. But effective observability layers multiple signal types for different purposes.

A three-question test for choosing the right signal:

1. **What needs causality and full-request context?** → Traces (spans)
2. **What needs inexpensive long-term storage and fast alerting?** → Metrics
3. **What is rare vs. common, and what are the audit requirements?** → Logs / events

**The histogram-alongside-spans pattern:** For high-throughput HTTP services, emit both a
span and a histogram metric for each handled request. This lets you head-sample traces
for cost while histograms provide last-ditch alerting — and exemplars link outlier metric
points back to specific traces for deeper investigation.

The technique is *layering* (not duplication) because each signal provides a different
view at a different level of detail.

For architectural patterns where layering is essential (streaming, async jobs, ETL), see
`references/architectural-patterns.md`.

For AWS Lambda-specific patterns — choosing between the AWS Managed OTel Layer
and manual SDK setup, forceFlush, SDK 2.x setup, cross-Lambda trace propagation,
header normalisation, TOKEN vs REQUEST authorizers — see
`references/lambda.md`.

## Logs

OTel can send logs too. If you have existing log infrastructure, the OTel Collector can
ingest logs and forward them to your observability backend as structured events:

- **OTel SDK log bridge**: Captures logs from your existing logging library (`slog` in Go,
  `logging` in Python, `winston`/`pino` in Node.js) and exports them as OTel log records.
- **OTel Collector `filelog` receiver**: Reads log files, parses them, exports as OTLP.

Logs sent through OTel arrive as structured events that can carry the same attributes and
trace context as spans.

## Naming Conventions

- **Span names**: Describe the operation (`HTTP GET /api/users`, `db.query SELECT`, `process-payment`)
- **Attribute names**: Use dot-separated namespaces (`user.id`, `order.total`, `cache.hit`)
- **Follow OTel semantic conventions** where applicable (`http.method`, `db.system`, `rpc.service`)
- **Custom attributes**: Use your own namespace (`app.`, `checkout.`, `mycompany.`)

## Additional Resources

### Reference Files
- **`references/sdk-setup-by-language.md`** — OTLP configuration and SDK setup for Go,
  Python, Node.js, Java, Ruby, .NET, Rust
- **`references/local-collector-debug-test.md`** — Run a local OTel Collector via Docker
  to verify spans, logs, and metrics locally; includes `jq` commands for inspecting NDJSON
  output
- **`references/custom-instrumentation.md`** — Custom instrumentation patterns with full
  code examples (timing attributes, exception slugs, async request summaries)
- **`references/collector-config.md`** — OTel Collector configuration for format
  conversion, processing, and sampling
- **`references/wide-event-attributes.md`** — Canonical attribute catalog organized by
  category with example queries
- **`references/architectural-patterns.md`** — Trace design patterns for streaming, async,
  ETL, and serverless architectures
- **`references/lambda.md`** — AWS Lambda: OTel Layer vs manual SDK setup trade-offs,
  forceFlush and per-request latency, SDK 2.x setup, cross-Lambda trace propagation,
  header normalisation, TOKEN vs REQUEST authorizer migration

### Cross-References
- For conceptual foundations of why wide events and attributes matter: **observability-fundamentals** skill
- After instrumenting, verify that data is arriving in your observability backend

## Attribution
Adapted from the Honeycomb agent skill of the same name; vendor-specific parts removed
because we don't use Honeycomb. See `NOTICE.md` for details and license.
