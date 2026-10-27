/**
 * Acceptance tests for the user_profile migration.
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

describe('user_profile migration', () => {
  let migrationFile;
  let sql;

  beforeAll(() => {
    // Precondition: the migrations directory must exist and contain a migration
    // for user_profile. A missing file is a structural failure, not a test
    // skip — assert loudly so a missing migration does not silently pass.
    expect(fs.existsSync(MIGRATIONS_DIR)).toBe(true);

    migrationFile = findMigration(/user_profile/i);
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
    test('creates user_profile table with IF NOT EXISTS guard', () => {
      expect(sql).toMatch(/CREATE TABLE IF NOT EXISTS\s+user_profile\b/i);
    });

    test('id column: UUID NOT NULL with uuid_generate_v4() default', () => {
      expect(sql).toMatch(/\bid\s+UUID\s+NOT NULL\s+DEFAULT\s+uuid_generate_v4\(\)/i);
    });

    test('keycloak_subject column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bkeycloak_subject\s+TEXT\s+NOT NULL\b/i);
    });

    test('display_name column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\bdisplay_name\s+TEXT\s+NOT NULL\b/i);
    });

    test('role column: TEXT NOT NULL', () => {
      expect(sql).toMatch(/\brole\s+TEXT\s+NOT NULL\b/i);
    });

    test('is_active column: BOOLEAN NOT NULL with DEFAULT TRUE', () => {
      expect(sql).toMatch(/\bis_active\s+BOOLEAN\s+NOT NULL\s+DEFAULT\s+TRUE\b/i);
    });

    test('created_at column: TIMESTAMPTZ NOT NULL with DEFAULT NOW()', () => {
      expect(sql).toMatch(/\bcreated_at\s+TIMESTAMPTZ\s+NOT NULL\s+DEFAULT\s+NOW\(\)/i);
    });

    test('updated_at column: TIMESTAMPTZ NOT NULL with DEFAULT NOW()', () => {
      expect(sql).toMatch(/\bupdated_at\s+TIMESTAMPTZ\s+NOT NULL\s+DEFAULT\s+NOW\(\)/i);
    });

    test('last_seen_at column: TIMESTAMPTZ (nullable)', () => {
      expect(sql).toMatch(/\blast_seen_at\s+TIMESTAMPTZ\b/i);
      // last_seen_at must NOT have a NOT NULL constraint
      const colLine = sql.split('\n').find(l => /\blast_seen_at\b/i.test(l));
      expect(colLine).toBeDefined();
      expect(colLine.toUpperCase()).not.toMatch(/NOT NULL/);
    });
  });

  describe('primary key constraint', () => {
    test('primary key constraint named pk_user_profile on id', () => {
      expect(sql).toMatch(/CONSTRAINT\s+pk_user_profile\s+PRIMARY KEY\s*\(\s*id\s*\)/i);
    });
  });

  describe('unique constraint', () => {
    test('unique constraint named uq_user_profile_keycloak_subject on keycloak_subject', () => {
      expect(sql).toMatch(/CONSTRAINT\s+uq_user_profile_keycloak_subject\s+UNIQUE\s*\(\s*keycloak_subject\s*\)/i);
    });
  });

  describe('indexes', () => {
    test('index idx_user_profile_role on (role)', () => {
      expect(sql).toMatch(/CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_user_profile_role\s+ON\s+user_profile\s*\(\s*role\s*\)/i);
    });

    test('index idx_user_profile_is_active on (is_active)', () => {
      expect(sql).toMatch(/CREATE INDEX\s+(?:IF NOT EXISTS\s+)?idx_user_profile_is_active\s+ON\s+user_profile\s*\(\s*is_active\s*\)/i);
    });

    test('indexes use IF NOT EXISTS to allow safe re-runs', () => {
      const indexLines = sql
        .split('\n')
        .filter(line => /CREATE INDEX/i.test(line) && /user_profile/i.test(line));
      expect(indexLines.length).toBeGreaterThan(0);
      for (const line of indexLines) {
        expect(line).toMatch(/IF NOT EXISTS/i);
      }
    });
  });

  describe('classification comment', () => {
    test('COMMENT ON TABLE includes CONFIDENTIAL classification', () => {
      expect(sql).toMatch(/COMMENT ON TABLE\s+user_profile\s+IS\s+'Classification: CONFIDENTIAL\./i);
    });

    test('COMMENT ON TABLE includes PII notice for display_name', () => {
      expect(sql).toMatch(/Contains PII \(display_name\)\./i);
    });

    test('COMMENT ON TABLE includes data residency', () => {
      expect(sql).toMatch(/Data residency: eu-west-1\./i);
    });
  });
});
