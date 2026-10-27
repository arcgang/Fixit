/**
 * Acceptance tests for the machine, maintenance_request, and audit_event migration.
 *
 * Strategy: read the actual migration file and assert its structural content.
 * Tests for a migration artifact must read the generated file itself, not a
 * hand-written parallel copy.
 *
 * All assertions verify the migration matches the LLD contract at
 * docs/contracts/fixit-api-backend.schema.sql exactly.
 */

const fs = require('fs');
const path = require('path');

const MIGRATIONS_DIR = path.join(__dirname, '..', 'migrations');
const CONTRACT_PATH = path.join(__dirname, '..', '..', '..', 'docs', 'contracts', 'fixit-api-backend.schema.sql');

function findMigration(pattern) {
  const files = fs.readdirSync(MIGRATIONS_DIR).sort();
  return files.find(f => pattern.test(f)) || null;
}

describe('machine / maintenance_request / audit_event migration', () => {
  let migrationFile;
  let sql;
  let contractSql;

  beforeAll(() => {
    // Precondition: migrations directory must exist.
    expect(fs.existsSync(MIGRATIONS_DIR)).toBe(true);

    // Precondition: contract file must exist.
    expect(fs.existsSync(CONTRACT_PATH)).toBe(true);
    contractSql = fs.readFileSync(CONTRACT_PATH, 'utf8');

    // Precondition: a migration covering these tables must be present.
    migrationFile = findMigration(/machine_maintenance_request_audit_event/i);
    expect(migrationFile).not.toBeNull();

    sql = fs.readFileSync(path.join(MIGRATIONS_DIR, migrationFile), 'utf8');
  });

  // ----------------------------------------------------------------
  // File-level checks
  // ----------------------------------------------------------------
  describe('file naming and transaction wrapping', () => {
    test('migration filename follows Flyway versioned naming convention', () => {
      expect(migrationFile).toMatch(/^V\d+__.*\.sql$/);
    });

    test('migration is wrapped in a transaction', () => {
      expect(sql).toMatch(/BEGIN\s*;/i);
      expect(sql).toMatch(/COMMIT\s*;/i);
    });
  });

  // ----------------------------------------------------------------
  // Enums
  // PostgreSQL does not support CREATE TYPE IF NOT EXISTS; the idiomatic
  // idempotent guard is a DO $$ BEGIN ... EXCEPTION WHEN duplicate_object $$
  // block.  Tests assert that the type name and AS ENUM appear in the SQL
  // (confirming the correct type is declared) and that a duplicate_object
  // exception handler is present (confirming idempotent re-run safety).
  // ----------------------------------------------------------------
  describe('enum types', () => {
    test('creates priority_level enum (CREATE TYPE ... AS ENUM)', () => {
      expect(sql).toMatch(/CREATE TYPE\s+priority_level\s+AS\s+ENUM/i);
    });

    test('priority_level enum definition is guarded against duplicate_object', () => {
      expect(sql).toMatch(/duplicate_object/i);
    });

    test('priority_level enum includes CRITICAL, MEDIUM, LOW values', () => {
      expect(sql).toMatch(/'CRITICAL'/);
      expect(sql).toMatch(/'MEDIUM'/);
      expect(sql).toMatch(/'LOW'/);
    });

    test('creates request_status enum (CREATE TYPE ... AS ENUM)', () => {
      expect(sql).toMatch(/CREATE TYPE\s+request_status\s+AS\s+ENUM/i);
    });

    test('request_status enum includes OPEN, IN_PROGRESS, RESOLVED values', () => {
      expect(sql).toMatch(/'OPEN'/);
      expect(sql).toMatch(/'IN_PROGRESS'/);
      expect(sql).toMatch(/'RESOLVED'/);
    });

    test('creates sla_status enum (CREATE TYPE ... AS ENUM)', () => {
      expect(sql).toMatch(/CREATE TYPE\s+sla_status\s+AS\s+ENUM/i);
    });

    test('sla_status enum includes OK, AT_RISK, BREACHED, RESOLVED_WITHIN_SLA, RESOLVED_BREACHED values', () => {
      expect(sql).toMatch(/'OK'/);
      expect(sql).toMatch(/'AT_RISK'/);
      expect(sql).toMatch(/'BREACHED'/);
      expect(sql).toMatch(/'RESOLVED_WITHIN_SLA'/);
      expect(sql).toMatch(/'RESOLVED_BREACHED'/);
    });
  });

  // ----------------------------------------------------------------
  // machine table
  // ----------------------------------------------------------------
  describe('machine table definition', () => {
    test('creates machine table with IF NOT EXISTS guard', () => {
      expect(sql).toMatch(/CREATE TABLE IF NOT EXISTS\s+machine\b/i);
    });

    test('id column: UUID NOT NULL with uuid_generate_v4() default', () => {
      // Match within the machine table block
      expect(sql).toMatch(/\bid\s+UUID\s+NOT NULL\s+DEFAULT\s+uuid_generate_v4\(\)/i);
    });

    test('name column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bname\s+TEXT\s+NOT NULL\b/i);
    });

    test('asset_reference column: TEXT (nullable)', () => {
      expect(sql).toMatch(/\basset_reference\s+TEXT\b/i);
    });

    test('location column: TEXT (nullable)', () => {
      expect(sql).toMatch(/\blocation\s+TEXT\b/i);
    });

    test('is_active column: BOOLEAN NOT NULL DEFAULT TRUE', () => {
      expect(sql).toMatch(/\bis_active\s+BOOLEAN\s+NOT NULL\s+DEFAULT\s+TRUE\b/i);
    });

    test('created_at column: TIMESTAMPTZ NOT NULL DEFAULT NOW()', () => {
      expect(sql).toMatch(/\bcreated_at\s+TIMESTAMPTZ\s+NOT NULL\s+DEFAULT\s+NOW\(\)/i);
    });

    test('updated_at column: TIMESTAMPTZ NOT NULL DEFAULT NOW()', () => {
      expect(sql).toMatch(/\bupdated_at\s+TIMESTAMPTZ\s+NOT NULL\s+DEFAULT\s+NOW\(\)/i);
    });

    test('deactivated_at column: TIMESTAMPTZ (nullable)', () => {
      expect(sql).toMatch(/\bdeactivated_at\s+TIMESTAMPTZ\b/i);
    });

    test('created_by_user_id column: UUID NOT NULL', () => {
      expect(sql).toMatch(/\bcreated_by_user_id\s+UUID\s+NOT NULL\b/i);
    });
  });

  describe('machine primary key constraint', () => {
    test('primary key constraint named pk_machine on id', () => {
      expect(sql).toMatch(/CONSTRAINT\s+pk_machine\s+PRIMARY KEY\s*\(\s*id\s*\)/i);
    });
  });

  describe('machine foreign key constraints', () => {
    test('FK to user_profile named fk_machine_created_by', () => {
      expect(sql).toMatch(
        /CONSTRAINT\s+fk_machine_created_by\s+FOREIGN KEY\s*\(\s*created_by_user_id\s*\)\s*REFERENCES\s+user_profile\s*\(\s*id\s*\)/i
      );
    });
  });

  describe('machine indexes', () => {
    test('index idx_machine_is_active on (is_active)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_machine_is_active\s+ON\s+machine\s*\(\s*is_active\s*\)/i
      );
    });

    test('index idx_machine_created_by_user_id on (created_by_user_id)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_machine_created_by_user_id\s+ON\s+machine\s*\(\s*created_by_user_id\s*\)/i
      );
    });

    test('GIN trigram index idx_machine_name_trgm on (name gin_trgm_ops)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_machine_name_trgm\s+ON\s+machine\s+USING\s+GIN\s*\(\s*name\s+gin_trgm_ops\s*\)/i
      );
    });
  });

  describe('machine classification comment', () => {
    test('COMMENT ON TABLE machine includes classification marker', () => {
      expect(sql).toMatch(/COMMENT ON TABLE\s+machine\s+IS\s+'Classification: INTERNAL\./i);
    });

    test('COMMENT ON TABLE machine includes data residency', () => {
      // The comment for machine must mention eu-west-1
      const machineComment = sql.match(/COMMENT ON TABLE\s+machine\s+IS\s+'[^']+'/i);
      expect(machineComment).not.toBeNull();
      expect(machineComment[0]).toMatch(/eu-west-1/);
    });
  });

  // ----------------------------------------------------------------
  // maintenance_request table
  // ----------------------------------------------------------------
  describe('maintenance_request table definition', () => {
    test('creates maintenance_request table with IF NOT EXISTS guard', () => {
      expect(sql).toMatch(/CREATE TABLE IF NOT EXISTS\s+maintenance_request\b/i);
    });

    test('machine_id column: UUID NOT NULL', () => {
      expect(sql).toMatch(/\bmachine_id\s+UUID\s+NOT NULL\b/i);
    });

    test('submitted_by_user_id column: UUID NOT NULL', () => {
      expect(sql).toMatch(/\bsubmitted_by_user_id\s+UUID\s+NOT NULL\b/i);
    });

    test('assigned_to_user_id column: UUID (nullable)', () => {
      expect(sql).toMatch(/\bassigned_to_user_id\s+UUID\b/i);
    });

    test('description column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bdescription\s+TEXT\s+NOT NULL\b/i);
    });

    test('priority column: priority_level NOT NULL', () => {
      expect(sql).toMatch(/\bpriority\s+priority_level\s+NOT NULL\b/i);
    });

    test('status column: request_status NOT NULL DEFAULT OPEN', () => {
      expect(sql).toMatch(/\bstatus\s+request_status\s+NOT NULL\s+DEFAULT\s+'OPEN'/i);
    });

    test('resolution_note column: TEXT (nullable)', () => {
      expect(sql).toMatch(/\bresolution_note\s+TEXT\b/i);
    });

    test('sla_target_at column: TIMESTAMPTZ (nullable)', () => {
      expect(sql).toMatch(/\bsla_target_at\s+TIMESTAMPTZ\b/i);
    });

    test('sla_breached column: BOOLEAN NOT NULL DEFAULT FALSE', () => {
      expect(sql).toMatch(/\bsla_breached\s+BOOLEAN\s+NOT NULL\s+DEFAULT\s+FALSE\b/i);
    });

    test('sla_status column: sla_status NOT NULL DEFAULT OK', () => {
      expect(sql).toMatch(/\bsla_status\s+sla_status\s+NOT NULL\s+DEFAULT\s+'OK'/i);
    });

    test('out_of_hours column: BOOLEAN NOT NULL DEFAULT FALSE', () => {
      expect(sql).toMatch(/\bout_of_hours\s+BOOLEAN\s+NOT NULL\s+DEFAULT\s+FALSE\b/i);
    });

    test('assigned_at column: TIMESTAMPTZ (nullable)', () => {
      expect(sql).toMatch(/\bassigned_at\s+TIMESTAMPTZ\b/i);
    });

    test('in_progress_at column: TIMESTAMPTZ (nullable)', () => {
      expect(sql).toMatch(/\bin_progress_at\s+TIMESTAMPTZ\b/i);
    });

    test('resolved_at column: TIMESTAMPTZ (nullable)', () => {
      expect(sql).toMatch(/\bresolved_at\s+TIMESTAMPTZ\b/i);
    });
  });

  describe('maintenance_request primary key constraint', () => {
    test('primary key constraint named pk_maintenance_request on id', () => {
      expect(sql).toMatch(/CONSTRAINT\s+pk_maintenance_request\s+PRIMARY KEY\s*\(\s*id\s*\)/i);
    });
  });

  describe('maintenance_request foreign key constraints', () => {
    test('FK to machine named fk_maintenance_request_machine', () => {
      expect(sql).toMatch(
        /CONSTRAINT\s+fk_maintenance_request_machine\s+FOREIGN KEY\s*\(\s*machine_id\s*\)\s*REFERENCES\s+machine\s*\(\s*id\s*\)/i
      );
    });

    test('FK to user_profile for submitted_by named fk_maintenance_request_submitted_by', () => {
      expect(sql).toMatch(
        /CONSTRAINT\s+fk_maintenance_request_submitted_by\s+FOREIGN KEY\s*\(\s*submitted_by_user_id\s*\)\s*REFERENCES\s+user_profile\s*\(\s*id\s*\)/i
      );
    });

    test('FK to user_profile for assigned_to named fk_maintenance_request_assigned_to', () => {
      expect(sql).toMatch(
        /CONSTRAINT\s+fk_maintenance_request_assigned_to\s+FOREIGN KEY\s*\(\s*assigned_to_user_id\s*\)\s*REFERENCES\s+user_profile\s*\(\s*id\s*\)/i
      );
    });
  });

  describe('maintenance_request indexes', () => {
    test('index idx_maintenance_request_machine_id on (machine_id)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_machine_id\s+ON\s+maintenance_request\s*\(\s*machine_id\s*\)/i
      );
    });

    test('index idx_maintenance_request_submitted_by on (submitted_by_user_id)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_submitted_by\s+ON\s+maintenance_request\s*\(\s*submitted_by_user_id\s*\)/i
      );
    });

    test('index idx_maintenance_request_assigned_to on (assigned_to_user_id)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_assigned_to\s+ON\s+maintenance_request\s*\(\s*assigned_to_user_id\s*\)/i
      );
    });

    test('index idx_maintenance_request_status on (status)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_status\s+ON\s+maintenance_request\s*\(\s*status\s*\)/i
      );
    });

    test('index idx_maintenance_request_priority_created on (priority, created_at ASC)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_priority_created\s+ON\s+maintenance_request\s*\(\s*priority\s*,\s*created_at\s+ASC\s*\)/i
      );
    });

    test('index idx_maintenance_request_status_created on (status, created_at)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_status_created\s+ON\s+maintenance_request\s*\(\s*status\s*,\s*created_at\s*\)/i
      );
    });

    test('partial index idx_maintenance_request_sla_target on (sla_target_at) WHERE status != RESOLVED', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_sla_target\s+ON\s+maintenance_request\s*\(\s*sla_target_at\s*\)\s+WHERE\s+status\s*!=\s*'RESOLVED'/i
      );
    });

    test('partial index idx_maintenance_request_resolved_at on (resolved_at) WHERE resolved_at IS NOT NULL', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_resolved_at\s+ON\s+maintenance_request\s*\(\s*resolved_at\s*\)\s+WHERE\s+resolved_at\s+IS\s+NOT\s+NULL/i
      );
    });

    test('index idx_maintenance_request_created_at on (created_at)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_maintenance_request_created_at\s+ON\s+maintenance_request\s*\(\s*created_at\s*\)/i
      );
    });
  });

  describe('maintenance_request classification comment', () => {
    test('COMMENT ON TABLE maintenance_request includes classification marker', () => {
      expect(sql).toMatch(/COMMENT ON TABLE\s+maintenance_request\s+IS\s+'Classification: INTERNAL\./i);
    });

    test('COMMENT ON TABLE maintenance_request mentions resolution_note immutability', () => {
      const mrComment = sql.match(/COMMENT ON TABLE\s+maintenance_request\s+IS\s+'[^']+'/i);
      expect(mrComment).not.toBeNull();
      expect(mrComment[0]).toMatch(/resolution_note/i);
    });

    test('COMMENT ON TABLE maintenance_request includes data residency', () => {
      const mrComment = sql.match(/COMMENT ON TABLE\s+maintenance_request\s+IS\s+'[^']+'/i);
      expect(mrComment).not.toBeNull();
      expect(mrComment[0]).toMatch(/eu-west-1/);
    });
  });

  // ----------------------------------------------------------------
  // audit_event table
  // ----------------------------------------------------------------
  describe('audit_event table definition', () => {
    test('creates audit_event table with IF NOT EXISTS guard', () => {
      expect(sql).toMatch(/CREATE TABLE IF NOT EXISTS\s+audit_event\b/i);
    });

    test('event_type column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bevent_type\s+TEXT\s+NOT NULL\b/i);
    });

    test('entity_type column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bentity_type\s+TEXT\s+NOT NULL\b/i);
    });

    test('entity_id column: UUID NOT NULL', () => {
      expect(sql).toMatch(/\bentity_id\s+UUID\s+NOT NULL\b/i);
    });

    test('actor_user_id column: UUID NOT NULL', () => {
      expect(sql).toMatch(/\bactor_user_id\s+UUID\s+NOT NULL\b/i);
    });

    test('actor_role column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bactor_role\s+TEXT\s+NOT NULL\b/i);
    });

    test('occurred_at column: TIMESTAMPTZ NOT NULL DEFAULT NOW()', () => {
      expect(sql).toMatch(/\boccurred_at\s+TIMESTAMPTZ\s+NOT NULL\s+DEFAULT\s+NOW\(\)/i);
    });

    test('outcome column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\boutcome\s+TEXT\s+NOT NULL\b/i);
    });

    test('payload_json column: JSONB (nullable)', () => {
      expect(sql).toMatch(/\bpayload_json\s+JSONB\b/i);
    });
  });

  describe('audit_event primary key constraint', () => {
    test('primary key constraint named pk_audit_event on id', () => {
      expect(sql).toMatch(/CONSTRAINT\s+pk_audit_event\s+PRIMARY KEY\s*\(\s*id\s*\)/i);
    });
  });

  describe('audit_event indexes', () => {
    test('composite index idx_audit_event_entity on (entity_type, entity_id, occurred_at DESC)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_audit_event_entity\s+ON\s+audit_event\s*\(\s*entity_type\s*,\s*entity_id\s*,\s*occurred_at\s+DESC\s*\)/i
      );
    });

    test('composite index idx_audit_event_actor on (actor_user_id, occurred_at DESC)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_audit_event_actor\s+ON\s+audit_event\s*\(\s*actor_user_id\s*,\s*occurred_at\s+DESC\s*\)/i
      );
    });

    test('index idx_audit_event_occurred_at on (occurred_at DESC)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_audit_event_occurred_at\s+ON\s+audit_event\s*\(\s*occurred_at\s+DESC\s*\)/i
      );
    });

    test('index idx_audit_event_event_type on (event_type)', () => {
      expect(sql).toMatch(
        /CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_audit_event_event_type\s+ON\s+audit_event\s*\(\s*event_type\s*\)/i
      );
    });
  });

  describe('audit_event classification comment', () => {
    test('COMMENT ON TABLE audit_event includes classification marker', () => {
      expect(sql).toMatch(/COMMENT ON TABLE\s+audit_event\s+IS\s+'Classification: INTERNAL\./i);
    });

    test('COMMENT ON TABLE audit_event mentions immutability (no UPDATE or DELETE)', () => {
      const aeComment = sql.match(/COMMENT ON TABLE\s+audit_event\s+IS\s+'[^']+'/i);
      expect(aeComment).not.toBeNull();
      expect(aeComment[0]).toMatch(/Immutable/i);
    });

    test('COMMENT ON TABLE audit_event includes data residency', () => {
      const aeComment = sql.match(/COMMENT ON TABLE\s+audit_event\s+IS\s+'[^']+'/i);
      expect(aeComment).not.toBeNull();
      expect(aeComment[0]).toMatch(/eu-west-1/);
    });
  });

  // ----------------------------------------------------------------
  // Idempotency
  // ----------------------------------------------------------------
  describe('idempotency', () => {
    test('all CREATE INDEX statements use IF NOT EXISTS', () => {
      const indexLines = sql
        .split('\n')
        .filter(line => /CREATE INDEX/i.test(line));
      expect(indexLines.length).toBeGreaterThan(0);
      for (const line of indexLines) {
        expect(line).toMatch(/IF NOT EXISTS/i);
      }
    });

    test('all CREATE TABLE statements use IF NOT EXISTS', () => {
      const tableLines = sql
        .split('\n')
        .filter(line => /CREATE TABLE/i.test(line));
      expect(tableLines.length).toBeGreaterThan(0);
      for (const line of tableLines) {
        expect(line).toMatch(/IF NOT EXISTS/i);
      }
    });
  });

  // ----------------------------------------------------------------
  // Permissions
  // ----------------------------------------------------------------
  describe('permissions', () => {
    test('GRANTs SELECT on machine to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT SELECT ON\s+machine\s+TO\s+"fixit-db-user"/i);
    });

    test('GRANTs INSERT on machine to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT INSERT ON\s+machine\s+TO\s+"fixit-db-user"/i);
    });

    test('GRANTs SELECT on maintenance_request to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT SELECT ON\s+maintenance_request\s+TO\s+"fixit-db-user"/i);
    });

    test('GRANTs INSERT on maintenance_request to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT INSERT ON\s+maintenance_request\s+TO\s+"fixit-db-user"/i);
    });

    test('GRANTs UPDATE on maintenance_request to fixit-db-user (status transitions)', () => {
      expect(sql).toMatch(/GRANT UPDATE ON\s+maintenance_request\s+TO\s+"fixit-db-user"/i);
    });

    test('GRANTs SELECT on audit_event to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT SELECT ON\s+audit_event\s+TO\s+"fixit-db-user"/i);
    });

    test('GRANTs INSERT on audit_event to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT INSERT ON\s+audit_event\s+TO\s+"fixit-db-user"/i);
    });

    test('does NOT grant DELETE on audit_event (immutable)', () => {
      const grantLines = sql
        .split('\n')
        .filter(line => /GRANT\s+/i.test(line) && /audit_event/i.test(line));
      for (const line of grantLines) {
        expect(line.toUpperCase()).not.toMatch(/\bDELETE\b/);
      }
    });

    test('does NOT grant UPDATE on audit_event (immutable)', () => {
      const grantLines = sql
        .split('\n')
        .filter(line => /GRANT\s+/i.test(line) && /audit_event/i.test(line));
      for (const line of grantLines) {
        expect(line.toUpperCase()).not.toMatch(/\bUPDATE\b/);
      }
    });
  });
});
