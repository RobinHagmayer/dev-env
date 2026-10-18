# Verification Checklist

After completing each migration phase, verify that instrumentation is correct and complete.
Silent failures are the norm in OTel migration — code compiles and runs correctly, but traces
are disconnected, attributes are missing, or telemetry is dropped. Always verify with your
tracing backend. If you do not have a backend set up yet or want to verify locally before
sending data upstream, run a local OTel Collector and inspect its debug output and NDJSON log
file — see the local collector debug/test reference in the **otel-instrumentation** skill for setup and `jq` inspection commands.

## 1. Traces Exist and Are Connected

Query your tracing backend for your service name. Check that:

- Spans have `parent_id` fields (not all root spans)
- Trace waterfall view shows a tree structure, not a flat list of disconnected spans
- The span count per trace is reasonable (not all single-span traces)

**Example question:** For `service.name = "your-service"`, how many spans have a parent span ID
versus no parent span ID (count spans, grouped by whether a parent exists)?

If most spans lack a `parent_id`, context isn't propagating from your entry points to
downstream operations.

## 2. Trace Structure Matches Expectations

For a typical web request, you should see a connected tree:

```
HTTP GET /api/endpoint (from framework middleware)
  +-- business logic span (your custom span)
       +-- database query span (your storage span)
```

If you see this instead:

```
HTTP GET /api/endpoint
database query span    (no parent -- disconnected!)
```

Context isn't propagating from the HTTP handler to the database layer. Common causes:
- Using the wrong context accessor for your framework (see framework-middleware.md)
- Not passing context through function calls (Go)
- Thread pool context loss (Java, Python, Ruby)
- Callback-based code breaking async context chain (Node.js)

## 3. Attributes Are Present

Click into a span and verify:

- **Auto-instrumented attributes** are present: `http.method`, `http.route`,
  `http.status_code`, `url.path`
- **Custom attributes** you added appear with correct values
- **Semantic convention** attributes use standard names (not custom variants of standard fields)

**Example question:** For `service.name = "your-service"`, how many spans are there per
`http.route`?

If `http.route` is empty or missing, the framework middleware may not be installed correctly.

## 4. Span Status Is Set Correctly

Verify that error spans have `span.status = ERROR`:

**Example question:** How many spans for `service.name = "your-service"` have an error status
(status code `ERROR`)?

(`status_code = 2` is `ERROR` in OTel). If errors occur but no spans have error status,
check that your code calls `span.SetStatus(codes.Error, message)` (Go) or equivalent.

## 5. Metrics Are Arriving

If using a Prometheus bridge or OTel metrics:

- Check that metric names appear in your backend
- Verify metric values are reasonable (counters increase, gauges have expected ranges)
- If using the Prometheus bridge, Prometheus metric names may appear with `_total` suffixes
  stripped or with `_` to `.` conversion depending on your backend's metric naming rules

Depending on your backend, Prometheus metrics may land in a default or catch-all location if
metric routing is not configured. Check both your service's metrics and any default or
"unknown" metrics location your backend uses.

## 6. Logs Are Correlated

If using a logging bridge:

- Check that log events include `trace_id` and `span_id` fields
- Verify you can navigate from a log event to its parent trace
- Check that log severity levels map correctly (e.g., `slog.Error` → `SEVERITY_NUMBER >= 17`)

**Example question:** For `service.name = "your-service"`, how many log records have a trace ID,
grouped by severity (`SeverityText`)?

If the trace ID is missing from logs, the logging bridge is either not installed or the
log statement is executing outside of a span context.

## 7. Shutdown Is Clean

Send SIGTERM to your process and check that a final batch of telemetry arrives:

- A few final spans should appear with timestamps near the shutdown time
- If telemetry is missing from the last few seconds before shutdown, the shutdown timeout
  may be too short or shutdown is not being called

Test this explicitly:
1. Start your service
2. Make a few requests
3. Send SIGTERM
4. Wait 15-30 seconds
5. Check your backend for spans from the last few seconds before shutdown

## Phase-Specific Verification

### After Phase 1 (SDK Init)

- [ ] Telemetry data appears in your backend with the correct service name
- [ ] Application starts and runs normally even if the OTel endpoint is unreachable
- [ ] Process shutdown flushes pending telemetry

### After Phase 2 (Middleware)

- [ ] Every HTTP request produces a span automatically
- [ ] HTTP spans have standard attributes (method, route, status code)
- [ ] No orphaned root spans from HTTP requests

### After Phase 3 (Context Propagation)

- [ ] Trace waterfall shows connected parent-child spans (not flat/disconnected)
- [ ] Database/cache/external HTTP calls appear as child spans of the request
- [ ] Background goroutines/threads produce correctly parented spans

### After Phase 4 (Custom Spans)

- [ ] Business logic operations appear as spans in traces
- [ ] Custom attributes are present and correctly typed
- [ ] Span names are descriptive and follow naming conventions

### After Phase 5 (Logging)

- [ ] Log records include trace_id and span_id
- [ ] Logs appear in both local output (stderr/file) and OTel backend
- [ ] Log severity levels map correctly

### After Phase 6 (Metrics Bridge)

- [ ] Existing metric names appear in your backend
- [ ] Metric values are reasonable and updating
- [ ] Both Prometheus scraping (if kept) and OTLP export work simultaneously
