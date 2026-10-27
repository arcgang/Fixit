module "keycloak_idp" {
  source      = "./keycloak-idp"
  environment = var.environment
}

module "aws_api_gateway" {
  source      = "./aws-api-gateway"
  environment = var.environment
}

module "aws_alb" {
  source      = "./aws-alb"
  environment = var.environment
}

module "aws_cloudwatch_logs" {
  source      = "./aws-cloudwatch-logs"
  environment = var.environment
}
