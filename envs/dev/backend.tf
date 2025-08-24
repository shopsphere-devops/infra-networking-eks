terraform {
  backend "s3" {
    bucket         = "shopsphere-tfstate-dev"
    key            = "env/dev/root.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopsphere-dev-tf-lock"
    encrypt        = true
    profile        = "dev-sso"
  }
}