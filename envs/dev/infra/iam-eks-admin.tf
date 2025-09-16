# Create a dedicated EKS admin role which CI and SSO roles can assume
resource "aws_iam_role" "eks_admin" {
  name = "EKSClusterAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            # SSO permission-set role (no /username): find exact role in IAM Roles list
            "arn:aws:iam::246412345195:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_6a55a17fdf06e815",

            # Your GitHub Actions deploy role (the role GitHub assumes)
            "arn:aws:iam::246412345195:role/github-actions-deploy-role"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Attach broad admin in dev (tighten for production)
resource "aws_iam_role_policy_attachment" "eks_admin_attach_admin" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
