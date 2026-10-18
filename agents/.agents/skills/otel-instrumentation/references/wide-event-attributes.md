# Wide Event Attribute Catalog

**This is the canonical attribute catalog.** Other skills reference this
file rather than maintaining their own attribute lists.

Attributes to add to your spans, organized by category. Each attribute enriches your
events with context that enables outlier analysis and investigation workflows. The wider your
events, the more questions you can answer without re-deploying.

Drawn from Chapter 6 of *Observability Engineering* (2nd edition) by Charity Majors,
Liz Fong-Jones, George Miranda, and Austin Parker, with contributions from Jeremy Morrell.

## Service Metadata

Connect services to their owners and understand which team is responsible.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `service.name` | `api`, `shoppingcart` | The name of this service |
| `service.environment` | `production`, `staging` | The environment where this service is running |
| `service.team` | `web-services`, `dev-ex` | The team that owns this service — useful for knowing who to page |
| `service.slack_channel` | `#web-services` | Where to reach out if you discover an issue |

**Why it matters:** During an incident, the first question is often "who owns this?" These
attributes let you answer that from your telemetry without switching to a service catalog.

**Example question — how many services does each team run?** Count the distinct `service.name`
values where `service.environment = "production"`, grouped by `service.team`.

## Infrastructure

Understand the physical or virtual resources backing each service instance.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `instance.id` | `656993bd-40e1...` | An ID mapping to this one instance of the service |
| `instance.memory_mb` | `12336` | RAM available to this service |
| `instance.cpu_count` | `4`, `8`, `196` | Number of cores available |
| `instance.type` | `m6i.xlarge` | Vendor name for this instance type |

**Why it matters:** Correlating performance with instance resources answers questions like
"is this service under-provisioned?" or "are the larger instances actually faster?"

**Example question — which services use the most memory?** Take the max of `instance.memory_mb` grouped by `service.name` and `instance.type`, sorted descending, top 10.

## Orchestration

Capture container and cluster context so you can correlate issues with infrastructure topology.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `container.id` | `a3bf90e006b2` | Docker container ID |
| `container.name` | `nginx-proxy` | Container name used by runtime |
| `k8s.cluster.name` | `api-cluster` | Kubernetes cluster name |
| `k8s.pod.name` | `nginx-2723453542-065rx` | Kubernetes pod name |
| `cloud.availability_zone` | `us-east-1c` | AZ where the service runs |
| `cloud.region` | `us-east-1` | Region where the service runs |

**Why it matters:** Infrastructure issues often manifest per-AZ or per-node. These attributes
let you surface "all slow requests are from `us-east-1c`" by comparing outlier and baseline attribute distributions.

**Example question — request distribution across AZs:** Count requests where `service.name = "api-service"`, grouped by `cloud.availability_zone`.

## Build and Deploy

Answer "what changed?" during incidents without leaving your observability tool.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `service.version` | `v123`, `9731945...` | Version string or image hash |
| `service.build.git_hash` | `6f6466b0e693...` | Git SHA of the deployed commit |
| `service.build.deployment.age_minutes` | `1`, `10230` | How long ago this version was deployed |
| `service.build.deployment.trigger` | `merge-to-main`, `slack-bot` | What triggered this deployment |
| `service.build.deployment.user` | `keanu@company.com` | Who kicked off the build |

**Why it matters:** "Did something just get deployed?" is one of the most frequent incident
questions. With `deployment.age_minutes < 20` you can instantly find recent deploys, and
with `service.version` you can compare error rates between versions.

**Example question — what was recently deployed?** For spans where `service.build.deployment.age_minutes < 20`, take the min age grouped by `service.name`, sorted ascending, top 10.

**Example question — 500s correlated with deploy versions:** Count requests where `service.name = "api-service"`, grouped by `http.response.status_code` and `service.version`.

## Feature Flags

Correlate issues with feature rollouts by tracking which flags are active per-request.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `feature_flag.<flag_name>` | `true`, `false` | The value of a particular feature flag for this request |

Use one attribute per flag (e.g., `feature_flag.auth_v2`, `feature_flag.new_checkout_flow`).

**Why it matters:** Feature flags are a developer superpower for testing in production, but
only if you can compare performance between flag states. Comparing outlier and baseline attribute distributions can instantly show that
errors correlate with `feature_flag.auth_v2 = true`.

