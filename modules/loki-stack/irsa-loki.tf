
resource "aws_iam_role" "loki_irsa_role" {
  name               = "loki-irsa-role-${var.project_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": var.oidc_provider_arn
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${var.oidc_provider_url}:aud": "sts.amazonaws.com",
            "${var.oidc_provider_url}:sub": "system:serviceaccount:monitoring:loki-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "loki_irsa_policy" {
  name        = "loki-irsa-policy-${var.project_name}"
  description = "IAM policy for Loki IRSA"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": "arn:aws:s3:::loki-${var.project_name}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki_irsa_policy_attachment" {
  role       = aws_iam_role.loki_irsa_role.name
  policy_arn = aws_iam_policy.loki_irsa_policy.arn
}
