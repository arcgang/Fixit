-- prometheus-grafana owns its own lightweight configuration/state tables
-- for alert rule definitions and dashboard registry.
-- Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------------------------------------------------------
-- alert_rule
-- Stores Prometheus / CloudWatch alert rule definitions managed
-- by this component. State is refreshed by the sync job.
-- ---------------------------------------------------------------
CREATE TABLE alert_rule (
    id                    UUID          NOT NULL DEFAULT uuid_generate_v4(),
    name                  TEXT          NOT NULL,
    expr                  TEXT          NOT NULL,
    duration_for          TEXT          NOT NULL,          -- e.g. '5m'
    severity              TEXT          NOT NULL CHECK (severity IN ('critical','warning','info')),
    state                 TEXT          NOT NULL DEFAULT 'inactive'
                                        CHECK (state IN ('firing','pending','inactive')),
    annotations           JSONB         NOT NULL DEFAULT '{}',
    labels                JSONB         NOT NULL DEFAULT '{}',
    cloudwatch_alarm_arn  TEXT,
    created_at            TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT alert_rule_pkey PRIMARY KEY (id),
    CONSTRAINT alert_rule_name_unique UNIQUE (name)
);

CREATE INDEX idx_alert_rule_state   ON alert_rule (state);
CREATE INDEX idx_alert_rule_severity ON alert_rule (severity);

-- ---------------------------------------------------------------
-- dashboard_registry
-- Tracks Grafana dashboards provisioned for this platform.
-- ---------------------------------------------------------------
CREATE TABLE dashboard_registry (
    id          UUID        NOT NULL DEFAULT uuid_generate_v4(),
    uid         TEXT        NOT NULL,          -- Grafana dashboard UID
    title       TEXT        NOT NULL,
    url         TEXT        NOT NULL,
    tags        JSONB       NOT NULL DEFAULT '[]',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT dashboard_registry_pkey PRIMARY KEY (id),
    CONSTRAINT dashboard_registry_uid_unique UNIQUE (uid)
);

CREATE INDEX idx_dashboard_registry_title ON dashboard_registry (title);

-- ---------------------------------------------------------------
-- scrape_target
-- Prometheus scrape target catalogue with last-known health.
-- ---------------------------------------------------------------
CREATE TABLE scrape_target (
    id              UUID        NOT NULL DEFAULT uuid_generate_v4(),
    job             TEXT        NOT NULL,
    instance        TEXT        NOT NULL,
    health          TEXT        NOT NULL DEFAULT 'unknown'
                                CHECK (health IN ('up','down','unknown')),
    labels          JSONB       NOT NULL DEFAULT '{}',
    last_scraped_at TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT scrape_target_pkey PRIMARY KEY (id),
    CONSTRAINT scrape_target_job_instance_unique UNIQUE (job, instance)
);

CREATE INDEX idx_scrape_target_health ON scrape_target (health);
CREATE INDEX idx_scrape_target_job    ON scrape_target (job);

-- ---------------------------------------------------------------
-- metric_snapshot
-- Rolling short-term cache of key metric values pulled from
-- Prometheus for the /metrics/snapshot API. Rows older than
-- 24 hours are purged by a scheduled job.
-- ---------------------------------------------------------------
CREATE TABLE metric_snapshot (
    id          UUID        NOT NULL DEFAULT uuid_generate_v4(),
    metric_name TEXT        NOT NULL,
    labels      JSONB       NOT NULL DEFAULT '{}',
    value       NUMERIC(20,6) NOT NULL,
    sampled_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT metric_snapshot_pkey PRIMARY KEY (id)
);

CREATE INDEX idx_metric_snapshot_name_sampled ON metric_snapshot (metric_name, sampled_at DESC);
CREATE INDEX idx_metric_snapshot_sampled_at   ON metric_snapshot (sampled_at DESC);

COMMENT ON TABLE metric_snapshot IS
  'Short-term rolling cache; rows older than 24 h are purged by scheduled maintenance job.';
