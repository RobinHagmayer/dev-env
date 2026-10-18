# SDK Setup by Language

Complete OpenTelemetry SDK setup instructions for each language, configured to send
traces to your observability backend over OTLP.

## Environment Variables (All Languages)

### Required

```bash
export OTEL_SERVICE_NAME="your-service-name"
export OTEL_EXPORTER_OTLP_ENDPOINT="<your OTLP endpoint>"
export OTEL_EXPORTER_OTLP_HEADERS="<auth headers required by your backend>"
```

### Optional (Recommended)

```bash
# Protocol selection (default: http/protobuf)
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"  # or "grpc"

# Signal-specific endpoints (override base endpoint)
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="<your OTLP traces endpoint>"
export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT="<your OTLP metrics endpoint>"
```

### For Metrics (Preferred)

Prefer modern OTLP metrics and native datapoints. If metrics need different credentials
than traces, set them separately:

```bash
export OTEL_EXPORTER_OTLP_METRICS_HEADERS="<auth headers required by your backend>"
```

### Authentication Pitfall

The auth headers in `OTEL_EXPORTER_OTLP_HEADERS` are **required** for many backends to
accept OTLP data. Without them, such backends **silently reject** requests — no error is
returned, data simply never appears.

A common mistake: the app has an API key in `.env` but never sets
`OTEL_EXPORTER_OTLP_HEADERS`. The OTel SDK does NOT automatically read
vendor-specific API key variables — you must either:

1. Set `OTEL_EXPORTER_OTLP_HEADERS="<auth headers required by your backend>"` explicitly,
   **or**
2. Pass headers programmatically when constructing exporters:
   ```typescript
   const headers = { "<header-name>": process.env.YOUR_BACKEND_API_KEY };
   new OTLPTraceExporter({ headers });
   new OTLPMetricExporter({ headers });
   ```

Also ensure `.env` is loaded (e.g., `import "dotenv/config"`) **before** the OTel SDK
initializes. In ESM/TypeScript, all imports resolve before module body code runs, so
`dotenv.config()` in the main file may execute too late.

## Go

### Dependencies
```bash
go get go.opentelemetry.io/otel \
       go.opentelemetry.io/otel/sdk/trace \
       go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp
```

### Auto-instrumentation libraries
```bash
go get go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp
go get go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc
```

### Notes
- Use `otelhttp.NewHandler()` to wrap HTTP handlers
- Use `otelgrpc.UnaryServerInterceptor()` for gRPC
- SDK reads env vars automatically

## Python

See `references/python.md` for the
full Python guide: package catalogue, ASGI programmatic setup, async SQLAlchemy,
middleware enrichment, and resource attributes.

### Quick start (WSGI apps only — Flask, Django)
```bash
pip install opentelemetry-sdk opentelemetry-exporter-otlp-proto-http \
            opentelemetry-distro
opentelemetry-instrument python app.py
```

**For ASGI apps (FastAPI, Starlette, NiceGUI) always use programmatic setup** — the
CLI runner doesn't integrate cleanly with ASGI lifespans. See the Python guide above.

## Node.js

### Dependencies
```bash
npm install @opentelemetry/sdk-node \
            @opentelemetry/exporter-trace-otlp-http \
            @opentelemetry/auto-instrumentations-node
```

### Setup (tracing.js — require before app)
```javascript
const { NodeSDK } = require("@opentelemetry/sdk-node");
const { OTLPTraceExporter } = require("@opentelemetry/exporter-trace-otlp-http");
const { getNodeAutoInstrumentations } = require("@opentelemetry/auto-instrumentations-node");

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter(),
  instrumentations: [getNodeAutoInstrumentations()],
});
sdk.start();
```

### Run
```bash
node --require ./tracing.js app.js
```

## Java

### Java Agent (recommended — zero code changes)
```bash
# Download agent jar
curl -L -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

# Run with agent
java -javaagent:opentelemetry-javaagent.jar \
     -Dotel.exporter.otlp.endpoint=<your OTLP endpoint> \
     -Dotel.exporter.otlp.headers=<auth headers required by your backend> \
     -Dotel.service.name=your-service \
     -jar your-app.jar
```

### Notes
- Java agent auto-instruments most frameworks (Spring, Servlet, JDBC, etc.)
- No code changes required for basic tracing
- Add custom spans via OTel API for business logic

