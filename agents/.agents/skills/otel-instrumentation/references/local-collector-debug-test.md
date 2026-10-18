# Local OTel Collector for Migration Verification

Running a local OTel Collector during migration lets you verify that spans are being
produced and structured correctly without sending data to a remote backend. Useful for
the early phases of migration (SDK init, middleware, context propagation) where you just
need to confirm telemetry is flowing.

The collector runs via Docker with a small config that receives OTLP, prints spans to
stdout with the `debug` exporter, and writes them to NDJSON files with the `file` exporter
(both available in the `otel/opentelemetry-collector-contrib` image).

## Starting the Collector

Save this as `local-collector-config.yaml`:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  file/traces:
    path: /data/otelcol-spans.ndjson
  file/logs:
    path: /data/otelcol-logs.ndjson
  file/metrics:
    path: /data/otelcol-metrics.ndjson

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [debug, file/traces]
    logs:
      receivers: [otlp]
      exporters: [debug, file/logs]
    metrics:
      receivers: [otlp]
      exporters: [debug, file/metrics]
```

Then start the collector:

```bash
docker run --rm \
  -p 4317:4317 -p 4318:4318 \
  -v "$(pwd)/local-collector-config.yaml:/etc/otelcol/config.yaml:ro" \
  -v "$(pwd):/data" \
  otel/opentelemetry-collector-contrib:latest \
  --config /etc/otelcol/config.yaml
```

No auth headers are required. Spans are printed to stdout and written to
`./otelcol-spans.ndjson` (logs and metrics go to `./otelcol-logs.ndjson` and
`./otelcol-metrics.ndjson`).

To forward to a real backend as well, add an `otlp` exporter to the `exporters` section
(with your OTLP endpoint and the auth headers your backend requires) and list it in the
pipelines alongside `debug`.

The collector listens on `localhost:4317` (gRPC) and `localhost:4318` (HTTP). Point your
SDK at either:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318  # HTTP
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317  # gRPC
```

## Reading the Debug Output

The `debug` exporter prints a human-readable block for each span to stdout as it arrives.
Key fields to check during migration:

```
ResourceSpans #0
Resource attributes:
     -> service.name: Str(my-service)        ← confirms SDK is setting service name
ScopeSpans #0
Span #0
    Trace ID       : 0af7651916cd43dd8448eb211c80319c
    Parent ID      : b7ad6b7169203331          ← non-empty = span is connected to a parent
    ID             : c5e2f3a1b4d67890
    Name           : GET /api/orders
    Kind           : Server
    Start time     : ...
    End time       : ...
    Status code    : Ok
Attributes:
     -> http.method: Str(GET)
     -> http.route:  Str(/api/orders)
     -> http.status_code: Int(200)
```

**What to look for:**

| Field | What it tells you |
| :--- | :--- |
| `service.name` present | SDK resource is configured correctly |
| `Parent ID` non-empty | Context is propagating; span is connected to a parent |
| `Parent ID` empty | Span is a root — expected for entry points, a bug for internal spans |
| `http.route` present | Framework middleware is installed and working |
| `Status code: Error` | `span.SetStatus` is being called on error paths |

## Reading the NDJSON Log File

Each line in `otelcol-spans.ndjson` is one batch of spans serialised as OTLP JSON. To
inspect individual spans, use `jq`:

```bash
# Pretty-print all spans
jq . otelcol-spans.ndjson

# List all span names received
jq -r '.resourceSpans[].scopeSpans[].spans[].name' otelcol-spans.ndjson

# Check for disconnected spans (missing parentSpanId)
jq '.resourceSpans[].scopeSpans[].spans[] | select(.parentSpanId == null or .parentSpanId == "") | .name' \
  otelcol-spans.ndjson

# List all attribute keys seen across all spans
jq -r '.resourceSpans[].scopeSpans[].spans[].attributes[].key' otelcol-spans.ndjson | sort -u
```

## Stopping the Collector

`Ctrl+C` — with `--rm`, Docker stops and removes the container. The NDJSON files are kept
so you can inspect them after shutdown.
