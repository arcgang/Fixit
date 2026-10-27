# fixit

FixIt — every component of the architecture

| Component | Path | Technology | Seed |
|---|---|---|---|
| fixit-react-spa | `apps/fixit-react-spa` | React 18, TypeScript, Vite, AWS CloudFront, AWS S3 | React |
| fixit-api-backend | `services/fixit-api-backend` | Java 21, Spring Boot 3.x, Spring Security, Spring Data JPA, Hibernate, AWS EKS | Java (Spring Boot) |
| fixit-postgresql-db | `services/fixit-postgresql-db` | PostgreSQL 16, AWS RDS Multi-AZ, AWS KMS encryption at rest | blank |
| prometheus-grafana | `services/prometheus-grafana` | Prometheus, Grafana, Spring Boot Actuator, AWS CloudWatch Alarms | Java (Spring Boot) |
| aws-secrets-manager | `services/aws-secrets-manager` | AWS Secrets Manager, AWS KMS, VPC Endpoint | blank |
| keycloak-idp | `platform/keycloak-idp` | Keycloak 24.x, PostgreSQL (Keycloak DB), AWS EKS | blank |
| aws-api-gateway | `platform/aws-api-gateway` | AWS API Gateway HTTP API, JWT Authoriser, VPC Link | blank |
| aws-alb | `platform/aws-alb` | AWS Application Load Balancer, TLS 1.2+, ACM Certificate | blank |
| aws-cloudwatch-logs | `platform/aws-cloudwatch-logs` | AWS CloudWatch Logs, AWS S3 (archival), AWS KMS | blank |

Part of the **fixit** estate (mono layout). Contracts: `contracts/` in this repository.

Stacks: React, Java (Spring Boot).
