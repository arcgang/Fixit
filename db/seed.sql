-- Seed data for the local stack: 3 synthetic rows per table, derived from the LLD's
-- Postgres DDL. Deterministic; contains no real personal data. Load after the schema.
BEGIN;

INSERT INTO user_profile (id, keycloak_subject, display_name, role, last_seen_at)
VALUES
  ('f8331368-cea5-5ee4-9149-906d7598d260', 'keycloak subject 1', 'Sarah Chen', 'role 1', '2026-01-01T09:00:00Z'),
  ('60ba6939-21a5-548a-a277-753864070d92', 'keycloak subject 2', 'James Okafor', 'role 2', '2026-01-02T09:00:00Z'),
  ('a52f77c9-ce8e-59f1-aa39-e07156c8a6c5', 'keycloak subject 3', 'Priya Nair', 'role 3', '2026-01-03T09:00:00Z')
ON CONFLICT DO NOTHING;

INSERT INTO audit_event (id, event_type, entity_type, entity_id, actor_user_id, actor_role, outcome, payload_json)
VALUES
  ('6e99a7cf-b294-5c0e-9d24-12cc5e0fad6b', 'event type 1', 'entity type 1', '36af5b12-8a74-56af-91e6-b0c370b4cff9', '574c6610-da35-57d3-9db7-abc94a93381d', 'actor role 1', 'outcome 1', '{}'),
  ('cd73ae31-2e9e-53e9-afc7-e4d6602ea083', 'event type 2', 'entity type 2', 'a0eeb8a3-42f0-5e92-92d9-ab190e434147', 'f94272ee-aa65-59aa-adc2-24d43c7f19eb', 'actor role 2', 'outcome 2', '{}'),
  ('b0235580-9c7f-5937-b1f6-c6dbe35049c8', 'event type 3', 'entity type 3', '39d44add-fa28-528e-b207-df7a8e144391', '389fe5d6-30b0-5e9b-a8f5-b59c67e69636', 'actor role 3', 'outcome 3', '{}')
ON CONFLICT DO NOTHING;

INSERT INTO alert_rule (id, name, expr, duration_for, severity, cloudwatch_alarm_arn)
VALUES
  ('a7728cbf-8337-5bc5-a743-9da04df671ff', 'Sarah Chen', 'expr 1', 'duration for 1', 'critical', 'cloudwatch alarm arn 1'),
  ('89180f20-1024-53ec-9277-65045472dac9', 'James Okafor', 'expr 2', 'duration for 2', 'warning', 'cloudwatch alarm arn 2'),
  ('1210f420-77d9-5c9b-a490-567f1c8b963d', 'Priya Nair', 'expr 3', 'duration for 3', 'info', 'cloudwatch alarm arn 3')
ON CONFLICT DO NOTHING;

INSERT INTO dashboard_registry (id, uid, title, url)
VALUES
  ('61ddd809-9325-5a1a-8f23-e6121b93e5d2', 'uid 1', 'title 1', 'https://example.com/dashboard_registry/1'),
  ('1f7ff6c1-f365-5c60-90fb-a1740b297cfe', 'uid 2', 'title 2', 'https://example.com/dashboard_registry/2'),
  ('c29019fd-9d5d-5de4-927d-1ea0c355402b', 'uid 3', 'title 3', 'https://example.com/dashboard_registry/3')
ON CONFLICT DO NOTHING;

INSERT INTO scrape_target (id, job, instance, last_scraped_at)
VALUES
  ('55c88e0d-d9ab-5db0-ac7b-9a0c27d3c512', 'job 1', 'instance 1', '2026-01-01T09:00:00Z'),
  ('45d56ce5-5436-53ba-9f34-d561e7303df3', 'job 2', 'instance 2', '2026-01-02T09:00:00Z'),
  ('64c20098-7567-54a8-94db-aa9b62e7de5e', 'job 3', 'instance 3', '2026-01-03T09:00:00Z')
ON CONFLICT DO NOTHING;

INSERT INTO metric_snapshot (id, metric_name, value)
VALUES
  ('688dbceb-fd62-50f9-883a-17beb4fd478c', 'metric name 1', 1250.5),
  ('090a47bb-3f53-5c32-9887-970ada058ffe', 'metric name 2', 2501.0),
  ('3b653674-150c-5e16-b3ac-434faa675ff8', 'metric name 3', 3751.5)
ON CONFLICT DO NOTHING;

INSERT INTO machine (id, name, asset_reference, location, deactivated_at, created_by_user_id)
VALUES
  ('6f7aa0ec-e357-50d9-8d8c-1b986f9231c1', 'Sarah Chen', 'MAC-001', 'location 1', '2026-01-01T09:00:00Z', 'f8331368-cea5-5ee4-9149-906d7598d260'),
  ('ed267f95-c4a5-51db-b780-31fb2ae56711', 'James Okafor', 'MAC-002', 'location 2', '2026-01-02T09:00:00Z', '60ba6939-21a5-548a-a277-753864070d92'),
  ('2a8885a9-3a2f-5b35-a20f-488b095e3b24', 'Priya Nair', 'MAC-003', 'location 3', '2026-01-03T09:00:00Z', 'a52f77c9-ce8e-59f1-aa39-e07156c8a6c5')
