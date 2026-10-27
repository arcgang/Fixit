-- ============================================================
-- FixIt API Backend — PostgreSQL DDL
-- Region: eu-west-1 (all data residency in single region)
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ------------------------------------------------------------
-- ENUM TYPES
-- ------------------------------------------------------------
CREATE TYPE priority_level AS ENUM ('CRITICAL', 'MEDIUM', 'LOW');
CREATE TYPE request_status AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED');
CREATE TYPE clock_mode AS ENUM ('CONTINUOUS', 'SHIFT_HOURS_ONLY');
CREATE TYPE sla_status AS ENUM ('OK', 'AT_RISK', 'BREACHED', 'RESOLVED_WITHIN_SLA', 'RESOLVED_BREACHED');

-- ------------------------------------------------------------
-- user_profile
-- Classification: CONFIDENTIAL (contains PII: display_name)
-- ------------------------------------------------------------
CREATE TABLE user_profile (
    id                  UUID        NOT NULL DEFAULT uuid_generate_v4(),
    keycloak_subject    TEXT        NOT NULL,
    display_name        TEXT        NOT NULL,  -- PII: pseudonymised on GDPR erasure
    role                TEXT        NOT NULL,  -- OPERATOR | TECHNICIAN | SUPERVISOR
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at        TIMESTAMPTZ,
    CONSTRAINT pk_user_profile PRIMARY KEY (id),
    CONSTRAINT uq_user_profile_keycloak_subject UNIQUE (keycloak_subject)
);

CREATE INDEX idx_user_profile_role ON user_profile (role);
CREATE INDEX idx_user_profile_is_active ON user_profile (is_active);

COMMENT ON TABLE user_profile IS 'Classification: CONFIDENTIAL. Contains PII (display_name). Data residency: eu-west-1.';

-- ------------------------------------------------------------
-- machine
-- Classification: INTERNAL
-- ------------------------------------------------------------
CREATE TABLE machine (
    id                  UUID        NOT NULL DEFAULT uuid_generate_v4(),
    name                TEXT        NOT NULL,
    asset_reference     TEXT,
    location            TEXT,
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deactivated_at      TIMESTAMPTZ,
    created_by_user_id  UUID        NOT NULL,
    CONSTRAINT pk_machine PRIMARY KEY (id),
    CONSTRAINT fk_machine_created_by FOREIGN KEY (created_by_user_id)
        REFERENCES user_profile (id)
);

CREATE INDEX idx_machine_is_active ON machine (is_active);
CREATE INDEX idx_machine_created_by_user_id ON machine (created_by_user_id);
CREATE INDEX idx_machine_name_trgm ON machine USING GIN (name gin_trgm_ops);

COMMENT ON TABLE machine IS 'Classification: INTERNAL. Data residency: eu-west-1.';

-- ------------------------------------------------------------
-- sla_configuration
-- Classification: INTERNAL
-- One row per priority level per effective period.
-- The latest row per priority_level (by effective_from) is active.
-- ------------------------------------------------------------
CREATE TABLE sla_configuration (
    id                  UUID            NOT NULL DEFAULT uuid_generate_v4(),
    priority_level      priority_level  NOT NULL,
    target_minutes      INTEGER         NOT NULL CHECK (target_minutes > 0),
    clock_mode          clock_mode      NOT NULL,
    shift_start_time    TEXT,           -- HH:MM local time; NULL when clock_mode=CONTINUOUS
    shift_end_time      TEXT,           -- HH:MM local time; NULL when clock_mode=CONTINUOUS
    effective_from      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    set_by_user_id      UUID            NOT NULL,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_sla_configuration PRIMARY KEY (id),
    CONSTRAINT fk_sla_configuration_set_by FOREIGN KEY (set_by_user_id)
        REFERENCES user_profile (id)
);

CREATE INDEX idx_sla_configuration_priority_effective ON sla_configuration (priority_level, effective_from DESC);
CREATE INDEX idx_sla_configuration_set_by_user_id ON sla_configuration (set_by_user_id);

COMMENT ON TABLE sla_configuration IS 'Classification: INTERNAL. Append-only; latest row per priority_level wins. Data residency: eu-west-1.';

-- ------------------------------------------------------------
-- maintenance_request
-- Classification: INTERNAL
-- ------------------------------------------------------------
CREATE TABLE maintenance_request (
    id                      UUID            NOT NULL DEFAULT uuid_generate_v4(),
    machine_id              UUID            NOT NULL,
    submitted_by_user_id    UUID            NOT NULL,
    assigned_to_user_id     UUID,
    description             TEXT            NOT NULL,
    priority                priority_level  NOT NULL,
    status                  request_status  NOT NULL DEFAULT 'OPEN',
    resolution_note         TEXT,           -- immutable once set
    sla_target_at           TIMESTAMPTZ,
    sla_breached            BOOLEAN         NOT NULL DEFAULT FALSE,
    sla_status              sla_status      NOT NULL DEFAULT 'OK',
    out_of_hours            BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    assigned_at             TIMESTAMPTZ,
    in_progress_at          TIMESTAMPTZ,
    resolved_at             TIMESTAMPTZ,
    CONSTRAINT pk_maintenance_request PRIMARY KEY (id),
    CONSTRAINT fk_maintenance_request_machine FOREIGN KEY (machine_id)
        REFERENCES machine (id),
    CONSTRAINT fk_maintenance_request_submitted_by FOREIGN KEY (submitted_by_user_id)
        REFERENCES user_profile (id),
    CONSTRAINT fk_maintenance_request_assigned_to FOREIGN KEY (assigned_to_user_id)
        REFERENCES user_profile (id)
);

