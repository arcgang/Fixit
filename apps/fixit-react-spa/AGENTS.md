# fixit-react-spa

LLD component `cmp:fixit-react-spa` · React 18, TypeScript, Vite, AWS CloudFront, AWS S3 · seeded from React

Browser-based UI for all three personas: request submission form, My Requests view, Technician priority queue, Supervisor dashboard, machine management, commenting, SLA display, downtime report

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

- **data: data residency single region eu west 1** → All FixIt data stored exclusively in AWS eu-west-1 (Ireland); no cross-region replication; single-site manufacturing scope does not require multi-region (`data-residency-single-region-eu-west-1`)
- **hosting: cloud aws eks** → Host FixIt on AWS using EKS (Kubernetes) as the compute platform (`cloud-aws-eks`)
- **other: project topology new solution** → FixIt is classified as a New Solution (greenfield), not a replacement or migration (`project-topology-new-solution`)
- **other: product line pl8 zone function** → Classify FixIt under PL8 — Zone / Function (non-product-line) (`product-line-pl8-zone-function`)
- **integration: messaging none sse for realtime** → No message broker introduced; real-time status updates (NFR-02) delivered via Server-Sent Events (SSE) from Spring Boot to React frontend (`messaging-none-sse-for-realtime`)
- **Which OAuth 2.0 / OIDC flow should the SPA use with Keycloak?** → Authorization Code Flow with PKCE (Proof Key for Code Exchange). No client secret stored in the browser. (`oidc-pkce-flow`)
- **Where should the JWT access token be stored in the browser?** → In-memory only (React state / context). Never in localStorage or sessionStorage. (`token-storage-memory-only`)
- **How does the SPA refresh the access token without interrupting the user?** → Use Keycloak JS adapter's silent SSO check (hidden iframe to Keycloak's check-session endpoint) to obtain a new token before expiry. If the session has expired, redirect to login. (`silent-token-refresh`)
- **How does the SPA receive real-time status updates within the 60-second NFR without a message broker?** → The SPA opens a persistent SSE connection to GET /events/stream on the fixit-api-backend. The backend pushes request.updated and request.created events over this stream. The SPA reconnects automatically on disconnect. (`sse-for-realtime-updates`)
- **What happens if the SSE connection drops and cannot be re-established?** → The SPA falls back to polling the relevant API endpoint every 30 seconds when the SSE EventSource enters a failed state after 3 reconnect attempts. A subtle 'Live updates paused' indicator is shown. (`polling-fallback-60s`)
- **How does the SPA enforce role-based UI rendering (hide Assign/Start/Resolve for wrong roles)?** → The SPA reads the role claim from the decoded JWT and conditionally renders action buttons. Server-side enforcement in fixit-api-backend is the authoritative control; client-side gating is a UX convenience only. (`client-side-rbac-ui-gating`)
- **Does the SPA calculate SLA status client-side or rely on the API?** → The SPA relies entirely on slaStatus, slaTargetMinutes, and slaElapsedMinutes fields returned by the API. It does not recalculate SLA thresholds independently. (`sla-calculation-client-side`)
- **Where is form validation performed for request submission and machine management?** → Client-side validation runs first (required fields, non-empty strings) to give immediate feedback. The SPA also handles API 400 validation errors and maps them back to field-level error messages. (`form-validation-client-side-first`)
- **How does the SPA implement the deactivation confirmation with open-request warning?** → When the Supervisor clicks Deactivate, the SPA calls GET /machines/{machineId}/history (or inspects the machine's openRequestCount from the list response) to check for open/in-progress requests. If any exist, a modal lists them and requires a second explicit confirm click. If none exist, a simple confirm dialog is shown. (`deactivation-confirmation-modal`)
- **How does the SPA prevent unauthorised personas from navigating to restricted routes?** → React Router guards check the role claim from the JWT before rendering protected routes (/queue, /dashboard, /machines). Unauthorised navigation renders an in-app 403 error page. The backend independently enforces the same rules. (`route-based-access-control`)
- **How does the SPA handle paginated list responses?** → Lists (My Requests, queue, comments, machine history) use cursor-based pagination. The SPA renders a 'Load more' button that appends the next page using the next_cursor value. Default limit is 25 items. (`cursor-pagination-infinite-scroll`)
- **How does the SPA display the 'Raised out of hours' label and SLA clock mode?** → The API returns raisedOutOfHours: boolean and slaClockMode: 'continuous' | 'shift-hours-only' on each request. The SPA renders the label when raisedOutOfHours is true and adjusts the SLA countdown tooltip to explain which clock mode is active. (`out-of-hours-label-rendering`)
- **How does the SPA implement the month selector for the downtime report?** → A month/year picker (HTML input type=month or a controlled React component) defaults to the current month. On change it calls GET /reports/downtime?year=YYYY&month=MM. The current month response includes a periodIncomplete flag which the SPA renders as a banner. (`downtime-report-month-selector`)
- **How does the SPA trigger file downloads for the export endpoints?** → The SPA calls GET /export/requests or GET /export/downtime with the Bearer token in the Authorization header using fetch(). On success it creates a Blob URL and triggers an anchor click to download the JSON file. No new browser tab is opened. (`export-file-download`)
- **What does the SPA show if Keycloak is unreachable during login?** → If the OIDC redirect or token exchange times out (10-second timeout per NFR-13), the SPA renders a 'Service temporarily unavailable — please try again shortly' page. No partial session is created. (`idp-unavailable-ux`)
- **How is WCAG 2.1 Level AA enforced in the SPA?** → All interactive components use semantic HTML elements, ARIA labels where needed, sufficient colour contrast ratios (≥4.5:1 for normal text), keyboard navigability, and focus management in modals. Automated axe-core scans run in CI. SLA status flags use both colour and text/icon to avoid colour-only communication. (`wcag-aa-compliance`)
- **How is the SPA built and deployed?** → Vite builds the React/TypeScript SPA into static assets (HTML, JS, CSS) which are uploaded to an S3 bucket. CloudFront serves the assets with cache-control headers. The index.html is served with Cache-Control: no-cache to ensure users always get the latest version. JS/CSS chunks are content-hashed for long-term caching. (`vite-build-cloudfront-deployment`)
- **How does the SPA know the fixit-api-backend base URL?** → The API base URL is injected at build time via a Vite environment variable (VITE_API_BASE_URL). For production this points to the ALB/API Gateway endpoint. A runtime config endpoint (GET /config) is also available for feature flags. (`api-base-url-configuration`)

## Contract

The endpoints, schemas, tables and events above are defined in `contracts/` in this repository. Implement them as written; a change to the contract is a change to the design.
