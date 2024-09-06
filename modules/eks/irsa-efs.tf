
resource "aws_iam_role" "efs_csi_driver_role" {
  name = "EFS_CSI_Driver_Role-${var.project_name}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${module.eks.oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa",
                    "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy" {
  role       = aws_iam_role.efs_csi_driver_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}