## Ruby

### Dependencies
```ruby
# Gemfile
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
```

### Setup
```ruby
require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "your-service"
  c.use_all  # auto-instrument all supported libraries
end
```

## .NET

### Dependencies
```bash
dotnet add package OpenTelemetry.Extensions.Hosting
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.Http
```

### Setup (Program.cs)
```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddOtlpExporter());
```

## Rust

### Dependencies (Cargo.toml)
```toml
[dependencies]
opentelemetry = "0.32"
# reqwest-rustls is not optional — without it there's no TLS backend, and exports
# to https:// endpoints fail silently. See Notes below.
opentelemetry-otlp = { version = "0.32", default-features = false, features = ["http-proto", "reqwest-blocking-client", "reqwest-rustls"] }
opentelemetry_sdk = "0.32"
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
tracing-opentelemetry = "0.33"
```
Verify current versions with `cargo add` — this crate family moves fast and pins go stale.

### Setup
```rust
use opentelemetry::trace::TracerProvider as _;
use opentelemetry_sdk::trace::SdkTracerProvider;
use opentelemetry_sdk::Resource;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;
use tracing_subscriber::EnvFilter;

fn init_telemetry(service_name: &str) -> Option<SdkTracerProvider> {
    let provider = opentelemetry_otlp::SpanExporter::builder()
        .with_http() // reads OTEL_EXPORTER_OTLP_ENDPOINT / _HEADERS / _PROTOCOL from env
        .build()
        .ok()
        .map(|exporter| {
            let resource = Resource::builder().with_service_name(service_name.to_string()).build();
            SdkTracerProvider::builder().with_batch_exporter(exporter).with_resource(resource).build()
        });

    let otel_layer = provider.as_ref().map(|p| tracing_opentelemetry::layer().with_tracer(p.tracer(service_name.to_string())));

    tracing_subscriber::registry()
        .with(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .with(otel_layer)
        // Don't skip this: batch-exporter failures (TLS, network, auth) log via
        // tracing::error!, and with no fmt layer they vanish with no trace at all.
        .with(tracing_subscriber::fmt::layer().with_writer(std::io::stderr))
        .init();

    provider
}
// Flush before exit: if let Some(p) = provider { let _ = p.shutdown(); }
```

### Notes
- Rust uses OTLP exporter directly; no auto-instrumentation, all spans are manual
- Prefer the `tracing` crate with `tracing-opentelemetry` for ergonomic instrumentation
  (`#[tracing::instrument]`, `tracing::info_span!`) over calling `opentelemetry::trace::Tracer` directly
- **Tokio apps:** the plain `with_batch_exporter()` runs its export loop on a dedicated
  OS thread, not a tokio task. Pairing it with the exporter's default async-reqwest client
  panics at runtime ("no reactor running") because that thread has no tokio reactor. Use
  the `reqwest-blocking-client` feature shown above, or if you need to stay on async
  reqwest, use `opentelemetry_sdk`'s `rt-tokio` feature with
  `span_processor_with_async_runtime::BatchSpanProcessor` instead.
- **Silent export failures:** the SDK reports export errors (TLS, network, auth) via
  `tracing::error!`, not panics. With no `fmt` (or other output) layer in the subscriber,
  those errors vanish and the process exits 0 having sent nothing. Keep a `fmt` layer
  wired up, at least during setup.
- The local collector setup below runs over plain `http://`, so it proves span
  structure/wiring but not that TLS export to a real `https://` endpoint works — do one
  live check against your backend (or an `https://` collector) before calling it done.
- Verify locally with the collector setup below before pointing at your backend.

## Testing Locally

Before pointing your SDK at your backend, verify that spans are being produced and
structured correctly using a local OTel Collector. Point your SDK at the local
collector instead of your backend:

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
export OTEL_SERVICE_NAME="your-service"
# No OTEL_EXPORTER_OTLP_HEADERS needed — the local collector has no auth
```

Then start the collector (Docker command and config in the reference below).

Spans appear in the debug output (stdout) and are written to `./otelcol-spans.ndjson`,
`./otelcol-logs.ndjson`, and `./otelcol-metrics.ndjson` on the host.

For full setup instructions and `jq` commands for inspecting the NDJSON output, see
`references/local-collector-debug-test.md`.
