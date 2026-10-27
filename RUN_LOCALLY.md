# Run fixit locally

Prerequisites: Docker Desktop, Node 20+, Python 3.11+, JDK 21 + Maven.

```sh
git clone https://github.com/arcgang/fixit.git && cd fixit
make up        # the local platform: postgres, oidc, minio
make db-schema # the LLD's tables, in postgres
make seed      # synthetic rows to click through
make install   # every component's dependencies
make test      # every component's tests
make help      # everything else
```

## Platform (docker compose)

| Service | Stands in for | Connect with |
|---|---|---|
| postgres — Postgres 16 | keycloak-idp | `DATABASE_URL=postgresql://postgres:local@localhost:5432/app` |
| oidc — mock OAuth2/OIDC server standing in for the identity provider — any login succeeds | keycloak-idp | `OIDC_ISSUER_URL=http://localhost:8090/default`<br>`OIDC_CLIENT_ID=local`<br>`OIDC_CLIENT_SECRET=local` |
| minio — MinIO, S3-compatible | aws-cloudwatch-logs | `S3_ENDPOINT=http://localhost:9000`<br>`AWS_ACCESS_KEY_ID=local`<br>`AWS_SECRET_ACCESS_KEY=localpassword` |

The connection settings are in `.env.example` (copied to `.env` by `make up`).

## Database

`db/schema.sql` is the LLD's Postgres DDL — the contract the services implement. `make db-schema` loads it into `postgres` so the app runs before any service ships migrations; once one does, run its migrations instead and keep the two in step. `db/seed.sql` holds synthetic rows (a few per table, parents first, no real personal data) generated from that DDL: `make seed` loads them, `make db-reset` starts over. Never load it outside a laptop.

### Not run locally

No faithful local stand-in — stub or mock these in tests and point at a shared environment for integration:

- aws-api-gateway (AWS API Gateway HTTP API, JWT Authoriser, VPC Link)
- aws-alb (AWS Application Load Balancer, TLS 1.2+, ACM Certificate)

## Components

| Component | Path | Run | Notes |
|---|---|---|---|
| fixit-react-spa | `apps/fixit-react-spa` | `make dev-fixit-react-spa` | `make test-fixit-react-spa` |
| fixit-api-backend | `services/fixit-api-backend` | `make dev-fixit-api-backend` | `make test-fixit-api-backend` |
| fixit-postgresql-db | `services/fixit-postgresql-db` | — | no toolchain yet — the first task for this component lays it down |
| prometheus-grafana | `services/prometheus-grafana` | `make dev-prometheus-grafana` | `make test-prometheus-grafana` |
| aws-secrets-manager | `services/aws-secrets-manager` | — | no toolchain yet — the first task for this component lays it down |
