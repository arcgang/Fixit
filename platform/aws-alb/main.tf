# aws-alb — AWS Application Load Balancer, TLS 1.2+, ACM Certificate
# LLD component cmp:aws-alb. Provision and configure it here; nothing in this module is applied
# until a pull request adds the provider resources and the plan is reviewed.

variable "environment" {
  type = string
}