**Example question — errors by feature flag state:** Count requests where `service.name = "api-service"` and `error = true`, grouped by `feature_flag.auth_v2` and `exception.slug`.

## Runtime Versions

Track versions of languages, frameworks, and datastores to correlate issues with upgrades.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `go.version` | `go1.23.2` | Language runtime version |
| `rails.version` | `7.2.1.1` | Web framework version |
| `postgres.version` | `16.4` | Datastore version |

**Why it matters:** "Didn't we upgrade Go versions recently? Does that correlate with the
memory increase?" You can't answer this without version attributes.

**Example question — memory usage by Go version:** Show the distribution of `metrics.memory_mb` where `service.name = "api-service"`, grouped by `go.version`.

## HTTP Information (Beyond Auto-Instrumentation)

Auto-instrumentation captures basics, but parsing and enriching HTTP context unlocks
deeper analysis.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `http.route` | `/team/{team_id}/user/{user_id}` | The route pattern the URL matched |
| `http.route.param.team_id` | `14739` | Extracted route parameter value |
| `http.route.query.sort_dir` | `asc` | Relevant query parameters |
| `user_agent.device` | `computer`, `phone` | Device type parsed from User-Agent |
| `user_agent.browser` | `Chrome`, `Safari` | Browser parsed from User-Agent |
| `user_agent.browser_version` | `129` | Browser version parsed from User-Agent |

**Why it matters:** Without `http.route`, a latency spike just shows "some requests are slow."
With it, you see "only `POST /checkout` and `POST /signup` are slow." Parsed user-agent
fields let you find client-specific issues without regex.

**Example question — P99 latency by route:** Compute the 99th percentile of `duration_ms` where `service.name = "api-service"`, grouped by `http.route`.

## Timing Breakdowns

Put important sub-operation durations as attributes on the parent span rather than
creating child spans for everything. This enables direct querying without JOINs.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `auth.duration_ms` | `52.2`, `0.2` | Time spent in authentication |
| `payload_parse.duration_ms` | `22.1`, `0.1` | Time spent parsing the request payload |

**Why it matters:** Child spans require JOINs to correlate with parent attributes. Timing
attributes on the parent span let you immediately see "that group of requests
was slow because authentication took 10 seconds." See the
[Timing Attributes pattern](custom-instrumentation.md)
for implementation guidance.

**Example question — payload parse P99 by user type and region:** Compute the 99th percentile of `payload_parse.duration_ms` where `service.name = "api-service"`, grouped by `user.type` and `cloud.region`.

## Async Request Summaries

Roll up child operation statistics onto the parent span to identify outlier requests.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `stats.http_requests_count` | `1`, `140` | HTTP requests triggered during this request |
| `stats.http_requests_duration_ms` | `849` | Cumulative time in HTTP requests |
| `stats.postgres_query_count` | `7`, `742` | Postgres queries triggered during this request |
| `stats.postgres_query_duration_ms` | `1254` | Cumulative time in Postgres queries |
| `stats.redis_query_count` | `3`, `240` | Redis queries triggered during this request |
| `stats.redis_query_duration_ms` | `43` | Cumulative time in Redis queries |

**Why it matters:** A request that makes 742 database queries is almost certainly doing
something wrong. Without summary stats on the parent span, these outliers are invisible
unless you manually count child spans per trace. See the
[Async Request Summaries pattern](custom-instrumentation.md)
for implementation guidance.

**Example question — database queries per request (a distribution reveals outliers):** Show the distribution of `stats.postgres_query_count` where `service.name = "api-service"`.

## Error Details

Go beyond `error = true` by capturing structured error context that enables fast triage.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `error` | `true`, `false` | Whether the request failed |
| `exception.message` | `undefined is not a function` | The exception message |
| `exception.type` | `IOError`, `java.net.ConnectException` | Programmatic exception type |
| `exception.stacktrace` | `ReferenceError: ...` | Stack trace if available |
| `exception.expected` | `true`, `false` | Is this an expected error (bot traffic, invalid routes)? |
| `exception.slug` | `auth-error`, `stripe-call-failed` | Unique greppable identifier for the error location in code |

**Why it matters:** `exception.slug` is a static string you assign at each error throw site.
It's low-cardinality (safe to group by), greppable (jump from dashboard to code), and any
failed request *without* a slug reveals gaps in your error handling. See the
[Exception Slugs pattern](custom-instrumentation.md)
for implementation guidance.

