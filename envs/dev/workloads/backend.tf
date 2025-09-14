# Remote Backend for State Storage - Workloads
terraform {
  backend "s3" {
    bucket         = "shopsphere-tfstate-dev"
    key            = "env/dev/workloads.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopsphere-dev-tf-lock-workloads"
    encrypt        = true
    #profile        = "dev-sso"
  }
}

# Terraform Remote State Datasource - Infra
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "shopsphere-tfstate-dev"
    key    = "env/dev/infra.tfstate"
    region = "us-east-1"
    #profile = "dev-sso"
  }
}
