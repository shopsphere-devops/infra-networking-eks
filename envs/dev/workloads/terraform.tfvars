#######################################################
#    Environment Details
#######################################################

env          = "dev"
region       = "us-east-1"
project      = "shopsphere"
cluster_name = "shopsphere-dev-eks"

tags = {
  Environment = "dev"
  Project     = "shopsphere"
  Terraform   = "true"
}
