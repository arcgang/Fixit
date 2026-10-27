# keycloak-idp — Keycloak 24.x, PostgreSQL (Keycloak DB), AWS EKS
# LLD component cmp:keycloak-idp. Provision and configure it here; nothing in this module is applied
# until a pull request adds the provider resources and the plan is reviewed.

variable "environment" {
  type = string
}
