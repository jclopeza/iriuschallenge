# Create an IAM Role for AWS App Runner
resource "aws_iam_role" "apprunner_service_role" {
  name = "${var.app_name}-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "build.apprunner.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "tasks.apprunner.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }

    ]
  })
}

# Create a Policy that Allows Access to Secrets in Secrets Manager or SSM Parameter Store
resource "aws_iam_policy" "apprunner_secrets_policy" {
  name        = "AppRunnerSecretsAccessPolicy"
  description = "Allows App Runner to access the necessary secrets"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory",
          "ssm:DescribeParameters",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource": "*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "apprunner_role_policy_attach" {
  role       = aws_iam_role.apprunner_service_role.name
  policy_arn = aws_iam_policy.apprunner_secrets_policy.arn
}

# Attach access policies to the IAM role
resource "aws_iam_role_policy_attachment" "apprunner_access" {
  role       = aws_iam_role.apprunner_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# Create a private repository in Amazon ECR
resource "aws_ecr_repository" "ecr" {
  name                 = "${var.app_name}-repository"
  image_scanning_configuration {
    scan_on_push = false  # Habilita el escaneo de imágenes al subir
  }
}

# Environment variables
resource "aws_ssm_parameter" "region_name" {
  name  = "/dev/irius/region_name"
  type  = "String"
  value = "${var.region_name}"
  description = "Region name"
}

resource "aws_ssm_parameter" "aws_access_key_id" {
  name  = "/dev/irius/aws_access_key_id"
  type  = "SecureString"
  value = "${var.aws_access_key_id}"
  description = "aws_access_key_id"
}

resource "aws_ssm_parameter" "aws_secret_access_key" {
  name  = "/dev/irius/aws_secret_access_key"
  type  = "SecureString"
  value = "${var.aws_secret_access_key}"
  description = "aws_secret_access_key"
}

# Create the bucket in S3 with public access.
resource "aws_s3_bucket" "public_bucket" {
  bucket = "${var.app_name}-public-bucket"
}

resource "aws_s3_bucket_public_access_block" "public_bucket_access_block" {
  bucket                  = aws_s3_bucket.public_bucket.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# Define the public policy to allow public access to the bucket
resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })
}