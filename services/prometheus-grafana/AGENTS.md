# prometheus-grafana

LLD component `cmp:prometheus-grafana` · Prometheus, Grafana, Spring Boot Actuator, AWS CloudWatch Alarms · seeded from Java (Spring Boot)

Platform observability: Prometheus scrapes Spring Boot Actuator metrics and kube-state-metrics; Grafana provides dashboards for p95 latency, availability, error rates, and SSE connection health. CloudWatch Alarms for availability alerting.

## Stories

- `US-001`
- `US-003`
- `US-005`
- `US-006`
- `US-008`

## Endpoints

- `GET /v1/observability/alerts`
- `POST /v1/observability/alerts`
- `GET /v1/observability/health`
- `GET /v1/observability/dashboards`
- `GET /v1/observability/scrape-targets`
- `GET /v1/observability/alerts/{alertId}`
- `PUT /v1/observability/alerts/{alertId}`
- `DELETE /v1/observability/alerts/{alertId}`
- `GET /v1/observability/metrics/snapshot`

## Entities

- `ent:alert-rule`
- `ent:dashboard-registry`
- `ent:metric-snapshot`
- `ent:scrape-target`

## Acceptance criteria

- AC-4bb8c0f4 (US-001): Given I am logged in as an Operator, When I open the new request form, Then I see a machine selector populated only with active machines from the master list, a free-text description field, and a priority selector with values Critical, Medium, and Low.
- AC-a6372e9c (US-001): Given I have selected a machine, entered a description, and chosen a priority, When I submit the form, Then the request is created with status Open, a creation timestamp is recorded, and I am shown an on-screen confirmation with the request reference number.
- AC-91d7680f (US-001): Given I submit the form with the machine selector empty, the description empty, or no priority selected, When I attempt to submit, Then the form is not submitted and each missing field is highlighted with an error message.
- AC-84645e7d (US-001): Given the machine list contains deactivated machines, When I open the machine selector, Then deactivated machines do not appear as selectable options.
- AC-af6de81d (US-003): Given I am logged in as a Technician, When I open the request queue, Then I see all requests with status Open, sorted with Critical at the top, followed by Medium, then Low; within the same priority, requests are sorted by creation timestamp ascending.
- AC-b0f38811 (US-003): Given multiple Critical requests exist, When I view the queue, Then they appear before any Medium or Low requests regardless of when they were created.
- AC-c2c2c5df (US-003): Given a new Critical request is submitted while I am viewing the queue, When the queue refreshes (within 60 seconds or on manual refresh), Then the new request appears in the correct position.
- AC-eed80de8 (US-003): Given I am logged in as an Operator, When I attempt to access the Technician queue view, Then I am denied access and see an authorisation error.
- AC-659dc640 (US-005): Given I am logged in as a Technician and I am the assignee of a request with status Open, When I click 'Start work', Then the request status changes to In Progress and the transition timestamp is recorded.
- AC-41284728 (US-005): Given a request is In Progress, When any user views the request, Then they see the In Progress status and the timestamp at which work started.
- AC-2dfbd88a (US-005): Given I am not the assignee of a request, When I view that request, Then the 'Start work' action is not available to me.
- AC-38a54266 (US-005): Given I am logged in as an Operator or Supervisor, When I view any request, Then the 'Start work' action is not available to me.
- AC-6b91db1d (US-006): Given I am logged in as a Technician and I am the assignee of a request with status In Progress, When I click 'Resolve', Then I am presented with a resolution note field that is mandatory before the action can be confirmed.
- AC-3cb6269a (US-006): Given I attempt to resolve a request with an empty resolution note field, When I click confirm, Then the request is not resolved and an error message states that a resolution note is required.
- AC-a727ab1b (US-006): Given I enter a resolution note and confirm, When the resolution is saved, Then the request status changes to Resolved, the resolution note is stored, and the resolution timestamp is recorded.
- AC-79943d9e (US-006): Given a request is Resolved, When any user views the request, Then they can read the resolution note and see the resolved timestamp.
- AC-dd8a9cfd (US-006): Given I am logged in as an Operator or Supervisor, When I view any request, Then the 'Resolve' action is not available to me.
- AC-46c40242 (US-008): Given I am logged in as a Supervisor, When I open the dashboard, Then I see three count tiles: Open, In Progress, and Resolved, each showing the current total for that status.
- AC-db58309e (US-008): Given at least one request has been in Open status for more than 24 hours, When I view the dashboard, Then those requests are listed in a dedicated 'Overdue (>24 h)' section showing machine name, priority, fault description summary, and time elapsed since creation.
- AC-f57841ce (US-008): Given all open requests are less than 24 hours old, When I view the dashboard, Then the overdue section shows an empty state message confirming no requests are currently overdue.
- AC-a9aa9905 (US-008): Given a request transitions from Open to In Progress, When the dashboard refreshes (within 60 seconds or on manual refresh), Then the Open count decreases by one and the In Progress count increases by one.
- AC-1ce41875 (US-008): Given I am logged in as an Operator or Technician, When I attempt to access the Supervisor dashboard URL, Then I am denied access and see an authorisation error.

## Non-functional requirements

