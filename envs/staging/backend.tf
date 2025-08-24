terraform {
  backend "s3" {
    bucket         = "shopsphere-tfstate-staging"
    key            = "env/staging/root.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopsphere-staging-tf-lock"
    encrypt        = true
    profile        = "staging-sso"
  }
}