CREATE INDEX idx_maintenance_request_machine_id ON maintenance_request (machine_id);
CREATE INDEX idx_maintenance_request_submitted_by ON maintenance_request (submitted_by_user_id);
CREATE INDEX idx_maintenance_request_assigned_to ON maintenance_request (assigned_to_user_id);
CREATE INDEX idx_maintenance_request_status ON maintenance_request (status);
CREATE INDEX idx_maintenance_request_priority_created ON maintenance_request (priority, created_at ASC);
CREATE INDEX idx_maintenance_request_status_created ON maintenance_request (status, created_at);
CREATE INDEX idx_maintenance_request_sla_target ON maintenance_request (sla_target_at) WHERE status != 'RESOLVED';
CREATE INDEX idx_maintenance_request_resolved_at ON maintenance_request (resolved_at) WHERE resolved_at IS NOT NULL;
CREATE INDEX idx_maintenance_request_created_at ON maintenance_request (created_at);

COMMENT ON TABLE maintenance_request IS 'Classification: INTERNAL. resolution_note and timestamps are immutable once set. Retained 7 years from resolved_at. Data residency: eu-west-1.';

-- ------------------------------------------------------------
-- status_transition  (append-only audit of state changes)
-- Classification: INTERNAL
-- ------------------------------------------------------------
CREATE TABLE status_transition (
    id                  UUID            NOT NULL DEFAULT uuid_generate_v4(),
    request_id          UUID            NOT NULL,
    actor_user_id       UUID            NOT NULL,
    actor_role          TEXT            NOT NULL,
    from_status         request_status  NOT NULL,
    to_status           request_status  NOT NULL,
    transitioned_at     TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    notes               TEXT,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_status_transition PRIMARY KEY (id),
    CONSTRAINT fk_status_transition_request FOREIGN KEY (request_id)
        REFERENCES maintenance_request (id),
    CONSTRAINT fk_status_transition_actor FOREIGN KEY (actor_user_id)
        REFERENCES user_profile (id)
);

CREATE INDEX idx_status_transition_request_id ON status_transition (request_id, transitioned_at ASC);
CREATE INDEX idx_status_transition_actor_user_id ON status_transition (actor_user_id);

COMMENT ON TABLE status_transition IS 'Classification: INTERNAL. Append-only; no UPDATE or DELETE permitted. Data residency: eu-west-1.';

-- ------------------------------------------------------------
-- request_comment  (append-only)
-- Classification: INTERNAL (author_display_name is PII)
-- ------------------------------------------------------------
CREATE TABLE request_comment (
    id                  UUID        NOT NULL DEFAULT uuid_generate_v4(),
    request_id          UUID        NOT NULL,
    author_user_id      UUID        NOT NULL,
    author_display_name TEXT        NOT NULL,  -- PII: pseudonymised on GDPR erasure
    author_role         TEXT        NOT NULL,
    comment_text        TEXT        NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_request_comment PRIMARY KEY (id),
    CONSTRAINT fk_request_comment_request FOREIGN KEY (request_id)
        REFERENCES maintenance_request (id),
    CONSTRAINT fk_request_comment_author FOREIGN KEY (author_user_id)
        REFERENCES user_profile (id)
);

CREATE INDEX idx_request_comment_request_id ON request_comment (request_id, created_at ASC);
CREATE INDEX idx_request_comment_author_user_id ON request_comment (author_user_id);

COMMENT ON TABLE request_comment IS 'Classification: INTERNAL. Append-only; no UPDATE or DELETE permitted. author_display_name is PII. Data residency: eu-west-1.';

-- ------------------------------------------------------------
-- audit_event  (immutable audit log)
-- Classification: INTERNAL
-- ------------------------------------------------------------
CREATE TABLE audit_event (
    id              UUID        NOT NULL DEFAULT uuid_generate_v4(),
    event_type      TEXT        NOT NULL,
    entity_type     TEXT        NOT NULL,
    entity_id       UUID        NOT NULL,
    actor_user_id   UUID        NOT NULL,
    actor_role      TEXT        NOT NULL,
    occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    outcome         TEXT        NOT NULL,
    payload_json    JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_audit_event PRIMARY KEY (id)
    -- No FK on actor_user_id intentionally: audit must survive user pseudonymisation
);

CREATE INDEX idx_audit_event_entity ON audit_event (entity_type, entity_id, occurred_at DESC);
CREATE INDEX idx_audit_event_actor ON audit_event (actor_user_id, occurred_at DESC);
CREATE INDEX idx_audit_event_occurred_at ON audit_event (occurred_at DESC);
CREATE INDEX idx_audit_event_event_type ON audit_event (event_type);

COMMENT ON TABLE audit_event IS 'Classification: INTERNAL. Immutable; no UPDATE or DELETE permitted. Operational retention 90 days in CloudWatch; 7-year archival in S3. Data residency: eu-west-1.';
