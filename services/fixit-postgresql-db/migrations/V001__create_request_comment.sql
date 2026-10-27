-- Migration: create request_comment table
-- Classification: INTERNAL (author_display_name is PII)
-- Implements: ent:requestcomment (US-007, BR-06, BR-12)
-- Append-only: no UPDATE or DELETE granted per NFR-07 and SC-20

BEGIN;

CREATE TABLE IF NOT EXISTS request_comment (
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

CREATE INDEX IF NOT EXISTS idx_request_comment_request_id ON request_comment (request_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_request_comment_author_user_id ON request_comment (author_user_id);

COMMENT ON TABLE request_comment IS 'Classification: INTERNAL. Append-only; no UPDATE or DELETE permitted. author_display_name is PII. Data residency: eu-west-1.';

GRANT SELECT ON request_comment TO "fixit-db-user";
GRANT INSERT ON request_comment TO "fixit-db-user";

COMMIT;
