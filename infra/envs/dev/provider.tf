provider "aws" {
  region = var.aws_region

  # The assignment is plan-only. These dummy values prevent Terraform from
  # requiring real AWS credentials for `terraform plan -refresh=false`.
  # For a real deployment, set plan_only=false and use normal AWS credentials.
  access_key                  = var.plan_only ? "plan-only-access-key" : null
  secret_key                  = var.plan_only ? "plan-only-secret-key" : null
  skip_credentials_validation = var.plan_only
  skip_metadata_api_check     = var.plan_only
  skip_requesting_account_id  = var.plan_only
}

provider "random" {}
