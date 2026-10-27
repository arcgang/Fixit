# aws-cloudwatch-logs — AWS CloudWatch Logs, AWS S3 (archival), AWS KMS
# LLD component cmp:aws-cloudwatch-logs. Provision and configure it here; nothing in this module is applied
# until a pull request adds the provider resources and the plan is reviewed.

variable "environment" {
  type = string
}
