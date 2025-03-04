# IRSA for api
# assume namespace=project_name

resource "aws_iam_role" "irsa_role" {
  name = "api-irsa-${var.project_name}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${var.oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            # "Condition": {
            #     "StringLike": {
            #         "${var.oidc_provider_url}:sub": "system:serviceaccount:*:iam-sa",
            #         "${var.oidc_provider_url}:aud": "sts.amazonaws.com"
            #     }
            # }
            "Condition": {
                "StringEquals": {
                    "${var.oidc_provider_url}:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "${var.oidc_provider_url}:sub": "system:serviceaccount:*:iam-sa"
                }
            }    
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_api_1" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_policy_api_2" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_policy_api_3" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}
