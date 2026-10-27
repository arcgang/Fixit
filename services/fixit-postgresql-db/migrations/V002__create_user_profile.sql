-- Migration: create user_profile table
-- Classification: CONFIDENTIAL (contains PII: display_name)
-- Implements: ent:userprofile (US-014, BR-12, BR-15)
-- display_name is pseudonymised on GDPR erasure per data minimisation decision

BEGIN;

CREATE TABLE IF NOT EXISTS user_profile (
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

CREATE INDEX IF NOT EXISTS idx_user_profile_role ON user_profile (role);
CREATE INDEX IF NOT EXISTS idx_user_profile_is_active ON user_profile (is_active);

COMMENT ON TABLE user_profile IS 'Classification: CONFIDENTIAL. Contains PII (display_name). Data residency: eu-west-1.';

COMMIT;