- availability: 99.5% uptime measured monthly during defined shift hours (excluding pre-announced maintenance windows of ≤ 2 hours per month)
- latency: 95th-percentile page load time ≤ 3 seconds under a concurrent load of 50 users on the shop-floor Wi-Fi network
- scalability: Supports 100 concurrent authenticated users with no increase in 95th-percentile response time beyond the NFR-01 threshold
- performance: 95th-percentile page load time ≤ 3 seconds under a concurrent load of 50 users on the shop-floor Wi-Fi network
- performance: Status change visible to all active sessions within 60 seconds of the transition being saved, without requiring a manual page reload
- availability: 99.5% uptime measured monthly during defined shift hours (excluding pre-announced maintenance windows of ≤ 2 hours per month)
- reliability: Zero silent data-loss events on request submission; 100% of failed submissions return an error message within 5 seconds
- security: 100% of HTTP traffic served over TLS 1.2 or higher; no unencrypted HTTP endpoints exposed
- security: Zero successful unauthorised actions in penetration testing; every role-restricted API endpoint returns HTTP 403 when called by an unauthorised role
- data_management: Zero records of timestamp or resolution-note modification in the audit log; any attempt to modify returns HTTP 403
- data_management: All request records retained for a minimum of 7 years from the date of resolution; records must be exportable before deletion
- usability: New Operator completes first successful request submission in ≤ 2 minutes in usability testing with no prior system exposure
- accessibility: WCAG 2.1 Level AA conformance across all pages, verified by automated scan and manual review
- scalability: Supports 100 concurrent authenticated users with no increase in 95th-percentile response time beyond the NFR-01 threshold
- observability: 100% of status transitions and notification dispatch events logged with request ID, timestamp, actor, and outcome; logs retained for 90 days
- integration: System displays a clear service-unavailable message within 10 seconds of IdP timeout; no partial or corrupted session is created
- maintainability: SLA thresholds and shift-hours configuration are stored in application configuration, changeable via an admin interface or configuration file, with changes taking effect within 5 minutes without a restart
- privacy: No personal data fields beyond display name, role, and system-generated user ID are stored; data minimisation reviewed at each release

## Settled decisions

- **Should prometheus-grafana expose an HTTP API for metric ingestion, or rely on Prometheus pull-based scraping?** → Prometheus uses its native pull model: it scrapes /actuator/prometheus on fixit-api-backend and kube-state-metrics on a configurable interval. No push gateway is introduced. (`no-inbound-http-api-for-scraping`)
- **Should the observability management API be publicly accessible or internal-only?** → The API is served on an internal cluster hostname (observability.fixit.internal) reachable only from within the EKS VPC. It is not exposed through the public ALB or API Gateway. (`internal-only-observability-api`)
- **How is the observability management API authenticated?** → BearerAuth (JWT issued by Keycloak) is required on all endpoints. Only users with a platform-admin or sre role claim may call write endpoints; read endpoints require at minimum an authenticated session. (`bearer-auth-on-observability-api`)
- **Which tool owns the 99.5% availability alarm — Prometheus or CloudWatch?** → AWS CloudWatch Alarms own the availability SLA alarm because they can evaluate uptime over the calendar month window aligned to shift hours. Prometheus alert rules own latency and error-rate alarms. Both feed into Grafana via webhook/datasource. (`cloudwatch-alarms-for-availability`)
- **What PromQL threshold triggers the p95 latency alert?** → histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m])) > 3 sustained for 5 minutes fires a 'warning' alert. A 10-second threshold fires 'critical'. (`p95-latency-alert-threshold`)
- **How is SSE connection health surfaced in Prometheus?** → fixit-api-backend exposes a custom Micrometer gauge sse_connections_active via /actuator/prometheus. Prometheus evaluates: sse_connections_active == 0 AND up{job='fixit-api-backend'} == 1 for 2 minutes → alert. (`sse-connection-gauge-metric`)
- **How long are metric_snapshot rows retained in PostgreSQL?** → Rows older than 24 hours are purged by a scheduled Spring Boot @Scheduled job running every hour. Long-term metric history is retained natively in Prometheus TSDB (15-day default) and CloudWatch (15 months). (`metric-snapshot-retention`)
- **Does Grafana query PostgreSQL directly for business metrics (e.g. request counts)?** → No. Grafana queries Prometheus exclusively for all time-series panels. Business-level counts (Open/In Progress/Resolved) displayed in the Supervisor dashboard are served by fixit-api-backend GET /v1/dashboard, not by Grafana. (`grafana-datasource-prometheus-only`)
- **What pagination style is used on list endpoints?** → Cursor-based pagination (?cursor=&limit=) returning a CursorPage envelope on all list endpoints, consistent with the project convention. (`cursor-pagination-on-all-list-endpoints`)
- **How is idempotency handled for alert rule creation?** → POST /v1/observability/alerts returns HTTP 409 if an alert rule with the same name already exists. Callers must use PUT /v1/observability/alerts/{alertId} to update. The name column has a UNIQUE constraint. (`alert-rule-idempotency`)
- **What scrape interval is used for fixit-api-backend?** → 15 seconds for fixit-api-backend /actuator/prometheus; 30 seconds for kube-state-metrics. Both are configurable in the Prometheus ConfigMap. (`scrape-interval`)
- **How is compliance with the 95th-percentile response-time threshold verified and monitored continuously for 100 concurrent users?** → prometheus-grafana scrapes Spring Boot Actuator /actuator/prometheus metrics from fixit-api-backend every 15 seconds, recording http_server_requests_seconds histogram buckets per route. A Grafana dashboard displays real-time p95 latency. A CloudWatch Alarm fires when p95 exceeds the NFR-01 threshold for two consecutive 1-minute periods. Pre-release load tests via AWS ALB simulate 100 concurrent authenticated users and gate deployment on p95 compliance. (`p95-latency-observability-under-concurrent-load`)

## Contract

The endpoints, schemas, tables and events above are defined in `contracts/` in this repository. Implement them as written; a change to the contract is a change to the design.