ON CONFLICT DO NOTHING;

INSERT INTO sla_configuration (id, priority_level, target_minutes, clock_mode, shift_start_time, shift_end_time, set_by_user_id)
VALUES
  ('43756221-4689-5048-8720-455baf2f78e4', 'CRITICAL', 10, 'CONTINUOUS', 'shift start time 1', 'shift end time 1', 'f8331368-cea5-5ee4-9149-906d7598d260'),
  ('46eff12f-319d-59e8-876b-0b666528fada', 'MEDIUM', 20, 'SHIFT_HOURS_ONLY', 'shift start time 2', 'shift end time 2', '60ba6939-21a5-548a-a277-753864070d92'),
  ('c6774e00-555f-54f0-a790-7ccc994a4943', 'LOW', 30, 'CONTINUOUS', 'shift start time 3', 'shift end time 3', 'a52f77c9-ce8e-59f1-aa39-e07156c8a6c5')
ON CONFLICT DO NOTHING;

INSERT INTO maintenance_request (id, machine_id, submitted_by_user_id, assigned_to_user_id, description, priority, resolution_note, sla_target_at, assigned_at, in_progress_at, resolved_at)
VALUES
  ('f813d48b-42df-572d-9422-a93a1e6d0d77', '6f7aa0ec-e357-50d9-8d8c-1b986f9231c1', 'f8331368-cea5-5ee4-9149-906d7598d260', 'f8331368-cea5-5ee4-9149-906d7598d260', 'description 1', 'CRITICAL', 'resolution note 1', '2026-01-01T09:00:00Z', '2026-01-01T09:00:00Z', '2026-01-01T09:00:00Z', '2026-01-01T09:00:00Z'),
  ('ca163596-a1eb-5c60-9cb9-ebb27466c5f9', 'ed267f95-c4a5-51db-b780-31fb2ae56711', '60ba6939-21a5-548a-a277-753864070d92', '60ba6939-21a5-548a-a277-753864070d92', 'description 2', 'MEDIUM', 'resolution note 2', '2026-01-02T09:00:00Z', '2026-01-02T09:00:00Z', '2026-01-02T09:00:00Z', '2026-01-02T09:00:00Z'),
  ('65461040-cef8-5cc6-b5d4-02cc655bf959', '2a8885a9-3a2f-5b35-a20f-488b095e3b24', 'a52f77c9-ce8e-59f1-aa39-e07156c8a6c5', 'a52f77c9-ce8e-59f1-aa39-e07156c8a6c5', 'description 3', 'LOW', 'resolution note 3', '2026-01-03T09:00:00Z', '2026-01-03T09:00:00Z', '2026-01-03T09:00:00Z', '2026-01-03T09:00:00Z')
ON CONFLICT DO NOTHING;

INSERT INTO status_transition (id, request_id, actor_user_id, actor_role, from_status, to_status, notes)
VALUES
  ('4aaa2706-24df-5ed4-bf17-d33be80692a4', 'f813d48b-42df-572d-9422-a93a1e6d0d77', 'f8331368-cea5-5ee4-9149-906d7598d260', 'actor role 1', 'OPEN', 'OPEN', 'notes 1'),
  ('3bb29733-c3c7-5966-9031-fdaa8d3f6caa', 'ca163596-a1eb-5c60-9cb9-ebb27466c5f9', '60ba6939-21a5-548a-a277-753864070d92', 'actor role 2', 'IN_PROGRESS', 'IN_PROGRESS', 'notes 2'),
  ('afc0f4ec-f52c-55cf-aed5-7995b0dfd587', '65461040-cef8-5cc6-b5d4-02cc655bf959', 'a52f77c9-ce8e-59f1-aa39-e07156c8a6c5', 'actor role 3', 'RESOLVED', 'RESOLVED', 'notes 3')
ON CONFLICT DO NOTHING;

INSERT INTO request_comment (id, request_id, author_user_id, author_display_name, author_role, comment_text)
VALUES
  ('7700f5ad-b97a-59a8-bce1-a626d8277721', 'f813d48b-42df-572d-9422-a93a1e6d0d77', 'f8331368-cea5-5ee4-9149-906d7598d260', 'author display name 1', 'author role 1', 'comment text 1'),
  ('b1b78cc0-25ab-52a6-8028-01a5d4404dfa', 'ca163596-a1eb-5c60-9cb9-ebb27466c5f9', '60ba6939-21a5-548a-a277-753864070d92', 'author display name 2', 'author role 2', 'comment text 2'),
  ('d97b5cc8-6af1-5b73-b392-44c5246656ff', '65461040-cef8-5cc6-b5d4-02cc655bf959', 'a52f77c9-ce8e-59f1-aa39-e07156c8a6c5', 'author display name 3', 'author role 3', 'comment text 3')
ON CONFLICT DO NOTHING;

COMMIT;
