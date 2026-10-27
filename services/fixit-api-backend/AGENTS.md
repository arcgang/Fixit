# fixit-api-backend

LLD component `cmp:fixit-api-backend` · Java 21, Spring Boot 3.x, Spring Security, Spring Data JPA, Hibernate, AWS EKS · seeded from Java (Spring Boot)

All business logic: request lifecycle management, server-side RBAC enforcement, SLA calculation and flagging, machine register CRUD, commenting, audit logging, SSE endpoint for real-time updates, system configuration management, Data Export API (Phase 2)

## Stories

- `US-001`
- `US-002`
- `US-003`
- `US-004`
- `US-005`
- `US-006`
- `US-007`
- `US-008`
- `US-009`
- `US-010`
- `US-011`
- `US-012`
- `US-013`
- `US-014`
- `US-015`
- `US-016`
- `US-017`
- `US-018`
- `US-019`
- `US-020`

## Endpoints

- `GET /config`
- `PUT /config`
- `GET /machines`
- `POST /machines`
- `GET /requests`
- `POST /requests`
- `GET /dashboard`
- `GET /events/stream`
- `GET /export/downtime`
- `GET /export/requests`
- `GET /reports/downtime`
- `PUT /machines/{machineId}`
- `PATCH /requests/{requestId}`
- `GET /machines/{machineId}/history`
- `GET /requests/{requestId}/comments`
- `POST /requests/{requestId}/comments`
- `PATCH /machines/{machineId}/deactivate`
- `POST /v1/requests`
- `GET /v1/requests`
- `PATCH /v1/requests/{id}`
- `GET /v1/requests/{id}/comments`
- `POST /v1/requests/{id}/comments`
- `GET /v1/dashboard`
- `GET /v1/machines`
- `POST /v1/machines`
- `PUT /v1/machines/{id}`
- `PATCH /v1/machines/{id}/deactivate`
- `GET /v1/reports/downtime`
- `GET /v1/events/stream`
- `GET /v1/config`
- `PUT /v1/config`
- `GET /v1/machines/{id}/history`
- `GET /v1/export/requests`
- `GET /v1/export/downtime`

## Entities

- `ent:audit-event`
- `ent:machine`
- `ent:maintenance-request`
- `ent:request-comment`
- `ent:sla-configuration`
- `ent:status-transition`
- `ent:user-profile`
- `ent:maintenancerequest`
- `ent:statustransition`
- `ent:requestcomment`
- `ent:userprofile`
- `ent:slaconfiguration`
- `ent:auditevent`

## Acceptance criteria

