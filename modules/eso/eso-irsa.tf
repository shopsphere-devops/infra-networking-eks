data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# IAM policy for SecretsManager access
resource "aws_iam_policy" "eso_secretsmanager" {
  name        = "eso-secretsmanager-access"
  description = "Allow ESO to get secrets from AWS Secrets Manager"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secretsmanager_arns # List of ARNs or "*" for all
      }
    ]
  })
}

# IAM role for ServiceAccount (IRSA)
resource "aws_iam_role" "eso_irsa" {
  name = "eso-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # Format: <OIDC_PROVIDER>:sub
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.eso_namespace}:${var.eso_service_account_name}"
          }
        }
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "eso_attach" {
  role       = aws_iam_role.eso_irsa.name
  policy_arn = aws_iam_policy.eso_secretsmanager.arn
}
