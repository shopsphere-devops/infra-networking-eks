# infra-networking-eks

## Overview

This repository contains the Terraform code and modules for provisioning and
managing the core AWS infrastructure for our Kubernetes platform, including
VPC, EKS cluster, ECR, and related networking components.

envs/: Environment-specific configurations (e.g., dev, staging, prod).
modules/: Reusable Terraform modules for VPC, EKS, ECR, and Helm-based ALB deployment.

## Usage

1. Configure Backend:
Ensure the remote backend (S3/DynamoDB) is already provisioned
(see terraform-backend-bootstrap repo).

2. Initialize Terraform:
cd envs/dev
terraform init

3. Plan and Apply:
terraform plan
terraform apply

4. Repeat for other environments as needed (e.g., envs/staging, envs/prod).
