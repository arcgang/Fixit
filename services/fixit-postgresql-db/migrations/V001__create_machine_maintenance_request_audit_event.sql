-- Migration: create machine, maintenance_request, and audit_event tables
-- Classification: INTERNAL
-- Implements: ent:machine, ent:maintenancerequest, ent:audit-event
-- Depends on: user_profile table (created in the same migration batch)
-- US-001 (BR-01, BR-08, BR-09, BR-15)

BEGIN;

-- Enable uuid-ossp if not already active (idempotent)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pg_trgm for GIN trigram index on machine.name (idempotent)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ------------------------------------------------------------
-- Enum types (idempotent via DO block)
-- ------------------------------------------------------------

DO $$ BEGIN
    CREATE TYPE priority_level AS ENUM ('CRITICAL', 'MEDIUM', 'LOW');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE request_status AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE sla_status AS ENUM (
        'OK',
        'AT_RISK',
        'BREACHED',
        'RESOLVED_WITHIN_SLA',
        'RESOLVED_BREACHED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ------------------------------------------------------------
-- machine
-- Classification: INTERNAL
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS machine (
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

CREATE INDEX IF NOT EXISTS idx_machine_is_active ON machine (is_active);
CREATE INDEX IF NOT EXISTS idx_machine_created_by_user_id ON machine (created_by_user_id);
CREATE INDEX IF NOT EXISTS idx_machine_name_trgm ON machine USING GIN (name gin_trgm_ops);

COMMENT ON TABLE machine IS 'Classification: INTERNAL. Data residency: eu-west-1.';

GRANT SELECT ON machine TO "fixit-db-user";
GRANT INSERT ON machine TO "fixit-db-user";
GRANT UPDATE ON machine TO "fixit-db-user";

-- ------------------------------------------------------------
-- maintenance_request
-- Classification: INTERNAL
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance_request (
    id                      UUID            NOT NULL DEFAULT uuid_generate_v4(),
    machine_id              UUID            NOT NULL,
    submitted_by_user_id    UUID            NOT NULL,
    assigned_to_user_id     UUID,
    description             TEXT            NOT NULL,
    priority                priority_level  NOT NULL,
    status                  request_status  NOT NULL DEFAULT 'OPEN',
    resolution_note         TEXT,
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

CREATE INDEX IF NOT EXISTS idx_maintenance_request_machine_id ON maintenance_request (machine_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_submitted_by ON maintenance_request (submitted_by_user_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_assigned_to ON maintenance_request (assigned_to_user_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_status ON maintenance_request (status);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_priority_created ON maintenance_request (priority, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_status_created ON maintenance_request (status, created_at);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_sla_target ON maintenance_request (sla_target_at) WHERE status != 'RESOLVED';
CREATE INDEX IF NOT EXISTS idx_maintenance_request_resolved_at ON maintenance_request (resolved_at) WHERE resolved_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_maintenance_request_created_at ON maintenance_request (created_at);

COMMENT ON TABLE maintenance_request IS 'Classification: INTERNAL. resolution_note and timestamps are immutable once set. Retained 7 years from resolved_at. Data residency: eu-west-1.';

GRANT SELECT ON maintenance_request TO "fixit-db-user";
GRANT INSERT ON maintenance_request TO "fixit-db-user";
GRANT UPDATE ON maintenance_request TO "fixit-db-user";

-- ------------------------------------------------------------
-- audit_event  (immutable audit log)
-- Classification: INTERNAL
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS audit_event (
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
    CONSTRAINT pk_audit_event PRIMARY KEY (id)
    -- No FK on actor_user_id intentionally: audit must survive user pseudonymisation
);

CREATE INDEX IF NOT EXISTS idx_audit_event_entity ON audit_event (entity_type, entity_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_event_actor ON audit_event (actor_user_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_event_occurred_at ON audit_event (occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_event_event_type ON audit_event (event_type);

COMMENT ON TABLE audit_event IS 'Classification: INTERNAL. Immutable; no UPDATE or DELETE permitted. Operational retention 90 days in CloudWatch; 7-year archival in S3. Data residency: eu-west-1.';

GRANT SELECT ON audit_event TO "fixit-db-user";
GRANT INSERT ON audit_event TO "fixit-db-user";

COMMIT;