**Example question — which enterprise users hit the most errors?** Count the distinct `user.id` values where `service.name = "api-service"` and `user.type = "enterprise"`, grouped by `exception.slug`.

**Example question — find requests with unhandled errors (missing slugs):** Count requests where `error = true` and `exception.slug` is missing, grouped by `http.route`.

## User and Business Context

The most important metadata you can add after the basics. No auto-instrumentation SDK
can automatically understand your user model.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `user.id` | `2147483647`, `user@example.com` | Primary user identifier |
| `user.type` | `free`, `premium`, `enterprise` | User tier or segment |
| `user.auth_method` | `token`, `jwt`, `sso-github` | Authentication method used |
| `user.team.id` | `5387`, `web-services` | Team or group the user belongs to |
| `user.org.id` | `278`, `enterprise-name` | Organization for enterprise accounts |
| `user.age_days` | `0`, `637` | Account age — distinguishes new vs established users |

**Why it matters:** A single enterprise account can represent 10%+ of revenue. Without user
attributes, you can't distinguish "weird edge case" from "revenue-critical path breaking
for high-value customers." Comparing outlier and baseline attribute distributions can instantly surface that all slow
requests are from one tenant.

**Example question — P99 latency by user type:** Compute the 99th percentile of `duration_ms` where `service.name = "api-service"`, grouped by `user.type`.

## Rate Limits

Track rate-limiting state so you can quickly identify affected users and diagnose complaints.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `ratelimit.limit` | `200000` | The rate limit being enforced |
| `ratelimit.remaining` | `130000` | Budget remaining for this user |
| `ratelimit.used` | `70000` | Budget consumed in the current window |

**Why it matters:** "Why am I being rate limited?" is a common customer complaint. Without
these attributes, finding rate-limited users requires digging through logs or separate
systems.

**Example question — users approaching their rate limit:** Take the max of `ratelimit.used` where `ratelimit.remaining < 1000`, grouped by `user.id` and `ratelimit.limit`.

## Caching

Record cache hit/miss booleans for every code path that could shortcut with a cache.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `cache.session_info` | `true`, `false` | Whether session info came from cache vs. database |
| `cache.feature_flags` | `true`, `false` | Whether feature flags were cached |

Use one boolean attribute per cacheable operation (e.g., `cache.user_profile`,
`cache.product_catalog`).

**Why it matters:** Cache misses are a common cause of latency spikes. Comparing outlier and baseline attribute distributions can surface
"slow requests all have `cache.session_info = false`" without you having to guess.

**Example question — latency difference between cache hit and miss:** Compute the 99th percentile of `duration_ms` where `service.name = "api-service"`, grouped by `cache.session_info`.

## Localization

Localization settings are a frequent source of bugs, especially around text layout
direction and currency formatting.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `localization.language_dir` | `rtl`, `ltr` | Text direction for the user's language |
| `localization.country` | `mexico`, `uk` | Country the user associates with (not physical location) |
| `localization.currency` | `USD`, `CAD` | Preferred currency |

**Why it matters:** Bugs that only reproduce with RTL text or specific currencies are notoriously
hard to find. These attributes let you filter and group by localization settings instantly.

**Example question — errors by text direction:** Count requests where `error = true`, grouped by `localization.language_dir`.

## Operational Metrics

Capture runtime health as span attributes so you can correlate system state with request
performance in a single query.

| Attribute | Examples | Description |
| :--- | :--- | :--- |
| `uptime_sec` | `1533` | Seconds since the service started — shows restarts |
| `metrics.memory_mb` | `153`, `2593` | Memory in use at request time |
| `metrics.cpu_load` | `0.57`, `5.89` | CPU load (active cores) at request time |
| `metrics.gc_count` | `5390` | Last observed garbage collection count |
| `metrics.gc_pause_time_ms` | `14`, `325` | Time spent in GC (cumulative or delta) |

**Why it matters:** "Are slow requests correlated with high memory or GC pauses?" These
attributes turn that from a multi-tool investigation into a single query comparing outlier and baseline requests.

**Example question — memory and CPU load for a service:** Show the distributions of `metrics.memory_mb` and `metrics.cpu_load` where `service.name = "api-service"`.
