# OpenTelemetry Collector Configuration

The OTel Collector receives, processes, and exports telemetry data. Use it between your
application and your observability backend for format conversion, processing, sampling,
and routing.

## When to Use a Collector

- Converting from other formats (Zipkin, Jaeger, OpenTracing) to OTLP
- Adding common attributes across all services (e.g., deployment info)
- Tail sampling at the infrastructure level
- Routing to multiple backends

## Basic Configuration

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: "0.0.0.0:4317"
      http:
        endpoint: "0.0.0.0:4318"

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024

exporters:
  otlp/backend:
    endpoint: "<your OTLP endpoint>"
    headers:
      # <auth headers required by your backend>
      <auth-header-name>: "${env:BACKEND_API_KEY}"

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/backend]
```

## Adding Attributes via Processor

Tag all spans with deployment info:

```yaml
processors:
  attributes:
    actions:
      - key: deployment.environment
        value: "production"
        action: upsert
```

## Tail Sampling Configuration

Sample based on trace characteristics (requires seeing complete traces):

```yaml
processors:
  tail_sampling:
    decision_wait: 10s
    num_traces: 100000
    policies:
      # Always keep error traces
      - name: errors
        type: status_code
        status_code:
          status_codes: [ERROR]
      # Always keep slow traces
      - name: slow-traces
        type: latency
        latency:
          threshold_ms: 5000
      # Sample 10% of everything else
      - name: probabilistic
        type: probabilistic
        probabilistic:
          sampling_percentage: 10
```

The Collector's `tail_sampling` processor buffers spans until `decision_wait` expires, so
all spans of a trace must reach the same Collector instance for decisions to be correct.
Size `num_traces` and memory for your traffic.

## Converting from Other Formats

### Zipkin to OTLP
```yaml
receivers:
  zipkin:
    endpoint: "0.0.0.0:9411"
```

### Jaeger to OTLP
```yaml
receivers:
  jaeger:
    protocols:
      grpc:
        endpoint: "0.0.0.0:14250"
      thrift_http:
        endpoint: "0.0.0.0:14268"
```