- AC-4bb8c0f4 (US-001): Given I am logged in as an Operator, When I open the new request form, Then I see a machine selector populated only with active machines from the master list, a free-text description field, and a priority selector with values Critical, Medium, and Low.
- AC-a6372e9c (US-001): Given I have selected a machine, entered a description, and chosen a priority, When I submit the form, Then the request is created with status Open, a creation timestamp is recorded, and I am shown an on-screen confirmation with the request reference number.
- AC-91d7680f (US-001): Given I submit the form with the machine selector empty, the description empty, or no priority selected, When I attempt to submit, Then the form is not submitted and each missing field is highlighted with an error message.
- AC-84645e7d (US-001): Given the machine list contains deactivated machines, When I open the machine selector, Then deactivated machines do not appear as selectable options.
- AC-278220d5 (US-002): Given I am logged in as an Operator, When I navigate to 'My Requests', Then I see only the requests I have raised, each showing machine name, fault description summary, priority, current status, and creation timestamp.
- AC-def5d740 (US-002): Given one of my requests has been transitioned to In Progress or Resolved by a technician, When I view 'My Requests', Then the updated status is reflected without requiring a page reload within 60 seconds of the transition.
- AC-584f8d4b (US-002): Given I have raised no requests, When I navigate to 'My Requests', Then I see an empty state message explaining how to raise a first request.
- AC-66ce3990 (US-002): Given I am logged in as a Technician or Supervisor, When I attempt to access the Operator's 'My Requests' view for another user, Then I am denied access and see an authorisation error.
- AC-af6de81d (US-003): Given I am logged in as a Technician, When I open the request queue, Then I see all requests with status Open, sorted with Critical at the top, followed by Medium, then Low; within the same priority, requests are sorted by creation timestamp ascending.
- AC-b0f38811 (US-003): Given multiple Critical requests exist, When I view the queue, Then they appear before any Medium or Low requests regardless of when they were created.
- AC-c2c2c5df (US-003): Given a new Critical request is submitted while I am viewing the queue, When the queue refreshes (within 60 seconds or on manual refresh), Then the new request appears in the correct position.
- AC-eed80de8 (US-003): Given I am logged in as an Operator, When I attempt to access the Technician queue view, Then I am denied access and see an authorisation error.
- AC-f02593bf (US-004): Given I am logged in as a Technician and a request has status Open, When I click 'Assign to me', Then the request is assigned to my user account, the status remains Open (or transitions to In Progress per US-005 if I choose), and my name is visible to all users viewing the request.
- AC-81c73c11 (US-004): Given a request is already assigned to another technician, When I view that request, Then the 'Assign to me' action is not available and the current assignee's name is displayed.
- AC-722752e1 (US-004): Given I self-assign a request, When the assignment is saved, Then the assignment timestamp is recorded and visible on the request detail.
- AC-3bc3a625 (US-004): Given I am logged in as an Operator or Supervisor, When I view a request, Then the 'Assign to me' action is not available to me.
- AC-659dc640 (US-005): Given I am logged in as a Technician and I am the assignee of a request with status Open, When I click 'Start work', Then the request status changes to In Progress and the transition timestamp is recorded.
- AC-41284728 (US-005): Given a request is In Progress, When any user views the request, Then they see the In Progress status and the timestamp at which work started.
- AC-2dfbd88a (US-005): Given I am not the assignee of a request, When I view that request, Then the 'Start work' action is not available to me.
- AC-38a54266 (US-005): Given I am logged in as an Operator or Supervisor, When I view any request, Then the 'Start work' action is not available to me.
- AC-6b91db1d (US-006): Given I am logged in as a Technician and I am the assignee of a request with status In Progress, When I click 'Resolve', Then I am presented with a resolution note field that is mandatory before the action can be confirmed.
- AC-3cb6269a (US-006): Given I attempt to resolve a request with an empty resolution note field, When I click confirm, Then the request is not resolved and an error message states that a resolution note is required.
- AC-a727ab1b (US-006): Given I enter a resolution note and confirm, When the resolution is saved, Then the request status changes to Resolved, the resolution note is stored, and the resolution timestamp is recorded.
- AC-79943d9e (US-006): Given a request is Resolved, When any user views the request, Then they can read the resolution note and see the resolved timestamp.
- AC-dd8a9cfd (US-006): Given I am logged in as an Operator or Supervisor, When I view any request, Then the 'Resolve' action is not available to me.
- AC-92b22fad (US-007): Given I am logged in as any role, When I open a request detail page, Then I see a comment input field and a chronological list of all previous comments, each showing the author's name, role, comment text, and timestamp.
- AC-bcec04af (US-007): Given I type a comment and submit it, When the comment is saved, Then it appears immediately at the bottom of the comment history with my name, role, and the current timestamp.
- AC-472e9681 (US-007): Given I submit an empty comment, When I click add, Then the comment is not saved and an error message is shown.
- AC-5a8d0512 (US-007): Given a request has no comments, When I view the comment history, Then I see an empty state message indicating no comments have been added yet.
- AC-46c40242 (US-008): Given I am logged in as a Supervisor, When I open the dashboard, Then I see three count tiles: Open, In Progress, and Resolved, each showing the current total for that status.
- AC-db58309e (US-008): Given at least one request has been in Open status for more than 24 hours, When I view the dashboard, Then those requests are listed in a dedicated 'Overdue (>24 h)' section showing machine name, priority, fault description summary, and time elapsed since creation.
- AC-f57841ce (US-008): Given all open requests are less than 24 hours old, When I view the dashboard, Then the overdue section shows an empty state message confirming no requests are currently overdue.
- AC-a9aa9905 (US-008): Given a request transitions from Open to In Progress, When the dashboard refreshes (within 60 seconds or on manual refresh), Then the Open count decreases by one and the In Progress count increases by one.
- AC-1ce41875 (US-008): Given I am logged in as an Operator or Technician, When I attempt to access the Supervisor dashboard URL, Then I am denied access and see an authorisation error.
- AC-bf020ce2 (US-009): Given I am logged in as a Supervisor, When I navigate to machine management and click 'Add machine', Then I see a form with fields for machine name (required), asset reference or location (optional), and a save action.
- AC-b26705c4 (US-009): Given I complete the required fields and save, When the machine is created, Then it appears in the machine list with status Active and is immediately available in the Operator's machine selector.
- AC-f6518108 (US-009): Given I attempt to save a machine with an empty name field, When I click save, Then the machine is not created and the name field is highlighted with an error.
- AC-7b4bdd2f (US-009): Given I am logged in as an Operator or Technician, When I attempt to access machine management, Then I am denied access and see an authorisation error.
- AC-f28b4f00 (US-010): Given I am logged in as a Supervisor, When I select an active machine and click 'Edit', Then I can modify the machine name and optional fields and save the changes.
- AC-b90176ef (US-010): Given I save an edit, When the change is persisted, Then the updated name is reflected immediately in the machine selector on the request submission form.
- AC-f8a0993d (US-010): Given I attempt to save an edit that leaves the machine name empty, When I click save, Then the change is not saved and an error is shown.
- AC-85d68e37 (US-010): Given a machine has open or in-progress requests, When I edit its name, Then existing requests retain a reference to the machine and display the updated name.
- AC-e928a740 (US-011): Given I am logged in as a Supervisor, When I select an active machine and click 'Deactivate', Then I am asked to confirm the action before it is applied.
- AC-a61ddfda (US-011): Given I confirm deactivation, When the machine is deactivated, Then it no longer appears in the Operator's machine selector for new requests.
- AC-1c93cafa (US-011): Given a deactivated machine has historical resolved requests, When I view those requests, Then they still reference the machine name and the full request history is preserved.
- AC-5781285e (US-011): Given a machine has open or in-progress requests, When I attempt to deactivate it, Then I am shown a warning listing the open requests and must explicitly confirm before deactivation proceeds.
- AC-0d4ac7e1 (US-012): Given a request exists with any priority, When any user views the request detail, Then the applicable SLA target resolution time is displayed alongside the priority label.
- AC-b7d8ba61 (US-012): Given a Critical request has been open for 45 minutes without being resolved, When the dashboard or request list is viewed, Then the request is visually flagged as 'At risk' (within 15 minutes of SLA breach).
- AC-3b88cc43 (US-012): Given a request has exceeded its SLA resolution time without being resolved, When any user views the request, Then it is visually flagged as 'SLA breached' with the elapsed overdue time shown.
- AC-d82b411a (US-012): Given a request is resolved within its SLA window, When the request is viewed after resolution, Then it is marked as resolved within SLA and no breach flag is shown.
- AC-46f8109b (US-013): Given I am logged in as a Supervisor, When I navigate to the downtime report, Then I see a table showing each machine, the number of resolved requests in the selected period, and the total downtime hours (calculated as sum of time from request creation to resolution for resolved requests).
- AC-92f7fbf0 (US-013): Given I select a specific month, When the report is rendered, Then only requests created and resolved within that month are included in the calculation.
- AC-826f7923 (US-013): Given no requests exist for a machine in the selected period, When I view the report, Then that machine shows zero requests and zero downtime hours.
- AC-d01ba8e1 (US-013): Given the current month's data is viewed, When the report is rendered, Then it includes all resolved requests up to the current moment and notes that the period is incomplete.
- AC-d99a7b4c (US-014): Given I navigate to the FixIt login page, When I click 'Sign in', Then I am redirected to the organisation's existing identity provider (IdP) login page.
- AC-ec74634a (US-014): Given I authenticate successfully with my organisational credentials, When the IdP redirects me back to FixIt, Then I am logged in with the role assigned to my account in the directory.
- AC-519e32c1 (US-014): Given my organisational account is disabled or my session expires, When I attempt to access any FixIt page, Then I am redirected to the login page and cannot access any data.
- AC-9e3efa04 (US-014): Given I have not been assigned a FixIt role in the directory, When I authenticate successfully, Then I see an access-denied message explaining that my account has not been provisioned.
- AC-6655b8e6 (US-015): Given a new Critical request is submitted, When the request is created, Then all Technicians who are not currently assigned to a Critical request receive a notification via the configured channel (email or messaging platform) within 2 minutes.
- AC-59b14799 (US-015): Given a request assigned to me has 15 minutes remaining before its SLA deadline, When the threshold is crossed, Then I receive a notification identifying the request, machine, and remaining time.
- AC-56335a6c (US-015): Given I have resolved a request before the SLA deadline, When the deadline passes, Then no SLA-breach notification is sent for that request.
- AC-b7289ef3 (US-015): Given the notification channel is email, When a notification is sent, Then the email contains the request reference, machine name, priority, and a direct link to the request in FixIt.
- AC-380e839f (US-016): Given a request has been in Open or In Progress status for exactly 24 hours, When the threshold is crossed, Then all Supervisors receive a notification via the configured channel identifying the request, machine, priority, and elapsed time.
- AC-62800b4c (US-016): Given a request is resolved before the 24-hour threshold, When the threshold time passes, Then no overdue notification is sent for that request.
- AC-65958ea0 (US-016): Given a request remains unresolved after 24 hours and a notification has already been sent, When another 24 hours elapse, Then a repeat notification is sent to prevent the alert from being forgotten.
- AC-5ed6e617 (US-016): Given the notification channel is email, When a notification is sent, Then the email contains the request reference, machine name, priority, elapsed time, and a direct link to the request.
- AC-4646719e (US-017): Given I raised a request and a Technician transitions it to In Progress, When the transition is saved, Then I receive a notification via the configured channel stating the request reference, machine name, and new status.
- AC-df2a7b7c (US-017): Given I raised a request and it is marked Resolved, When the resolution is saved, Then I receive a notification that includes the request reference, machine name, and the resolution note summary.
- AC-403c178a (US-017): Given I raised a request and no status change has occurred, When time passes, Then I do not receive spurious notifications.
- AC-76d414d0 (US-017): Given the notification channel is email, When a notification is sent, Then the email contains a direct link to the request detail page.
- AC-93a373bc (US-018): Given a request is submitted at any time (including outside defined working hours), When the request is created, Then it is immediately visible in the Technician queue and on the Supervisor dashboard with its creation timestamp.
- AC-7f50f8fd (US-018): Given working hours are defined in system configuration, When a request is created outside those hours, Then the request is labelled 'Raised out of hours' and the SLA clock behaviour (continuous or shift-hours-only) is applied as configured.
- AC-5c24b9fa (US-018): Given the SLA clock is configured to run on shift hours only, When an out-of-hours request is viewed at shift start, Then the SLA countdown reflects only the elapsed staffed time, not wall-clock time.
- AC-8db80cb2 (US-018): Given the SLA clock is configured to run continuously, When an out-of-hours request is viewed at shift start, Then the SLA countdown reflects total elapsed wall-clock time since creation.
- AC-fa39f6dd (US-019): Given the API is deployed, When I make an authenticated GET request to the requests endpoint with a date-range filter, Then I receive a JSON response conforming to the published OpenAPI 3.x schema containing request records with all status transition timestamps.
- AC-554d9609 (US-019): Given the API is deployed, When I make an authenticated GET request to the downtime summary endpoint, Then I receive aggregated downtime hours per machine per period in the documented schema.
- AC-a7e9fc8a (US-019): Given I make a request with an invalid or expired authentication token, When the API processes the request, Then it returns HTTP 401 and does not expose any data.
- AC-e3971f82 (US-019): Given the API schema is versioned, When a breaking change is introduced, Then the previous version remains available for a documented deprecation period of at least 90 days.
- AC-a9dc8a19 (US-020): Given I am logged in as a Technician, When I open a request and navigate to the machine's history, Then I see a list of all resolved requests for that machine in reverse chronological order, each showing the fault description, resolution note, priority, and resolved timestamp.
- AC-c927ac3b (US-020): Given a machine has no prior resolved requests, When I view its history, Then I see an empty state message confirming no prior faults are recorded.
- AC-4331b84e (US-020): Given I am logged in as any role, When I view a machine's request history, Then I can read resolution notes but cannot edit or delete them.
- AC-d1a5bd4b (US-020): Given a machine has been deactivated, When I view its history, Then the full resolved request history is still accessible and the machine is labelled as deactivated.

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

