
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "eks"
  chart      = "aws-load-balancer-controller"
  version    = "1.8.2"

  namespace        = "kube-system"
  
  set {
    name  = "clusterName"
    value = "${var.cluster_name}" 
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "alb-controller-sa-${var.project_name}"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_role.arn
  }

  set {
    name  = "region"
    value = "${var.region}"
  }  

  set {
    name  = "vpcId"
    value = "${var.vpc_id}"
  } 
}

