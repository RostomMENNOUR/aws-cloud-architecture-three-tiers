# 1. Création du rôle IAM (Uniquement en prod)
resource "aws_iam_role" "app_role" {
  count = var.env == "prod" ? 1 : 0
  name  = "app-ec2-role-prod"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 2. Politique d'accès ultra-stricte : S3 et Secrets Manager (Uniquement en prod)
resource "aws_iam_policy" "app_policy" {
  count = var.env == "prod" ? 1 : 0
  name  = "app-ec2-policy-prod"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        # Accès restreint uniquement au bucket créé dans s3.tf
        Resource = [
          data.aws_s3_bucket.app_artifacts.arn,
          "${data.aws_s3_bucket.app_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        # Accès restreint uniquement au secret créé dans rds.tf
        Resource = [
          aws_secretsmanager_secret.db_secret-v2.arn
        ]
      }
    ]
  })
}

# 3. Attachement de la politique au rôle (Uniquement en prod)
resource "aws_iam_role_policy_attachment" "app_policy_attach" {
  count      = var.env == "prod" ? 1 : 0
  role       = aws_iam_role.app_role[0].name
  policy_arn = aws_iam_policy.app_policy[0].arn
}

# 4. Création de l'Instance Profile pour l'EC2 (Uniquement en prod)
resource "aws_iam_instance_profile" "app_instance_profile" {
  count = var.env == "prod" ? 1 : 0
  name  = "app-ec2-instance-profile-prod"
  role  = aws_iam_role.app_role[0].name
}

# 5. La variable locale intelligente qui fait le pont pour ton Launch Template
locals {
  # Si prod -> utilise le profil qu'on vient de créer. Si dev -> utilise celui d'AWS Academy.
  instance_profile_name = var.env == "prod" ? aws_iam_instance_profile.app_instance_profile[0].name : "LabInstanceProfile"
}