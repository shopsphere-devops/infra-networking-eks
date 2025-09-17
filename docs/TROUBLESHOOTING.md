# Terraform + AWS SSO Troubleshooting Guide

This guide documents common issues encountered while working with **Terraform**
**AWS SSO**, **GitHub Actions**, and **STS AssumeRole**,
along with their resolutions. Use this as a reference the next time
similar problems occur.

## AWS STS AssumeRole Access Denied

aws sts assume-role \
  --role-arn arn:aws:iam::246412345195:role/EKSClusterAdminRole \
  --role-session-name local-eks-admin

An error occurred (AccessDenied) when calling the AssumeRole operation:
User: arn:aws:iam::435159110051:user/Abinash is not authorized to
perform: sts:AssumeRole

Root Cause:

You were logged in as an IAM User instead of an AWS SSO role.
That IAM user didn’t have permission for sts:AssumeRole.

Fix:

1. Check current identity:
aws sts get-caller-identity --profile dev-sso

Example output:
"Arn": "arn:aws:sts::246412345195:assumed-role/
AWSReservedSSO_AdministratorAccess_xxx/abinash.sethi"

Confirms you are using SSO role.

1. Correct ~/.aws/config:
[profile dev-sso]
sso_session = dev-sso
sso_account_id = 246412345195
sso_role_name = AdministratorAccess
region = us-east-1
output = json

[sso-session dev-sso]
[sso_start_url](https://d-9066207294.awsapps.com/start)
sso_region = us-east-1
sso_registration_scopes = sso:account:access

1. Login with SSO profile:
aws sso login --profile dev-sso
aws sts get-caller-identity --profile dev-sso
