terraform {
  backend "s3" {
    bucket         = "shopsphere-tfstate-prod"
    key            = "env/prod/root.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopsphere-prod-tf-lock"
    encrypt        = true
    profile        = "prod-sso"
  }
}