resource "helm_release" "ingress_nginx_main" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.2"
  namespace        = "ingress-nginx"
  create_namespace = true
  wait_for_jobs    = true
  cleanup_on_fail  = true
  #force_update     = true
  #replace          = true
  lint            = true

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.allowSnippetAnnotations"
    value = "true"
  }

  set {
    name  = "controller.enableAnnotationValidation"
    value = "false"
  }

  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "400m"
  }

  # set {
  #   name  = "controller.resources.limits.cpu"
  #   value = "400m"
  # }

  set {
    name  = "controller.resources.requests.memory"
    value = "400Mi"
  }

  # set {
  #   name  = "controller.resources.limits.memory"
  #   value = "400Mi"
  # }

  set {
    name  = "controller.autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "controller.autoscaling.minReplicas"
    value = "2"
  }

  set {
    name  = "controller.autoscaling.maxReplicas"
    value = "10"
  }

  set {
    name  = "controller.autoscaling.targetCPUUtilizationPercentage"
    value = "75"
  }

  set {
    name  = "controller.autoscaling.targetMemoryUtilizationPercentage"
    value = "75"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  # set {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
  #   value = var.
  # }
}

resource "helm_release" "ingress_nginx_main_internal" {
  count = var.internal_ingress == 0 ? 0 : 1
  name       = "ingress-nginx-internal"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace        = "ingress-nginx-internal"
  create_namespace = true
  wait_for_jobs    = true
  cleanup_on_fail  = true
  #force_update     = true
  #replace          = true
  lint            = true

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.allowSnippetAnnotations"
    value = "true"
  }

  set {
    name  = "controller.enableAnnotationValidation"
    value = "false"
  }

  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx-internal"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  # set {
  #   name  = "controller.resources.limits.cpu"
  #   value = "400m"
  # }

  set {
    name  = "controller.resources.requests.memory"
    value = "100Mi"
  }

  # set {
  #   name  = "controller.resources.limits.memory"
  #   value = "400Mi"
  # }

  set {
    name  = "controller.autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "controller.autoscaling.minReplicas"
    value = "2"
  }

  set {
    name  = "controller.autoscaling.maxReplicas"
    value = "10"
  }

  set {
    name  = "controller.autoscaling.targetCPUUtilizationPercentage"
    value = "75"
  }

  set {
    name  = "controller.autoscaling.targetMemoryUtilizationPercentage"
    value = "75"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internal"
  }

  # set {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
  #   value = var.
  # }
}