- **hosting: aws eks landing zone** → Host FixIt on AWS EKS within Organisation Landing Zone v2 (`aws-eks-landing-zone`)
- **data: postgresql rds multiaz** → Use Amazon RDS for PostgreSQL (Multi-AZ) as the sole data store; enforce immutability at the database layer via append-only audit tables (`postgresql-rds-multiaz`)
- **security: aws secrets manager no hardcoded creds** → All secrets (DB credentials, Keycloak client secret, notification channel credentials) stored in AWS Secrets Manager with automatic rotation (`aws-secrets-manager-no-hardcoded-creds`)
- **nfr: p2 business critical nfr tier** → Classify FixIt as P2 Business Critical (99.5% SLA, RTO ≤ 4 h, RPO ≤ 1 h) rather than P3 Standard (`p2-business-critical-nfr-tier`)
- **other: ibm meth 001 adr well architected** → Mandate ADRs for all significant architecture decisions and a Well-Architected review before production go-live per IBM-METH-001 (`ibm-meth-001-adr-well-architected`)
- **data: data classification fixcorp levels** → Apply FixCorp EA-DAT-001 classification levels (public / internal / confidential / restricted) to all FixIt data assets; operational request data classified Internal, user identity data classified Confidential (`data-classification-fixcorp-levels`)
- **data: data pii minimisation pseudonymisation** → Data minimisation enforced: only display name, role, and system-generated user ID stored; pseudonymisation (not hard deletion) applied on GDPR erasure requests to preserve audit trail integrity (`data-pii-minimisation-pseudonymisation`)
- **security: rbac server side enforcement** → All role-based access control is enforced server-side in the Spring Boot backend; client-side UI hiding is supplementary only (`rbac-server-side-enforcement`)
- **hosting: hosting aws eks landing zone** → Deploy FixIt on AWS EKS within a governed AWS landing zone with private subnets, IaC provisioning, and mandatory resource tagging (`hosting-aws-eks-landing-zone`)
- **auth: identity keycloak oidc arb exception** → Use Keycloak as the OIDC identity provider; ARB exception required for dec-004 (Okta mandate) unless Keycloak is deployed as a federation broker to Okta (`identity-keycloak-oidc-arb-exception`)
- **security: secrets aws secrets manager** → All credentials stored in AWS Secrets Manager with automatic rotation; no hardcoded credentials in source code or container images (`secrets-aws-secrets-manager`)
- **nfr: frontend cloudfront cdn p95 latency** → React SPA served via AWS CloudFront CDN to satisfy p95 ≤ 3s page load on shop-floor Wi-Fi (NFR-01) (`frontend-cloudfront-cdn-p95-latency`)
- **auth: auth oidc pkce keycloak mfa** → Use OIDC Authorization Code + PKCE via Keycloak with mandatory MFA for all interactive user sessions (`auth-oidc-pkce-keycloak-mfa`)
- **auth: auth irsa no static keys** → Use IAM Roles for Service Accounts (IRSA) for all EKS pod-to-AWS-service authentication; no static IAM access keys (`auth-irsa-no-static-keys`)
- **security: security server side rbac spring security** → Enforce all authorization server-side via Spring Security JWT role claims; client-side UI hiding is supplementary only (`security-server-side-rbac-spring-security`)
- **security: security tls everywhere** → Enforce TLS 1.2+ on every network hop; HTTP redirected to HTTPS at ALB and CloudFront (`security-tls-everywhere`)
- **security: security aws secrets manager credential vault** → All credentials stored in AWS Secrets Manager with automatic rotation; no static secrets in source code, container images, or Kubernetes Secrets (`security-aws-secrets-manager-credential-vault`)
- **security: security data classification internal** → All FixIt data assets classified 'internal'; AES-256 encryption at rest via AWS KMS; no PII beyond display name, role, and user ID stored (`security-data-classification-internal`)
- **What pagination style should list endpoints use?** → Cursor-based pagination using an opaque base64-encoded token encoding (id, sort-key) of the last seen row. All list endpoints accept ?cursor=&limit= and return a CursorPage object. (`cursor-pagination-opaque-token`)
- **What format should primary keys use?** → UUID v4 generated server-side via uuid_generate_v4() (uuid-ossp extension). Exposed as string format:uuid in all API responses. (`request-id-format-uuid-v4`)
- **How should state transitions (assign, start work, resolve) be modelled in the API?** → A single PATCH /v1/requests/{requestId} endpoint accepts an 'action' enum (ASSIGN_TO_ME, START_WORK, RESOLVE) plus optional resolutionNote. The backend enforces valid state machine transitions and RBAC. (`patch-action-enum-for-transitions`)
- **Where is the resolution note mandatory check enforced?** → Server-side: PATCH with action=RESOLVE and empty/absent resolutionNote returns HTTP 400 with code RESOLUTION_NOTE_REQUIRED. Client-side validation is supplementary. (`resolution-note-server-side-mandatory`)
- **Where is SLA target time calculated and stored?** → On request creation the backend reads the current sla_configuration for the given priority, computes sla_target_at = created_at + target_minutes (adjusted for clock_mode), and stores it on the maintenance_request row. sla_status is recomputed on every read and on resolution. (`sla-calculation-server-side`)
- **How are SLA configuration changes stored and applied?** → Each PUT /v1/config inserts new sla_configuration rows with a new effective_from timestamp. The active config for a priority is the row with the highest effective_from <= NOW(). Changes take effect within 5 minutes via a cache TTL in the Spring service. (`sla-config-append-only-latest-wins`)
- **How are real-time status updates delivered to connected clients?** → Server-Sent Events (SSE) via GET /v1/events/stream. The Spring Boot backend uses SseEmitter. After each state-changing write the backend broadcasts the relevant event to all connected emitters filtered by role/scope. (`sse-for-real-time-updates`)
- **How is the Operator 'My Requests' view scoped to the authenticated user?** → GET /v1/requests for an OPERATOR role automatically filters by submitted_by_user_id = JWT subject. Any attempt to pass a different userId query param is ignored; cross-user access returns HTTP 403. (`operator-my-requests-server-side-scope`)
- **How is machine deactivation implemented?** → Soft delete: is_active=false, deactivated_at=NOW(). Historical requests retain the FK to machine.id and display the current machine.name. GET /v1/machines?activeOnly=true (default) excludes inactive machines from the Operator selector. (`machine-deactivation-soft-delete`)
- **How is the 'machine has open requests' warning handled in the API?** → PATCH /v1/machines/{machineId}/deactivate with forceDeactivate=false returns HTTP 400 with code MACHINE_HAS_OPEN_REQUESTS and a details array listing the open request IDs. The client must re-submit with forceDeactivate=true to proceed. (`deactivation-open-requests-warning`)
- **How is downtime calculated for the report?** → Downtime per request = EXTRACT(EPOCH FROM resolved_at - created_at) / 60 minutes. Only requests where both created_at and resolved_at fall within the selected month are included. The report flags isPeriodIncomplete=true for the current calendar month. (`downtime-calculation-definition`)
- **Should audit_event have a FK to user_profile?** → No FK on actor_user_id in audit_event. The actor_user_id and actor_role are stored as plain columns. (`audit-event-no-fk-on-actor`)
- **Are status_transition and request_comment rows ever updated or deleted?** → Never. Both tables are append-only. No UPDATE or DELETE is permitted at the application layer. Spring Security enforces HTTP 403 on any modification attempt to resolved records. (`append-only-status-transitions-and-comments`)
- **How are US-015/016/017 notifications handled given messaging=NONE?** → Notifications are dispatched synchronously (or via a Spring @Async thread pool) as outbound SMTP/webhook calls from the Spring Boot service after each state transition is committed. No message broker is used. SMTP credentials are stored in AWS Secrets Manager. This is Phase 2 scope. (`notification-dispatch-phase2-outbound-only`)
- **How is the 7-year retention requirement implemented?** → maintenance_request, status_transition, request_comment, and audit_event rows are never deleted from PostgreSQL within 7 years of resolved_at. CloudWatch Logs operational retention is 90 days; logs are exported to S3 for 7-year archival via a lifecycle policy. (`data-retention-7-year`)
- **How is PII minimisation enforced?** → Only display_name, role, and system-generated UUID are stored. On GDPR erasure, display_name in user_profile and author_display_name in request_comment are replaced with a pseudonym token (e.g. 'User-<hash>'). No raw PII is written to CloudWatch logs. (`pii-minimisation-pseudonymisation`)
- **How is API versioning handled?** → URL path prefix /v1/. Breaking changes will be introduced under /v2/ with /v1/ maintained for a minimum 90-day deprecation period. (`api-versioning-url-prefix`)
- **How is priority sort order (Critical > Medium > Low) implemented in the database query?** → A CASE expression maps priority enum values to sort integers (CRITICAL=1, MEDIUM=2, LOW=3) in the ORDER BY clause. The sort=priority_asc_created_asc query parameter triggers this ordering. (`priority-sort-order-enum-mapping`)
- **How does the system guarantee that no request submission is silently lost and that every failure is surfaced to the caller within 5 seconds?** → fixit-api-backend writes each new maintenance request inside a single ACID transaction to fixit-postgresql-db (AWS RDS Multi-AZ). The Spring Boot controller returns HTTP 201 only after the transaction commits; any exception (constraint violation, connectivity failure, timeout) causes an immediate rollback and the controller returns a structured HTTP 4xx/5xx error response with a human-readable message. A global Spring @ControllerAdvice sets a 5-second server-side response timeout on all POST /requests calls, ensuring the error is returned within the NFR window. AWS RDS Multi-AZ automatic failover (typically <60 s) prevents the database from being a single point of silent loss; during failover the backend returns HTTP 503 rather than silently dropping the write. (`zero-silent-data-loss-on-submission`)
- **How are SLA thresholds and shift-hours configuration stored, exposed for admin changes, and applied within 5 minutes without a service restart?** → SLA thresholds (Critical 1 h, Medium 4 h, Low 8 h) and shift-hours definitions are stored as rows in a dedicated system_configuration table in fixit-postgresql-db, managed by fixit-api-backend. A Supervisor-only REST endpoint (PATCH /admin/configuration) enforces RBAC via Spring Security and writes changes transactionally to the database. fixit-api-backend uses a Spring @Scheduled task running every 60 seconds to reload configuration rows from the database into an in-memory cache (a Spring-managed singleton bean); any change written via the admin endpoint is therefore reflected in all running pods within at most 60 seconds, well within the 5-minute requirement. Credentials for the admin endpoint are protected by the existing JWT authorisation enforced at aws-api-gateway. (`runtime-configuration-hot-reload`)

## Contract

The endpoints, schemas, tables and events above are defined in `contracts/` in this repository. Implement them as written; a change to the contract is a change to the design.
