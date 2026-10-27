# aws-api-gateway

**Technology:** AWS API Gateway HTTP API, JWT Authoriser, VPC Link

**LLD component:** `cmp:aws-api-gateway`

Managed API gateway providing JWT authorisation (Keycloak JWKS), rate limiting, and routing of all REST API traffic from ALB to the Spring Boot backend via VPC Link. Replaces deprecated Kong (dec-002).
