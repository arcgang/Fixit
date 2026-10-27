/**
 * Acceptance tests for the request_comment migration.
 *
 * Strategy: read the actual migration file and assert its structural content.
 * This follows the project convention that tests for a migration artifact must
 * read the generated file itself, not a hand-written parallel copy.
 *
 * All assertions verify the migration matches the LLD contract at
 * docs/contracts/fixit-api-backend.schema.sql exactly.
 */

const fs = require('fs');
const path = require('path');

const MIGRATIONS_DIR = path.join(__dirname, '..', 'migrations');

function findMigration(pattern) {
  const files = fs.readdirSync(MIGRATIONS_DIR).sort();
  return files.find(f => pattern.test(f)) || null;
}

describe('request_comment migration', () => {
  let migrationFile;
  let sql;

  beforeAll(() => {
    // Precondition: the migrations directory must exist and contain a migration
    // for request_comment. A missing file is a structural failure, not a test
    // skip — assert loudly so a missing migration does not silently pass.
    expect(fs.existsSync(MIGRATIONS_DIR)).toBe(true);

    migrationFile = findMigration(/request_comment/i);
    expect(migrationFile).not.toBeNull();

    sql = fs.readFileSync(path.join(MIGRATIONS_DIR, migrationFile), 'utf8');
  });

  describe('file naming and transaction wrapping', () => {
    test('migration filename follows Flyway versioned naming convention', () => {
      expect(migrationFile).toMatch(/^V\d+__.*\.sql$/);
    });

    test('migration is wrapped in a transaction', () => {
      expect(sql).toMatch(/BEGIN\s*;/i);
      expect(sql).toMatch(/COMMIT\s*;/i);
    });
  });

  describe('table definition', () => {
    test('creates request_comment table with IF NOT EXISTS guard', () => {
      expect(sql).toMatch(/CREATE TABLE IF NOT EXISTS\s+request_comment\b/i);
    });

    test('id column: UUID NOT NULL with uuid_generate_v4() default', () => {
      expect(sql).toMatch(/\bid\s+UUID\s+NOT NULL\s+DEFAULT\s+uuid_generate_v4\(\)/i);
    });

    test('request_id column: UUID NOT NULL', () => {
      expect(sql).toMatch(/\brequest_id\s+UUID\s+NOT NULL\b/i);
    });

    test('author_user_id column: UUID NOT NULL', () => {
      expect(sql).toMatch(/\bauthor_user_id\s+UUID\s+NOT NULL\b/i);
    });

    test('author_display_name column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bauthor_display_name\s+TEXT\s+NOT NULL\b/i);
    });

    test('author_role column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bauthor_role\s+TEXT\s+NOT NULL\b/i);
    });

    test('comment_text column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bcomment_text\s+TEXT\s+NOT NULL\b/i);
    });

    test('created_at column: TIMESTAMPTZ NOT NULL with DEFAULT NOW()', () => {
      expect(sql).toMatch(/\bcreated_at\s+TIMESTAMPTZ\s+NOT NULL\s+DEFAULT\s+NOW\(\)/i);
    });

    test('updated_at column: TIMESTAMPTZ NOT NULL with DEFAULT NOW()', () => {
      expect(sql).toMatch(/\bupdated_at\s+TIMESTAMPTZ\s+NOT NULL\s+DEFAULT\s+NOW\(\)/i);
    });
  });

  describe('primary key constraint', () => {
    test('primary key constraint named pk_request_comment on id', () => {
      expect(sql).toMatch(/CONSTRAINT\s+pk_request_comment\s+PRIMARY KEY\s*\(\s*id\s*\)/i);
    });
  });

  describe('foreign key constraints', () => {
    test('FK to maintenance_request named fk_request_comment_request', () => {
      expect(sql).toMatch(/CONSTRAINT\s+fk_request_comment_request\s+FOREIGN KEY\s*\(\s*request_id\s*\)\s*REFERENCES\s+maintenance_request\s*\(\s*id\s*\)/i);
    });

    test('FK to user_profile named fk_request_comment_author', () => {
      expect(sql).toMatch(/CONSTRAINT\s+fk_request_comment_author\s+FOREIGN KEY\s*\(\s*author_user_id\s*\)\s*REFERENCES\s+user_profile\s*\(\s*id\s*\)/i);
    });
  });

  describe('indexes', () => {
    test('composite index idx_request_comment_request_id on (request_id, created_at ASC)', () => {
      expect(sql).toMatch(/CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_request_comment_request_id\s+ON\s+request_comment\s*\(\s*request_id\s*,\s*created_at\s+ASC\s*\)/i);
    });

    test('index idx_request_comment_author_user_id on (author_user_id)', () => {
      expect(sql).toMatch(/CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_request_comment_author_user_id\s+ON\s+request_comment\s*\(\s*author_user_id\s*\)/i);
    });
  });

  describe('classification comment', () => {
    test('COMMENT ON TABLE includes classification marker', () => {
      expect(sql).toMatch(/COMMENT ON TABLE\s+request_comment\s+IS\s+'Classification: INTERNAL\./i);
    });

    test('COMMENT ON TABLE includes append-only notice', () => {
      expect(sql).toMatch(/Append-only; no UPDATE or DELETE permitted\./i);
    });

    test('COMMENT ON TABLE includes PII notice for author_display_name', () => {
      expect(sql).toMatch(/author_display_name is PII\./i);
    });

    test('COMMENT ON TABLE includes data residency', () => {
      expect(sql).toMatch(/Data residency: eu-west-1\./i);
    });
  });

  describe('permissions (append-only enforcement)', () => {
    test('GRANTs SELECT on request_comment to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT SELECT ON\s+request_comment\s+TO\s+"fixit-db-user"/i);
    });

    test('GRANTs INSERT on request_comment to fixit-db-user', () => {
      expect(sql).toMatch(/GRANT INSERT ON\s+request_comment\s+TO\s+"fixit-db-user"/i);
    });

    test('does NOT grant UPDATE on request_comment', () => {
      // The GRANT lines in this migration must not include UPDATE
      const grantLines = sql
        .split('\n')
        .filter(line => /GRANT\s+(?!.*REVOKE)/i.test(line) && /request_comment/i.test(line));
      for (const line of grantLines) {
        expect(line.toUpperCase()).not.toMatch(/\bUPDATE\b/);
      }
    });

    test('does NOT grant DELETE on request_comment', () => {
      const grantLines = sql
        .split('\n')
        .filter(line => /GRANT\s+(?!.*REVOKE)/i.test(line) && /request_comment/i.test(line));
      for (const line of grantLines) {
        expect(line.toUpperCase()).not.toMatch(/\bDELETE\b/);
      }
    });
  });

  describe('idempotency', () => {
    test('indexes use IF NOT EXISTS to allow safe re-runs', () => {
      const indexLines = sql
        .split('\n')
        .filter(line => /CREATE INDEX/i.test(line) && /request_comment/i.test(line));
      expect(indexLines.length).toBeGreaterThan(0);
      for (const line of indexLines) {
        expect(line).toMatch(/IF NOT EXISTS/i);
      }
    });
  });
});
